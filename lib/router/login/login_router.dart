import 'package:amberflutter/amberflutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:go_router/go_router.dart';
import 'package:ndk/ndk.dart';
import 'package:ndk_amber/data_layer/repositories/signers/amber_event_signer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yana/utils/platform_util.dart';
import 'package:yana/utils/router_path.dart';

import '/js/js_helper.dart' as js;
import '../../i18n/i18n.dart';
import '../../main.dart';
import '../../nostr/client_utils/keys.dart';
import '../../nostr/nip07/extension_event_signer.dart';
import '../../nostr/nip19/nip19.dart';
import '../../provider/data_util.dart';
import '../../utils/base.dart' as base;
import '../../utils/index_taps.dart';
import '../../utils/string_util.dart';
import '../index/account_manager_component.dart';
import '../../config/app_features.dart'; // Added for AppFeatures

class LoginRouter extends StatefulWidget {
  final bool canGoBack;

  const LoginRouter({super.key, required this.canGoBack});

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

    var logoWidget = Image.asset("assets/imgs/logo/logo-with-name.png",
        width: 200, height: 200, isAntiAlias: true);

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
    //       fontFamily: 'Geist',
    //       color: Colors.white,
    //       fontSize: 30,
    //       fontWeight: FontWeight.bold,
    //     ),
    //   ),
    // ));

    var suffixIcons =
        // Row(children: [
        GestureDetector(
      onTap: () {
        setState(() {
          obscureText = !obscureText;
        });
      },
      child: Icon(obscureText ? Icons.visibility : Icons.visibility_off),
      // ),
      //   GestureDetector(
      //     onTap: () {
      //     },
      //     child: Image.asset("assets/imgs/scan.png", width: 32, height: 32)
      //   )
      // ]
    );
    list.add(TextField(
      controller: controller,
      decoration: InputDecoration(
        //border: InputBorder.none,
        hintText: s.Input_for_login,
        fillColor: Colors.white,
        suffixIcon: suffixIcons,
      ),
      style: const TextStyle(color: Colors.white),
      obscureText: obscureText,
    ));

    list.add(Container(
      margin: const EdgeInsets.all(base.Base.BASE_PADDING_HALF),
      child: InkWell(
        onTap: () async {
          await base.doLogin(controller.text, false, false, false);
        },
        child: Container(
          height: 42,
          color: themeData.primaryColor,
          alignment: Alignment.center,
          child: Text(
            s.Login,
            style: const TextStyle(
              fontFamily: 'Geist',
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    ));

    if (PlatformUtil.isAndroid()) {
      list.add(Container(
        margin: const EdgeInsets.all(base.Base.BASE_PADDING_HALF),
        child: InkWell(
          onTap: () async {
            if (isExternalSignerInstalled) {
              await doLoginExternalSigner();
            } else {
              var url = Uri.parse("https://github.com/greenart7c3/Amber");
              launchUrl(url, mode: LaunchMode.externalApplication);
            }
          },
          child: Container(
            height: 42,
            color: Colors.orange,
            alignment: Alignment.center,
            child: Text(
              s.LoginWithExternalSigner,
              style: const TextStyle(
                fontFamily: 'Geist',
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ));
    }

    if (PlatformUtil.isWeb()) {
      list.add(Container(
        margin: const EdgeInsets.all(base.Base.BASE_PADDING_HALF),
        child: InkWell(
          onTap: () async {
            var pubKey = await js.getPublicKeyAsync();
            if (StringUtil.isNotBlank(pubKey)) {
              if (kDebugMode) {
                EasyLoading.show(status: pubKey);
                print("PUBLIC KEY: " + pubKey);
              }
              await base.doLogin(pubKey, true, false, false);
            } else {
              EasyLoading.show(status: "Invalid public key");
            }
          },
          child: Container(
            height: 42,
            color: themeData.primaryColor,
            alignment: Alignment.center,
            child: const Text(
              "Login with Extension",
              style: TextStyle(
                fontFamily: 'Geist',
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ));
    }

    // list.add(Divider());
    list.add(Container(
      margin: const EdgeInsets.all(base.Base.BASE_PADDING_HALF),
      child: InkWell(
        onTap: () async {
          generatePK();
          await base.doLogin(controller.text, false, true, false);
        },
        child: Container(
          height: 42,
          color: Colors.deepPurple,
          alignment: Alignment.center,
          child: Text(
            s.Generate_a_new_private_key,
            style: const TextStyle(
              fontFamily: 'Geist',
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    ));
    if (widget.canGoBack) {
      list.add(Container(
        margin: const EdgeInsets.all(base.Base.BASE_PADDING),
        child: InkWell(
          onTap: () async {
            context.go(RouterPath.INDEX);
          },
          child: Container(
            height: 40,
            color: Colors.grey,
            alignment: Alignment.center,
            child: const Text(
              "<< cancel",
              style: TextStyle(
                fontFamily: 'Geist',
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ));
    }
    if (PlatformUtil.isWeb()) {}
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

  Future<void> doLoginExternalSigner() async {
    final amber = Amberflutter();
    final key = await amber.getPublicKey(
      permissions: const [
        Permission(type: 'nip04_decrypt'),
      ],
    );
    if (key['signature'] == null) return;
    AccountsState.clearCurrentMemInfo();

    base.doLogin(key['signature'], true, false, true);
  }
}
