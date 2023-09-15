import 'dart:convert';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:protocol_handler/protocol_handler.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yana/nostr/event.dart';
import 'package:yana/nostr/nip47/nwc_commands.dart';
import 'package:yana/nostr/nip47/nwc_kind.dart';
import 'package:yana/provider/nwc_provider.dart';
import 'package:yana/utils/base.dart';
import 'package:yana/main.dart';
import 'package:yana/utils/string_util.dart';

import '../../../ui/appbar4stack.dart';
import '../../../i18n/i18n.dart';
import '../../nostr/filter.dart';
import '../../nostr/nip04/nip04.dart';
import '../../nostr/nostr.dart';
import '../../provider/data_util.dart';
import '../../ui/webview_router.dart';
import '../../utils/router_path.dart';
import '../../utils/router_util.dart';

class NwcRouter extends StatefulWidget {
  const NwcRouter({super.key});

  @override
  State<StatefulWidget> createState() {
    return _NwcRouter();
  }
}

class _NwcRouter extends State<NwcRouter> with ProtocolListener {
  TextEditingController controller = TextEditingController();

  @override
  void onProtocolUrlReceived(String url) {
    // String log = 'Url received: $url)';
    // print(log);
    if (StringUtil.isNotBlank(url)) {
      Future.delayed(const Duration(microseconds: 1), () async {
        await nwcProvider.connect(url);
        await RouterUtil.router(context, RouterPath.WALLET);
      });
    }
  }
  @override
  void initState() {
    protocolHandler.addListener(this);
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

  // void readNwc() async {
  //   uri = await settingProvider.getNwc();
  //   if (StringUtil.isNotBlank(uri)) {
  //     await getBalance();
  //     setState(() {
  //       controller.text = uri!;
  //     });
  //   }
  //   controller.addListener(() async {
  //     if (uri == null || uri != controller.text) {
  //       uri = controller.text;
  //       await settingProvider.setNwc(uri!);
  //     }
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    var _nwcProvider = Provider.of<NwcProvider>(context);

    var s = I18n.of(context);
    var themeData = Theme.of(context);
    var cardColor = themeData.cardColor;
    var mainColor = themeData.primaryColor;

    Color? appbarBackgroundColor = Colors.transparent;

    var appBar = Appbar4Stack(
      title: Container(
        alignment: Alignment.center,
        child: const Text(
          "Nostr Wallet Connect",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: "Montserrat",
            fontSize: 20,
          ),
        ),
      ),
      backgroundColor: appbarBackgroundColor,
    );

    List<Widget> list = [];

    list.add(GestureDetector(
        onTap: () {
          //WebViewRouter.open(context, "https://nwc.getalby.com/apps/new?c=${packageInfo.appName}");
          launchUrl(
              Uri.parse(
                  "https://nwc.getalby.com/apps/new?c=${packageInfo.appName}"),
              mode: LaunchMode.externalApplication);
        },
        child: Container(
            margin: EdgeInsets.all(Base.BASE_PADDING),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(20.0)),
              border: Border.all(
                width: 1,
                color: themeData.hintColor,
              ),
            ),
            child: Row(children: [
              Container(
                margin: const EdgeInsets.all(Base.BASE_PADDING),
                child:
                    Image.asset("assets/imgs/alby.png", width: 30, height: 30),
              ),
              const Text("Connect with Alby (custodial)"),
            ]))));
    list.add(GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: scanNWC,
        child: Container(
            margin: EdgeInsets.all(Base.BASE_PADDING),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(20.0)),
              border: Border.all(
                width: 1,
                color: themeData.hintColor,
              ),
            ),
            child: Row(children: [
              Container(
                  margin: const EdgeInsets.all(Base.BASE_PADDING),
                  child: Icon(Icons.qr_code_scanner,
                      size: 25, color: themeData.iconTheme.color)),
              const Text("QR Scan (self-hosted or Alby)"),
            ]))));

    list.add(Row(
      children: [
        Expanded(
            child: TextField(
          controller: controller,
          decoration: const InputDecoration(
              hintText: "custom nostr+walletconnect URI"),
        )),
      ],
    ));

    list.add(GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () async {
          await _nwcProvider.connect(controller.text);
          await RouterUtil.router(context, RouterPath.WALLET);
        },
        child: Container(
            margin: EdgeInsets.all(Base.BASE_PADDING),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(20.0)),
              border: Border.all(
                width: 1,
                color: themeData.hintColor,
              ),
            ),
            child: Row(children: [
              Container(
                  margin: const EdgeInsets.all(Base.BASE_PADDING),
                  child: Icon(Icons.edit_note,
                      size: 25, color: themeData.iconTheme.color)),
              const Text("Connect custom URI"),
            ]))));

    // list.add(Container(
    //   decoration: BoxDecoration(
    //     borderRadius: const BorderRadius.all(Radius.circular(20.0)),
    //     border: Border.all(
    //       width: 1,
    //       color: themeData.hintColor,
    //     ),
    //   ),
    //   margin: const EdgeInsets.all(Base.BASE_PADDING),
    //
    //   child: InkWell(
    //     onTap: () async {
    //       await _nwcProvider.connect(controller.text);
    //     },
    //     child: Container(
    //       height: 36,
    //       color: mainColor,
    //       alignment: Alignment.center,
    //       child: const Text(
    //         "Connect",
    //         style: TextStyle(
    //           fontFamily: "Montserrat",
    //           color: Colors.white,
    //           fontSize: 16,
    //           fontWeight: FontWeight.bold,
    //         ),
    //       ),
    //     ),
    //   ),
    // ));
