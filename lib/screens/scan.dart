import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
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
          if (result != null)
            Text(
                'Barcode Type: ${describeEnum(result!.format)}   Data: ${result!.code}')
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
      });
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
