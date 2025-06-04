import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yana/models/video_autoplay_preference.dart';
import 'package:yana/utils/platform_util.dart';

import '../main.dart';
import '../utils/base.dart';
import '../utils/base_consts.dart';
import '../utils/theme_style.dart';
import '../utils/string_util.dart';
import 'data_util.dart';

IOSOptions _getIOSOptions() => const IOSOptions(
  accountName: "yana_flutter",
  accessibility: KeychainAccessibility.first_unlock
);

AndroidOptions _getAndroidOptions() => const AndroidOptions(
  encryptedSharedPreferences: true,
);

class SettingProvider extends ChangeNotifier {
  static SettingProvider? _settingProvider;
  static const int DEFAULT_FOLLOWEES_RELAY_MIN_COUNT = 2;
  static const int DEFAULT_BROADCAST_TO_INBOX_MAX_COUNT = 10;

  SharedPreferences? _sharedPreferences;

  final secureStorage = FlutterSecureStorage(aOptions: _getAndroidOptions(), iOptions: _getIOSOptions());

  SettingData? _settingData;

  Map<String, String> _keyMap = {};

  Map<String, bool> _keyIsPrivateMap = {};

  Map<String, bool> _keyIsExternalSignerMap = {};

  final String KEYS_MAP = "private_keys_map";
  final String IS_PRIVATE_MAP = "keys_is_private_map";
  final String IS_EXTERNAL_SIGNER_MAP = "keys_is_external_map";
  final String NWC_URI = "nwc_uri";
  final String NWC_SECRET = "nwc_secret";

  static Future<SettingProvider> getInstance() async {
    if (_settingProvider == null) {
      _settingProvider = SettingProvider();
      _settingProvider!._sharedPreferences = await DataUtil.getInstance();
      await _settingProvider!._init();
      _settingProvider!._reloadTranslateSourceArgs();
    }
    return _settingProvider!;
  }

  Future<void> _init() async {
    String? settingStr = _sharedPreferences!.getString(DataKey.SETTING);
    if (StringUtil.isNotBlank(settingStr)) {
      var jsonMap = json.decode(settingStr!);
      if (jsonMap != null) {
        var setting = SettingData.fromJson(jsonMap);
        _settingData = setting;
        _keyMap.clear();

        String? keyMapJson = await secureStorage.read(key: KEYS_MAP);
        String? keyIsPrivateMapJson= await secureStorage.read(key: IS_PRIVATE_MAP);
        String? keyIsExternalSignerMapJson = await secureStorage.read(key: IS_EXTERNAL_SIGNER_MAP);
        if (StringUtil.isNotBlank(keyMapJson)) {
          try {
            var jsonKeyMap = jsonDecode(keyMapJson!);
            var isPrivateJsonKeyMap = keyIsPrivateMapJson!=null?jsonDecode(keyIsPrivateMapJson):null;
            var isExternalJsonKeyMap = keyIsExternalSignerMapJson != null ? jsonDecode(keyIsExternalSignerMapJson) : null;
            if (jsonKeyMap != null) {
              for (var entry in (jsonKeyMap as Map<String, dynamic>).entries) {
                _keyMap[entry.key] = entry.value;
                _keyIsPrivateMap[entry.key] = isPrivateJsonKeyMap!=null && isPrivateJsonKeyMap[entry.key];
                _keyIsExternalSignerMap[entry.key] = isExternalJsonKeyMap != null && isExternalJsonKeyMap[entry.key];
              }
            }
          } catch (e) {
            log("secureStorage reading key KEYS_MAP jsonDecode error");
            log(e.toString());
          }
        }
        return;
      }
    }

    _settingData = SettingData();
  }

  Future<void> reload() async {
    await _init();
    _settingProvider!._reloadTranslateSourceArgs();
    notifyListeners();
  }

  Map<String, String> get keyMap => _keyMap;

  Map<String, bool> get keyIsPrivateMap => _keyIsPrivateMap;