// if (false) {
// if (StringUtil.isNotBlank(uri) && permissions.isNotEmpty) {
// permissions
//     .where((element) => element != NWC_GET_BALANCE_PERMISSION)
//     .forEach((permission) {
//   list.add(Container(
//       margin: const EdgeInsets.all(Base.BASE_PADDING),
//       child: Text(permission)));
// });
// if (balance != null) {
//   list.add(Container(
//       margin: const EdgeInsets.all(Base.BASE_PADDING),
//       child: Text("${balance!} sats", style: balanceTextStyle)));
//   if (maxAmount != null && maxAmount! > 0) {
//     list.add(Container(
//         margin: const EdgeInsets.all(Base.BASE_PADDING),
//         child: Text("Max amount: ${maxAmount!} sats")));
//   }
// } else if (permissions.contains(NWC_GET_BALANCE_PERMISSION)) {
//   list.add(
//     InkWell(
//       onTap: _nwcProvider.requestBalance,
//       child: Container(
//         height: 36,
//         color: mainColor,
//         margin: const EdgeInsets.all(Base.BASE_PADDING),
//         alignment: Alignment.center,
//         child: const Text(
//           "Get balance",
//           style: TextStyle(
//             fontFamily: "Montserrat",
//             color: Colors.white,
//             fontSize: 16,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ),
//     ),
//   );
// }
// if (permissions.contains(NWC_GET_BALANCE_PERMISSION)) {
//   list.add(
//     InkWell(
//       onTap: _nwcProvider.payInvoice,
//       child: Container(
//         height: 36,
//         color: mainColor,
//         margin: const EdgeInsets.all(Base.BASE_PADDING),
//         alignment: Alignment.center,
//         child: const Text(
//           "Pay invoice",
//           style: TextStyle(
//             fontFamily: "Montserrat",
//             color: Colors.white,
//             fontSize: 16,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ),
//     ),
//   );
// }

// list.add(
//   InkWell(
//     onTap: _nwcProvider.disconnect,
//     child: Container(
//       margin: const EdgeInsets.all(Base.BASE_PADDING),
//       height: 36,
//       color: mainColor,
//       alignment: Alignment.center,
//       child: const Text(
//         "Disconnect",
//         style: TextStyle(
//           fontFamily: "Montserrat",
//           color: Colors.white,
//           fontSize: 16,
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//     ),
//   ),
// );
// } else {
//   list.add(Row(children: [
//     const Text("Wallet Connect URI (NWC)"),
//     Container(
//       margin: const EdgeInsets.only(left: Base.BASE_PADDING),
//       child: Image.asset("assets/imgs/alby.png", width: 30, height: 30),
//     ),
//     Container(
//         margin: const EdgeInsets.only(left: Base.BASE_PADDING),
//         child: GestureDetector(
//             behavior: HitTestBehavior.translucent,
//             onTap: scanNWC,
//             child: Icon(Icons.qr_code_scanner,
//                 size: 25, color: themeData.iconTheme.color)))
//   ]));
//
//   list.add(Row(
//     children: [
//       Expanded(
//           child: TextField(
//         controller: controller,
//         decoration: const InputDecoration(hintText: "nostr+walletconnect:"),
//       )),
//     ],
//   ));
//
//   list.add(Container(
//     margin: const EdgeInsets.all(Base.BASE_PADDING),
//     child: InkWell(
//       onTap: () async {
//         await _nwcProvider.connect(controller.text);
//       },
//       child: Container(
//         height: 36,
//         color: mainColor,
//         alignment: Alignment.center,
//         child: const Text(
//           "Connect",
//           style: TextStyle(
//             fontFamily: "Montserrat",
//             color: Colors.white,
//             fontSize: 16,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ),
//     ),
//   ));
// }

    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: mediaDataCache.size.width,
            height: mediaDataCache.size.height - mediaDataCache.padding.top,
            margin: EdgeInsets.only(top: mediaDataCache.padding.top),
            child: Container(
              color: cardColor,
              child: Center(
                child: Container(
                    width: mediaDataCache.size.width * 0.8,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: list,
                    )),
              ),
            ),
          ),
          Positioned(
            top: mediaDataCache.padding.top,
            child: Container(
              width: mediaDataCache.size.width,
              child: appBar,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> scanNWC() async {
    var result = await RouterUtil.router(context, RouterPath.QRSCANNER);
    if (StringUtil.isNotBlank(result)) {
      controller.text = result;
      await nwcProvider.connect(controller.text);
      await RouterUtil.router(context, RouterPath.WALLET);
    }
  }
}
