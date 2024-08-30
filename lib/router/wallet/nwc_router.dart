import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:yana/main.dart';
import 'package:yana/provider/nwc_provider.dart';

import '../../ui/button.dart';
import '../../utils/router_path.dart';
import '../../utils/router_util.dart';
import '../../utils/string_util.dart';

class NwcRouter extends StatefulWidget {
  const NwcRouter({super.key});

  @override
  State<StatefulWidget> createState() {
    return _NwcRouter();
  }
}

class _NwcRouter extends State<NwcRouter> {
  // TextEditingController controller = TextEditingController();
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? qrController;
  bool disposed = false;

  // final MobileScannerController controller = MobileScannerController(
  //   // required options for the scanner
  // );
  //
  // StreamSubscription<Object?>? _subscription;

  String? nwcSecret;

  void _onQRViewCreated(QRViewController controller) {
    qrController = controller;
    controller.scannedDataStream.listen((scanData) async {
      if (nwcSecret == null) {
        if (scanData.code != null &&
            scanData.code!.startsWith(NwcProvider.NWC_PROTOCOL_PREFIX)) {
          nwcProvider.connect(scanData.code!);
        }
        setState(() {
          nwcSecret = scanData.code;
        });
      }
    });
  }

  @override
  Future<void> dispose() async {
    // unawaited(_subscription?.cancel());
    // _subscription = null;
    // Dispose the widget itself.
    super.dispose();
    disposed = true;
    if (qrController != null) {
      qrController!.dispose();
    }
    // Finally, dispose of the controller.
    // await controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var _nwcProvider = Provider.of<NwcProvider>(context);

    var themeData = Theme.of(context);
    var cardColor = themeData.cardColor;

    var appBarNew = AppBar(
      toolbarHeight: 70,
      // shape: RoundedRectangleBorder(
      //   borderRadius: BorderRadius.circular(30),
      // ),
      backgroundColor: themeData.appBarTheme.backgroundColor,
      leading: GestureDetector(
        onTap: () {
          RouterUtil.back(context);
        },
        child: Container(
          margin: const EdgeInsets.only(left: 10),
          child: Icon(
            Icons.arrow_back_ios,
            color: themeData.hintColor,
          ),
        ),
      ),
      // actions: [
      //   GestureDetector(
      //     onTap: addToCommunity,
      //     child: Container(
      //       margin: const EdgeInsets.only(
      //         left: Base.BASE_PADDING,
      //         right: Base.BASE_PADDING,
      //       ),
      //       child: Icon(
      //         Icons.add,
      //         color: themeData.appBarTheme.titleTextStyle!.color,
      //       ),
      //     ),
      //   )
      // ],
      title: const Text("Scan or Paste Pairing Secret",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: "Geist.Mono",
            fontSize: 20,
          )),
      actions: [barOptions()],
    );
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 150.0
        : 350.0;

    return Scaffold(
      appBar: appBarNew,
      body: Stack(children: [
        QRView(
          key: qrKey,
          overlay: QrScannerOverlayShape(
              cutOutBottomOffset: 50,
              borderColor: themeData.primaryColor,
              borderRadius: 10,
              borderLength: 30,
              borderWidth: 10,
              cutOutSize: scanArea),
          onQRViewCreated: _onQRViewCreated,
        ),
        Positioned(
            bottom: 0,
            child: Container(
              // padding: const EdgeInsets.all(4),
              decoration: ShapeDecoration(
                color: themeData.appBarTheme.backgroundColor,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: mediaDataCache.size.width,
                    // width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
                    // clipBehavior: Clip.antiAlias,
                    // decoration: ShapeDecoration(
                    //   color: themeData.appBarTheme.backgroundColor,
                    //   shape: RoundedRectangleBorder(
                    //       borderRadius: BorderRadius.circular(8)),
                    // ),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Button(
                          width: 328,
                          height: 56,
                          text: isConnecting()
                              ? "Connecting..."
                              : " Paste Secret",
                          before: isConnecting()
                              ? Container()
                              : const Icon(Icons.paste),
                          after: nwcSecret != null
                              ? const Row(children: [
                                  SizedBox(width: 50),
                                  // Lottie.asset("assets/animations/spinner.json")
                                  CircularProgressIndicator(
                                    color: Colors.white
                                      //     //   strokeWidth: 2.0,
                                      )
                                ])
                              : Container(),
                          onTap: () {
                            if (!isConnecting()) {
                              Clipboard.getData(Clipboard.kTextPlain)
                                  .then((clipboardData) {
                                if (clipboardData != null &&
                                    StringUtil.isNotBlank(clipboardData.text) &&
                                    clipboardData.text!.startsWith(
                                        NwcProvider.NWC_PROTOCOL_PREFIX)) {
                                  setState(() {
                                    nwcSecret = clipboardData.text;
                                  });
                                  nwcProvider.connect(clipboardData.text!,
                                      onConnect: () {
                                    RouterUtil.back(context);
                                  });
                                }
                              });
                            }
                          },
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ))
      ]),
    );
  }

  bool isConnecting() {
    return nwcSecret != null && !nwcProvider.isConnected;
  }

  Widget barOptions() {
    return PopupMenuButton<String>(
        icon: const Icon(Icons.image),
        tooltip: "settings",
        itemBuilder: (context) {
          List<PopupMenuEntry<String>> list = [
            //const PopupMenuItem(value: "settings", child: Text("Settings")),
          ];
          if (nwcProvider.isConnected) {
            list.add(
              const PopupMenuItem(
                value: "disconnect",
                child: Text("Disconnect wallet"),
              ),
            );
          }
          return list;
        },
        onSelected: (value) async {
          if (value == "disconnect") {
            setState(() async {
              await nwcProvider.disconnect();
            });
          }
        });
  }
}
