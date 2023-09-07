import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yana/utils/platform_util.dart';

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

  SharedPreferences? _sharedPreferences;

  final secureStorage = FlutterSecureStorage(aOptions: _getAndroidOptions(), iOptions: _getIOSOptions());

  SettingData? _settingData;

  Map<String, String> _keyMap = {};

  Map<String, bool> _keyIsPrivateMap = {};

  final String KEYS_MAP = "private_keys_map";
  final String IS_PRIVATE_MAP = "keys_is_private_map";

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
        if (StringUtil.isNotBlank(keyMapJson)) {
          try {
            var jsonKeyMap = jsonDecode(keyMapJson!);
            var isPrivateJsonKeyMap = keyIsPrivateMapJson!=null?jsonDecode(keyIsPrivateMapJson!):null;
            if (jsonKeyMap != null) {
              for (var entry in (jsonKeyMap as Map<String, dynamic>).entries) {
                _keyMap[entry.key] = entry.value;
                _keyIsPrivateMap[entry.key] = isPrivateJsonKeyMap!=null && isPrivateJsonKeyMap[entry.key];
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
  
  bool get isPrivateKey {
    return _keyIsPrivateMap[_settingData!.privateKeyIndex] ?? false;
  }

  int addAndChangeKey(String key, bool isPrivate, {bool updateUI = false}) {
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

        _settingData!.privateKeyIndex = i;

        secureStorage.write(key: KEYS_MAP,value: json.encode(_keyMap));
        secureStorage.write(key: IS_PRIVATE_MAP,value: json.encode(_keyIsPrivateMap));
        saveAndNotifyListeners(updateUI: updateUI);

        return i;
      }
    }

    return -1;
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

  int get linkPreview => _settingData!.linkPreview != null
      ? _settingData!.linkPreview!
      : OpenStatus.OPEN;

  String? get network => _settingData!.network;

  String? get imageService => _settingData!.imageService;

  int? get videoPreview => _settingData!.videoPreview ?? OpenStatus.OPEN;

  int? get imagePreview => _settingData!.imagePreview ?? OpenStatus.OPEN;

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

  int? get broadcaseWhenBoost =>
      _settingData!.broadcaseWhenBoost ?? OpenStatus.OPEN;

  double get fontSize =>
      _settingData!.fontSize ??
      (PlatformUtil.isTableMode()
          ? Base.BASE_FONT_SIZE_PC
          : Base.BASE_FONT_SIZE);

  int get webviewAppbarOpen => _settingData!.webviewAppbarOpen;

  int? get tableMode => _settingData!.tableMode;

  int? get autoOpenSensitive => _settingData!.autoOpenSensitive;

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
    _settingData!.backgroundService = o;
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

  set translateSourceArgs(String? o) {
    _settingData!.translateSourceArgs = o;
    saveAndNotifyListeners();
  }

  set translateTarget(String? o) {
    _settingData!.translateTarget = o;
    saveAndNotifyListeners();
  }

  set broadcaseWhenBoost(int? o) {
    _settingData!.broadcaseWhenBoost = o;
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

  String? network;

  bool? backgroundService;

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

  int? broadcaseWhenBoost;

  double? fontSize;

  late int webviewAppbarOpen;

  int? tableMode;

  int? autoOpenSensitive;

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
    this.imageService,
    this.imagePreview,
    this.i18n,
    this.i18nCC,
    this.imgCompress = 50,
    this.themeStyle = ThemeStyle.AUTO,
    this.themeColor,
    this.fontFamily,
    this.openTranslate,
    this.translateTarget,
    this.translateSourceArgs,
    this.broadcaseWhenBoost,
    this.fontSize,
    this.webviewAppbarOpen = OpenStatus.OPEN,
    this.tableMode,
    this.autoOpenSensitive,
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
    if (json['themeStyle'] != null) {
      themeStyle = json['themeStyle'];
    } else {
      themeStyle = ThemeStyle.AUTO;
    }
    themeColor = json['themeColor'];
    openTranslate = json['openTranslate'];
    translateTarget = json['translateTarget'];
    translateSourceArgs = json['translateSourceArgs'];
    broadcaseWhenBoost = json['broadcaseWhenBoost'];
    fontSize = json['fontSize'];
    webviewAppbarOpen = json['webviewAppbarOpen'] != null
        ? json['webviewAppbarOpen']
        : OpenStatus.OPEN;
    tableMode = json['tableMode'];
    autoOpenSensitive = json['autoOpenSensitive'];
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
    data['imageService'] = this.imageService;
    data['videoPreview'] = this.videoPreview;
    data['imagePreview'] = this.imagePreview;
    data['i18n'] = this.i18n;
    data['i18nCC'] = this.i18nCC;
    data['imgCompress'] = this.imgCompress;
    data['themeStyle'] = this.themeStyle;
    data['themeColor'] = this.themeColor;
    data['fontFamily'] = this.fontFamily;
    data['openTranslate'] = this.openTranslate;
    data['translateTarget'] = this.translateTarget;
    data['translateSourceArgs'] = this.translateSourceArgs;
    data['broadcaseWhenBoost'] = this.broadcaseWhenBoost;
    data['fontSize'] = this.fontSize;
    data['webviewAppbarOpen'] = this.webviewAppbarOpen;
    data['tableMode'] = this.tableMode;
    data['autoOpenSensitive'] = this.autoOpenSensitive;
    data['updatedTime'] = this.updatedTime;
    return data;
  }
}
