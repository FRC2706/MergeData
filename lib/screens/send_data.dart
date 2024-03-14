import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:gsheets/gsheets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SendData extends StatefulWidget {
  final Map<String, String> data;
  final bool isGame;
  final bool justSend;
  final String api;

  SendData(
      {Key? key,
      required this.data,
      required this.isGame,
      this.justSend = false,
      required this.api})
      : super(key: key);

  @override
  _SendDataState createState() => _SendDataState();
}

class _SendDataState extends State<SendData> {
  String? dataString;
  bool showQR = false;
  bool isCancelled = false;
  List<Map> savedGamesArray = [];

  late GSheets _gsheets;
  late String _spreadsheetId;
  late String _gameWorksheetName;
  late String _pitWorksheetName;
  late String _passcode;

  @override
  void initState() {
    super.initState();
    getLocalGames().then((_) {
      setState(
          () {}); //refresh, very unpracitical but this is a hotfix after all :P ...
    });
  }

  Future<void> getLocalGames() async {
    final prefs = await SharedPreferences.getInstance();
    var savedGamesString = prefs.getStringList('savedGames') ?? [];
    for (var game in savedGamesString) {
      savedGamesArray.add(jsonDecode(game));
    }
  }

  Future<Map> fetchApi(String key) async {
    var a = await http.get(Uri.parse('${widget.api}?key=$key'));
    if (a.statusCode == 200) {
      return jsonDecode(a.body);
    } else {
      return {"Error": "Invalid API key"};
    }
  }

  Future<void> loadApi() async {
    final prefs = await SharedPreferences.getInstance();
    String apiKey = prefs.getString('apiKey') ?? '';
    Map apiResponse = await fetchApi(apiKey);

    if (apiResponse.containsKey("Error")) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid or no API key entered')),
      );
    } else {
      _gsheets = GSheets(apiResponse["GOOGLE_SHEETS_DATA"]);
      _spreadsheetId = apiResponse["SPREADSHEET_ID"];
      _gameWorksheetName = apiResponse["GAME_WORKSHEET_NAME"];
      _pitWorksheetName = apiResponse["PIT_WORKSHEET_NAME"];
    }
  }

  Future<void> saveDataLocally() async {
    final prefs = await SharedPreferences.getInstance();
    final savedGames = prefs.getStringList('savedGames') ?? [];
    Map sillyData = {}; // silly way to avoid widget.data referenceing
    widget.data.forEach((k, v) => sillyData[k] = v);
    sillyData["isGame"] = widget.isGame ? "y" : "n";
    savedGames.add(jsonEncode(sillyData));
    await prefs.setStringList('savedGames', savedGames);
  }

  Future<void> sendDataToGoogleSheets() async {
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
          message =
              "Shep couldn\'t find any saved games to send! That means IT'S TIME TO GO SCOUTING SOME MORE!!1!11!";
        } else {
          if (widget.isGame) {
            // Send locally stored games
            for (final savedGame in savedGames) {
              Map gameData = jsonDecode(savedGame);
              var curSheet = ss.worksheetByTitle(_pitWorksheetName);
              try {
                if (gameData["isGame"] == "y") {
                  curSheet = ss.worksheetByTitle(_gameWorksheetName);
                }
              } catch (e) {
                message = "Invalid Save Data";
              }
              try {
                gameData.remove("isGame");
              } catch (e) {}
              List<dynamic> values = gameData.values.toList();
              final curRes = await curSheet!.values.appendRow(values);
              if (curRes) {
                message = "Successfully sent saved data!";
              }
            }
            // Clear the saved games after sending them
            final a = await prefs.setStringList('savedGames', []);
          }

          if (widget.data.values.isNotEmpty) {
            // Send current game
            final values = widget.data.values.toList();
            print(values);
            final result = await sheet.values.appendRow(values);
            if (result) {
              message = 'Shep collected the data, thanks scout! o7';
            }
          }
        }
      }
    } catch (e) {
      message = 'Could not send data to sheets!';
      print(e);
    }

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: loadApi(),
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
                              'All unsaved data will be sent to the shadow realm. If the page behind is blank anyway, no worries.',
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
                if (widget.justSend)
                  for (var entry in savedGamesArray) ...[
                    if (entry["isGame"] == "y") ...[
                      Padding(
                          padding: const EdgeInsets.only(top: 15, left: 15),
                          child: Text(
                            "Saved Data ${savedGamesArray.indexOf(entry) + 1} (Match)",
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          )),
                    ] else ...[
                      Padding(
                          padding: const EdgeInsets.only(top: 15, left: 15),
                          child: Text(
                            "Saved Data ${savedGamesArray.indexOf(entry) + 1} (Pit)",
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          )),
                    ],
                    for (var gameValue in entry.entries) ...[
                      if (gameValue.key != "isGame") ...[
                        ListTile(
                          title: Text(gameValue.key),
                          subtitle: Text(gameValue.value),
                        ),
                      ]
                    ]
                  ],
                if (showQR)
                  Center(
                    child: QrImageView(
                      data: dataString!,
                      version: QrVersions.auto,
                      size: 200.0,
                    ),
                  ),
                const Padding(
                  padding: EdgeInsets.all(15),
                )
              ],
            ),
            floatingActionButton: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (!showQR && !widget.justSend)
                  FloatingActionButton(
                    heroTag: "qr",
                    child: Icon(Icons.qr_code),
                    onPressed: () {
                      setState(() {
                        Map tempData = {};
                        for (MapEntry entry in widget.data.entries) {
                          tempData[entry.key] = entry.value;
                        }
                        tempData['isGame'] = widget.isGame ? "y" : "n";
                        dataString = jsonEncode(tempData);
                        showQR = true;
                      });
                    },
                  ),
                SizedBox(width: 10), // Add some spacing between the buttons
                if (!widget.justSend)
                  FloatingActionButton(
                    heroTag: "archive",
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
                  heroTag: "send",
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
                                  //send to google sheets, but authenticate first
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
