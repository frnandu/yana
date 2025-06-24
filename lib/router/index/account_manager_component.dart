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
import 'package:go_router/go_router.dart';

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
import '../../config/app_features.dart'; // Added for AppFeatures

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
    var isDark = themeData.brightness == Brightness.dark;
    var bgColor = isDark ? Colors.black : Color(0xFF181818);
    var titleColor = Colors.white;
    var dividerColor = Colors.white.withOpacity(0.08);
    var addProfileColor = Colors.white.withOpacity(0.5);

    List<Widget> profileWidgets = [];
    privateKeyMap.forEach((key, value) {
      var index = int.tryParse(key);
      bool isPrivate = _settingProvider.keyIsPrivateMap[key] ?? true;
      if (index == null) {
        log("parse index key error");
        return;
      }
      profileWidgets.add(AccountManagerItemComponent(
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

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Switch Profile',
              style: TextStyle(
                color: titleColor,
                fontWeight: FontWeight.bold,
                fontSize: 22,
                fontFamily: 'Geist',
              ),
            ),
            const SizedBox(height: 24),
            ...profileWidgets,
            const SizedBox(height: 8),
            Divider(
                color: dividerColor, thickness: 1, indent: 24, endIndent: 24),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: addAccount,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF232323),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Icon(Icons.add_circle_outline,
                        color: addProfileColor, size: 24),
                    const SizedBox(width: 16),
                    Text(
                      'Add Account',
                      style: TextStyle(
                        color: addProfileColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Geist',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> addAccount() async {
    context.push(RouterPath.LOGIN);
  }

  bool addAccountCheck(BuildContext p1, String privateKey) {
    if (StringUtil.isNotBlank(privateKey)) {
      if (Nip19.isPrivateKey(privateKey)) {
        privateKey = Nip19.decode(privateKey);
      }
      try {
        getPublicKey(privateKey);
      } catch (e) {
        EasyLoading.show(
            status: I18n.of(context).Wrong_Private_Key_format,
            maskType: EasyLoadingMaskType.black);
        return false;
      }
    }
    return true;
  }

  void onLoginTap(int index) {
    if (settingProvider.privateKeyIndex != index) {
      EasyLoading.show(
          status: "Logging out...", maskType: EasyLoadingMaskType.black);
      clearCurrentMemInfo();
      ndk.requests.closeAllSubscription();
      ndk.accounts.logout();
      settingProvider.privateKeyIndex = index;

      // signOut complete
      if (settingProvider.key != null) {
        // use next privateKey to login
        doLogin(settingProvider.key!, settingProvider.isPublicKey, false,
            settingProvider.isExternalSignerKey);
        settingProvider.notifyListeners();
        context.pop();
      }
    }
  }

  static void onLogoutTap(int index,
      {bool routerBack = true, required BuildContext context}) {
    var oldIndex = settingProvider.privateKeyIndex;
    clearLocalData(index);
    if (AppFeatures.enableWallet) {
      nwcProvider?.disconnect();
    }
    if (oldIndex == index) {
      clearCurrentMemInfo();
      ndk.requests.closeAllSubscription();
      ndk.accounts.logout();
      if (settingProvider.keyMap.isNotEmpty) {
        settingProvider.privateKeyIndex =
            int.tryParse(settingProvider.keyMap.keys.first);
        if (settingProvider.key != null) {
          // use next privateKey to login
          doLogin(settingProvider.key!, settingProvider.isPublicKey, false,
              settingProvider.isExternalSignerKey);
          settingProvider.notifyListeners();
          context.pop();
        }
      }
    }

    settingProvider.notifyListeners();
    if (routerBack && context != null) {
      context.pop();
    }
  }

  static void clearCurrentMemInfo() {
    sharedPreferences.remove(DataKey.NOTIFICATIONS_TIMESTAMP);
    sharedPreferences.remove(DataKey.FEED_POSTS_TIMESTAMP);
    sharedPreferences.remove(DataKey.FEED_REPLIES_TIMESTAMP);
    if (AppFeatures.enableNotifications) {
      notificationsProvider?.clear();
      newNotificationsProvider?.clear();
    }
    followEventProvider?.clear();
    followNewEventProvider?.clear();
    dmProvider?.clear();
    noticeProvider.clear();
    contactListProvider?.clear();
    // cacheManager.removeAllEvents();

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
  static const double AVATAR_SIZE = 48;
  String? pubkey;

  @override
  void initState() {
    super.initState();
    try {
      pubkey = StringUtil.isBlank(widget.publicKey) &&
              StringUtil.isNotBlank(widget.privateKey)
          ? getPublicKey(widget.privateKey!)
          : widget.publicKey!;
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    var themeData = Theme.of(context);
    var isDark = themeData.brightness == Brightness.dark;
    var nameColor = Colors.white;
    var pubkeyColor = Colors.white.withOpacity(0.5);
    var borderColor =
        widget.isCurrent ? const Color(0xFFFFD600) : Colors.transparent;
    var bgColor = isDark ? const Color(0xFF232323) : const Color(0xFF232323);

    return FutureBuilder<Metadata?>(
        future: metadataProvider.getMetadata(pubkey!),
        builder: (context, snapshot) {
          var metadata = snapshot.data;
          String? url =
              metadata != null && StringUtil.isNotBlank(metadata.picture)
                  ? metadata.picture
                  : StringUtil.robohash(pubkey!);

          String displayName = metadata?.name ?? 'User';
          if (StringUtil.isBlank(displayName)) {
            displayName = 'User';
          }

          String npub = Nip19.encodePubKey(pubkey!);
          String truncatedNpub =
              "${npub.substring(0, 10)}...${npub.substring(npub.length - 10)}";

          return GestureDetector(
            onTap: onLoginTap,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor, width: 2),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: AVATAR_SIZE,
                    height: AVATAR_SIZE,
                    child: ClipOval(
                      child: url != null
                          ? CachedNetworkImage(
                              imageUrl: url,
                              width: AVATAR_SIZE,
                              height: AVATAR_SIZE,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: Colors.grey[800],
                              ),
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.error),
                              cacheManager: localCacheManager,
                            )
                          : Container(color: Colors.grey[800]),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayName,
                          style: TextStyle(
                            color: nameColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            fontFamily: 'Geist',
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          truncatedNpub,
                          style: TextStyle(
                            color: pubkeyColor,
                            fontSize: 14,
                            fontFamily: 'Geist',
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (widget.isCurrent)
                    const Padding(
                      padding: EdgeInsets.only(right: 8.0),
                      child: Icon(Icons.check_circle,
                          color: Color(0xFFFFD600), size: 24),
                    ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'logout' && widget.onLogoutTap != null) {
                        widget.onLogoutTap!(widget.index);
                      }
                    },
                    itemBuilder: (BuildContext context) =>
                        <PopupMenuEntry<String>>[
                      const PopupMenuItem<String>(
                        value: 'logout',
                        child: Text('Logout'),
                      ),
                    ],
                    icon: const Icon(Icons.more_horiz, color: Colors.white54),
                    color: const Color(0xFF2c2c2c),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  void onLoginTap() {
    if (widget.onLoginTap != null) {
      widget.onLoginTap!(widget.index);
    }
  }
}