  String? get key {
    if (_settingData!.privateKeyIndex != null &&
        _keyMap.isNotEmpty) {
      return _keyMap[_settingData!.privateKeyIndex.toString()];
    }
    return null;
  }

  bool get isExternalSignerKey {
    return _keyIsExternalSignerMap[_settingData!.privateKeyIndex.toString()] ?? false;
  }
  bool isExternalSignerKeyIndex(int index) {
    return _keyIsExternalSignerMap[index.toString()] ?? false;
  }

  bool get isPrivateKey {
    return _keyIsPrivateMap[_settingData!.privateKeyIndex.toString()] ?? false;
  }

  bool isPrivateKeyIndex(int index) {
    return _keyIsPrivateMap[index.toString()] ?? false;
  }

  Future<int> addAndChangeKey(String key, bool isPrivate, bool isExternalSigner, {bool updateUI = false}) async {
    int? findIndex;
    var entries = _keyMap.entries;
    for (var entry in entries) {
      if (entry.value == key) {
        findIndex = int.tryParse(entry.key);
        break;
      }
    }
    if (findIndex != null) {
      privateKeyIndex = findIndex;
      return findIndex;
    }

    for (var i = 0; i < 20; i++) {
      var index = i.toString();
      var _pk = _keyMap[index];
      if (_pk == null) {
        _keyMap[index] = key;
        _keyIsPrivateMap[index] = isPrivate;
        _keyIsExternalSignerMap[index] = isExternalSigner;

        _settingData!.privateKeyIndex = i;

        await secureStorage.write(key: KEYS_MAP,value: json.encode(_keyMap));
        await secureStorage.write(key: IS_PRIVATE_MAP,value: json.encode(_keyIsPrivateMap));
        await secureStorage.write(key: IS_EXTERNAL_SIGNER_MAP,value: json.encode(_keyIsExternalSignerMap));
        saveAndNotifyListeners(updateUI: updateUI);

        return i;
      }
    }

    return -1;
  }

  Future<String?> getNwc() async {
    return await secureStorage.read(key: NWC_URI);
  }

  Future<void> setNwc(String? uri) async {
    await secureStorage.write(key: NWC_URI,value: uri);
  }

  Future<String?> getNwcSecret() async {
    return await secureStorage.read(key: NWC_SECRET);
  }

  Future<void> setNwcSecret(String? secret) async {
    await secureStorage.write(key: NWC_SECRET,value: secret);
  }

  void removeKey(int index) {
    var indexStr = index.toString();
    _keyMap.remove(indexStr);
    secureStorage.write(key: KEYS_MAP,value: json.encode(_keyMap));
    if (_settingData!.privateKeyIndex == index) {
      if (_keyMap.isEmpty) {
        _settingData!.privateKeyIndex = null;
      } else {
        // find a index
        var keyIndex = _keyMap.keys.first;
        _settingData!.privateKeyIndex = int.tryParse(keyIndex);
      }
    }

    saveAndNotifyListeners();
  }

  SettingData get settingData => _settingData!;

  int? get privateKeyIndex => _settingData!.privateKeyIndex;

  // String? get privateKeyMap => _settingData!.privateKeyMap;

  /// open lock
  int get lockOpen => _settingData!.lockOpen;

  int? get defaultIndex => _settingData!.defaultIndex;

  int? get defaultTab => _settingData!.defaultTab;

  bool get backgroundService => _settingData!.backgroundService ?? true;

  bool get notificationsReactions => _settingData!.notificationsReactions ?? true;

  bool get notificationsReposts => _settingData!.notificationsReposts ?? true;

  bool get notificationsZaps => _settingData!.notificationsZaps ?? true;

  int get linkPreview => _settingData!.linkPreview != null
      ? _settingData!.linkPreview!
      : OpenStatus.OPEN;

  String? get network => _settingData!.network;

  String? get imageService => _settingData!.imageService;

  int? get videoPreview => _settingData!.videoPreview ?? OpenStatus.OPEN;

