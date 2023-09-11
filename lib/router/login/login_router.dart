import 'package:flutter/foundation.dart';

import '/js/js_helper.dart' as js;
import 'dart:developer';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
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

  static Future<void> handleRemoteRelays(Event? remoteRelayEvent, String privKey) async {
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
      relayProvider.setRelayListAndUpdate(list, privKey);
    }
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
    var maxWidth = mediaDataCache.size.width;
    var mainWidth = maxWidth * 0.8;
    if (PlatformUtil.isTableMode()) {
      if (mainWidth > 550) {
        mainWidth = 550;
      }
    }

    var logoWiget = Image.asset(
      "assets/imgs/logo/logo-with-name.png",
      width: 100,
      height: 100,
    );

    List<Widget> list = [];
    list.add(logoWiget);
    // list.add(Container(
    //   margin: const EdgeInsets.only(
    //     top: Base.BASE_PADDING,
    //     bottom: 40,
    //   ),
    //   child: Text(
    //     packageInfo.appName,
    //     style: const TextStyle(
    //       fontFamily: 'Montserrat',
    //       color: Colors.white,
    //       fontSize: 30,
    //       fontWeight: FontWeight.bold,
    //     ),
    //   ),
    // ));

    var suffixIcon = GestureDetector(
      onTap: () {
        setState(() {
          obscureText = !obscureText;
        });
      },
      child: Icon(obscureText ? Icons.visibility : Icons.visibility_off),
    );
    list.add(TextField(
      controller: controller,
      decoration: InputDecoration(
        //border: InputBorder.none,
        hintText: s.Input_for_login,
        fillColor: Colors.white,
        suffixIcon: suffixIcon,
      ),
      style: const TextStyle(color: Colors.white),
      obscureText: obscureText,
    ));

    list.add(Container(
      margin: const EdgeInsets.all(Base.BASE_PADDING),
      child: InkWell(
        onTap: () {
          doLogin(controller.text, false, false);
        },
        child: Container(
          height: 36,
          color: themeData.primaryColor,
          alignment: Alignment.center,
          child: Text(
            s.Login,
            style: const TextStyle(
              fontFamily: 'Montserrat',
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    ));

    if (PlatformUtil.isWeb()) {
      list.add(Container(
        margin: const EdgeInsets.all(Base.BASE_PADDING),
        child: InkWell(
          onTap: () async {
            var pubKey = await js.getPublicKeyAsync();
            if (StringUtil.isNotBlank(pubKey)) {
              if (kDebugMode) {
                BotToast.showText(text: pubKey);
                print("PUBLIC KEY: " + pubKey);
              }
              doLogin(pubKey, true, false);
            } else {
              BotToast.showText(text: "Invalid public key");
            }
          },
          child: Container(
            height: 36,
            color: themeData.primaryColor,
            alignment: Alignment.center,
            child: const Text(
              "Login with Extension",
              style: TextStyle(
                fontFamily: 'Montserrat',
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ));
    }

    // list.add(Divider());
    list.add(Container(
      margin: const EdgeInsets.all(Base.BASE_PADDING),
      child: InkWell(
        onTap: () {
          generatePK();
          doLogin(controller.text, false, true);
        },
        child: Container(
          height: 40,
          color: Colors.deepPurple,
          alignment: Alignment.center,
          child: Text(
            s.Generate_a_new_private_key,
            style: const TextStyle(
              fontFamily: 'Montserrat',
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    ));
    //
    // mainList.add(Container(
    //   margin: const EdgeInsets.only(bottom: 100),
    //   child: GestureDetector(
    //     onTap: generatePK,
    //     child: Text(
    //       s.Generate_a_new_private_key,
    //       style: TextStyle(
    //         color: mainColor,
    //         decoration: TextDecoration.underline,
    //       ),
    //     ),
    //   ),
    // ));
    if (PlatformUtil.isWeb()) {
      var github = Image.asset("assets/imgs/github.png", width: 200);
      list.add(MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
              onTap: () {
                var url = Uri.parse(
                    "https://github.com/frnandu/yana/releases");
                launchUrl(url, mode: LaunchMode.externalApplication);
              },
              child: github)));

      var obtainium = Image.asset("assets/imgs/obtainium.png", width: 200);
      list.add(MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
              onTap: () {
                var url = Uri.parse("https://github.com/ImranR98/Obtainium");
                launchUrl(url, mode: LaunchMode.externalApplication);
              },
              child: obtainium)));

      // var f_droid = Image.asset(
      //   "assets/imgs/f-droid.png",
      //     width: 200
      // );
      // list.add(MouseRegion(
      //                         cursor: SystemMouseCursors.click,
      //                         child: GestureDetector(onTap: () {
      //   var url = Uri.parse(
      //       "TODO");
      //   launchUrl(url, mode: LaunchMode.externalApplication);
      // }, child: f_droid)));
    }
    return Scaffold(
      backgroundColor: const Color(0xff281237) ,
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
                children: list,
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
              child: Text(I18n.of(context).Searching_relays)),
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

  void doLogin(String key,bool pubOnly, bool newKey) {
    if (StringUtil.isBlank(key)) {
      BotToast.showText(text: I18n.of(context).Private_key_is_null);
      return;
    }
    showLoaderDialog(context);

    try {
      bool isPublic = pubOnly || Nip19.isPubkey(key);
      if (Nip19.isPubkey(key) || Nip19.isPrivateKey(key)) {
        key = Nip19.decode(key);
      }
      settingProvider.addAndChangeKey(key, !isPublic, updateUI: false);
      if (!newKey) {
        var tempNostr = Nostr(privateKey: !isPublic?key:null, publicKey: isPublic?key:null);

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
        var alreadyClosed = false;

        tempNostr!.addInitQuery([filter.toJson()], (event) {
          if (tempNostr!=null) {
            LoginRouter.handleRemoteRelays(event, tempNostr!.privateKey!);
          }
          getNostrAndClose(alreadyClosed, key, !isPublic);
          alreadyClosed = true;
        });
        Future.delayed(Duration(seconds: 5), () {
          getNostrAndClose(alreadyClosed, key, !isPublic);
        });
      } else {
        getNostrAndClose(false, key, !isPublic);
      }
    } catch (e) {
      BotToast.showText(text: e.toString());
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

  void getNostrAndClose(bool alreadyClosed, String key, bool isPrivate) async {
    if (!alreadyClosed) {
      nostr = await relayProvider.genNostr(privateKey: isPrivate? key: null, publicKey: isPrivate?null:key);
      Navigator.of(context, rootNavigator: true).pop();
      settingProvider.notifyListeners();

      firstLogin = true;
      indexProvider.setCurrentTap(IndexTaps.FOLLOW);
    }
  }
}
