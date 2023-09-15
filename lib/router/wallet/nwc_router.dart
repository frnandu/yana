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
          RouterUtil.back(context);
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
      RouterUtil.back(context);
    }
  }
}