  int? get imagePreview => _settingData!.imagePreview ?? OpenStatus.OPEN;

  int? get gossip => _settingData!.gossip ?? OpenStatus.CLOSE;

  int? get inboxForReactions => _settingData!.inboxForReactions ?? OpenStatus.CLOSE;

  int get followeesRelayMinCount => _settingData!.followeesRelayMinCount ?? DEFAULT_FOLLOWEES_RELAY_MIN_COUNT;

  int get broadcastToInboxMaxCount => _settingData!.broadcastToInboxMaxCount ?? DEFAULT_BROADCAST_TO_INBOX_MAX_COUNT;

  /// i18n
  String? get i18n => _settingData!.i18n;

  String? get i18nCC => _settingData!.i18nCC;

  /// image compress
  int get imgCompress => _settingData!.imgCompress;

  /// theme style
  int get themeStyle => _settingData!.themeStyle;

  /// theme color
  int? get themeColor => _settingData!.themeColor;

  /// fontFamily
  String? get fontFamily => _settingData!.fontFamily;

  int? get openTranslate => _settingData!.openTranslate;

  static const ALL_SUPPORT_LANGUAGES =
      "en";

  String? get translateSourceArgs {
    if (StringUtil.isNotBlank(_settingData!.translateSourceArgs)) {
      return _settingData!.translateSourceArgs!;
    }
    return null;
  }

  String? get translateTarget => _settingData!.translateTarget;

  String? get currency => _settingData!.currency?? "usd";

  Map<String, int> _translateSourceArgsMap = {};

  void _reloadTranslateSourceArgs() {
    _translateSourceArgsMap.clear();
    var args = _settingData!.translateSourceArgs;
    if (StringUtil.isNotBlank(args)) {
      var argStrs = args!.split(",");
      for (var argStr in argStrs) {
        if (StringUtil.isNotBlank(argStr)) {
          _translateSourceArgsMap[argStr] = 1;
        }
      }
    }
  }

  bool translateSourceArgsCheck(String str) {
    return _translateSourceArgsMap[str] != null;
  }

  int? get broadcastWhenBoost =>
      _settingData!.broadcastWhenBoost ?? OpenStatus.OPEN;

  double get fontSize =>
      _settingData!.fontSize ??
      (PlatformUtil.isTableModeWithoutSetting()
          ? Base.BASE_FONT_SIZE_PC
          : Base.BASE_FONT_SIZE);

  int get webviewAppbarOpen => _settingData!.webviewAppbarOpen;

  int? get tableMode => _settingData!.tableMode;


  int? get autoOpenSensitive => _settingData!.autoOpenSensitive;

  VideoAutoplayPreference get videoAutoplayPreference => _settingData!.videoAutoplayPreference ?? VideoAutoplayPreference.wifiOnly;

  set settingData(SettingData o) {
    _settingData = o;
    saveAndNotifyListeners();
  }

  set privateKeyIndex(int? o) {
    _settingData!.privateKeyIndex = o;
    saveAndNotifyListeners();
  }

  // set privateKeyMap(String? o) {
  //   _settingData!.privateKeyMap = o;
  //   saveAndNotifyListeners();
  // }

  /// open lock
  set lockOpen(int o) {
    _settingData!.lockOpen = o;
    saveAndNotifyListeners();
  }

  set defaultIndex(int? o) {
    _settingData!.defaultIndex = o;
    saveAndNotifyListeners();
  }

  set defaultTab(int? o) {
    _settingData!.defaultTab = o;
    saveAndNotifyListeners();
  }

  set linkPreview(int o) {
    _settingData!.linkPreview = o;
    saveAndNotifyListeners();
  }

  set videoPreview(int? o) {
    _settingData!.videoPreview = o;
    saveAndNotifyListeners();
  }

  set network(String? o) {
    _settingData!.network = o;
    saveAndNotifyListeners();
  }

  set imageService(String? o) {
    _settingData!.imageService = o;
    saveAndNotifyListeners();
  }

