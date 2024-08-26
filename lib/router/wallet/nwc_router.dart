import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    qrController?.dispose();
    // unawaited(_subscription?.cancel());
    // _subscription = null;
    // Dispose the widget itself.
    super.dispose();
    // Finally, dispose of the controller.
    // await controller.dispose();
  }

  @override
  void initState() {
    // Start listening to the barcode events.
    // _subscription = controller.barcodes.listen((data) {
    // });
    //
    // // Finally, start the scanner itself.
    // unawaited(controller.start());

    // String? uri = nwcProvider.uri;
    // if (StringUtil.isNotBlank(uri)) {
    //   controller.text = uri!;
    // }
    // controller.addListener(() async {
    //   if (uri == null || uri != controller.text) {
    //     uri = controller.text;
    //   }
    // });

//    nwcProvider.reload();
    // String? perms = sharedPreferences.getString(DataKey.NWC_PERMISSIONS);
    // if (StringUtil.isNotBlank(perms)) {
    //   permissions = perms!.split(",");
    // }
    //
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   readNwc();
    // });
  }

  @override
  Widget build(BuildContext context) {
    var _nwcProvider = Provider.of<NwcProvider>(context);

    var themeData = Theme.of(context);
    var cardColor = themeData.cardColor;

    Color? appbarBackgroundColor = Colors.transparent;

    // var appBar = Appbar4Stack(
    //   title: Container(
    //     alignment: Alignment.center,
    //     child: const Text(
    //       "Scan or Paste Pairing Secret",
    //       style: TextStyle(
    //         fontWeight: FontWeight.bold,
    //         fontFamily: "Geist",
    //         fontSize: 20,
    //       ),
    //     ),
    //   ),
    //   backgroundColor: appbarBackgroundColor,
    // );

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
        child: Icon(
          Icons.arrow_back_ios,
          color: themeData.appBarTheme.titleTextStyle!.color,
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
    // if (_nwcProvider.isConnected) {
    //   Future.microtask(() {
    //     RouterUtil.router(context, RouterPath.WALLET);
    //   });
    //   // scannedCode = null;
    //   // qrController?.dispose();
    //   // dispose();
    //   // RouterUtil.router(context, RouterPath.WALLET);
    // }

    // list.add(GestureDetector(
    //     onTap: () {
    //       //WebViewRouter.open(context, "https://nwc.getalby.com/apps/new?c=${packageInfo.appName}");
    //       launchUrl(
    //           Uri.parse(
    //               "https://nwc.getalby.com/apps/new?c=${packageInfo.appName}"),
    //           mode: LaunchMode.externalApplication);
    //     },
    //     child: MouseRegion(
    //         cursor: SystemMouseCursors.click,
    //         child: Container(
    //             margin: const EdgeInsets.all(Base.BASE_PADDING),
    //             padding: const EdgeInsets.only(left: Base.BASE_PADDING),
    //             decoration: const BoxDecoration(
    //                 gradient: LinearGradient(
    //                     colors: [Color(0xffFFDE6E), Colors.orange]),
    //                 borderRadius: BorderRadius.all(Radius.circular(20.0))),
    //             child: Row(children: [
    //               Container(
    //                 margin: const EdgeInsets.all(Base.BASE_PADDING),
    //                 child: Image.asset("assets/imgs/alby.png",
    //                     width: 30, height: 30),
    //               ),
    //               const Text("Connect with Alby account",
    //                   style: TextStyle(color: Colors.black))
    //             ])))));
    // list.add(GestureDetector(
    //     // onTap: () {
    //     //   launchUrl(
    //     //       Uri.parse(
    //     //           "https://app.mutinywallet.com/settings/connections?callbackUri=yana&name=${packageInfo.appName}"),
    //     //       mode: LaunchMode.externalApplication);
    //     // },
    //     child: MouseRegion(
    //         cursor: SystemMouseCursors.click,
    //         child: Container(
    //             margin: const EdgeInsets.all(Base.BASE_PADDING),
    //             padding: const EdgeInsets.only(left: Base.BASE_PADDING),
    //             decoration: const BoxDecoration(
    //                 gradient: LinearGradient(
    //                     colors: [Color(0xff800000), Color(0xff550000)]),
    //                 borderRadius: BorderRadius.all(Radius.circular(20.0))),
    //             child: Row(children: [
    //               Container(
    //                 margin: const EdgeInsets.all(Base.BASE_PADDING),
    //                 child: Image.asset("assets/imgs/mutiny.png",
    //                     width: 30, height: 30),
    //               ),
    //               const Text("Connect with Mutiny wallet", style: TextStyle(color: Colors.white)),
    //               Text('  (soon)',
    //                   style: TextStyle(
    //                       color: themeData.hintColor,
    //                       fontFamily: "Geist",
    //                       fontSize: 12))
    //             ])))));
    // if (!PlatformUtil.isWeb()) {
    //   list.add(GestureDetector(
    //       behavior: HitTestBehavior.translucent,
    //       onTap: scanNWC,
    //       child: Container(
    //           margin: const EdgeInsets.all(Base.BASE_PADDING),
    //           decoration: BoxDecoration(
    //             borderRadius: const BorderRadius.all(Radius.circular(20.0)),
    //             border: Border.all(
    //               width: 1,
    //               color: themeData.hintColor,
    //             ),
    //           ),
    //           child: Row(children: [
    //             Container(
    //                 margin: const EdgeInsets.all(Base.BASE_PADDING),
    //                 child: Icon(Icons.qr_code_scanner,
    //                     size: 25, color: themeData.iconTheme.color)),
    //             const Text("QR Scan pairing secret"),
    //           ]))));
    // }
    // list.add(Divider());
    // list.add(Container(
    //     alignment: Alignment.center,
    //     margin: EdgeInsets.all(Base.BASE_PADDING),
    //     child: Text("or")));
    //
    // list.add(Row(
    //   children: [
    //     Expanded(
    //         child: TextField(
    //       controller: controller,
    //       decoration: const InputDecoration(
    //           hintText: "enter manually nostr+walletconnect://..."),
    //     )),
    //   ],
    // ));
    //
    // list.add(GestureDetector(
    //     behavior: HitTestBehavior.translucent,
    //     onTap: () async {
    //       await _nwcProvider.connect(controller.text);
    //       RouterUtil.back(context);
    //     },
    //     child: MouseRegion(
    //         cursor: SystemMouseCursors.click,
    //         child: Container(
    //             margin: EdgeInsets.all(Base.BASE_PADDING),
    //             decoration: BoxDecoration(
    //               borderRadius: const BorderRadius.all(Radius.circular(20.0)),
    //               border: Border.all(
    //                 width: 1,
    //                 color: themeData.hintColor,
    //               ),
    //             ),
    //             child: Row(children: [
    //               Container(
    //                   margin: const EdgeInsets.all(Base.BASE_PADDING),
    //                   child: Icon(Icons.edit_note,
    //                       size: 25, color: themeData.iconTheme.color)),
    //               const Text("Connect manual address"),
    //             ])))));
    //
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
                          text:
                              isConnecting() ? "Connecting..." : "Paste Secret",
                          before: isConnecting()
                              ? Container()
                              : const Icon(Icons.paste),
                          after: nwcSecret != null
                              ? Row(children: [
                                  const SizedBox(width: 50),
                                  Selector<NwcProvider, bool>(
                                      builder: (context, isConnected, child) {
                                    if (isConnected) {
                                      RouterUtil.back(context);
                                      return Container();
                                    } else {
                                      return const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.0,
                                          ));
                                    }
                                  }, selector: (context, _provider) {
                                    return _provider.isConnected;
                                  })
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
                                  nwcProvider.connect(clipboardData.text!);
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
      // Stack(
      //   children: [
      //     Container(
      //       width: mediaDataCache.size.width,
      //       height: mediaDataCache.size.height - mediaDataCache.padding.top,
      //       margin: EdgeInsets.only(top: mediaDataCache.padding.top),
      //       child: Container(
      //         color: cardColor,
      //         child: Center(
      //           child: Container(
      //               width: mediaDataCache.size.width * 0.8,
      //               child: Column(
      //                 mainAxisSize: MainAxisSize.min,
      //                 children: list,
      //               )),
      //         ),
      //       ),
      //     ),
      //     Positioned(
      //       top: mediaDataCache.padding.top,
      //       child: Container(
      //         width: mediaDataCache.size.width,
      //         child: appBar,
      //       ),
      //     ),
      //   ],
      // ),
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

// Future<void> scanNWC() async {
//   var result = await RouterUtil.router(context, RouterPath.QRSCANNER);
//   if (StringUtil.isNotBlank(result)) {
//     controller.text = result;
//     await nwcProvider.connect(controller.text);
//     RouterUtil.back(context);
//   }
// }
}
