import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../utils/router_util.dart';

class QRScannerRouter extends StatefulWidget {
  const QRScannerRouter({super.key});

  @override
  State<StatefulWidget> createState() {
    return _QRScannerRouter();
  }
}

class _QRScannerRouter extends State<QRScannerRouter> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  final MobileScannerController scannerController = MobileScannerController();

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      scannerController.stop();
    } else if (Platform.isIOS) {
      scannerController.start();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MobileScanner(
        controller: scannerController,
        onDetect: (result) async {
          scannerController.stop();
          if (result.barcodes.isNotEmpty) {
            String? qr = result.barcodes.first.rawValue;
            RouterUtil.back(context, qr);
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    scannerController.dispose();
    super.dispose();
  }
}