  set imagePreview(int? o) {
    _settingData!.imagePreview = o;
    saveAndNotifyListeners();
  }

  set backgroundService(bool? o) {
    if (o!=null && o) {
      checkBackgroundPermission().then((allowed) async {
        if (allowed) {
          await initBackgroundService(backgroundService);
          _settingData!.backgroundService = o;
          saveAndNotifyListeners();
        }
      });
    } else {
      _settingData!.backgroundService = o;
      saveAndNotifyListeners();
    }
  }

  set notificationsReactions(bool? o) {
    _settingData!.notificationsReactions = o;
    saveAndNotifyListeners();
  }

  set notificationsReposts(bool? o) {
    _settingData!.notificationsReposts = o;
    saveAndNotifyListeners();
  }

  set notificationsZaps(bool? o) {
    _settingData!.notificationsZaps = o;
    saveAndNotifyListeners();
  }

  /// i18n
  set i18n(String? o) {
    _settingData!.i18n = o;
    saveAndNotifyListeners();
  }

  void setI18n(String? i18n, String? i18nCC) {
    _settingData!.i18n = i18n;
    _settingData!.i18nCC = i18nCC;
    saveAndNotifyListeners();
  }

  /// image compress
  set imgCompress(int o) {
    _settingData!.imgCompress = o;
    saveAndNotifyListeners();
  }

  /// theme style
  set themeStyle(int o) {
    _settingData!.themeStyle = o;
    saveAndNotifyListeners();
  }

  /// theme color
  set themeColor(int? o) {
    _settingData!.themeColor = o;
    saveAndNotifyListeners();
  }

  /// fontFamily
  set fontFamily(String? _fontFamily) {
    _settingData!.fontFamily = _fontFamily;
    saveAndNotifyListeners();
  }

  set openTranslate(int? o) {
    _settingData!.openTranslate = o;
    saveAndNotifyListeners();
  }

  set gossip(int? o) {
    _settingData!.gossip = o;
    saveAndNotifyListeners();
  }

  set inboxForReactions(int? o) {
    _settingData!.inboxForReactions = o;
    saveAndNotifyListeners();
  }

  set followeesRelayMinCount(int? o) {
    _settingData!.followeesRelayMinCount = o;
    saveAndNotifyListeners();
  }

  set broadcastToInboxMaxCount(int? o) {
    _settingData!.broadcastToInboxMaxCount = o;
    saveAndNotifyListeners();
  }

  set translateSourceArgs(String? o) {
    _settingData!.translateSourceArgs = o;
    saveAndNotifyListeners();
  }

  set currency(String? o) {
    _settingData!.currency = o;
    saveAndNotifyListeners();
  }

  set translateTarget(String? o) {
    _settingData!.translateTarget = o;
    saveAndNotifyListeners();
  }

  set broadcastWhenBoost(int? o) {
    _settingData!.broadcastWhenBoost = o;
    saveAndNotifyListeners();
  }

  set fontSize(double o) {
    _settingData!.fontSize = o;
    saveAndNotifyListeners();
  }

  set webviewAppbarOpen(int o) {
    _settingData!.webviewAppbarOpen = o;
    saveAndNotifyListeners();
  }

  set tableMode(int? o) {
    _settingData!.tableMode = o;
    saveAndNotifyListeners();
  }

  set autoOpenSensitive(int? o) {
    _settingData!.autoOpenSensitive = o;
    saveAndNotifyListeners();
  }

  set videoAutoplayPreference(VideoAutoplayPreference o) {
    _settingData!.videoAutoplayPreference = o;
    saveAndNotifyListeners();
  }

  Future<void> saveAndNotifyListeners({bool updateUI = true}) async {
    _settingData!.updatedTime = DateTime.now().millisecondsSinceEpoch;
    var m = _settingData!.toJson();
    var jsonStr = json.encode(m);
    // print(jsonStr);
    await _sharedPreferences!.setString(DataKey.SETTING, jsonStr);
    _settingProvider!._reloadTranslateSourceArgs();

    if (updateUI) {
      notifyListeners();
    }
  }
}

