import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:merge_data/screens/send_data.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class ScanResultsPage extends StatefulWidget {
  final String title;
  final int year;

  ScanResultsPage({Key? key, required this.title, required this.year})
      : super(key: key);

  @override
  _ScanResultsPageState createState() => _ScanResultsPageState();
}

class _ScanResultsPageState extends State<ScanResultsPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;

  void sendData(values, isGame) {
    // redirect to `send_data.dart` and pass the data
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => SendData(
                data: values,
                isGame: isGame,
              )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title, style: const TextStyle(color: Colors.black)),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: (kIsWeb ||
                    Theme.of(context).platform == TargetPlatform.linux ||
                    Theme.of(context).platform == TargetPlatform.macOS ||
                    Theme.of(context).platform == TargetPlatform.windows)
                ? Center(
                    child: Text(
                        'The camera function is only available on Android and iOS.'))
                : QRView(
                    key: qrKey,
                    onQRViewCreated: _onQRViewCreated,
                  ),
          ),
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      result = scanData;
      if (result != null) {
        String? resultData = result!.code;
        Map? resultDataMap = jsonDecode(resultData!);
        bool? isGame = resultDataMap!['isGame'] == "y" ? true : false;
        resultDataMap.remove("isGame");
        sendData(resultDataMap, isGame);
      }
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
