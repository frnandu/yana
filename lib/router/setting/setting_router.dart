import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

// import 'package:flutter_font_picker/flutter_font_picker.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:local_auth/local_auth.dart';
import 'package:ndk/ndk.dart';
import 'package:ndk/shared/nips/nip01/helpers.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yana/nostr/relay_metadata.dart';
import 'package:yana/provider/filter_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:yana/router/index/account_manager_component.dart';
import 'package:yana/utils/platform_util.dart';
import 'package:yana/utils/when_stop_function.dart';

import '../../i18n/i18n.dart';
import '../../main.dart';
import '../../models/currency.dart';
import '../../provider/relay_provider.dart';
import '../../provider/setting_provider.dart';
import '../../ui/confirm_dialog.dart';
import '../../ui/enum_multi_selector_component.dart';
import '../../ui/enum_selector_component.dart';
import '../../utils/auth_util.dart';
import '../../utils/base_consts.dart';
import '../../utils/image_services.dart';
import '../../utils/locale_util.dart';
import '../../utils/rates.dart';
import '../../utils/router_path.dart';
import '../../utils/string_util.dart';
import '../../utils/theme_style.dart';
import 'package:yana/config/app_features.dart';

class SettingRouter extends StatefulWidget {
  Function indexReload;

  SettingRouter({
    super.key,
    required this.indexReload,
  });

  @override
  State<StatefulWidget> createState() {
    return _SettingRouter();
  }
}

class _SettingRouter extends State<SettingRouter> with WhenStopFunction {
  bool loadingGossipRelays = false;
  String? gossipStatus;
  int gossipCount = 0;
  int gossipTotal = 0;

  Uri OUTBOX_MODEL_INFO_URL =
      Uri.parse("https://github.com/frnandu/yana/blob/master/GOSSIP.md");

