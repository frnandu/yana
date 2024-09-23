import 'package:bech32/bech32.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yana/nostr/nip19/nip19.dart';
import 'package:yana/utils/base.dart';
import 'package:yana/main.dart';

import '../../ui/appbar4stack.dart';
import '../../i18n/i18n.dart';

class KeyBackupRouter extends StatefulWidget {
  const KeyBackupRouter({super.key});

  @override
  State<StatefulWidget> createState() {
    return _KeyBackupRouter();
  }
}

class _KeyBackupRouter extends State<KeyBackupRouter> {

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
      // title: appbarTitle,
    );

    List<Widget> list = [];
    list.add(Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: const Text(
        "Public key",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
    ));
    list.add(Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Text(
        Nip19.encodePubKey(loggedUserSigner!.getPublicKey()),
        style: const TextStyle(
          fontWeight: FontWeight.normal,
          fontSize: 16,
        ),
      ),
    ));
    list.add(Container(
      margin: const EdgeInsets.all(Base.BASE_PADDING),
      child: InkWell(
        onTap: copyPublic,
        child: Container(
          height: 36,
          color: mainColor,
          alignment: Alignment.center,
          child: const Text(
            "Copy public key",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    ));

    list.add(const SizedBox(height: 40,));

    list.add(Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Text(
        s.Backup_and_Safety_tips,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
    ));

    list.add(Container(
      margin: const EdgeInsets.all(Base.BASE_PADDING),
      child: InkWell(
        onTap: copyPrivate,
        child: Container(
          height: 36,
          color: mainColor,
          alignment: Alignment.center,
          child: const Text(
            "Copy private key",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    ));

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
                child: SizedBox(
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
            child: SizedBox(
              width: mediaDataCache.size.width,
              child: appBar,
            ),
          ),
        ],
      ),
    );
  }

  void copyPrivate() {
    // if (!checkTips()) {
    //   return;
    // }
    if (settingProvider.isPrivateKey) {
      var pk = settingProvider.key;
      var nip19Key = Nip19.encodePrivateKey(pk!);
      doCopy(nip19Key);
    }
  }

  void copyPublic() {
    doCopy(Nip19.encodePubKey(loggedUserSigner!.getPublicKey()));
  }

  void doCopy(String key) {
    Clipboard.setData(ClipboardData(text: key)).then((_) {
      EasyLoading.showSuccess(I18n.of(context).key_has_been_copied, dismissOnTap: true, duration: const Duration(seconds: 5));
    });
  }
}
