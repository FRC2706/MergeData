import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:convert';

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

  @override
  Widget build(BuildContext context) {
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
                    content: Text('Make sure you have an internet connection to do this!'),
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
                                    Text("Shep is collecting the data..."),
                                    Image.asset('assets/images/shep-loading.gif'),
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
                          Future.delayed(Duration(seconds: 3), () {
                            if (!isCancelled) {
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Shep collected the data, thanks scout! o7'))
                              );
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
  }
}