class SettingData {
  int? privateKeyIndex;

  // String? privateKeyMap;
  //
  // String? encryptPrivateKeyMap;
  //
  /// open lock
  late int lockOpen;

  int? defaultIndex;

  int? defaultTab;

  int? linkPreview;

  int? videoPreview;

  int? gossip;

  int? inboxForReactions;

  int? followeesRelayMinCount;
  int? broadcastToInboxMaxCount;

  String? network;
  String? currency;

  bool? backgroundService;

  bool? notificationsReactions;
  bool? notificationsReposts;
  bool? notificationsZaps;

  String? imageService;

  int? imagePreview;

  /// i18n
  String? i18n;

  String? i18nCC;

  /// image compress
  late int imgCompress;

  /// theme style
  late int themeStyle;

  /// theme color
  int? themeColor;

  /// fontFamily
  String? fontFamily;

  int? openTranslate;

  String? translateTarget;

  String? translateSourceArgs;

  int? broadcastWhenBoost;

  double? fontSize;

  late int webviewAppbarOpen;

  int? tableMode;

  int? autoOpenSensitive;
  VideoAutoplayPreference? videoAutoplayPreference;

  /// updated time
  late int updatedTime;

  SettingData({
    this.privateKeyIndex,
    // this.privateKeyMap,
    this.lockOpen = OpenStatus.CLOSE,
    this.defaultIndex,
    this.defaultTab,
    this.linkPreview,
    this.videoPreview,
    this.network,
    this.backgroundService,
    this.notificationsReactions,
    this.notificationsReposts,
    this.notificationsZaps,
    this.imageService,
    this.imagePreview,
    this.gossip,
    this.followeesRelayMinCount = SettingProvider.DEFAULT_FOLLOWEES_RELAY_MIN_COUNT,
    this.broadcastToInboxMaxCount = SettingProvider.DEFAULT_BROADCAST_TO_INBOX_MAX_COUNT,
    this.i18n,
    this.i18nCC,
    this.imgCompress = 50,
    this.themeStyle = ThemeStyle.AUTO,
    this.themeColor,
    this.fontFamily,
    this.openTranslate,
    this.translateTarget,
    this.translateSourceArgs,
    this.broadcastWhenBoost,
    this.fontSize,
    this.currency,
    this.webviewAppbarOpen = OpenStatus.OPEN,
    this.tableMode,
    this.autoOpenSensitive,
    this.videoAutoplayPreference = VideoAutoplayPreference.wifiOnly,
    this.updatedTime = 0,
  });

