import 'dart:convert';
import 'dart:developer';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_font_picker/flutter_font_picker.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:yana/models/event_mem_box.dart';
import 'package:yana/nostr/filter.dart';
import 'package:yana/nostr/nip02/contact_list.dart';
import 'package:yana/nostr/relay_metadata.dart';
import 'package:yana/router/index/account_manager_component.dart';
import 'package:yana/utils/platform_util.dart';
import 'package:yana/utils/router_util.dart';
import 'package:yana/utils/when_stop_function.dart';

import '../../i18n/i18n.dart';
import '../../main.dart';
import '../../models/metadata.dart';
import '../../nostr/event.dart';
import '../../nostr/event_kind.dart' as kind;
import '../../nostr/relay.dart';
import '../../provider/relay_provider.dart';
import '../../provider/setting_provider.dart';
import '../../ui/confirm_dialog.dart';
import '../../ui/enum_multi_selector_component.dart';
import '../../ui/enum_selector_component.dart';
import '../../utils/auth_util.dart';
import '../../utils/base_consts.dart';
import '../../utils/image_services.dart';
import '../../utils/locale_util.dart';
import '../../utils/router_path.dart';
import '../../utils/string_util.dart';
import '../../utils/theme_style.dart';

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

  @override
  Widget build(BuildContext context) {
    var themeData = Theme.of(context);
    var titleFontSize = themeData.textTheme.bodyLarge!.fontSize;
    var _settingProvider = Provider.of<SettingProvider>(context);
    var _relayProvider = Provider.of<RelayProvider>(context);

    var mainColor = themeData.primaryColor;
    var hintColor = themeData.hintColor;

    var s = I18n.of(context);

    initOpenList(s);
    init(s);
    initCompressList(s);
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

    List<AbstractSettingsTile> networkTiles = [];

    networkTiles.add(SettingsTile.switchTile(
        activeSwitchColor: themeData.primaryColor,
        onToggle: (value) {
          settingProvider.gossip = value ? 1 : 0;
          if (value && followsNostr == null) {
            rebuildFollowsNostr();
          }
        },
        initialValue: settingProvider.gossip == OpenStatus.OPEN,
        leading: const Icon(Icons.grain),
        title: Text("Use following outbox relays for Feed")));

    if (settingProvider.gossip == 1) {
      networkTiles.add(SettingsTile.navigation(
          leading: const Icon(Icons.lan_outlined),
          trailing: Text('${settingProvider.followeesRelayMinCount}'),
          onPressed: (context) async {
            int? old = _settingProvider.followeesRelayMinCount;
            await pickMaxRelays();
            if (_settingProvider.followeesRelayMinCount! != old) {
              rebuildFollowsNostr();
            }
          },
          title: const Text("Minimal amount of relays per following")));

      networkTiles.add(
        SettingsTile.navigation(
            onPressed: (context) {
              if (followRelays != null &&
                  followRelays!.isNotEmpty &&
                  !loadingGossipRelays) {
                List<RelayMetadata> filteredRelays = followRelays!.where((relay) {
                  Relay? r = followsNostr!.getRelay(relay.addr!);
                  return r!=null;
                }).toList();
                RouterUtil.router(
                    context, RouterPath.USER_RELAYS, filteredRelays );
              }
            },
            leading: Text(
              "Connected / Total relays from following",
              style: TextStyle(color: themeData.disabledColor),
            ),
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
              return _provider.followRelayNumStr();
            })),
      );
    }

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

    if (!PlatformUtil.isWeb() &&
        (PlatformUtil.isIOS() || PlatformUtil.isAndroid())) {
      notificationTiles.add(SettingsTile.switchTile(
        activeSwitchColor: themeData.primaryColor,
        onToggle: (value) {
          settingProvider.backgroundService = value;
          if (!value && backgroundService != null) {
            backgroundService!
                .isRunning()
                .whenComplete(() => {backgroundService!.invoke('stopService')});
          }
        },
        initialValue: settingProvider.backgroundService,
        leading: const Icon(Icons.notification_important_outlined),
        title: const Text("Start pull background service"),
      ));
    }

    List<AbstractSettingsTile> accountTiles = [];

    accountTiles.add(SettingsTile.navigation(
      trailing: const Text(""),
      onPressed: (context) {
        var index = settingProvider.privateKeyIndex;
        if (index != null) {
          AccountsState.onLogoutTap(index, routerBack: true, context: context);
          metadataProvider.clear();
        } else {
          nostr = null;
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
    if (!PlatformUtil.isWeb() &&
        (PlatformUtil.isIOS() || PlatformUtil.isAndroid())) {
      sections.add(SettingsSection(
          title: Text('Notifications'), tiles: notificationTiles));
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
            RouterUtil.back(context);
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

  List<EnumObj>? maxRelays;

  void init(I18n s) {
    if (i18nList == null) {
      i18nList = [];
      i18nList!.add(EnumObj("", s.auto));
      for (var item in I18n.delegate.supportedLocales) {
        var key = LocaleUtil.getLocaleKey(item);
        i18nList!.add(EnumObj(key, key));
      }
    }
    if (maxRelays == null) {
      maxRelays = [];
      for (var i = 1; i <= 10; i++) {
        maxRelays!.add(EnumObj(i, "$i"));
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

  Future pickMaxRelays() async {
    EnumObj? resultEnumObj =
        await EnumSelectorComponent.show(context, maxRelays!);
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

  List<EnumObj>? compressList;

  void initCompressList(I18n s) {
    if (compressList == null) {
      compressList = [];
      compressList!.add(EnumObj(100, s.Dont_Compress));
      compressList!.add(EnumObj(90, "90%"));
      compressList!.add(EnumObj(80, "80%"));
      compressList!.add(EnumObj(70, "70%"));
      compressList!.add(EnumObj(60, "60%"));
      compressList!.add(EnumObj(50, "50%"));
      compressList!.add(EnumObj(40, "40%"));
    }
  }

  Future<void> pickImageCompressList() async {
    EnumObj? resultEnumObj =
        await EnumSelectorComponent.show(context, compressList!);
    if (resultEnumObj != null) {
      settingProvider.imgCompress = resultEnumObj.value;
    }
  }

  EnumObj getCompressList(int compress) {
    for (var eo in compressList!) {
      if (eo.value == compress) {
        return eo;
      }
    }
    return compressList![0];
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

  String getFontEnumResult(String? fontFamily) {
    if (StringUtil.isNotBlank(fontFamily)) {
      return fontFamily!;
    }
    return fontEnumList![0].name;
  }

  Future pickFontEnum() async {
    EnumObj? resultEnumObj =
        await EnumSelectorComponent.show(context, fontEnumList!);
    if (resultEnumObj != null) {
      if (resultEnumObj.value == true) {
        pickFont();
      } else {
        settingProvider.fontFamily = null;
        widget.indexReload();
      }
    }
  }

  void pickFont() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FontPicker(
          onFontChanged: (PickerFont font) {
            settingProvider.fontFamily = font.fontFamily;
            widget.indexReload();
          },
        ),
      ),
    );
  }

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
          .add(EnumObj(ImageServices.NOSTRIMG_COM, ImageServices.NOSTRIMG_COM));
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

  EventMemBox waitingDeleteEventBox = EventMemBox(sortAfterAdd: false);

  CancelFunc? deleteAccountLoadingCancel;

  askToDeleteAccount() async {
    var result =
        await ConfirmDialog.show(context, I18n.of(context).Delete_Account_Tips);
    if (result == true) {
      deleteAccountLoadingCancel = BotToast.showLoading();
      try {
        whenStopMS = 2000;

        waitingDeleteEventBox.clear();

        // use a blank metadata to update it
        var blankMetadata = Metadata();
        var updateEvent = Event(nostr!.publicKey, kind.EventKind.METADATA, [],
            jsonEncode(blankMetadata));
        nostr!.sendEvent(updateEvent);

        // use a blank contact list to update it
        var blankContactList = ContactList();
        nostr!.sendContactList(blankContactList);

        var filter = Filter(authors: [
          nostr!.publicKey
        ], kinds: [
          kind.EventKind.TEXT_NOTE,
          kind.EventKind.REPOST,
          kind.EventKind.GENERIC_REPOST,
        ]);
        nostr!.query([filter.toJson()], onDeletedEventReceive);
      } catch (e) {
        log("delete account error ${e.toString()}");
      }
    }
  }

  onDeletedEventReceive(Event event) {
    print(event.toJson());
    waitingDeleteEventBox.add(event);
    whenStop(handleDeleteEvent);
  }

  void handleDeleteEvent() {
    try {
      List<Event> all = waitingDeleteEventBox.all();
      List<String> ids = [];
      for (var event in all) {
        ids.add(event.id);

        if (ids.length > 20) {
          nostr!.deleteEvents(ids);
          ids.clear();
        }
      }

      if (ids.isNotEmpty) {
        nostr!.deleteEvents(ids);
      }
    } finally {
      var index = settingProvider.privateKeyIndex;
      if (index != null) {
        AccountsState.onLogoutTap(index, routerBack: true, context: context);
        metadataProvider.clear();
      } else {
        nostr = null;
      }
      if (deleteAccountLoadingCancel != null) {
        deleteAccountLoadingCancel!.call();
      }
    }
  }

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
      settingProvider.broadcaseWhenBoost = resultEnumObj.value;
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

  Future<void> rebuildFollowsNostr() async {
    setState(() {
      loadingGossipRelays = true;
    });
    await relayProvider.buildNostrFromContactsRelays(
        nostr!.publicKey,
        contactListProvider.contactList!,
        settingProvider.followeesRelayMinCount!, (builtNostr) {
      reloadingFollowNostr = true;
      if (followsNostr != null) {
        followsNostr!.close();
      }
      followsNostr = builtNostr;
      // add logged user's configured read relays
      // nostr!
      //     .activeRelays()
      //     .where((relay) => relay.access != WriteAccess.writeOnly)
      //     .forEach((relay) {
      //   followsNostr!.addRelay(relay, connect: true);
      // });
      reloadingFollowNostr = false;
      setState(() {
        loadingGossipRelays = false;
      });
      followEventProvider.doQuery();
    });
  }
}