  @override
  Widget build(BuildContext context) {
    var themeData = Theme.of(context);
    var titleFontSize = themeData.textTheme.bodyLarge!.fontSize;
    var _settingProvider = Provider.of<SettingProvider>(context);
    var _relayProvider = Provider.of<RelayProvider>(context);
    var _filterProvider = Provider.of<FilterProvider>(context);

    var mainColor = themeData.primaryColor;
    var hintColor = themeData.hintColor;

    var s = I18n.of(context);

    initOpenList(s);
    init(s);
    initDefaultTabListTimeline(s);

    initThemeStyleList(s);
    initFontEnumList(s);
    initImageServiceList();
    initTranslateLanguages();

    List<Widget> list = [];

    // list.add(
    //   SettingGroupItemComponent(
    //     name: s.Language,
    //     value: getI18nList(_settingProvider.i18n, _settingProvider.i18nCC).name,
    //     onTap: pickI18N,
    //   ),
    // );
    // list.add(SettingGroupItemComponent(
    //   name: s.Image_Compress,
    //   value: getCompressList(settingProvider.imgCompress).name,
    //   onTap: pickImageCompressList,
    // ));
    // if (!PlatformUtil.isPC()) {
    //   list.add(SettingGroupItemComponent(
    //     name: s.Privacy_Lock,
    //     value: getLockOpenList(settingProvider.lockOpen).name,
    //     onTap: pickLockOpenList,
    //   ));
    // }
    // List<EnumObj> defaultTabList = defaultTabListTimeline!;
    // list.add(SettingGroupItemComponent(
    //   name: s.Default_tab,
    //   value: getDefaultTab(defaultTabList, settingProvider.defaultTab).name,
    //   onTap: () {
    //     pickDefaultTab(defaultTabList);
    //   },
    // ));

    // list.add(SettingGroupTitleComponent(iconData: Icons.palette, title: "UI"));
    // list.add(
    //   SettingGroupItemComponent(
    //     name: s.Theme_Style,
    //     value: getThemeStyle(_settingProvider.themeStyle).name,
    //     onTap: pickThemeStyle,
    //   ),
    // );
    // list.add(SettingGroupItemComponent(
    //   name: s.Font_Family,
    //   value: getFontEnumResult(settingProvider.fontFamily),
    //   onTap: pickFontEnum,
    // ));
    // list.add(SettingGroupItemComponent(
    //   name: s.Font_Size,
    //   value: getFontSize(settingProvider.fontSize).name,
    //   onTap: pickFontSize,
    // ));
    // list.add(SettingGroupItemComponent(
    //   name: s.Web_Appbar,
    //   value: getOpenList(settingProvider.webviewAppbarOpen).name,
    //   onTap: pickWebviewAppbar,
    // ));
    // if (!PlatformUtil.isPC()) {
    //   list.add(SettingGroupItemComponent(
    //     name: s.Table_Mode,
    //     value: getOpenMode(settingProvider.tableMode).name,
    //     onTap: pickOpenMode,
    //   ));
    // }

    // list.add(
    //     SettingGroupTitleComponent(iconData: Icons.article, title: s.Global));
    // list.add(SettingGroupItemComponent(
    //   name: s.Link_preview,
    //   value: getOpenList(settingProvider.linkPreview).name,
    //   onTap: pickLinkPreview,
    // ));
    // if (!PlatformUtil.isPC()) {
    //   list.add(SettingGroupItemComponent(
    //     name: s.Video_preview,
    //     value: getOpenList(settingProvider.videoPreview).name,
    //     onTap: pickvideoPreview,
    //   ));
    // }
    // // list.add(SettingGroupItemComponent(
    // //   name: s.Image_service,
    // //   value: getImageServcie(settingProvider.imageService).name,
    // //   onTap: pickImageServcie,
    // // ));
    // list.add(SettingGroupItemComponent(
    //   name: s.Image_preview,
    //   value: getOpenList(settingProvider.imagePreview).name,
    //   onTap: pickImagePreview,
    // ));
    // if (!PlatformUtil.isPC()) {
    //   list.add(SettingGroupItemComponent(
    //     name: s.Forbid_video,
    //     value: getOpenList(settingProvider.videoPreview).name,
    //     onTap: pickVideoPreview,
    //   ));
    //   list.add(SettingGroupItemComponent(
    //     name: s.Translate,
    //     value: getOpenTranslate(settingProvider.openTranslate).name,
    //     onTap: pickOpenTranslate,
    //   ));
    //   if (settingProvider.openTranslate == OpenStatus.OPEN) {
    //     list.add(SettingGroupItemComponent(
    //       name: s.Translate_Source_Language,
    //       value: settingProvider.translateSourceArgs,
    //       onTap: pickTranslateSource,
    //     ));
    //     list.add(SettingGroupItemComponent(
    //       name: s.Translate_Target_Language,
    //       value: settingProvider.translateTarget,
    //       onTap: pickTranslateTarget,
    //     ));
    //   }
    // }
    // list.add(SettingGroupItemComponent(
    //   name: s.Broadcast_When_Boost,
    //   value: getOpenList(settingProvider.broadcaseWhenBoost).name,
    //   onTap: pickBroadcaseWhenBoost,
    // ));
    // list.add(SettingGroupItemComponent(
    //   name: s.Auto_Open_Sensitive_Content,
    //   value: getOpenListDefault(settingProvider.autoOpenSensitive).name,
    //   onTap: pickAutoOpenSensitive,
    // ));
    //
    // list.add(SettingGroupTitleComponent(iconData: Icons.source, title: s.Data));
    // list.add(SettingGroupItemComponent(
    //   name: s.Delete_Account,
    //   nameColor: Colors.red,
    //   onTap: askToDeleteAccount,
    // ));

    list.add(SliverToBoxAdapter(
      child: Container(
        height: 30,
      ),
    ));

    List<AbstractSettingsTile> interfaceTiles = [];
    interfaceTiles.add(SettingsTile.navigation(
      trailing: Text("English"),
      leading: const Icon(Icons.language),
      title: Text(s.Language),
      onPressed: (context) {
        pickI18N();
      },
    ));

    interfaceTiles.add(SettingsTile.switchTile(
        activeSwitchColor: themeData.primaryColor,
        onToggle: (value) {
          settingProvider.themeStyle = value
              ? ThemeStyle.AUTO
              : MediaQuery.of(context).platformBrightness == Brightness.dark
                  ? ThemeStyle.DARK
                  : ThemeStyle.LIGHT;
          widget.indexReload();
        },
        initialValue: settingProvider.themeStyle == ThemeStyle.AUTO,
        leading: const Icon(Icons.lan),
        title: Text(s.Theme_Style)));

    if (settingProvider.themeStyle != ThemeStyle.AUTO) {
      interfaceTiles.add(SettingsTile.switchTile(
          activeSwitchColor: themeData.primaryColor,
          enabled: settingProvider.themeStyle != ThemeStyle.AUTO,
          onToggle: (value) {
            settingProvider.themeStyle =
                value ? ThemeStyle.DARK : ThemeStyle.LIGHT;
            widget.indexReload();
          },
          initialValue: settingProvider.themeStyle == ThemeStyle.AUTO
              ? MediaQuery.of(context).platformBrightness == Brightness.dark
              : settingProvider.themeStyle == ThemeStyle.DARK,
          leading: const Icon(Icons.dark_mode_outlined),
          title: Text(s.Dark_mode)));
    }

    interfaceTiles.add(SettingsTile.switchTile(
        activeSwitchColor: themeData.primaryColor,
        onToggle: (value) {
          settingProvider.linkPreview = value ? 1 : 0;
        },
        initialValue: settingProvider.linkPreview == OpenStatus.OPEN,
        leading: const Icon(Icons.link_outlined),
        title: Text(s.Link_preview)));
    interfaceTiles.add(SettingsTile.switchTile(
        activeSwitchColor: themeData.primaryColor,
        onToggle: (value) {
          settingProvider.imagePreview = value ? 1 : 0;
        },
        initialValue: settingProvider.imagePreview == OpenStatus.OPEN,
        leading: const Icon(Icons.image_outlined),
        title: Text(s.Image_preview)));
    interfaceTiles.add(SettingsTile.switchTile(
        activeSwitchColor: themeData.primaryColor,
        onToggle: (value) {
          settingProvider.videoPreview = value ? 1 : 0;
        },
        initialValue: settingProvider.videoPreview == OpenStatus.OPEN,
        leading: const Icon(Icons.video_collection_outlined),
        title: Text(s.Video_preview)));
    interfaceTiles.add(SettingsTile.switchTile(
        activeSwitchColor: themeData.primaryColor,
        onToggle: (value) {
          settingProvider.autoOpenSensitive = value ? 1 : 0;
        },
        initialValue: settingProvider.autoOpenSensitive == OpenStatus.OPEN,
        leading: const Icon(Icons.accessibility),
        title: const Text("Automatically open sensitive content")));

    //   name: s.Auto_Open_Sensitive_Content,
    //   value: getOpenListDefault(settingProvider.autoOpenSensitive).name,
    //   onTap: pickAutoOpenSensitive,

    List<AbstractSettingsTile> networkTiles = [];

    networkTiles.add(SettingsTile.switchTile(
        activeSwitchColor: themeData.primaryColor,
        onToggle: (value) {
          settingProvider.gossip = value ? 1 : 0;
          if (value && feedRelaySet == null) {
            rebuildFeedRelaySet();
          } else {
            followEventProvider?.refreshPosts();
          }
        },
        initialValue: settingProvider.gossip == OpenStatus.OPEN,
        leading: GestureDetector(
            child: Icon(Icons.info_outline, color: themeData.primaryColor),
            onTap: () {
              launchUrl(OUTBOX_MODEL_INFO_URL,
                  mode: LaunchMode.externalApplication);
            }),
        title: const Text("Use contacts outbox relays for feed")));

    if (settingProvider.gossip == 1) {
      networkTiles.add(SettingsTile.navigation(
          leading: Container(
              margin: const EdgeInsets.only(left: 20),
              child: const Icon(Icons.lan_outlined)),
          trailing: Text('${settingProvider.followeesRelayMinCount}'),
          onPressed: (context) async {
            int? old = _settingProvider.followeesRelayMinCount;
            await pickMinRelays();
            if (_settingProvider.followeesRelayMinCount! != old) {
              rebuildFeedRelaySet();
            }
          },
          title: const Text("Minimal amount of relays per contact")));

      networkTiles.add(
        SettingsTile.navigation(
            onPressed: (context) {
              if (feedRelaySet != null &&
                  feedRelaySet!.urls.isNotEmpty &&
                  !loadingGossipRelays) {
                List<RelayMetadata> filteredRelays = feedRelaySet!
                    .relaysMap.entries
                    .map((entry) => RelayMetadata.full(
                        url: entry.key,
                        read: false,
                        write: true,
                        count: entry.value.length))
                    .toList();

                // List<RelayMetadata> filteredRelays =
                //     followRelays!.where((relay) {
                //   Relay? r = followsNostr!.getRelay(relay.url!);
                //   return r != null;
                // }).toList();
                context.go(RouterPath.USER_RELAYS, extra: filteredRelays);
              }
            },
            leading: loadingGossipRelays
                ? Padding(
                    padding: EdgeInsets.all(15.0),
                    child: LinearPercentIndicator(
                      width: MediaQuery.of(context).size.width - 100,
                      animation: false,
                      lineHeight: 40.0,
                      backgroundColor: themeData.disabledColor,
                      percent: gossipTotal > 0 ? gossipCount / gossipTotal : 0,
                      center: Text(
                        "$gossipStatus $gossipCount/$gossipTotal",
                        style: TextStyle(color: Colors.black),
                      ),
                      linearStrokeCap: LinearStrokeCap.roundAll,
                      progressColor: themeData.primaryColor,
                    ))
                : Container(
                    margin: const EdgeInsets.only(left: 20),
                    child: Text(
                      "Outbox feed relays for all contacts: ",
                      style: TextStyle(color: themeData.disabledColor),
                    )),
            // Container(
            //     margin: const EdgeInsets.only(left: 20),
            //     child: Text(
            //       ,
            //       style: TextStyle(color: themeData.disabledColor),
            //     )),
            trailing: loadingGossipRelays
                ? Container()
                : Icon(Icons.navigate_next, color: themeData.disabledColor),
            title: Selector<RelayProvider, String>(
                builder: (context, relayNum, child) {
              if (loadingGossipRelays) {
                return SpinKitFadingCircle(
                  color: themeData.disabledColor,
                  size: 20.0,
                );
              }
              return Text(
                relayNum,
                style: TextStyle(color: themeData.disabledColor),
              );
            }, selector: (context, _provider) {
              return "${feedRelaySet != null ? feedRelaySet!.urls.length : 0}"; //_provider.feedRelaysNumStr();
            })),
      );
    }

    networkTiles.add(SettingsTile.switchTile(
        activeSwitchColor: themeData.primaryColor,
        onToggle: (value) {
          settingProvider.inboxForReactions = value ? 1 : 0;
        },
        initialValue: settingProvider.inboxForReactions == OpenStatus.OPEN,
        leading: GestureDetector(
            child: Icon(Icons.info_outline, color: themeData.primaryColor),
            onTap: () {
              launchUrl(OUTBOX_MODEL_INFO_URL,
                  mode: LaunchMode.externalApplication);
            }),
        title: const Text(
            "Broadcast reactions & replies to inbox relays of participants")));

    if (settingProvider.inboxForReactions == 1) {
      networkTiles.add(SettingsTile.navigation(
          leading: Container(
              margin: const EdgeInsets.only(left: 20),
              child: const Icon(Icons.lan_outlined)),
          trailing: Text('${settingProvider.broadcastToInboxMaxCount}'),
          onPressed: (context) async {
            int? old = _settingProvider.broadcastToInboxMaxCount;
            await pickMaxRelays();
          },
          title: const Text("Max amount of relays per reaction")));
    }

    List<AbstractSettingsTile> listsTiles = [];

    listsTiles.add(SettingsTile.navigation(
        onPressed: (context) async {
          if (filterProvider.muteListCount > 0) {
            bool finished = false;
            Future.delayed(const Duration(milliseconds: 500), () {
              if (!finished) {
                EasyLoading.showInfo('Loading list...',
                    maskType: EasyLoadingMaskType.black,
                    dismissOnTap: true,
                    duration: const Duration(seconds: 3));
              }
            });
            try {
              Nip51List? list = await ndk.lists
                  .getSingleNip51List(Nip51List.kMute, loggedUserSigner!);
              finished = true;
              context.go(RouterPath.MUTE_LIST,
                  extra: list ??
                      Nip51List(
                          pubKey: loggedUserSigner!.getPublicKey(),
                          kind: Nip51List.kMute,
                          elements: [],
                          createdAt: Helpers.now));
            } finally {
              EasyLoading.dismiss();
            }
          } else {
            context.go(RouterPath.MUTE_LIST,
                extra: Nip51List(
                    pubKey: loggedUserSigner!.getPublicKey(),
                    kind: Nip51List.kMute,
                    elements: [],
                    createdAt: Helpers.now));
          }
        },
        leading: const Icon(
          Icons.volume_mute,
        ),
        trailing: Icon(Icons.navigate_next),
        title: Selector<FilterProvider, int>(
          builder: (context, count, child) {
            return Text(
              "${count} Mute",
            );
          },
          selector: (p0, filterProvider) {
            return filterProvider.muteListCount;
          },
        )));

    listsTiles.add(SettingsTile.navigation(
        onPressed: (context) async {
          if (ndk.relays.globalState.blockedRelays.length > 0) {
            bool finished = false;
            Future.delayed(const Duration(milliseconds: 500), () {
              if (!finished) {
                EasyLoading.showInfo('Loading relay list...',
                    maskType: EasyLoadingMaskType.black,
                    dismissOnTap: true,
                    duration: const Duration(seconds: 3));
              }
            });
            try {
              Nip51List? list = await ndk.lists.getSingleNip51List(
                  Nip51List.kBlockedRelays, loggedUserSigner!);
              finished = true;
              context.go(RouterPath.RELAY_LIST,
                  extra: list ??
                      Nip51List(
                          pubKey: loggedUserSigner!.getPublicKey(),
                          kind: Nip51List.kBlockedRelays,
                          elements: [],
                          createdAt: Helpers.now));
            } finally {
              EasyLoading.dismiss();
            }
          } else {
            context.go(RouterPath.RELAY_LIST,
                extra: Nip51List(
                    pubKey: loggedUserSigner!.getPublicKey(),
                    kind: Nip51List.kBlockedRelays,
                    elements: [],
                    createdAt: Helpers.now));
          }
        },
        leading: const Icon(
          Icons.not_interested,
        ),
        trailing: Icon(Icons.navigate_next),
        title: Text(
          "${ndk.relays.globalState.blockedRelays.length} Blocked relays",
        )));

    listsTiles.add(SettingsTile.navigation(
        onPressed: (context) async {
          if (searchRelays.isNotEmpty) {
            bool finished = false;
            Future.delayed(const Duration(milliseconds: 500), () {
              if (!finished) {
                EasyLoading.showInfo('Loading relay list...',
                    maskType: EasyLoadingMaskType.black,
                    dismissOnTap: true,
                    duration: const Duration(seconds: 3));
              }
            });
            try {
              Nip51List? list = await ndk.lists.getSingleNip51List(
                  Nip51List.kSearchRelays, loggedUserSigner!);
              finished = true;
              context.go(RouterPath.RELAY_LIST,
                  extra: list ??
                      Nip51List(
                          pubKey: loggedUserSigner!.getPublicKey(),
                          kind: Nip51List.kSearchRelays,
                          elements: [],
                          createdAt: Helpers.now));
            } finally {
              EasyLoading.dismiss();
            }
          } else {
            context.go(RouterPath.RELAY_LIST,
                extra: Nip51List(
                    pubKey: loggedUserSigner!.getPublicKey(),
                    kind: Nip51List.kSearchRelays,
                    elements: [],
                    createdAt: Helpers.now));
          }
        },
        leading: const Icon(
          Icons.search,
        ),
        trailing: Icon(Icons.navigate_next),
        title: Selector<RelayProvider, List<String>?>(
            builder: (context, searchRelays, child) {
          return Text(
            "${searchRelays != null ? searchRelays.length : 0} Search relays",
          );
        }, selector: (context, provider) {
          return relayProvider.getSearchRelays();
        })));

    List<AbstractSettingsTile> securityTiles = [];

    if (!PlatformUtil.isWeb() &&
        (PlatformUtil.isIOS() || PlatformUtil.isAndroid())) {
      securityTiles.add(SettingsTile.switchTile(
        activeSwitchColor: themeData.primaryColor,
        onToggle: (value) {
          authenticate(
              value, s.Please_authenticate_to_turn_off_the_privacy_lock);
        },
        initialValue: settingProvider.lockOpen == OpenStatus.OPEN,
        leading: const Icon(Icons.lock_open),
        title: Text(s.Privacy_Lock),
      ));
    }

    List<AbstractSettingsTile> notificationTiles = [];

    if (AppFeatures.enableNotifications) {
      notificationTiles.add(SettingsTile.switchTile(
        activeSwitchColor: themeData.primaryColor,
        onToggle: (value) {
          settingProvider.notificationsReactions = value;
          notificationsProvider?.refresh();
        },
        initialValue: settingProvider.notificationsReactions,
        leading: const Icon(Icons.favorite_border),
        title: const Text("Include reactions"),
      ));
      notificationTiles.add(SettingsTile.switchTile(
        activeSwitchColor: themeData.primaryColor,
        onToggle: (value) {
          settingProvider.notificationsReposts = value;
          notificationsProvider?.refresh();
        },
        initialValue: settingProvider.notificationsReposts,
        leading: const Icon(Icons.repeat),
        title: const Text("Include reposts"),
      ));
      notificationTiles.add(SettingsTile.switchTile(
        activeSwitchColor: themeData.primaryColor,
        onToggle: (value) {
          settingProvider.notificationsZaps = value;
          notificationsProvider?.refresh();
        },
        initialValue: settingProvider.notificationsZaps,
        leading: const Icon(Icons.bolt),
        title: const Text("Include zaps"),
      ));
    }

    List<AbstractSettingsTile> walletTiles = [];
    walletTiles.add(SettingsTile.navigation(
      onPressed: (context) async {
        context.go(RouterPath.SETTINGS_WALLET);
      },
      leading: const Icon(Icons.wallet),
      trailing: const Icon(Icons.navigate_next),
      title: const Text("Wallet Settings"),
    ));

    List<AbstractSettingsTile> accountTiles = [];

    accountTiles.add(SettingsTile.navigation(
      trailing: const Text(""),
      onPressed: (context) async {
        var result = await ConfirmDialog.show(context, "Are you sure?");
        if (result == true) {
          var index = settingProvider.privateKeyIndex;
          if (index != null) {
            AccountsState.onLogoutTap(index,
                routerBack: true, context: context);
            metadataProvider.clear();
          } else {
            await ndk.requests.closeAllSubscription();
            // await ndk.destroy();
            // ndk = Ndk.emptyBootstrapRelaysConfig();
          }
        }
      },
      leading: const Icon(Icons.logout),
      title: const Text("Logout"),
    ));

    // accountTiles.add(SettingsTile.navigation(
    //   trailing: const Text(""),
    //   onPressed: (context) {
    //     askToDeleteAccount();
    //   },
    //   leading: const Icon(Icons.delete_outline),
    //   title: Text(s.Delete_Account, style: const TextStyle(color: Colors.red)),
    // ));

    List<SettingsSection> sections = [];

    sections
        .add(SettingsSection(title: Text('Interface'), tiles: interfaceTiles));
    sections.add(SettingsSection(title: Text('Network'), tiles: networkTiles));
    sections.add(SettingsSection(title: Text('Lists'), tiles: listsTiles));
    if (notificationTiles.isNotEmpty) {
      sections.add(SettingsSection(
          title: Text('Notifications'), tiles: notificationTiles));
    }
    sections.add(SettingsSection(title: Text('Wallet'), tiles: walletTiles));
    if (!PlatformUtil.isWeb() &&
        (PlatformUtil.isIOS() || PlatformUtil.isAndroid())) {
      sections
          .add(SettingsSection(title: Text('Security'), tiles: securityTiles));
    }
    sections.add(SettingsSection(title: Text('Account'), tiles: accountTiles));

    SettingsList settingsList = SettingsList(
        applicationType: ApplicationType.both,
        // contentPadding: const EdgeInsets.only(top: Base.BASE_PADDING),
        sections: sections);

    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            context.go(RouterPath.INDEX);
          },
          child: Icon(
            Icons.arrow_back_ios,
            color: themeData.appBarTheme.titleTextStyle!.color,
          ),
        ),
        title: Text(
          s.Settings,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: titleFontSize,
          ),
        ),
      ),
      body:
          // CustomScrollView(
          //   slivers: list,
          // ),
          Container(
              // margin: const EdgeInsets.only(top: Base.BASE_PADDING),
              // padding: const EdgeInsets.only(
              //   left: 20,
              //   right: 20,
              // ),
              child: settingsList),
    );
  }

  List<EnumObj>? openList;

  void initOpenList(I18n s) {
    if (openList == null) {
      openList = [];
      openList!.add(EnumObj(OpenStatus.OPEN, s.open));
      openList!.add(EnumObj(OpenStatus.CLOSE, s.close));
    }
  }

  EnumObj getOpenList(int? value) {
    for (var o in openList!) {
      if (value == o.value) {
        return o;
      }
    }

    return openList![0];
  }

  EnumObj getOpenListDefault(int? value) {
    for (var o in openList!) {
      if (value == o.value) {
        return o;
      }
    }

    return openList![1];
  }

  List<EnumObj>? i18nList;

  List<EnumObj>? relaysNums;

  void init(I18n s) {
    if (i18nList == null) {
      i18nList = [];
      i18nList!.add(EnumObj("", s.auto));
      for (var item in I18n.delegate.supportedLocales) {
        var key = LocaleUtil.getLocaleKey(item);
        i18nList!.add(EnumObj(key, key));
      }
    }
    if (relaysNums == null) {
      relaysNums = [];
      for (var i = 1; i <= 20; i++) {
        relaysNums!.add(EnumObj(i, "$i"));
      }
    }
  }

  EnumObj getI18nList(String? i18n, String? i18nCC) {
    var key = LocaleUtil.genLocaleKeyFromSring(i18n, i18nCC);
    for (var eo in i18nList!) {
      if (eo.value == key) {
        return eo;
      }
    }
    return EnumObj("", I18n.of(context).auto);
  }

  Future pickI18N() async {
    EnumObj? resultEnumObj =
        await EnumSelectorComponent.show(context, i18nList!);
    if (resultEnumObj != null) {
      if (resultEnumObj.value == "") {
        settingProvider.setI18n(null, null);
      } else {
        for (var item in I18n.delegate.supportedLocales) {
          var key = LocaleUtil.getLocaleKey(item);
          if (resultEnumObj.value == key) {
            settingProvider.setI18n(item.languageCode, item.countryCode);
          }
        }
      }
      widget.indexReload();
      Future.delayed(Duration(seconds: 1), () {
        setState(() {
          // TODO others setting enumObjList
          i18nList = null;
          themeStyleList = null;
        });
      });
    }
  }

  Future pickMinRelays() async {
    EnumObj? resultEnumObj =
        await EnumSelectorComponent.show(context, relaysNums!);
    if (resultEnumObj != null) {
      settingProvider.followeesRelayMinCount = resultEnumObj.value;
      widget.indexReload();
      // Future.delayed(Duration(seconds: 1), () {
      //   setState(() {
      //     // TODO others setting enumObjList
      //     i18nList = null;
      //     themeStyleList = null;
      //   });
      // });
    }
  }

  String getFlagEmoji(String countryCode) {
    // Check if the country code is exactly two letters
    if (countryCode.length != 2) {
      return ''; // Return empty string if the input is invalid
    }

    // Convert the country code to uppercase
    countryCode = countryCode.toUpperCase();

    // Calculate the regional indicator symbols
    int flagOffset = 0x1F1E6; // Unicode offset for regional indicator 'A'
    int asciiOffset = 0x41; // ASCII value for 'A'

    String firstChar = String.fromCharCode(
        flagOffset + countryCode.codeUnitAt(0) - asciiOffset);
    String secondChar = String.fromCharCode(
        flagOffset + countryCode.codeUnitAt(1) - asciiOffset);

    return firstChar + secondChar; // Combine the two regional indicator symbols
  }

  Future pickFiatCurrency() async {
    List<EnumObj> objs = [];
    Map<String, dynamic>? rates = await RatesUtil.fiatCurrencies();

    Map<String, Currency>? currencies = await RatesUtil.loadCurrencies();

    rates!.forEach((key, map) {
      if (map['type'] == 'fiat') {
        Currency? currency =
            currencies != null ? currencies[key.toUpperCase()] : null;
        objs.add(EnumObj(key, "(${map['name']} ${map['unit']})",
            widget: RichText(
                text: TextSpan(children: [
              TextSpan(
                text: "${key.toUpperCase()} ",
              ),
              TextSpan(
                  text:
                      " ${currency != null ? getFlagEmoji(currency!.countryCode) : ''}"),
              TextSpan(
                  text: " ${map['name']}",
                  style: TextStyle(color: Colors.grey[700]))
            ]))));
      }
    });

    objs.sort((a, b) {
      // Convert values to lowercase strings for case-insensitive comparison
      String valueA = a.value.toString().toLowerCase();
      String valueB = b.value.toString().toLowerCase();

      // Assign special priority to 'usd' and 'eur'
      if (valueA == 'usd') return -1; // 'usd' should come first
      if (valueB == 'usd') return 1;

      if (valueA == 'eur') return -1; // 'eur' should come second, after 'usd'
      if (valueB == 'eur') return 1;

      // For all other cases, use the standard string comparison
      return valueA.compareTo(valueB);
    });

    EnumObj? resultEnumObj = await EnumSelectorComponent.show(context, objs);
    if (resultEnumObj != null) {
      var a = await RatesUtil.fiatCurrency(resultEnumObj!.value);
      fiatCurrencyRate = a;
      settingProvider.currency = resultEnumObj.value;
    }
  }

  Future pickMaxRelays() async {
    EnumObj? resultEnumObj =
        await EnumSelectorComponent.show(context, relaysNums!);
    if (resultEnumObj != null) {
      settingProvider.broadcastToInboxMaxCount = resultEnumObj.value;
      // widget.indexReload();
      // Future.delayed(Duration(seconds: 1), () {
      //   setState(() {
      //     // TODO others setting enumObjList
      //     i18nList = null;
      //     themeStyleList = null;
      //   });
      // });
    }
  }

  List<EnumObj>? lockOpenList;

  EnumObj getLockOpenList(int lockOpen) {
    if (lockOpen == OpenStatus.OPEN) {
      return openList![0];
    }
    return openList![1];
  }

  Future<void> pickLockOpenList() async {
    List<EnumObj> newLockOpenList = [];
    newLockOpenList.add(openList![1]);

    var localAuth = LocalAuthentication();
    List<BiometricType> availableBiometrics =
        await localAuth.getAvailableBiometrics();
    if (availableBiometrics.isNotEmpty) {
      newLockOpenList.add(openList![0]);
    }

    var s = I18n.of(context);

    EnumObj? resultEnumObj =
        await EnumSelectorComponent.show(context, newLockOpenList);
    if (resultEnumObj != null) {
      if (resultEnumObj.value == OpenStatus.CLOSE) {
        bool didAuthenticate = await AuthUtil.authenticate(
            context, s.Please_authenticate_to_turn_off_the_privacy_lock);
        if (didAuthenticate) {
          settingProvider.lockOpen = resultEnumObj.value;
        }
        settingProvider.lockOpen = resultEnumObj.value;
      } else if (resultEnumObj.value == OpenStatus.OPEN) {
        bool didAuthenticate = await AuthUtil.authenticate(
            context, s.Please_authenticate_to_turn_on_the_privacy_lock);
        if (didAuthenticate) {
          settingProvider.lockOpen = resultEnumObj.value;
        }
      }
    }
  }

  List<EnumObj>? defaultTabListTimeline;

  void initDefaultTabListTimeline(I18n s) {
    if (defaultTabListTimeline == null) {
      defaultTabListTimeline = [];
      defaultTabListTimeline!.add(EnumObj(0, s.Following));
      defaultTabListTimeline!.add(EnumObj(1, s.Following_replies));
      defaultTabListTimeline!.add(EnumObj(2, s.Global));
    }
  }

  Future<void> pickDefaultTab(List<EnumObj> list) async {
    EnumObj? resultEnumObj = await EnumSelectorComponent.show(context, list);
    if (resultEnumObj != null) {
      settingProvider.defaultTab = resultEnumObj.value;
      widget.indexReload();
    }
  }

  EnumObj getDefaultTab(List<EnumObj> list, int? value) {
    for (var eo in list) {
      if (eo.value == value) {
        return eo;
      }
    }
    return list[0];
  }

  List<EnumObj>? themeStyleList;

  void initThemeStyleList(I18n s) {
    if (themeStyleList == null) {
      themeStyleList = [];
      themeStyleList?.add(EnumObj(ThemeStyle.AUTO, s.Follow_System));
      themeStyleList?.add(EnumObj(ThemeStyle.LIGHT, s.Light));
      themeStyleList?.add(EnumObj(ThemeStyle.DARK, s.Dark_mode));
    }
  }

  Future<void> pickThemeStyle() async {
    EnumObj? resultEnumObj =
        await EnumSelectorComponent.show(context, themeStyleList!);
    if (resultEnumObj != null) {
      settingProvider.themeStyle = resultEnumObj.value;
      widget.indexReload();
    }
  }

  EnumObj getThemeStyle(int themeStyle) {
    for (var eo in themeStyleList!) {
      if (eo.value == themeStyle) {
        return eo;
      }
    }
    return themeStyleList![0];
  }

  List<EnumObj>? fontEnumList;

  void initFontEnumList(I18n s) {
    if (fontEnumList == null) {
      fontEnumList = [];
      fontEnumList!.add(EnumObj(false, s.Default_Font_Family));
      fontEnumList!.add(EnumObj(true, s.Custom_Font_Family));
    }
  }

  // Future pickFontEnum() async {
  //   EnumObj? resultEnumObj =
  //       await EnumSelectorComponent.show(context, fontEnumList!);
  //   if (resultEnumObj != null) {
  //     if (resultEnumObj.value == true) {
  //       pickFont();
  //     } else {
  //       settingProvider.fontFamily = null;
  //       widget.indexReload();
  //     }
  //   }
  // }

  // void pickFont() {
  //   Navigator.of(context).push(
  //     MaterialPageRoute(
  //       builder: (context) => FontPicker(
  //         onFontChanged: (PickerFont font) {
  //           settingProvider.fontFamily = font.fontFamily;
  //           widget.indexReload();
  //         },
  //       ),
  //     ),
  //   );
  // }

  List<EnumObj> fontSizeList = [
    EnumObj(20.0, "20"),
    EnumObj(19.0, "19"),
    EnumObj(18.0, "18"),
    EnumObj(17.0, "17"),
    EnumObj(16.0, "16"),
    EnumObj(15.0, "15"),
    EnumObj(14.0, "14"),
    EnumObj(13.0, "13"),
    EnumObj(12.0, "12"),
  ];

  EnumObj getFontSize(double value) {
    for (var eo in fontSizeList) {
      if (eo.value == value) {
        return eo;
      }
    }
    return fontSizeList[1];
  }

  Future<void> pickFontSize() async {
    EnumObj? resultEnumObj =
        await EnumSelectorComponent.show(context, fontSizeList);
    if (resultEnumObj != null) {
      settingProvider.fontSize = resultEnumObj.value;
      widget.indexReload();
    }
  }

  Future<void> pickLinkPreview() async {
    EnumObj? resultEnumObj =
        await EnumSelectorComponent.show(context, openList!);
    if (resultEnumObj != null) {
      settingProvider.linkPreview = resultEnumObj.value;
    }
  }

  Future<void> pickvideoPreview() async {
    EnumObj? resultEnumObj =
        await EnumSelectorComponent.show(context, openList!);
    if (resultEnumObj != null) {
      settingProvider.videoPreview = resultEnumObj.value;
    }
  }

  List<EnumObj>? imageServiceList;

  void initImageServiceList() {
    if (imageServiceList == null) {
      imageServiceList = [];
      imageServiceList!
          .add(EnumObj(ImageServices.NOSTR_BUILD, ImageServices.NOSTR_BUILD));
    }
  }

  EnumObj getImageService(String? o) {
    for (var eo in imageServiceList!) {
      if (eo.value == o) {
        return eo;
      }
    }
    return imageServiceList![0];
  }

  Future<void> pickImageService() async {
    EnumObj? resultEnumObj =
        await EnumSelectorComponent.show(context, imageServiceList!);
    if (resultEnumObj != null) {
      settingProvider.imageService = resultEnumObj.value;
    }
  }

  pickImagePreview() async {
    EnumObj? resultEnumObj =
        await EnumSelectorComponent.show(context, openList!);
    if (resultEnumObj != null) {
      settingProvider.imagePreview = resultEnumObj.value;
    }
  }

  pickVideoPreview() async {
    EnumObj? resultEnumObj =
        await EnumSelectorComponent.show(context, openList!);
    if (resultEnumObj != null) {
      settingProvider.videoPreview = resultEnumObj.value;
    }
  }

  // EventMemBox waitingDeleteEventBox = EventMemBox(sortAfterAdd: false);
  //
  // CancelFunc? deleteAccountLoadingCancel;
  //
  // askToDeleteAccount() async {
  //   var result =
  //       await ConfirmDialog.show(context, I18n.of(context).Delete_Account_Tips);
  //   if (result == true) {
  //     deleteAccountLoadingCancel = BotToast.showLoading();
  //     try {
  //       whenStopMS = 2000;
  //
  //       waitingDeleteEventBox.clear();
  //
  //       // use a blank metadata to update it
  //       var blankMetadata = Metadata();
  //       var updateEvent = Event(loggedUserSigner!.getPublicKey(), kind.EventKind.METADATA, [],
  //           jsonEncode(blankMetadata));
  //       nostr!.sendEvent(updateEvent);
  //
  //       // use a blank contact list to update it
  //       var blankContactList = ContactList();
  //       nostr!.sendContactList(blankContactList);
  //
  //       var filter = Filter(authors: [
  //         loggedUserSigner!.getPublicKey()
  //       ], kinds: [
  //         Nip01Event.kTextNodeKind,
  //         kind.EventKind.REPOST,
  //         kind.EventKind.GENERIC_REPOST,
  //       ]);
  //       nostr!.query([filter.toMap()], onDeletedEventReceive);
  //     } catch (e) {
  //       log("delete account error ${e.toString()}");
  //     }
  //   }
  // }
  //
  // onDeletedEventReceive(Event event) {
  //   print(event.toJson());
  //   waitingDeleteEventBox.add(event);
  //   whenStop(handleDeleteEvent);
  // }
  //
  // void handleDeleteEvent() {
  //   try {
  //     List<Event> all = waitingDeleteEventBox.all();
  //     List<String> ids = [];
  //     for (var event in all) {
  //       ids.add(event.id);
  //
  //       if (ids.length > 20) {
  //         nostr!.deleteEvents(ids);
  //         ids.clear();
  //       }
  //     }
  //
  //     if (ids.isNotEmpty) {
  //       nostr!.deleteEvents(ids);
  //     }
  //   } finally {
  //     var index = settingProvider.privateKeyIndex;
  //     if (index != null) {
  //       AccountsState.onLogoutTap(index, routerBack: true, context: context);
  //       metadataProvider.clear();
  //     } else {
  //       nostr = null;
  //     }
  //     if (deleteAccountLoadingCancel != null) {
  //       deleteAccountLoadingCancel!.call();
  //     }
  //   }
  // }

  List<EnumObj>? translateLanguages;

  void initTranslateLanguages() {
    if (translateLanguages == null) {
      translateLanguages = [];
      // for (var tl in TranslateLanguage.values) {
      //   translateLanguages!.add(EnumObj(tl.bcpCode, tl.bcpCode));
      // }
    }
  }

  EnumObj getOpenTranslate(int? value) {
    for (var o in openList!) {
      if (value == o.value) {
        return o;
      }
    }

    return openList![1];
  }

  pickOpenTranslate() async {
    EnumObj? resultEnumObj =
        await EnumSelectorComponent.show(context, openList!);
    if (resultEnumObj != null) {
      await handleTranslateModel(openTranslate: resultEnumObj.value);
      settingProvider.openTranslate = resultEnumObj.value;
    }
  }

  pickTranslateSource() async {
    var translateSourceArgs = settingProvider.translateSourceArgs;
    List<EnumObj> values = [];
    if (StringUtil.isNotBlank(translateSourceArgs)) {
      var strs = translateSourceArgs!.split(",");
      for (var str in strs) {
        values.add(EnumObj(str, str));
      }
    }
    List<EnumObj>? resultEnumObjs = await EnumMultiSelectorComponent.show(
        context, translateLanguages!, values);
    if (resultEnumObjs != null) {
      List<String> resultStrs = [];
      for (var value in resultEnumObjs) {
        resultStrs.add(value.value);
      }
      var text = resultStrs.join(",");
      await handleTranslateModel(translateSourceArgs: text);
      settingProvider.translateSourceArgs = text;
    }
  }

  pickTranslateTarget() async {
    EnumObj? resultEnumObj =
        await EnumSelectorComponent.show(context, translateLanguages!);
    if (resultEnumObj != null) {
      await handleTranslateModel(translateTarget: resultEnumObj.value);
      settingProvider.translateTarget = resultEnumObj.value;
    }
  }

  Future<void> handleTranslateModel(
      {int? openTranslate,
      String? translateTarget,
      String? translateSourceArgs}) async {
    openTranslate = openTranslate ?? settingProvider.openTranslate;
    translateTarget = translateTarget ?? settingProvider.translateTarget;
    translateSourceArgs =
        translateSourceArgs ?? settingProvider.translateSourceArgs;

    if (openTranslate == OpenStatus.OPEN &&
        StringUtil.isNotBlank(translateTarget) &&
        StringUtil.isNotBlank(translateSourceArgs)) {
      List<String> bcpCodes = translateSourceArgs!.split(",");
      bcpCodes.add(translateTarget!);

      // var translateModelManager = TranslateModelManager.getInstance();
      // BotToast.showText(
      //     text: I18n.of(context).Begin_to_download_translate_model);
      // var cancelFunc = BotToast.showLoading();
      // try {
      //   await translateModelManager.checkAndDownloadTargetModel(bcpCodes);
      // } finally {
      //   cancelFunc.call();
      // }
    }
  }

  pickBroadcaseWhenBoost() async {
    EnumObj? resultEnumObj =
        await EnumSelectorComponent.show(context, openList!);
    if (resultEnumObj != null) {
      settingProvider.broadcastWhenBoost = resultEnumObj.value;
    }
  }

  EnumObj getAutoOpenSensitive(int? value) {
    for (var o in openList!) {
      if (value == o.value) {
        return o;
      }
    }

    return openList![1];
  }

  pickAutoOpenSensitive() async {
    EnumObj? resultEnumObj =
        await EnumSelectorComponent.show(context, openList!);
    if (resultEnumObj != null) {
      settingProvider.autoOpenSensitive = resultEnumObj.value;
    }
  }

  pickWebviewAppbar() async {
    EnumObj? resultEnumObj =
        await EnumSelectorComponent.show(context, openList!);
    if (resultEnumObj != null) {
      settingProvider.webviewAppbarOpen = resultEnumObj.value;
    }
  }

  getOpenMode(int? value) {
    for (var o in openList!) {
      if (value == o.value) {
        return o;
      }
    }

    if (PlatformUtil.isTableModeWithoutSetting()) {
      return openList![0];
    }
    return openList![1];
  }

  pickOpenMode() async {
    EnumObj? resultEnumObj =
        await EnumSelectorComponent.show(context, openList!);
    if (resultEnumObj != null) {
      settingProvider.tableMode = resultEnumObj.value;
      widget.indexReload();
    }
  }

  void authenticate(value, text) async {
    if (await AuthUtil.authenticate(context, text)) {
      settingProvider.lockOpen = value ? 1 : 0;
    }
  }

  Future<void> rebuildFeedRelaySet() async {
    setState(() {
      loadingGossipRelays = true;
    });
    RelaySet newRelaySet = await relayProvider.recalculateFeedRelaySet(
        onProgress: (status, count, total) {
      setState(() {
        gossipStatus = status;
        gossipCount = count;
        gossipTotal = total;
      });
    });
    setState(() {
      loadingGossipRelays = false;
    });

    // await relayProvider.buildNostrFromContactsRelays(
    //     loggedUserSigner!.getPublicKey(),
    //     contactListProvider.nip02ContactList!,
    //     settingProvider.followeesRelayMinCount!, (builtNostr) {
    //   reloadingFollowNostr = true;
    //   if (followsNostr != null) {
    //     followsNostr!.close();
    //   }
    //   followsNostr = builtNostr;
    //   // add logged user's configured read relays
    //   // nostr!
    //   //     .activeRelays()
    //   //     .where((relay) => relay.access != WriteAccess.writeOnly)
    //   //     .forEach((relay) {
    //   //   followsNostr!.addRelay(relay, connect: true);
    //   // });
    //   reloadingFollowNostr = false;
    //   setState(() {
    //     loadingGossipRelays = false;
    //   });
    //   followEventProvider.doQuery();
    // });
  }
}
