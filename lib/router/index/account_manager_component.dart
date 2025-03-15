import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:ndk/ndk.dart';
import 'package:ndk_amber/data_layer/repositories/signers/amber_event_signer.dart';
import 'package:provider/provider.dart';
import 'package:yana/provider/setting_provider.dart';
import 'package:yana/ui/name_component.dart';
import 'package:yana/ui/point_component.dart';
import 'package:yana/utils/router_util.dart';

import '/js/js_helper.dart' as js;
import '../../i18n/i18n.dart';
import '../../main.dart';
import '../../nostr/client_utils/keys.dart';
import '../../nostr/nip07/extension_event_signer.dart';
import '../../nostr/nip19/nip19.dart';
import '../../provider/data_util.dart';
import '../../ui/confirm_dialog.dart';
import '../../utils/base.dart';
import '../../utils/platform_util.dart';
import '../../utils/router_path.dart';
import '../../utils/string_util.dart';
import 'index_drawer_content.dart';

class AccountsComponent extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return AccountsState();
  }
}

class AccountsState extends State<AccountsComponent> {
  @override
  Widget build(BuildContext context) {
    var s = I18n.of(context);
    var _settingProvider = Provider.of<SettingProvider>(context);
    var privateKeyMap = _settingProvider.keyMap;

    var themeData = Theme.of(context);
    var hintColor = themeData.hintColor;
    var btnTextColor = themeData.textTheme.bodyMedium!.color;

    List<Widget> list = [];
    list.add(Container(
      padding: const EdgeInsets.only(
        top: Base.BASE_PADDING_HALF,
        bottom: Base.BASE_PADDING_HALF,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            width: 1,
            color: hintColor,
          ),
        ),
      ),
      child: IndexDrawerItem(
        iconData: Icons.supervisor_account,
        name: s.Accounts,
        onTap: () {},
      ),
    ));

    privateKeyMap.forEach((key, value) {
      var index = int.tryParse(key);
      bool isPrivate = _settingProvider.keyIsPrivateMap[key] ?? true;
      if (index == null) {
        log("parse index key error");
        return;
      }
      list.add(AccountManagerItemComponent(
        index: index,
        privateKey: isPrivate ? value : null,
        publicKey: !isPrivate ? value : null,
        isCurrent: _settingProvider.privateKeyIndex == index,
        onLoginTap: onLoginTap,
        onLogoutTap: (index) {
          AccountsState.onLogoutTap(index, context: context);
        },
      ));
    });

    list.add(Container(
      margin: const EdgeInsets.only(
        top: Base.BASE_PADDING_HALF,
        bottom: Base.BASE_PADDING_HALF,
      ),
      padding: const EdgeInsets.only(
        left: Base.BASE_PADDING * 2,
        right: Base.BASE_PADDING * 2,
      ),
      width: double.maxFinite,
      child: TextButton(
        onPressed: addAccount,
        style: ButtonStyle(
          side: MaterialStateProperty.all(BorderSide(
            width: 1,
            color: hintColor.withOpacity(0.4),
          )),
        ),
        child: Text(
          s.Add_Account,
          style: TextStyle(color: btnTextColor),
        ),
      ),
    ));

    return Container(
      // height: 200,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: list,
      ),
    );
  }

  Future<void> addAccount() async {
    RouterUtil.router(context, RouterPath.LOGIN);
  }

  bool addAccountCheck(BuildContext p1, String privateKey) {
    if (StringUtil.isNotBlank(privateKey)) {
      if (Nip19.isPrivateKey(privateKey)) {
        privateKey = Nip19.decode(privateKey);
      }

      // try to gen publicKey check the formate
      try {
        getPublicKey(privateKey);
      } catch (e) {
        EasyLoading.show(status: I18n.of(context).Wrong_Private_Key_format, maskType: EasyLoadingMaskType.black);
        return false;
      }
    }

    return true;
  }

  static void doLogin() async {
    EasyLoading.show(status: "Logging in...", maskType: EasyLoadingMaskType.black, dismissOnTap: true);

    String? key = settingProvider.key;
    bool isPrivate = settingProvider.isPrivateKey;
    String publicKey = isPrivate ? getPublicKey(key!) : key!;
    EventSigner eventSigner = settingProvider.isExternalSignerKey
        ? AmberEventSigner(publicKey: publicKey, amberFlutterDS: amberFlutterDS)
        : isPrivate || !PlatformUtil.isWeb()
            ? Bip340EventSigner(privateKey: isPrivate ? key : null, publicKey: publicKey)
            : Nip07EventSigner(await js.getPublicKeyAsync());
    await ndk.destroy();
    // ndk = Ndk(
    //     NdkConfig(
    //       eventVerifier: eventVerifier,
    //       cache: cacheManager,
    //       eventOutFilters:  [filterProvider],
    //       logLevel: logLevel
    //     ));
    ndk.accounts.loginExternalSigner(signer: eventSigner);

    await followEventProvider.loadCachedFeed();
    initRelays(newKey: false);
    notificationsProvider.notifyListeners();
    nwcProvider.init();
    settingProvider.notifyListeners();
    EasyLoading.dismiss();
  }

  void onLoginTap(int index) {
    if (settingProvider.privateKeyIndex != index) {
      EasyLoading.show(status: "Logging out...", maskType: EasyLoadingMaskType.black);
      clearCurrentMemInfo();
      ndk.destroy().then((a) {
        ndk = Ndk.emptyBootstrapRelaysConfig();
        settingProvider.privateKeyIndex = index;

        // signOut complete
        if (settingProvider.key != null) {
          // use next privateKey to login
          doLogin();
          settingProvider.notifyListeners();
          RouterUtil.back(context);
        }
      });
    }
  }

  static void onLogoutTap(int index, {bool routerBack = true, required BuildContext context}) {
    var oldIndex = settingProvider.privateKeyIndex;
    clearLocalData(index);
    nwcProvider.disconnect();
    if (oldIndex == index) {
      clearCurrentMemInfo();
      if (settingProvider.keyMap.isNotEmpty) {
        settingProvider.privateKeyIndex = int.tryParse(settingProvider.keyMap.keys.first);
        if (settingProvider.key != null) {
          // use next privateKey to login
          doLogin();
          settingProvider.notifyListeners();
          RouterUtil.back(context);
        }
      } else {
        ndk.destroy().then((a) {
          ndk = Ndk.emptyBootstrapRelaysConfig();
        });
      }
    }

    settingProvider.notifyListeners();
    if (routerBack && context != null) {
      RouterUtil.back(context);
    }
  }

  static void clearCurrentMemInfo() {
    sharedPreferences.remove(DataKey.NOTIFICATIONS_TIMESTAMP);
    sharedPreferences.remove(DataKey.FEED_POSTS_TIMESTAMP);
    sharedPreferences.remove(DataKey.FEED_REPLIES_TIMESTAMP);
    notificationsProvider.clear();
    newNotificationsProvider.clear();
    followEventProvider.clear();
    followNewEventProvider.clear();
    dmProvider.clear();
    noticeProvider.clear();
    contactListProvider.clear();
    cacheManager.removeAllEvents();

    eventReactionsProvider.clear();
    linkPreviewDataProvider.clear();
  }

  static void clearLocalData(int index) {
    // remove private key
    settingProvider.removeKey(index);
    // cacheManager.removeAllEvents();
    // clear local db
    // DMSessionInfoDB.deleteAll(index);
    // EventDB.deleteAll(index);
    // MetadataDB.deleteAll(); // MetadataDB don't delete here, but delete in setting
  }
}

