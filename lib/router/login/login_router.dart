import 'package:bot_toast/bot_toast.dart';
import 'package:dart_ndk/nips/nip65/nip65.dart';
import 'package:dart_ndk/nips/nip65/read_write_marker.dart';
import 'package:dart_ndk/pubkey_mapping.dart';
import 'package:dart_ndk/read_write.dart';
import 'package:dart_ndk/relay_manager.dart';
import 'package:dart_ndk/relay_set.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yana/utils/platform_util.dart';

import '/js/js_helper.dart' as js;
import '../../i18n/i18n.dart';
import '../../main.dart';
import '../../nostr/client_utils/keys.dart';
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
    var maxWidth = mediaDataCache.size.width;
    var mainWidth = maxWidth * 0.8;
    if (PlatformUtil.isTableMode()) {
      if (mainWidth > 550) {
        mainWidth = 550;
      }
    }

    var logoWidget = Image.asset(
      "assets/imgs/logo/logo-with-name.png",
      width: 200,
      height: 200,
    );

    // var logoWidget = SvgPicture.asset(
    //   width: 200,
    //   height: 200,
    //   "assets/imgs/logo/logo-name.svg",
    //  color: Color.fromARGB(255, 75, 75, 75),
    //   //
    //   // colorFilter: ColorFilter.mode(Colors.red, BlendMode.srcIn),
    // );

    // var logoWidget =  Stack(children: [
    //   Container(
    //   width: 200,
    //   height: 200,
    //   child: SvgPicture.asset(
    //     "assets/imgs/logo/logo-name.svg",
    //     fit: BoxFit.cover,
    //   ),)]);

    List<Widget> list = [];
    list.add(logoWidget);
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
        onTap: () async {
          await doLogin(controller.text, false, false);
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
              await doLogin(pubKey, true, false);
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
        onTap: () async {
          generatePK();
          await doLogin(controller.text, false, true);
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
                var url = Uri.parse("https://github.com/frnandu/yana/releases");
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
      backgroundColor: const Color(0xff281237),
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

  Future<void> doLogin(String key, bool pubOnly, bool newKey) async {
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
      await settingProvider.addAndChangeKey(key, !isPublic, updateUI: false);
      if (!newKey) {
        nostr = Nostr(
            privateKey: !isPublic ? key : null,
            publicKey: !isPublic ? null : key);

        initRelayManager(false, isPublic ? key : getPublicKey(key));
        var alreadyClosed = true;
        Future.delayed(const Duration(seconds: 10), () {
          initRelayManager(alreadyClosed, isPublic ? key : getPublicKey(key));
        });
      } else {
        initRelayManager(false, isPublic ? key : getPublicKey(key));
      }
    } catch (e) {
      BotToast.showText(text: e.toString());
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

  void initRelayManager(bool alreadyClosed, String publicKey) async {
    if (!alreadyClosed) {
      relayManager = RelayManager();
      await relayManager.init();
      await relayManager.connect();
      Nip65? nip65 = await relayManager.getSingleNip65(publicKey);
      if (nip65!=null) {
        createMyRelaySets(nip65);
      }
      await relayManager.connect(bootstrapRelays: nip65!=null? nip65.urls : RelayManager.DEFAULT_BOOTSTRAP_RELAYS);

      // nostr = await relayProvider.genNostr(
      //     privateKey: isPrivate ? key : null,
      //     publicKey: isPrivate ? null : key);
      Navigator.of(context, rootNavigator: true).pop();
      settingProvider.notifyListeners();

      firstLogin = true;
      indexProvider.setCurrentTap(IndexTaps.FOLLOW);
    }
  }
}