  SettingData.fromJson(Map<String, dynamic> json) {
    privateKeyIndex = json['privateKeyIndex'];
    // privateKeyMap = json['privateKeyMap'];
    // encryptPrivateKeyMap = json['encryptPrivateKeyMap'];
    if (json['lockOpen'] != null) {
      lockOpen = json['lockOpen'];
    } else {
      lockOpen = OpenStatus.CLOSE;
    }
    backgroundService = json['backgroundService'];
    notificationsReactions = json['notificationsReactions'];
    notificationsReposts = json['notificationsReposts'];
    notificationsZaps = json['notificationsZaps'];
    defaultIndex = json['defaultIndex'];
    defaultTab = json['defaultTab'];
    linkPreview = json['linkPreview'];
    videoPreview = json['videoPreview'];
    network = json['network'];
    imageService = json['imageService'];
    videoPreview = json['videoPreview'];
    imagePreview = json['imagePreview'];
    i18n = json['i18n'];
    i18nCC = json['i18nCC'];
    if (json['imgCompress'] != null) {
      imgCompress = json['imgCompress'];
    } else {
      imgCompress = 50;
    }
    if (json['currency'] != null) {
      currency = json['currency'];
    } else {
      currency = "usd";
    }
    if (json['gossip'] != null) {
      gossip = json['gossip'];
    } else {
      gossip = 0;
    }
    if (json['inboxForReactions'] != null) {
      inboxForReactions = json['inboxForReactions'];
    } else {
      inboxForReactions = 0;
    }
    if (json['followeesRelayMinCount']!=null) {
      followeesRelayMinCount = json['followeesRelayMinCount'];
    } else {
      followeesRelayMinCount = SettingProvider.DEFAULT_FOLLOWEES_RELAY_MIN_COUNT;
    }
    if (json['broadcastToInboxMaxCount']!=null) {
      broadcastToInboxMaxCount = json['broadcastToInboxMaxCount'];
    } else {
      broadcastToInboxMaxCount = SettingProvider.DEFAULT_BROADCAST_TO_INBOX_MAX_COUNT;
    }
    if (json['themeStyle'] != null) {
      themeStyle = json['themeStyle'];
    } else {
      themeStyle = ThemeStyle.AUTO;
    }
    themeColor = json['themeColor'];
    openTranslate = json['openTranslate'];
    translateTarget = json['translateTarget'];
    translateSourceArgs = json['translateSourceArgs'];
    broadcastWhenBoost = json['broadcaseWhenBoost'];
    fontSize = json['fontSize'];
    webviewAppbarOpen = json['webviewAppbarOpen'] != null
        ? json['webviewAppbarOpen']
        : OpenStatus.OPEN;
    tableMode = json['tableMode'];
    autoOpenSensitive = json['autoOpenSensitive'];
    if (json['videoAutoplayPreference'] != null) {
      videoAutoplayPreference = VideoAutoplayPreference.values[json['videoAutoplayPreference'] as int];
    } else {
      videoAutoplayPreference = VideoAutoplayPreference.wifiOnly;
    }
    if (json['updatedTime'] != null) {
      updatedTime = json['updatedTime'];
    } else {
      updatedTime = 0;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['privateKeyIndex'] = this.privateKeyIndex;
    // data['privateKeyMap'] = this.privateKeyMap;
    // data['encryptPrivateKeyMap'] = this.encryptPrivateKeyMap;
    data['lockOpen'] = this.lockOpen;
    data['defaultIndex'] = this.defaultIndex;
    data['defaultTab'] = this.defaultTab;
    data['linkPreview'] = this.linkPreview;
    data['videoPreview'] = this.videoPreview;
    data['network'] = this.network;
    data['backgroundService'] = this.backgroundService;
    data['notificationsReactions'] = this.notificationsReactions;
    data['notificationsReposts'] = this.notificationsReactions;
    data['imageService'] = this.imageService;
    data['videoPreview'] = this.videoPreview;
    data['imagePreview'] = this.imagePreview;
    data['i18n'] = this.i18n;
    data['i18nCC'] = this.i18nCC;
    data['gossip'] = this.gossip;
    data['inboxForReactions'] = this.inboxForReactions;
    data['followeesRelayMinCount'] = this.followeesRelayMinCount;
    data['broadcastToInboxMaxCount'] = this.broadcastToInboxMaxCount;
    data['imgCompress'] = this.imgCompress;
    data['themeStyle'] = this.themeStyle;
    data['themeColor'] = this.themeColor;
    data['fontFamily'] = this.fontFamily;
    data['openTranslate'] = this.openTranslate;
    data['currency'] = this.currency;
    data['translateTarget'] = this.translateTarget;
    data['translateSourceArgs'] = this.translateSourceArgs;
    data['broadcastWhenBoost'] = this.broadcastWhenBoost;
    data['fontSize'] = this.fontSize;
    data['webviewAppbarOpen'] = this.webviewAppbarOpen;
    data['tableMode'] = this.tableMode;
    data['autoOpenSensitive'] = this.autoOpenSensitive;
    data['videoAutoplayPreference'] = this.videoAutoplayPreference?.index;
    data['updatedTime'] = this.updatedTime;
    return data;
  }
}