class AccountManagerItemComponent extends StatefulWidget {
  final bool isCurrent;

  final int index;

  final String? privateKey;
  final String? publicKey;

  Function(int)? onLoginTap;

  Function(int)? onLogoutTap;

  AccountManagerItemComponent({
    super.key,
    required this.isCurrent,
    required this.index,
    this.privateKey,
    this.publicKey,
    this.onLoginTap,
    this.onLogoutTap,
  });

  @override
  State<StatefulWidget> createState() {
    return _AccountManagerItemComponent();
  }
}

class _AccountManagerItemComponent extends State<AccountManagerItemComponent> {
  static const double IMAGE_WIDTH = 26;

  static const double LINE_HEIGHT = 44;

  String? pubkey;

  @override
  void initState() {
    super.initState();
    try {
      pubkey = StringUtil.isBlank(widget.publicKey) && StringUtil.isNotBlank(widget.privateKey) ? getPublicKey(widget.privateKey!) : widget.publicKey!;
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    var themeData = Theme.of(context);
    Color? cardColor = themeData.cardColor;
    if (cardColor == Colors.white) {
      cardColor = Colors.grey[300];
    }

    return FutureBuilder<Metadata?>(
        future: metadataProvider.getMetadata(pubkey!),
        builder: (context, snapshot) {
          var metadata = snapshot.data;
          Color currentColor = Colors.green;
          List<Widget> list = [];
          // if (metadata==null) {
          //   return Container();
          // }
          String? nip19PubKey;
          try {
            nip19PubKey = pubkey != null ? Nip19.encodePubKey(pubkey!) : null;
          } catch (e) {
            return Container();
          }

          Widget? imageWidget;

          String? url = metadata != null && StringUtil.isNotBlank(metadata.picture) ? metadata.picture : StringUtil.robohash(pubkey!);

          if (url != null) {
            imageWidget = CachedNetworkImage(
              imageUrl: url,
              width: IMAGE_WIDTH,
              height: IMAGE_WIDTH,
              fit: BoxFit.cover,
              placeholder: (context, url) => const CircularProgressIndicator(),
              errorWidget: (context, url, error) => const Icon(Icons.error),
              cacheManager: localCacheManager,
            );
          }
          list.add(Container(
            width: 24,
            alignment: Alignment.centerLeft,
            child: Container(
                width: 15,
                margin: const EdgeInsets.only(right: 10),
                child: widget.isCurrent
                    ? PointComponent(
                        width: 15,
                        color: currentColor,
                      )
                    : GestureDetector(
                        onTap: onLoginTap,
                        child: Icon(Icons.login, color: themeData.disabledColor),
                      )),
          ));
          list.add(Container(
            width: IMAGE_WIDTH,
            height: IMAGE_WIDTH,
            margin: const EdgeInsets.only(left: 10),
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(IMAGE_WIDTH / 2),
              color: Colors.grey,
            ),
            child: imageWidget,
          ));

          list.add(Container(
            margin: const EdgeInsets.only(left: 5, right: 5),
            child: NameComponent(
              pubkey: pubkey!,
              fontColor: widget.isCurrent ? null : themeData.hintColor,
              metadata: metadata,
            ),
          ));
          if (settingProvider.isExternalSignerKeyIndex(widget.index)) {
            list.add(Container(
                width: 50,
                alignment: Alignment.centerLeft,
                child: const Text(
                  "(external)",
                  style: TextStyle(fontWeight: FontWeight.w100, fontSize: 10),
                )));
          } else if (!settingProvider.isPrivateKeyIndex(widget.index)) {
            list.add(Container(
                width: 50,
                alignment: Alignment.centerLeft,
                child: const Text(
                  "(read only)",
                  style: TextStyle(fontWeight: FontWeight.w100, fontSize: 10),
                )));
          }
          list.add(Expanded(
              child: Container(
            padding: const EdgeInsets.only(
              left: Base.BASE_PADDING_HALF,
              right: Base.BASE_PADDING_HALF,
              top: 4,
              bottom: 4,
            ),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              nip19PubKey!,
              overflow: TextOverflow.ellipsis,
            ),
          )));

          list.add(GestureDetector(
            onTap: onLogout,
            child: Container(
              padding: const EdgeInsets.only(left: 5),
              height: LINE_HEIGHT,
              child: Icon(Icons.close, color: widget.isCurrent ? null : themeData.disabledColor),
            ),
          ));

          return GestureDetector(
            onTap: onLoginTap,
            behavior: HitTestBehavior.translucent,
            child: Container(
              height: LINE_HEIGHT,
              width: double.maxFinite,
              padding: const EdgeInsets.only(
                left: Base.BASE_PADDING * 2,
                right: Base.BASE_PADDING * 2,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: list,
              ),
            ),
          );
        });
  }

  void onLogout() async {
    bool? result = await ConfirmDialog.show(context, "Confirm remove account");
    if (result != null && result) {
      if (widget.onLogoutTap != null) {
        widget.onLogoutTap!(widget.index);
      }
    }
  }

  void onLoginTap() {
    if (widget.onLoginTap != null) {
      widget.onLoginTap!(widget.index);
    }
  }
}
