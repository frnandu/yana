import 'package:flutter/material.dart';
import 'package:protocol_handler/protocol_handler.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yana/main.dart';
import 'package:yana/provider/nwc_provider.dart';
import 'package:yana/utils/base.dart';
import 'package:yana/utils/string_util.dart';

import '../../../ui/appbar4stack.dart';
import '../../utils/platform_util.dart';
import '../../utils/router_path.dart';
import '../../utils/router_util.dart';

class NwcRouter extends StatefulWidget {
  const NwcRouter({super.key});

  @override
  State<StatefulWidget> createState() {
    return _NwcRouter();
  }
}

class _NwcRouter extends State<NwcRouter> {
  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    String? uri = nwcProvider.uri;
    if (StringUtil.isNotBlank(uri)) {
      controller.text = uri!;
    }
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
        child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Container(
                margin: const EdgeInsets.all(Base.BASE_PADDING),
                padding: const EdgeInsets.only(left: Base.BASE_PADDING),
                decoration: const BoxDecoration(
                    gradient: LinearGradient(
                        colors: [Color(0xffFFDE6E), Colors.orange]),
                    borderRadius: BorderRadius.all(Radius.circular(20.0))),
                child: Row(children: [
                  Container(
                    margin: const EdgeInsets.all(Base.BASE_PADDING),
                    child: Image.asset("assets/imgs/alby.png",
                        width: 30, height: 30),
                  ),
                  const Text("Connect with Alby account",
                      style: TextStyle(color: Colors.black))
                ])))));
    list.add(GestureDetector(
        // onTap: () {
        //   launchUrl(
        //       Uri.parse(
        //           "https://app.mutinywallet.com/settings/connections?callbackUri=yana&name=${packageInfo.appName}"),
        //       mode: LaunchMode.externalApplication);
        // },
        child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Container(
                margin: const EdgeInsets.all(Base.BASE_PADDING),
                padding: const EdgeInsets.only(left: Base.BASE_PADDING),
                decoration: const BoxDecoration(
                    gradient: LinearGradient(
                        colors: [Color(0xff800000), Color(0xff550000)]),
                    borderRadius: BorderRadius.all(Radius.circular(20.0))),
                child: Row(children: [
                  Container(
                    margin: const EdgeInsets.all(Base.BASE_PADDING),
                    child: Image.asset("assets/imgs/mutiny.png",
                        width: 30, height: 30),
                  ),
                  const Text("Connect with Mutiny wallet"),
                  Text('  (soon)',
                      style: TextStyle(
                          color: themeData.hintColor,
                          fontFamily: "Montserrat",
                          fontSize: 12))
                ])))));
    if (!PlatformUtil.isWeb()) {
      list.add(GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: scanNWC,
          child: Container(
              margin: const EdgeInsets.all(Base.BASE_PADDING),
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
                const Text("QR Scan pairing secret"),
              ]))));
    }
    list.add(Divider());
    list.add(Container(
        alignment: Alignment.center,
        margin: EdgeInsets.all(Base.BASE_PADDING),
        child: Text("or")));

    list.add(Row(
      children: [
        Expanded(
            child: TextField(
          controller: controller,
          decoration: const InputDecoration(
              hintText: "enter manually nostr+walletconnect://..."),
        )),
      ],
    ));

    list.add(GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () async {
          await _nwcProvider.connect(controller.text);
          RouterUtil.back(context);
        },
        child: MouseRegion(
            cursor: SystemMouseCursors.click,
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
                  const Text("Connect manual address"),
                ])))));

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
