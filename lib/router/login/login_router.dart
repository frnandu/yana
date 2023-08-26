import 'dart:developer';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:yana/utils/platform_util.dart';

import '../../i18n/i18n.dart';
import '../../main.dart';
import '../../nostr/client_utils/keys.dart';
import '../../nostr/event.dart';
import '../../nostr/event_kind.dart' as kind;
import '../../nostr/filter.dart';
import '../../nostr/nip19/nip19.dart';
import '../../nostr/nostr.dart';
import '../../utils/base.dart';
import '../../utils/index_taps.dart';
import '../../utils/string_util.dart';

class LoginRouter extends StatefulWidget {
  const LoginRouter({super.key});

  @override
  State<StatefulWidget> createState() {
    return _LoginRouter();
  }
}

class _LoginRouter extends State<LoginRouter>
    with SingleTickerProviderStateMixin {
  bool obscureText = true;

  TextEditingController controller = TextEditingController();

  late AnimationController animationController;

  @override
  void initState() {
    animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2));
    // animation = ;
  }

  @override
  Widget build(BuildContext context) {
    var s = I18n.of(context);
    var themeData = Theme.of(context);
    var mainColor = themeData.primaryColor;
    var maxWidth = mediaDataCache.size.width;
    var mainWidth = maxWidth * 0.8;
    if (PlatformUtil.isTableMode()) {
      if (mainWidth > 550) {
        mainWidth = 550;
      }
    }

    var logoWiget = Image.asset(
      "assets/imgs/logo/logo.png",
      width: 100,
      height: 100,
    );

    List<Widget> mainList = [];
    mainList.add(logoWiget);
    mainList.add(Container(
      margin: const EdgeInsets.only(
        top: Base.BASE_PADDING,
        bottom: 40,
      ),
      child: Text(
        packageInfo.appName,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    ));

    var suffixIcon = GestureDetector(
      onTap: () {
        setState(() {
          obscureText = !obscureText;
        });
      },
      child: Icon(obscureText ? Icons.visibility : Icons.visibility_off),
    );
    mainList.add(TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: "nsec / hex private key",
        fillColor: Colors.white,
        suffixIcon: suffixIcon,
      ),
      obscureText: obscureText,
    ));

    // const spinkit = SpinKitRotatingCircle(
    //   color: Colors.white,
    //   size: 50.0,
    // );

    var login = Text(
      s.Login,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );

    mainList.add(Container(
      margin: const EdgeInsets.all(Base.BASE_PADDING * 2),
      child: InkWell(
        onTap: () {
          showLoaderDialog(context);
          doLogin();
        },
        child: Container(
          height: 36,
          color: mainColor,
          alignment: Alignment.center,
          child: login,
        ),
      ),
    ));

    mainList.add(Container(
      margin: const EdgeInsets.only(bottom: 100),
      child: GestureDetector(
        onTap: generatePK,
        child: Text(
          s.Generate_a_new_private_key,
          style: TextStyle(
            color: mainColor,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    ));

    return Scaffold(
      body: SizedBox(
        width: double.maxFinite,
        height: double.maxFinite,
        child: Stack(
          alignment: AlignmentDirectional.center,
          children: [
            SizedBox(
              width: mainWidth,
              // color: Colors.red,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: mainList,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void generatePK() {
    var pk = generatePrivateKey();
    controller.text = pk;
  }

  showLoaderDialog(BuildContext context) {
    AlertDialog alert = AlertDialog(
      content: Row(
        children: [
          const CircularProgressIndicator(),
          Container(
              margin: const EdgeInsets.only(left: 7),
              child: Text(I18n.of(context).Loading)),
        ],
      ),
    );
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Future<void> handleRemoteRelays(Event? remoteRelayEvent) async {
    var relaysUpdatedTime = relayProvider.updatedTime();
    if (remoteRelayEvent != null &&
        (relaysUpdatedTime == null ||
            remoteRelayEvent!.createdAt - relaysUpdatedTime > 60 * 5)) {
      List<String> list = [];
      for (var tag in remoteRelayEvent!.tags) {
        if (tag.length > 1) {
          var key = tag[0];
          var value = tag[1];
          if (key == "r") {
            list.add(value);
          }
        }
      }
      relayProvider.setRelayListAndUpdate(list);
    }
  }

  void doLogin() {
    var pk = controller.text;
    if (StringUtil.isBlank(pk)) {
      BotToast.showText(text: I18n.of(context).Private_key_is_null);
      return;
    }

    if (Nip19.isPrivateKey(pk)) {
      pk = Nip19.decode(pk);
    }
    settingProvider.addAndChangePrivateKey(pk, updateUI: false);

    var tempNostr = Nostr(privateKey: pk);

    var filter = Filter(
        authors: [tempNostr!.publicKey],
        limit: 1,
        kinds: [kind.EventKind.RELAY_LIST_METADATA]);

    relayProvider.relayAddrs.forEach((relayAddr) {
      var custRelay = relayProvider.genRelay(relayAddr);
      try {
        tempNostr.addRelay(custRelay, init: true);
      } catch (e) {
        log("relay $relayAddr add to pool error ${e.toString()}");
      }
    });

    tempNostr!.addInitQuery([filter.toJson()], (event) {
      handleRemoteRelays(event);

      nostr = relayProvider.genNostr(pk);
      Navigator.of(context, rootNavigator: true).pop();
      settingProvider.notifyListeners();

      firstLogin = true;
      indexProvider.setCurrentTap(IndexTaps.FOLLOW);
    });
  }
}
