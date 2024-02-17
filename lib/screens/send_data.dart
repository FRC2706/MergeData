import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:convert';

class SendData extends StatelessWidget {
  final Map<String, String> data;

  SendData({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String dataString = jsonEncode(data);

    return Scaffold(
      appBar: AppBar(
        title: Text('Send Data'),
      ),
      body: ListView(
        children: [
          ...data.entries.map((entry) {
            return ListTile(
              title: Text(entry.key),
              subtitle: Text(entry.value),
            );
          }).toList(),
          Center(
            child: QrImageView(
              data: dataString,
              version: QrVersions.auto,
              size: 200.0,
            ),
          ),
        ],
      ),
    );
  }
}