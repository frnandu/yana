import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yana/main.dart';
import 'package:yana/provider/nwc_provider.dart';
import 'package:yana/config/app_features.dart';

import '../../ui/button.dart';
import '../../utils/string_util.dart';

class NwcRouter extends StatefulWidget {
  const NwcRouter({super.key});

  @override
  State<StatefulWidget> createState() {
    return _NwcRouter();
  }
}

class _NwcRouter extends State<NwcRouter> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  final MobileScannerController scannerController = MobileScannerController();
  bool disposed = false;

  String? nwcSecret;

  @override
  Future<void> dispose() async {
    // Dispose the widget itself.
    super.dispose();
    disposed = true;
    scannerController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var _nwcProvider = Provider.of<NwcProvider>(context);

    var themeData = Theme.of(context);
    var cardColor = themeData.cardColor;

    var appBarNew = AppBar(
      toolbarHeight: 70,
      backgroundColor: themeData.appBarTheme.backgroundColor,
      leading: GestureDetector(
        onTap: () {
          context.pop();
        },
        child: Container(
          margin: const EdgeInsets.only(left: 10),
          child: Icon(
            Icons.arrow_back_ios,
            color: themeData.hintColor,
          ),
        ),
      ),
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
        MobileScanner(
          controller: scannerController,
          onDetect: (result) async {
            scannerController.stop();
            if (nwcSecret == null) {
              if (result.barcodes.isNotEmpty) {
                String? nwc;
                for (var code in result.barcodes) {
                  if (code.rawValue != null &&
                      code.rawValue!
                          .startsWith(NwcProvider.NWC_PROTOCOL_PREFIX)) {
                    nwc = code.rawValue!;
                  }
                }
                if (nwc != null) {
                  scannerController.stop();
                  setState(() {
                    nwcSecret = nwc;
                  });
                  await nwcProvider?.connect(nwc!, onConnect: (lud16) async {
                    await metadataProvider.updateLud16IfEmpty(lud16);
                    context.pop();
                  }, onError: (error) async {
                    EasyLoading.showError(
                        'Error connecting to wallet...${error!}',
                        maskType: EasyLoadingMaskType.black,
                        dismissOnTap: true,
                        duration: const Duration(seconds: 7));
                    scannerController.start();
                    setState(() {
                      nwcSecret = null;
                    });
                  });
                  return;
                }
              }
              EasyLoading.showError(
                  'Error connecting to wallet...${result.barcodes.map((code) => code.toString()).toString()}',
                  maskType: EasyLoadingMaskType.black,
                  dismissOnTap: true,
                  duration: const Duration(seconds: 7));
              scannerController.start();
            }
          },
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
                                  CircularProgressIndicator(color: Colors.white
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
                                  nwcProvider?.connect(clipboardData.text!,
                                      onConnect: (lud16) async {
                                    await metadataProvider
                                        .updateLud16IfEmpty(lud16);
                                    context.pop();
                                  }, onError: (error) async {
                                    EasyLoading.showError(
                                        'Error connecting to wallet...${error!}',
                                        maskType: EasyLoadingMaskType.black,
                                        dismissOnTap: true,
                                        duration: const Duration(seconds: 7));
                                    setState(() {
                                      nwcSecret = null;
                                    });
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
    return nwcSecret != null && !(nwcProvider?.isConnected ?? false);
  }

  Widget barOptions() {
    return PopupMenuButton<String>(
        icon: const Icon(Icons.image),
        tooltip: "settings",
        itemBuilder: (context) {
          List<PopupMenuEntry<String>> list = [
            //const PopupMenuItem(value: "settings", child: Text("Settings")),
          ];
          if (nwcProvider?.isConnected ?? false) {
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
              await nwcProvider?.disconnect();
            });
          }
        });
  }
}
