import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:convert';
import 'package:gsheets/gsheets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SendData extends StatefulWidget {
  final Map<String, String> data;

  SendData({Key? key, required this.data}) : super(key: key);

  @override
  _SendDataState createState() => _SendDataState();
}

class _SendDataState extends State<SendData> {
  String? dataString;
  bool showQR = false;
  bool isCancelled = false;

  late GSheets _gsheets;
  late String _spreadsheetId;
  late String _worksheetName;

  Future<void> loadEnv() async {
    await dotenv.load(fileName: ".env");
    _gsheets = GSheets(dotenv.env['GOOGLE_SHEETS_DATA']!);
    _spreadsheetId = dotenv.env['SPREADSHEET_ID']!;
    _worksheetName = dotenv.env['WORKSHEET_NAME']!;
  }

  Future<void> sendDataToGoogleSheets() async {
    await loadEnv(); // Wait for loadEnv to complete before proceeding
    String message = '';
    try {
      final ss = await _gsheets.spreadsheet(_spreadsheetId);
      final sheet = ss.worksheetByTitle(_worksheetName);
      if (sheet != null) {
        final values = widget.data.values.toList();
        final result = await sheet.values.appendRow(values);
        if (result) {
          message = 'Shep collected the data, thanks scout! o7';
        }
      }
    } catch (e) {
      message = 'Shep Error!: $e';
      print(e);
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
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
              title: Text('Send Data'),
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
