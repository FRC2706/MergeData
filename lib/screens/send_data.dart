import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:convert';
import 'package:gsheets/gsheets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SendData extends StatefulWidget {
  final Map<String, String> data;
  final bool isGame;
  final bool justSend;

  SendData({Key? key, required this.data, required this.isGame, this.justSend = false})
      : super(key: key);

  @override
  _SendDataState createState() => _SendDataState();
}

class _SendDataState extends State<SendData> {
  String? dataString;
  bool showQR = false;
  bool isCancelled = false;

  late GSheets _gsheets;
  late String _spreadsheetId;
  late String _gameWorksheetName;
  late String _pitWorksheetName;

  Future<void> loadEnv() async {
    await dotenv.load(fileName: ".env");
    _gsheets = GSheets(dotenv.env['GOOGLE_SHEETS_DATA']!);
    _spreadsheetId = dotenv.env['SPREADSHEET_ID']!;
    _gameWorksheetName = dotenv.env['GAME_WORKSHEET_NAME']!;
    _pitWorksheetName = dotenv.env['PIT_WORKSHEET_NAME']!;
  }

  Future<void> saveDataLocally() async {
    final prefs = await SharedPreferences.getInstance();
    final savedGames = prefs.getStringList('savedGames') ?? [];
    savedGames.add(jsonEncode(widget.data));
    await prefs.setStringList('savedGames', savedGames);
  }

  Future<void> sendDataToGoogleSheets() async {
    await loadEnv();
    String message = '';

    try {
      final ss = await _gsheets.spreadsheet(_spreadsheetId);
      var sheet;
      if (widget.isGame) {
        sheet = ss.worksheetByTitle(_gameWorksheetName);
      } else {
        sheet = ss.worksheetByTitle(_pitWorksheetName);
      }

      if (sheet != null) {
        // Check for locally stored games
        final prefs = await SharedPreferences.getInstance();
        final savedGames = prefs.getStringList('savedGames') ?? [];

        if (savedGames.isEmpty && widget.data.isEmpty) {
          message = "Shep couldn\'t find any saved games to send! That means IT'S TIME TO GO SCOUTING SOME MORE!!1!11!";
        } else {

          if (widget.isGame) {
            // Send locally stored games
            for (final savedGame in savedGames) {
              final gameData = jsonDecode(savedGame);
              List<dynamic> values = gameData.values.toList();
              await sheet.values.appendRow(values);
            }            
            // Clear the saved games after sending them
            final a = await prefs.setStringList('savedGames', []);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Cleared games: $a')),
            );
          }

          // Send current game
          final values = widget.data.values.toList();
          final result = await sheet.values.appendRow(values);
          if (result) {
            message = 'Shep collected the data, thanks scout! o7';
          }
        }
      }
    } catch (e) {
      message = 'Shep Error!: $e';
      print(e);
    }

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: loadEnv(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
              title: const Text("Send Data",
                  style: TextStyle(color: Colors.black)),
              actions: <Widget>[
                IconButton(
                  icon: const Icon(Icons.home),
                  tooltip: 'Return to Home',
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title:
                              Text('Are you sure you want to return to home?'),
                          content: Text(
                              'All unsaved data will be sent to the shadow realm.',
                              style:
                                  TextStyle(fontSize: 12, color: Colors.red)),
                          actions: [
                            TextButton(
                              child: Text('Yes'),
                              onPressed: () {
                                Navigator.of(context)
                                    .popUntil((route) => route.isFirst);
                              },
                            ),
                            TextButton(
                              child: Text('No'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ],
            ),
            body: ListView(
              children: [
                ...widget.data.entries.map((entry) {
                  return ListTile(
                    title: Text(entry.key),
                    subtitle: Text(entry.value),
                  );
                }).toList(),
                if (showQR)
                  Center(
                    child: QrImageView(
                      data: dataString!,
                      version: QrVersions.auto,
                      size: 200.0,
                    ),
                  ),
                const Padding(
                  padding: EdgeInsets.all(5),
                )
              ],
            ),
            floatingActionButton: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (!showQR)
                  FloatingActionButton(
                    child: Icon(Icons.qr_code),
                    onPressed: () {
                      setState(() {
                        dataString = jsonEncode(widget.data);
                        showQR = true;
                      });
                    },
                  ),
                SizedBox(width: 10), // Add some spacing between the buttons
                if (widget.isGame && !widget.justSend)
                  FloatingActionButton(
                    child: Icon(Icons.archive),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Save data locally?'),
                            content: Text(
                              "The data will NOT be uploaded yet, but will be saved locally.\n"
                              "You can send it later. JUST DON'T FORGET TO SEND IT!"),
                            actions: [
                              TextButton(
                                child: Text('Yes'),
                                onPressed: () {
                                  saveDataLocally();
                                  Navigator.of(context)
                                      .popUntil((route) => route.isFirst);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              'Data saved locally, thanks scout! o7')));
                                },
                              ),
                              TextButton(
                                child: Text('No'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                
                SizedBox(width: 10),
                FloatingActionButton(
                  child: Icon(Icons.send),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Confirmation'),
                          content: Text(
                              'Make sure you have an internet connection to do this!'),
                          actions: [
                            TextButton(
                              child: Text('SEND IT BABY!'),
                              onPressed: () {
                                Navigator.of(context).pop();
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          CircularProgressIndicator(),
                                          Text(
                                              "Shep is collecting the data..."),
                                          Image.asset(
                                              'assets/images/shep-loading.gif'),
                                          TextButton(
                                            child: Text('Cancel'),
                                            onPressed: () {
                                              isCancelled = true;
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                                sendDataToGoogleSheets().then((_) {
                                  if (!isCancelled) {
                                    Navigator.of(context).pop();
                                  }
                                });
                              },
                            ),
                            TextButton(
                              child: Text('Cancel'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          );
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else {
          return Scaffold(
            body: Center(child: Text('Error loading environment variables')),
          );
        }
      },
    );
  }
}
