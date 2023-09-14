import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yana/nostr/event.dart';
import 'package:yana/nostr/nip19/nip19.dart';
import 'package:yana/nostr/nip47/nwc_kind.dart';
import 'package:yana/utils/base.dart';
import 'package:yana/main.dart';
import 'package:yana/utils/string_util.dart';

import '../../ui/appbar4stack.dart';
import '../../i18n/i18n.dart';
import '../nostr/filter.dart';
import '../nostr/nip04/nip04.dart';
import '../nostr/nostr.dart';
import '../nostr/relay.dart';
import '../provider/data_util.dart';
import '../utils/router_path.dart';
import '../utils/router_util.dart';

class WalletRouter extends StatefulWidget {
  const WalletRouter({super.key});

  @override
  State<StatefulWidget> createState() {
    return _WalletRouter();
  }
}

const String NWC_GET_BALANCE_PERMISSION = "get_balance";


class _WalletRouter extends State<WalletRouter> {
  TextEditingController controller = TextEditingController();

  String? uri;
  List<String> permissions = [];

  @override
  void initState() {
    String? perms = sharedPreferences.getString(DataKey.NWC_PERMISSIONS);
    if (StringUtil.isNotBlank(perms)) {
      permissions = perms!.split(",");
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      readNwc();
    });
  }

  void readNwc() async {
    uri = await settingProvider.getNwc();
    if (StringUtil.isNotBlank(uri)) {
      setState(() {
        controller.text = uri!;
      });
    }
    controller.addListener(() async{
      if (uri == null || uri != controller.text) {
        uri = controller.text;
        await settingProvider.setNwc(uri!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var s = I18n.of(context);
    var themeData = Theme.of(context);
    var cardColor = themeData.cardColor;
    var mainColor = themeData.primaryColor;

    // initCheckBoxItems(context);

    Color? appbarBackgroundColor = Colors.transparent;
    var appBar = Appbar4Stack(
      backgroundColor: appbarBackgroundColor,
    );

    List<Widget> list = [];
    
    if (StringUtil.isNotBlank(uri) && permissions.isNotEmpty) {
      permissions.where((element) => element != NWC_GET_BALANCE_PERMISSION).forEach((permission) {
        list.add(Container(              margin: const EdgeInsets.all(Base.BASE_PADDING),
            child:Text(permission)));
      });
      if (permissions.contains(NWC_GET_BALANCE_PERMISSION)) {
        list.add(
          InkWell(
            onTap: getBalance,
            child: Container(
              height: 36,
              color: mainColor,
              margin: const EdgeInsets.all(Base.BASE_PADDING),
              alignment: Alignment.center,
              child: const Text(
                "Get balance",
                style: TextStyle(
                  fontFamily: "Montserrat",
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      }
      list.add(
        InkWell(
          onTap: disconnect,
          child: Container(
            margin: const EdgeInsets.all(Base.BASE_PADDING),
            height: 36,
            color: mainColor,
            alignment: Alignment.center,
            child: const Text(
              "Disconnect",
              style: TextStyle(
                fontFamily: "Montserrat",
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      );
    } else {
      list.add(Row(children: [
        const Text("Wallet Connect URI (NWC)"),
        Container(
          margin: const EdgeInsets.only(left: Base.BASE_PADDING),
          child: Image.asset("assets/imgs/alby.png", width: 30, height: 30),
        ),
        Container(
            margin: const EdgeInsets.only(left: Base.BASE_PADDING),
            child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: scanNWC,
                child: Icon(Icons.qr_code_scanner,
                    size: 25, color: themeData.iconTheme.color)))
      ]));

      list.add(Row(
        children: [
          Expanded(
              child: TextField(
                controller: controller,
                decoration: const InputDecoration(
                    hintText: "nostr+walletconnect:"),
              )),
        ],
      ));

      list.add(Container(
        margin: const EdgeInsets.all(Base.BASE_PADDING),
        child: InkWell(
          onTap: connect,
          child: Container(
            height: 36,
            color: mainColor,
            alignment: Alignment.center,
            child: const Text(
              "Connect",
              style: TextStyle(
                fontFamily: "Montserrat",
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ));
    }
    
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
                  ),
                ),
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

  static RegExp nwcRegExp = RegExp(r'^nostr\+walletconnect:\/\/([ZA-ZZa-z0-9_]+)\?(.*)');
  static RegExp relayRegExp = RegExp(
      r'^(wss?:\/\/)([0-9]{1,3}(?:\.[0-9]{1,3}){3}|[^:]+):?([0-9]{1,5})?$');

  Map<String, String> parseQueryString(String input) {
    Map<String, String> resultMap = {};
    List<String> pairs = input.split('&');

    for (String pair in pairs) {
      List<String> keyValue = pair.split('=');
      if (keyValue.length == 2) {
        String key = keyValue[0];
        String value = keyValue[1];
        resultMap[key] = value;
      }
    }
    return resultMap;
  }

  Future<void> disconnect() async {
    sharedPreferences.setString(DataKey.NWC_PERMISSIONS, "");
    setState(() {
      permissions = [];
    });
  }

  Future<void> connect() async {

    String nwc = controller.text;
    var match = nwcRegExp.firstMatch(nwc);
    if (match != null) {
      String? pubKey = match!.group(1);
      String? params = match!.group(2);
      if (StringUtil.isNotBlank(params)) {
        Map<String, String> map = parseQueryString(params!);
        String? relay = map['relay'];
        String? secret = map['secret'];
        String? lud16 = map['lub16'];
        if (StringUtil.isBlank(relay)) {
          BotToast.showText(text: "missing relay parameter");
          return;
        }
        if (StringUtil.isBlank(secret)) {
          BotToast.showText(text: "missing secret parameter");
          return;
        }
        if (StringUtil.isBlank(pubKey)) {
          BotToast.showText(text: "missing pubKey from connection uri");
          return;
        }
        await settingProvider.setNwcSecret(secret!);
        var filter = Filter(kinds: [NwcKind.INFO_REQUEST], authors: [pubKey!]);
        nostr!.queryRelay(filter.toJson(), relay!, onEventInfo);
      }
    }
  }

  Future<void> scanNWC() async {
    var result = await RouterUtil.router(context, RouterPath.QRSCANNER);
    controller.text = result;
  }

  void onEventInfo(Event event) {
    if (event.kind == NwcKind.INFO_REQUEST && StringUtil.isNotBlank(event.content)) {
      sharedPreferences.setString(DataKey.NWC_PERMISSIONS, event.content);
      sharedPreferences.setString(DataKey.NWC_RELAY, event.sources[0]);
      sharedPreferences.setString(DataKey.NWC_PUB_KEY, event.pubKey);
      setState(() {
        permissions = event.content.split(",");
      });
    }
  }

  void onGetBalanceResponse(Event event) async {
    if (event.kind == NwcKind.RESPONSE && StringUtil.isNotBlank(event.content)) {
      String? pubKey = sharedPreferences.getString(DataKey.NWC_PUB_KEY);
      if (event.pubKey == pubKey) {
        String? secret = await settingProvider.getNwcSecret();
        var agreement = NIP04.getAgreement(nostr!.privateKey!);
        // var agreement = NIP04.getAgreement(secret!);
        // String? pubKey = sharedPreferences.getString(DataKey.NWC_PUB_KEY);
        var decrypted = NIP04.decrypt(event.content, agreement, pubKey!);
        print("get balance response: $decrypted");
      }
    }
  }

  Future<void> getBalance() async {
    String? pubKey = sharedPreferences.getString(DataKey.NWC_PUB_KEY);
    String? relay = sharedPreferences.getString(DataKey.NWC_RELAY);
    String? secret = await settingProvider.getNwcSecret();
    if (StringUtil.isNotBlank(pubKey) && StringUtil.isNotBlank(relay) && StringUtil.isNotBlank(secret)) {
      Nostr nwcNostr = Nostr(privateKey: secret);

      var agreement = NIP04.getAgreement(secret!);
      var encrypted = NIP04.encrypt("{'method':'get_balance'}", agreement, pubKey!);
      var tags = [["p",pubKey]];
      final event = Event(nwcNostr!.publicKey, NwcKind.REQUEST, tags, encrypted);

      nwcNostr!.sendRelayEvent(event, relay!);
      Future.delayed(Duration(seconds: 5), () {
        var filter = Filter(kinds: [NwcKind.RESPONSE], p: [nostr!.publicKey] );
        nwcNostr!.queryRelay(filter.toJson(), relay!, onGetBalanceResponse);
      });
    } else {
      BotToast.showText(text: "missing pubKey and/or relay for connectiong");
    }
  }
}
