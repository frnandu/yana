import 'dart:developer';

import 'package:bot_toast/bot_toast.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dart_ndk/db/user_relay_list.dart';
import 'package:dart_ndk/nips/nip01/metadata.dart';
import 'package:dart_ndk/nips/nip65/nip65.dart';
import 'package:dart_ndk/relay_manager.dart';
import 'package:flutter/material.dart';
import 'package:yana/ui/editor/text_input_dialog.dart';
import 'package:yana/ui/name_component.dart';
import 'package:yana/ui/point_component.dart';
import 'package:yana/provider/metadata_provider.dart';
import 'package:yana/provider/setting_provider.dart';
import 'package:yana/utils/router_util.dart';
import 'package:provider/provider.dart';

import '../../nostr/client_utils/keys.dart';
import '../../nostr/nip19/nip19.dart';
import '../../ui/confirm_dialog.dart';
import '../../utils/base.dart';
import '../../models/dm_session_info_db.dart';
import '../../models/event_db.dart';
import '../../i18n/i18n.dart';
import '../../main.dart';
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
        privateKey: isPrivate? value: null,
        publicKey: !isPrivate? value: null,
        isCurrent: _settingProvider.privateKeyIndex == index,
        onLoginTap: onLoginTap,
        onLogoutTap: (index) {
          onLogoutTap(index, context: context);
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
    String? key = await TextInputDialog.show(
        context, I18n.of(context).Input_account_private_key,
        valueCheck: addAccountCheck);
    if (StringUtil.isNotBlank(key)) {
      if (mounted) {
        var result = await ConfirmDialog.show(
            context, I18n.of(context).Add_account_and_login);
        if (result == true) {
          bool isPublic = Nip19.isPubkey(key!);
          if (isPublic || Nip19.isPrivateKey(key)) {
            key = Nip19.decode(key);
          }
          // logout current and login new
          var oldIndex = settingProvider.privateKeyIndex;
          var newIndex = await settingProvider.addAndChangeKey(key, !isPublic);
          if (oldIndex != newIndex) {
            clearCurrentMemInfo();
            doLogin();
            settingProvider.notifyListeners();
            RouterUtil.back(context);
          }
        }
      }
    }
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
        BotToast.showText(text: I18n.of(context).Wrong_Private_Key_format);
        return false;
      }
    }

    return true;
  }

  void doLogin() async {
    String? key = settingProvider.key;
    bool isPrivate = settingProvider.isPrivateKey;
    UserRelayList? userRelayList = await relayManager!.getSingleUserRelayList(isPrivate ? getPublicKey(key!): key!);
    await relayManager!.connect(bootstrapRelays: userRelayList!=null? userRelayList.urls : RelayManager.DEFAULT_BOOTSTRAP_RELAYS);

    // nostr = await relayProvider.genNostr(
    //     privateKey: isPrivate ? key : null, publicKey: isPrivate ? null : key);
  }

  void onLoginTap(int index) {
    if (settingProvider.privateKeyIndex != index) {
      clearCurrentMemInfo();
      nostr!.close();
      nostr = null;

      settingProvider.privateKeyIndex = index;

      // signOut complete
      if (settingProvider.key != null) {
        // use next privateKey to login
        doLogin();
        settingProvider.notifyListeners();
        RouterUtil.back(context);
      }
    }
  }

  static void onLogoutTap(int index,
      {bool routerBack = true, BuildContext? context}) async {
    var oldIndex = settingProvider.privateKeyIndex;
    clearLocalData(index);

    if (oldIndex == index) {
      clearCurrentMemInfo();
      nostr!.close();
      nostr = null;

      // signOut complete
      String? key = settingProvider.key;
      if (settingProvider.key != null) {
        // use next privateKey to login
        bool isPrivate = settingProvider.isPrivateKey;
        UserRelayList? userRelayList = await relayManager!.getSingleUserRelayList(isPrivate ? getPublicKey(key!): key!);
        await relayManager!.connect(bootstrapRelays: userRelayList!=null? userRelayList.urls : RelayManager.DEFAULT_BOOTSTRAP_RELAYS);
        //
        // nostr = await relayProvider.genNostr(
        //     privateKey: isPrivate ? key : null,
        //     publicKey: isPrivate ? null : key);
      }
    }

    settingProvider.notifyListeners();
    if (routerBack && context != null) {
      RouterUtil.back(context);
    }
  }

  static void clearCurrentMemInfo() {
    notificationsProvider.clear();
    followEventProvider.clear();
    dmProvider.clear();
    noticeProvider.clear();
    contactListProvider.clear();

    eventReactionsProvider.clear();
    linkPreviewDataProvider.clear();
    relayProvider.clear();
  }

  static void clearLocalData(int index) {
    // remove private key
    settingProvider.removeKey(index);
    // clear local db
    DMSessionInfoDB.deleteAll(index);
    EventDB.deleteAll(index);
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

  late String pubkey;

  @override
  void initState() {
    super.initState();
    pubkey = StringUtil.isBlank(widget.publicKey) &&
            StringUtil.isNotBlank(widget.privateKey)
        ? getPublicKey(widget.privateKey!)
        : widget.publicKey!;
  }

  @override
  Widget build(BuildContext context) {
    var themeData = Theme.of(context);
    Color? cardColor = themeData.cardColor;
    if (cardColor == Colors.white) {
      cardColor = Colors.grey[300];
    }

    return Selector<MetadataProvider, Metadata?>(
        builder: (context, metadata, child) {
      Color currentColor = Colors.green;
      List<Widget> list = [];

      var nip19PubKey = Nip19.encodePubKey(pubkey);

      Widget? imageWidget;

      String? url = metadata != null && StringUtil.isNotBlank(metadata.picture)
          ? metadata.picture
          : StringUtil.robohash(pubkey);

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
          child: widget.isCurrent
              ? PointComponent(
                  width: 15,
                  color: currentColor,
                )
              : null,
        ),
      ));

      list.add(Container(
        width: IMAGE_WIDTH,
        height: IMAGE_WIDTH,
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(IMAGE_WIDTH / 2),
          color: Colors.grey,
        ),
        child: imageWidget,
      ));

      list.add(Container(
        margin: EdgeInsets.only(left: 5, right: 5),
        child: NameComponent(
          pubkey: pubkey,
          metadata: metadata,
        ),
      ));

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
          nip19PubKey,
          overflow: TextOverflow.ellipsis,
        ),
      )));

      list.add(GestureDetector(
        onTap: onLogout,
        child: Container(
          padding: EdgeInsets.only(left: 5),
          height: LINE_HEIGHT,
          child: Icon(Icons.logout),
        ),
      ));

      return GestureDetector(
        onTap: onTap,
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
    }, selector: (context, _provider) {
      return _provider.getMetadata(pubkey);
    });
  }

  void onLogout() {
    if (widget.onLogoutTap != null) {
      widget.onLogoutTap!(widget.index);
    }
  }

  void onTap() {
    if (widget.onLoginTap != null) {
      widget.onLoginTap!(widget.index);
    }
  }
}
