import 'dart:async';
import 'dart:ui';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:dart_ndk/cache_manager.dart';
import 'package:dart_ndk/db/db_cache_manager.dart';
import 'package:dart_ndk/models/pubkey_mapping.dart';
import 'package:dart_ndk/models/relay_set.dart';
import 'package:dart_ndk/models/user_relay_list.dart';
import 'package:dart_ndk/nips/nip01/bip340_event_signer.dart';
import 'package:dart_ndk/nips/nip01/event.dart';
import 'package:dart_ndk/nips/nip01/event_signer.dart';
import 'package:dart_ndk/nips/nip01/metadata.dart';
import 'package:dart_ndk/nips/nip02/contact_list.dart';
import 'package:dart_ndk/nips/nip65/read_write_marker.dart';
import 'package:dart_ndk/read_write.dart';
import 'package:dart_ndk/relay.dart';
import 'package:dart_ndk/relay_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart' as FlutterCacheManager;
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get_time_ago/get_time_ago.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:isar/isar.dart' as isar;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:protocol_handler/protocol_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:window_manager/window_manager.dart';
import 'package:yana/hybrid_event_verifier.dart';
import 'package:yana/nostr/nip07/extension_event_signer.dart';
import 'package:yana/provider/badge_definition_provider.dart';
import 'package:yana/provider/community_info_provider.dart';
import 'package:yana/provider/custom_emoji_provider.dart';
import 'package:yana/provider/follow_new_event_provider.dart';
import 'package:yana/provider/new_notifications_provider.dart';
import 'package:yana/provider/nwc_provider.dart';
import 'package:yana/router/login/login_router.dart';
import 'package:yana/router/relays/relay_info_router.dart';
import 'package:yana/router/search/search_router.dart';
import 'package:yana/router/user/followed_router.dart';
import 'package:yana/router/user/followed_tags_list_router.dart';
import 'package:yana/router/user/user_history_contact_list_router.dart';
import 'package:yana/router/user/user_zap_list_router.dart';
import 'package:yana/router/wallet/nwc_router.dart';
import 'package:yana/router/wallet/wallet_router.dart';
import 'package:yana/utils/image/cache_manager_builder.dart';
import 'package:yana/utils/platform_util.dart';

import '/js/js_helper.dart' as js;
import 'i18n/i18n.dart';
import 'nostr/client_utils/keys.dart';
import 'nostr/nip19/nip19.dart';
import 'nostr/nip19/nip19_tlv.dart';
import 'provider/community_approved_provider.dart';
import 'provider/contact_list_provider.dart';
import 'provider/data_util.dart';
import 'provider/dm_provider.dart';
import 'provider/event_reactions_provider.dart';
import 'provider/filter_provider.dart';
import 'provider/follow_event_provider.dart';
import 'provider/index_provider.dart';
import 'provider/link_preview_data_provider.dart';
import 'provider/metadata_provider.dart';
import 'provider/notice_provider.dart';
import 'provider/notifications_provider.dart';
import 'provider/pc_router_fake_provider.dart';
import 'provider/relay_provider.dart';
import 'provider/setting_provider.dart';
import 'provider/single_event_provider.dart';
import 'provider/webview_provider.dart';
import 'router/community/community_detail_router.dart';
import 'router/dm/dm_detail_router.dart';
import 'router/event_detail/event_detail_router.dart';
import 'router/filter/filter_router.dart';
import 'router/index/index_router.dart';
import 'router/keybackup/key_backup_router.dart';
import 'router/notice/notice_router.dart';
import 'router/profile_editor/profile_editor_router.dart';
import 'router/qrscanner/qrscanner_router.dart';
import 'router/relays/relays_router.dart';
import 'router/setting/setting_router.dart';
import 'router/tag/tag_detail_router.dart';
import 'router/thread/thread_detail_router.dart';
import 'router/user/followed_communities_router.dart';
import 'router/user/user_contact_list_router.dart';
import 'router/user/user_relays_router.dart';
import 'router/user/user_router.dart';
import 'ui/home_component.dart';
import 'utils/locale_util.dart';
import 'utils/media_data_cache.dart';
import 'utils/router_path.dart';
import 'utils/string_util.dart';
import 'utils/theme_style.dart';

late SharedPreferences sharedPreferences;

late SettingProvider settingProvider;

late MetadataProvider metadataProvider;

late ContactListProvider contactListProvider;

late FollowEventProvider followEventProvider;

late FollowNewEventProvider followNewEventProvider;

late NotificationsProvider notificationsProvider;

late NewNotificationsProvider newNotificationsProvider;

late DMProvider dmProvider;

late IndexProvider indexProvider;

late EventReactionsProvider eventReactionsProvider;

late NoticeProvider noticeProvider;

late SingleEventProvider singleEventProvider;

late RelayProvider relayProvider;

late FilterProvider filterProvider;

late LinkPreviewDataProvider linkPreviewDataProvider;

late BadgeDefinitionProvider badgeDefinitionProvider;

late MediaDataCache mediaDataCache;

late FlutterCacheManager.CacheManager localCacheManager;

late PcRouterFakeProvider pcRouterFakeProvider;

late Map<String, WidgetBuilder> routes;

late WebViewProvider webViewProvider;

late CustomEmojiProvider customEmojiProvider;

late CommunityApprovedProvider communityApprovedProvider;

late CommunityInfoProvider communityInfoProvider;

late NwcProvider nwcProvider;

AppLifecycleState appState = AppLifecycleState.resumed;

EventSigner? loggedUserSigner;

RelayManager relayManager = RelayManager();
late CacheManager cacheManager;

RelaySet? feedRelaySet;
RelaySet? myInboxRelaySet;
RelaySet? myOutboxRelaySet;

bool firstLogin = false;

late PackageInfo packageInfo;

FlutterBackgroundService? backgroundService;

late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

int c = 0;

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });

    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }

  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  await initProvidersAndStuff();
  SettingProvider ss = await SettingProvider.getInstance();
  if (!ss.backgroundService) {
    service.stopSelf();
  } else {
    Timer.periodic(const Duration(seconds: 60), (timer) {
      if (service is AndroidServiceInstance) {
        AwesomeNotifications().getAppLifeCycle().then((value) {
          if (value.toString() != "NotificationLifeCycle.Foreground" && myInboxRelaySet != null) {
            appState = AppLifecycleState.inactive;
            relayManager.reconnectRelays(myInboxRelaySet!.urls).then((a) async {
              await newNotificationsProvider.queryNew();
            });
          }
        });
      }
    });
  }
}

Future<void> initProvidersAndStuff() async {
  sharedPreferences = await DataUtil.getInstance();
  metadataProvider = await MetadataProvider.getInstance();
  relayProvider = RelayProvider.getInstance();

  settingProvider = await SettingProvider.getInstance();
  if (StringUtil.isNotBlank(settingProvider.key)) {
    try {

      String? key = settingProvider.key;
      if (StringUtil.isNotBlank(key)) {
        bool isPrivate = settingProvider.isPrivateKey;
        String publicKey = isPrivate ? getPublicKey(key!) : key!;
        loggedUserSigner = isPrivate || !PlatformUtil.isWeb()? Bip340EventSigner(isPrivate? key:null, publicKey) : Nip07EventSigner(await js.getPublicKeyAsync());
      }
      //
      // loggedUserSigner = Bip340EventSigner(settingProvider.key!, getPublicKey(settingProvider.key!));
      filterProvider = FilterProvider.getInstance();
      relayManager.eventFilters.add(filterProvider);

      await relayManager.connect();
      UserRelayList? userRelayList = await relayManager.getSingleUserRelayList(loggedUserSigner!.getPublicKey());
      if (userRelayList != null) {
        createMyRelaySets(userRelayList);
      }
      await relayManager.connect(urls: userRelayList != null ? userRelayList.urls : RelayManager.DEFAULT_BOOTSTRAP_RELAYS);
      // await relayProvider!.loadRelays(loggedUserSigner!.getPublicKey(), () {
      //   relayProvider.addRelays(nostr!).then((bla) {
      notificationsProvider = NotificationsProvider();
      dmProvider = DMProvider();
      newNotificationsProvider = NewNotificationsProvider();
      //   });
      // });
      // log("nostr init over");
    } catch (e) {
      print(e);
      // var index = settingProvider.privateKeyIndex;
      // if (index != null) {
      //   settingProvider.removeKey(index);
      // }
    }
  }
}

Future<void> initRelays({bool newKey = false}) async {
  relayManager.eventFilters.add(filterProvider);

  await relayManager.connect();

  UserRelayList? userRelayList = !newKey ? await relayManager.getSingleUserRelayList(loggedUserSigner!.getPublicKey()) : null;
  if (userRelayList != null) {
    createMyRelaySets(userRelayList);
    await relayManager.connect(urls: userRelayList != null ? userRelayList!.urls : RelayManager.DEFAULT_BOOTSTRAP_RELAYS);
  } else {
    int now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    createMyRelaySets(UserRelayList(
        pubKey: loggedUserSigner!.getPublicKey(),
        relays: {for (String url in RelayManager.DEFAULT_BOOTSTRAP_RELAYS) url: ReadWriteMarker.readWrite},
        createdAt: now,
        refreshedTimestamp: now));
  }
  print("Loading contact list...");
  ContactList? contactList = !newKey ? await relayManager.loadContactList(loggedUserSigner!.getPublicKey()) : null;
  if (contactList != null) {
    print("Loaded ${contactList.contacts.length} contacts...");
    if (settingProvider.gossip == 1) {
      feedRelaySet = relayManager.getRelaySet("feed", loggedUserSigner!.getPublicKey());
      if (feedRelaySet == null) {
        feedRelaySet = await relayManager.calculateRelaySet(
            name: "feed",
            ownerPubKey: loggedUserSigner!.getPublicKey(),
            pubKeys: contactList.contacts,
            direction: RelayDirection.outbox,
            relayMinCountPerPubKey: settingProvider.followeesRelayMinCount);
        await relayManager.saveRelaySet(feedRelaySet!);
      } else {
        final startTime = DateTime.now();
        print("connecting ${feedRelaySet!.relaysMap.length} relays");
        List<bool> connected = await Future.wait(feedRelaySet!.relaysMap.keys.map((url) => relayManager.connectRelay(url)));
        final endTime = DateTime.now();
        final duration = endTime.difference(startTime);
        print(
            "CONNECTED ${connected.where((element) => element).length} , ${connected.where((element) => !element).length} FAILED took ${duration.inMilliseconds} ms");
      }
    }
  }
  followEventProvider.startSubscriptions();
  notificationsProvider.startSubscription();
  dmProvider.initDMSessions(loggedUserSigner!.getPublicKey());
  metadataProvider.notifyListeners();
}

Future<Iterable<String>> broadcastUrls(String? pubKey) async {
  Iterable<String> urlsToBroadcast = [];
  if (settingProvider.inboxForReactions == 1 && pubKey!=null) {
    UserRelayList? userRelayList = await relayManager.getSingleUserRelayList(pubKey!);
    if (userRelayList!=null) {
      urlsToBroadcast = userRelayList.readUrls;
      if (urlsToBroadcast.length > settingProvider.broadcastToInboxMaxCount) {
        urlsToBroadcast = urlsToBroadcast.take(settingProvider.broadcastToInboxMaxCount);
      }
    }
  }
  if (urlsToBroadcast.isEmpty) {
    urlsToBroadcast = myOutboxRelaySet!.urls;
  }
  return urlsToBroadcast;
}

void createMyRelaySets(UserRelayList userRelayList) {
  print("FROM USER RELAY LIST: ");
  userRelayList.relays.entries.forEach((entry) { print("  - ${entry.key} : ${entry.value}");});

  Map<String, List<PubkeyMapping>> inbox = {
    for (var item in userRelayList.relays.entries.where((entry) => entry.value.isRead))
      Relay.clean(item.key) ?? item.key: [PubkeyMapping(pubKey: userRelayList.pubKey, rwMarker: item.value)]
  };
  Map<String, List<PubkeyMapping>> outbox = {
    for (var item in userRelayList.relays.entries.where((entry) => entry.value.isWrite))
      Relay.clean(item.key) ?? item.key: [PubkeyMapping(pubKey: userRelayList.pubKey, rwMarker: item.value)]
  };
  myInboxRelaySet = RelaySet(
      name: "inbox",
      pubKey: userRelayList.pubKey,
      relayMinCountPerPubkey: inbox.length,
      direction: RelayDirection.inbox,
      relaysMap: inbox,
      notCoveredPubkeys: []);
  myOutboxRelaySet =
      RelaySet(name: "outbox", pubKey: userRelayList.pubKey, relayMinCountPerPubkey: outbox.length, direction: RelayDirection.outbox, relaysMap: outbox);
  print("GENERATED INBOX: ");
  myInboxRelaySet!.relaysMap.entries.forEach((entry) { print("  - ${entry.key} : ${entry.value.first.rwMarker}");});
  print("GENERATED OUTBOX: ");
  myOutboxRelaySet!.relaysMap.entries.forEach((entry) { print("  - ${entry.key} : ${entry.value.first.rwMarker}");});
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  packageInfo = await PackageInfo.fromPlatform();
  try {
    await protocolHandler.register('nostr+walletconnect');
    await protocolHandler.register('yana');
    await protocolHandler.register('nostr');
  } catch (err) {
    print(err);
  }
  DbCacheManager dbCacheManager = DbCacheManager();
  await dbCacheManager.init(directory: PlatformUtil.isWeb() ? isar.Isar.sqliteInMemory : (await getApplicationDocumentsDirectory()).path);
  cacheManager = dbCacheManager;
  relayManager.cacheManager = cacheManager;
  relayManager.eventVerifier = HybridEventVerifier();

  if (!PlatformUtil.isWeb() && PlatformUtil.isPC()) {
    await windowManager.ensureInitialized();

    WindowOptions windowOptions = WindowOptions(
      size: const Size(1280, 800),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.normal,
      title: packageInfo.appName,
    );
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }
  if(!PlatformUtil.isTableModeWithoutSetting()) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }
  // if (PlatformUtil.isWeb()) {
  //   databaseFactory = databaseFactoryFfiWeb;
  // } else if (PlatformUtil.isWindowsOrLinux()) {
  //   // Initialize FFI
  //   sqfliteFfiInit();
  //   // Change the default factory
  //   databaseFactory = databaseFactoryFfi;
  // }
  //
  try {
    // SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.top]);
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);
  } catch (e) {
    print(e);
  }

  var dataUtilTask = DataUtil.getInstance();
  var dataFutureResultList = await Future.wait([dataUtilTask]);
  sharedPreferences = dataFutureResultList[0] as SharedPreferences;

  var settingTask = SettingProvider.getInstance();
  var metadataTask = MetadataProvider.getInstance();
  var futureResultList = await Future.wait([settingTask, metadataTask]);
  settingProvider = futureResultList[0] as SettingProvider;
  metadataProvider = futureResultList[1] as MetadataProvider;
  contactListProvider = ContactListProvider.getInstance();
  followEventProvider = FollowEventProvider();
  followNewEventProvider = FollowNewEventProvider();
  notificationsProvider = NotificationsProvider();
  newNotificationsProvider = NewNotificationsProvider();
  dmProvider = DMProvider();
  indexProvider = IndexProvider(
    indexTap: settingProvider.defaultIndex,
  );
  eventReactionsProvider = EventReactionsProvider();
  noticeProvider = NoticeProvider();
  singleEventProvider = SingleEventProvider();
  relayProvider = RelayProvider.getInstance();
  filterProvider = FilterProvider.getInstance();
  linkPreviewDataProvider = LinkPreviewDataProvider();
  badgeDefinitionProvider = BadgeDefinitionProvider();
  mediaDataCache = MediaDataCache();
  localCacheManager = CacheManagerBuilder.build();
  pcRouterFakeProvider = PcRouterFakeProvider();
  webViewProvider = WebViewProvider();
  customEmojiProvider = CustomEmojiProvider.load();
  communityApprovedProvider = CommunityApprovedProvider();
  communityInfoProvider = CommunityInfoProvider();
  nwcProvider = NwcProvider();

  try {
    if (PlatformUtil.isAndroid() || PlatformUtil.isIOS()) {
      initBackgroundService(true);
    }
  } catch (e) {}

  String? key = settingProvider.key;
  if (StringUtil.isNotBlank(key)) {
    bool isPrivate = settingProvider.isPrivateKey;
    String publicKey = isPrivate ? getPublicKey(key!) : key!;
    loggedUserSigner = isPrivate || !PlatformUtil.isWeb()? Bip340EventSigner(isPrivate? key:null, publicKey) : Nip07EventSigner(await js.getPublicKeyAsync());
  }

  if (loggedUserSigner != null) {
    followEventProvider.loadCachedFeed();
    initRelays();
    nwcProvider.init();
  }
  runApp(MyApp());
}

void initBackgroundService(bool startOnBoot) async {
  // await AndroidAlarmManager.initialize();
  // const int helloAlarmID = 0;
  // await AndroidAlarmManager.periodic(const Duration(seconds: 10), helloAlarmID, printHello, wakeup: true, exact: true, allowWhileIdle: true, rescheduleOnReboot: true);

  AwesomeNotifications().isNotificationAllowed().then((isAllowed) async {
    if (!isAllowed) {
      await AwesomeNotifications().requestPermissionToSendNotifications(permissions: [
        NotificationPermission.Vibration,
        NotificationPermission.Badge,
        NotificationPermission.Light,
        NotificationPermission.Sound,
        NotificationPermission.PreciseAlarms,
      ]);
    }
  });
  AwesomeNotifications().initialize('resource://drawable/white', [
    NotificationChannel(
      channelGroupKey: 'yana',
      channelKey: 'yana',
      channelShowBadge: true,
      channelName: 'Basic notifications',
      channelDescription: 'Notification channel for basic tests',
      // channelShowBadge: true,
    ),
  ]);
  AwesomeNotifications().setListeners(
    onActionReceivedMethod: NewNotificationsProvider.onActionReceivedMethod,
    onNotificationCreatedMethod: NewNotificationsProvider.onNotificationCreatedMethod,
  );

  /// OPTIONAL, using custom notification channel id
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'yana-service', // id
    'Background service (can be hidden)', // title
    showBadge: false,
    description: 'This channel is needed to be running in order for the system not to kill all used for important notifications.',
    // description
    importance: Importance.low, // importance must be at low or higher level
  );

  flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  // if (startOnBoot) {
  backgroundService = FlutterBackgroundService();
  await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);

  await backgroundService!.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: false,
      autoStartOnBoot: startOnBoot,
      isForegroundMode: true,
      notificationChannelId: 'yana-service',
      initialNotificationTitle: 'Yana pull service',
      initialNotificationContent: 'this notification can be hidden',
      foregroundServiceNotificationId: 888,
    ),
    iosConfiguration: IosConfiguration(
      autoStart: false,
      onForeground: onStart,
      // you have to enable background fetch capability on xcode project
      // onBackground: onIosBackground,
    ),
  );
  // } else {
  //   if (backgroundService!=null) {
  //     backgroundService!.invoke('stopService');
  //     backgroundService = null;
  //   }
  // }

  // var receivePort = ReceivePort();
  // await FlutterIsolate.spawn(entryPoint, receivePort.sendPort);
  //
  // // Receive the SendPort from the Isolate
  // //SendPort sendPort = await receivePort.first;
  //
  // receivePort.listen((data) {
  //   print("MAIN THREAD data received " + data.toString());
  //   if (data.toString() == "notifications") {
  //     print('MAIN THREAD running notifications: ${DateTime.now()}');
  //     nostr!.checkAndReconnectRelays();
  //     newNotificationsProvider.queryNew();
  //   }
  // });
}

// @pragma('vm:entry-point')
// entryPoint(SendPort sendPort) async {
//   // Open the ReceivePort to listen for incoming messages (optional)
//   var port = ReceivePort();
//
//   // Send messages to other Isolates
//   sendPort.send(port.sendPort);
//   sendPort.send("notifications");
//
//   Timer.periodic(const Duration(seconds: 30), (timer) async {
//     print('ISOLATE THREAD sending notifications: ${DateTime.now()}');
//     sendPort.send("notifications");
//   });
//   // Listen for messages (optional)
//   // await for (var data in port) {
//   //   print("ISOLATE data received " + data.toString());
//   //   // `data` is the message received.
//   // }
// }

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MyApp();
  }
}

class _MyApp extends State<MyApp> with WidgetsBindingObserver {
  reload() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Locale? _locale;
    if (StringUtil.isNotBlank(settingProvider.i18n)) {
      for (var item in I18n.delegate.supportedLocales) {
        if (item.languageCode == settingProvider.i18n && item.countryCode == settingProvider.i18nCC) {
          _locale = Locale(settingProvider.i18n!, settingProvider.i18nCC);
          break;
        }
      }
    }
    setGetTimeAgoDefaultLocale(_locale);
    var lightTheme = getLightTheme();
    var darkTheme = getDarkTheme();
    ThemeData defaultTheme;
    ThemeData? defaultDarkTheme;
    if (settingProvider.themeStyle == ThemeStyle.LIGHT) {
      defaultTheme = lightTheme;
    } else if (settingProvider.themeStyle == ThemeStyle.DARK) {
      defaultTheme = darkTheme;
    } else {
      defaultTheme = lightTheme;
      defaultDarkTheme = darkTheme;
    }

    routes = {
      RouterPath.INDEX: (context) => IndexRouter(reload: reload),
      RouterPath.USER: (context) => UserRouter(),
      RouterPath.USER_CONTACT_LIST: (context) => const UserContactListRouter(),
      RouterPath.USER_HISTORY_CONTACT_LIST: (context) => UserHistoryContactListRouter(),
      RouterPath.USER_ZAP_LIST: (context) => const UserZapListRouter(),
      RouterPath.USER_RELAYS: (context) => const UserRelayRouter(),
      RouterPath.DM_DETAIL: (context) => const DMDetailRouter(),
      RouterPath.THREAD_DETAIL: (context) => ThreadDetailRouter(),
      RouterPath.EVENT_DETAIL: (context) => const EventDetailRouter(),
      RouterPath.TAG_DETAIL: (context) => const TagDetailRouter(),
      RouterPath.NOTICES: (context) => const NoticeRouter(),
      RouterPath.SEARCH: (context) => const SearchRouter(),
      RouterPath.KEY_BACKUP: (context) => const KeyBackupRouter(),
      RouterPath.WALLET: (context) => const WalletRouter(),
      RouterPath.NWC: (context) => const NwcRouter(),
      RouterPath.RELAYS: (context) => const RelaysRouter(),
      RouterPath.FILTER: (context) => const FilterRouter(),
      RouterPath.PROFILE_EDITOR: (context) => const ProfileEditorRouter(),
      RouterPath.SETTING: (context) => SettingRouter(indexReload: reload),
      RouterPath.QRSCANNER: (context) => const QRScannerRouter(),
      RouterPath.RELAY_INFO: (context) => const RelayInfoRouter(),
      RouterPath.FOLLOWED_TAGS_LIST: (context) => const FollowedTagsListRouter(),
      RouterPath.COMMUNITY_DETAIL: (context) => const CommunityDetailRouter(),
      RouterPath.FOLLOWED_COMMUNITIES: (context) => const FollowedCommunitiesRouter(),
      RouterPath.FOLLOWED: (context) => const FollowedRouter(),
      RouterPath.LOGIN: (context) => const LoginRouter(canGoBack: true),
    };

    return MultiProvider(
        providers: [
          ListenableProvider<SettingProvider>.value(
            value: settingProvider,
          ),
          ListenableProvider<MetadataProvider>.value(
            value: metadataProvider,
          ),
          ListenableProvider<IndexProvider>.value(
            value: indexProvider,
          ),
          ListenableProvider<ContactListProvider>.value(
            value: contactListProvider,
          ),
          ListenableProvider<FollowEventProvider>.value(
            value: followEventProvider,
          ),
          ListenableProvider<FollowNewEventProvider>.value(
            value: followNewEventProvider,
          ),
          ListenableProvider<NotificationsProvider>.value(
            value: notificationsProvider,
          ),
          ListenableProvider<NewNotificationsProvider>.value(
            value: newNotificationsProvider,
          ),
          ListenableProvider<DMProvider>.value(
            value: dmProvider,
          ),
          ListenableProvider<EventReactionsProvider>.value(
            value: eventReactionsProvider,
          ),
          ListenableProvider<NoticeProvider>.value(
            value: noticeProvider,
          ),
          ListenableProvider<SingleEventProvider>.value(
            value: singleEventProvider,
          ),
          ListenableProvider<RelayProvider>.value(
            value: relayProvider,
          ),
          ListenableProvider<FilterProvider>.value(
            value: filterProvider,
          ),
          ListenableProvider<LinkPreviewDataProvider>.value(
            value: linkPreviewDataProvider,
          ),
          ListenableProvider<BadgeDefinitionProvider>.value(
            value: badgeDefinitionProvider,
          ),
          ListenableProvider<PcRouterFakeProvider>.value(
            value: pcRouterFakeProvider,
          ),
          ListenableProvider<WebViewProvider>.value(
            value: webViewProvider,
          ),
          ListenableProvider<CustomEmojiProvider>.value(
            value: customEmojiProvider,
          ),
          ListenableProvider<CommunityApprovedProvider>.value(
            value: communityApprovedProvider,
          ),
          ListenableProvider<CommunityInfoProvider>.value(
            value: communityInfoProvider,
          ),
          ListenableProvider<NwcProvider>.value(
            value: nwcProvider,
          ),
        ],
        child: HomeComponent(
          locale: _locale,
          theme: defaultTheme,
          child: Sizer(
            builder: (context, orientation, deviceType) {
              return MaterialApp(
                builder: EasyLoading.init(),
                // builder: BotToastInit(),
                // navigatorObservers: [
                //   BotToastNavigatorObserver(),
                // ],
                locale: _locale,
                title: packageInfo.appName,
                localizationsDelegates: const [
                  I18n.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                supportedLocales: I18n.delegate.supportedLocales,
                theme: defaultTheme,
                darkTheme: defaultDarkTheme,
                onGenerateInitialRoutes: (initialRoute) {
                  MaterialPageRoute? jump;
                  if (initialRoute!.startsWith("nostr:")) {
                    RegExpMatch? match = Nip19.nip19regex.firstMatch(initialRoute!);

                    if (match != null) {
                      var key = match.group(2)! + match.group(3)!;
                      String? otherStr;

                      if (Nip19.isPubkey(key)) {
                        // inline
                        // mention user
                        if (key.length > Nip19.NPUB_LENGTH) {
                          otherStr = key.substring(Nip19.NPUB_LENGTH);
                          key = key.substring(0, Nip19.NPUB_LENGTH);
                        }
                        key = Nip19.decode(key);
                        jump = MaterialPageRoute(settings: RouteSettings(name: RouterPath.USER, arguments: key), builder: (context) => UserRouter());
                      } else if (Nip19.isNoteId(key)) {
                        // block
                        if (key.length > Nip19.NOTEID_LENGTH) {
                          otherStr = key.substring(Nip19.NOTEID_LENGTH);
                          key = key.substring(0, Nip19.NOTEID_LENGTH);
                        }
                        key = Nip19.decode(key);
                        // var filter = Filter(ids: [key]);
                        // relayManager.requestRelays(relayManager.bootstrapRelays, filter, idleTimeout: 20).then((stream) {
                        //   stream.listen((event) {
                        //     RouterUtil.router(context, RouterPath.THREAD_DETAIL, event);
                        //   });
                        // },);

                        jump = MaterialPageRoute(settings: RouteSettings(name: RouterPath.THREAD_DETAIL, arguments: key), builder: (context) => ThreadDetailRouter(eventId: key));
                        // RouterUtil.router(context, RouterPath.THREAD_DETAIL, event);
                      } else if (NIP19Tlv.isNprofile(key)) {
                        var nprofile = NIP19Tlv.decodeNprofile(key);
                        if (nprofile != null) {
                          // inline
                          // mention user
                          jump = MaterialPageRoute(settings: RouteSettings(name: RouterPath.USER, arguments: nprofile.pubkey), builder: (context) => UserRouter());
                        }
                      } else if (NIP19Tlv.isNrelay(key)) {
                        var nrelay = NIP19Tlv.decodeNrelay(key);
                        String? url = nrelay != null ? Relay.clean(nrelay.addr) : null;
                        if (url != null) {
                          // inline
                          Relay relay = Relay(url);
                          jump = MaterialPageRoute(settings: RouteSettings(name: RouterPath.RELAY_INFO, arguments: relay), builder: (context) => const RelayInfoRouter());
                        }
                      } else if (NIP19Tlv.isNevent(key)) {
                        var nevent = NIP19Tlv.decodeNevent(key);
                        if (nevent != null) {
                          jump = MaterialPageRoute(settings: RouteSettings(name: RouterPath.THREAD_DETAIL, arguments: nevent.id), builder: (context) => ThreadDetailRouter(eventId: nevent.id,));
                        }
                      } else if (NIP19Tlv.isNaddr(key)) {
                        var naddr = NIP19Tlv.decodeNaddr(key);
                        if (naddr != null) {
                          if (StringUtil.isNotBlank(naddr.id) && naddr.kind == Nip01Event.TEXT_NODE_KIND) {
                            jump = MaterialPageRoute(settings: RouteSettings(name: RouterPath.THREAD_DETAIL, arguments: naddr.id), builder: (context) => ThreadDetailRouter(eventId: naddr.id,));
                          } else if (StringUtil.isNotBlank(naddr.author) && naddr.kind == Metadata.KIND) {
                            jump = MaterialPageRoute(settings: RouteSettings(name: RouterPath.USER, arguments: naddr.author), builder: (context) => UserRouter());
                          }
                        }
                      }
                    }
                  }
                  if (jump!=null) {
                    return [
                      MaterialPageRoute(builder: (context) => IndexRouter(reload: reload)),
                      jump
                    ];
                  }
                  return [
                    MaterialPageRoute(builder: (context) => IndexRouter(reload: reload)),
                    // MaterialPageRoute(
                    //     settings: RouteSettings(name: RouterPath.USER, arguments: "30782a8323b7c98b172c5a2af7206bb8283c655be6ddce11133611a03d5f1177"),
                    //     builder: (context) => UserRouter())
                  ];
                },
                // initialRoute: RouterPath.INDEX,
                routes: routes,
              );
            },
          ),
        ));
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
    // SystemTimer.run();
  }

  @override
  void dispose() {
    super.dispose();
    // SystemTimer.stopTask();
    WidgetsBinding.instance!.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState newState) {
    super.didChangeAppLifecycleState(newState);

    if (newState == AppLifecycleState.resumed &&
        (appState == AppLifecycleState.paused || appState == AppLifecycleState.hidden || appState == AppLifecycleState.inactive)) {
      //now you know that your app went to the background and is back to the foreground
      if (loggedUserSigner != null) {
        if (backgroundService != null && settingProvider.backgroundService) {
          backgroundService!.invoke('stopService');
        }

        followEventProvider.startSubscriptions();
        notificationsProvider.startSubscription();
      }
    }
    if (newState != AppLifecycleState.paused &&
        (appState == AppLifecycleState.resumed || appState == AppLifecycleState.hidden || appState == AppLifecycleState.inactive) &&
        backgroundService != null &&
        loggedUserSigner != null &&
        settingProvider.backgroundService) {
      backgroundService!.startService();
    }
    appState = newState;
  }

  ThemeData getLightTheme() {
    // Color background = const Color(0xff281237);
    Color background = const Color(0xFFF3E5F5);

    MaterialColor themeColor = const MaterialColor(
      0xffb583ce,
      <int, Color>{
        50: Color(0xFFF3E5F5),
        100: Color(0xFFE1BEE7),
        200: Color(0xFFCE93D8),
        300: Color(0xFFBA68C8),
        400: Color(0xFFAB47BC),
        500: Color(0xffaa529d),
        600: Color(0xFF8E24AA),
        700: Color(0xFF7B1FA2),
        800: Color(0xFF6A1B9A),
        900: Color(0xFF4A148C),
      },
    );

    // Color? mainTextColor;
    Color? topFontColor = Colors.white;
    Color hintColor = Colors.grey;
    var scaffoldBackgroundColor = background;

    double baseFontSize = settingProvider.fontSize;

    var textTheme = TextTheme(
      displaySmall: TextStyle(fontSize: baseFontSize - 2, fontFamily: 'Montserrat'),
      displayMedium: TextStyle(fontSize: baseFontSize, fontFamily: 'Montserrat'),
      displayLarge: TextStyle(fontSize: baseFontSize + 2, fontFamily: 'Montserrat'),
      headlineSmall: TextStyle(fontSize: baseFontSize - 2, fontFamily: 'Montserrat'),
      headlineMedium: TextStyle(fontSize: baseFontSize, fontFamily: 'Montserrat'),
      headlineLarge: TextStyle(fontSize: baseFontSize + 2, fontFamily: 'Montserrat'),
      titleSmall: TextStyle(fontSize: baseFontSize - 2, fontFamily: 'Montserrat'),
      titleMedium: TextStyle(fontSize: baseFontSize, fontFamily: 'Montserrat'),
      titleLarge: TextStyle(fontSize: baseFontSize + 2, fontFamily: 'Montserrat'),
      labelSmall: TextStyle(fontSize: baseFontSize - 2, fontFamily: 'Montserrat'),
      labelMedium: TextStyle(fontSize: baseFontSize, fontFamily: 'Montserrat'),
      labelLarge: TextStyle(fontSize: baseFontSize + 2, fontFamily: 'Montserrat'),
      bodyLarge: TextStyle(fontSize: baseFontSize + 2, height: 1.4),
      bodyMedium: TextStyle(fontSize: baseFontSize, height: 1.4),
      bodySmall: TextStyle(fontSize: baseFontSize - 2, height: 1.4),
    );
    var titleTextStyle = TextStyle(
      color: PlatformUtil.isPC() ? Colors.black : Colors.white,
    );

    if (settingProvider.fontFamily != null) {
      textTheme = GoogleFonts.getTextTheme(settingProvider.fontFamily!, textTheme);
      titleTextStyle = GoogleFonts.getFont(settingProvider.fontFamily!, textStyle: titleTextStyle);
    }

    return ThemeData(
      // fontFamily: 'Montserrat',
      useMaterial3: true,
      brightness: Brightness.light,
      platform: TargetPlatform.iOS,
      primarySwatch: themeColor,
      // scaffoldBackgroundColor: Base.SCAFFOLD_BACKGROUND_COLOR,
      // scaffoldBackgroundColor: Colors.grey[100],
      scaffoldBackgroundColor: scaffoldBackgroundColor,
      primaryColor: themeColor[500],
      appBarTheme: AppBarTheme(
        // color: Base.APPBAR_COLOR,
        backgroundColor: const Color(0xff281237),
        //   PlatformUtil.isPC() ? scaffoldBackgroundColor : themeColor[500],
        titleTextStyle: titleTextStyle,
        elevation: 0,
      ),
      // dividerColor: Colors.grey,
      cardColor: Colors.white,
      dividerColor: Colors.black,

      // indicatorColor: ColorsUtil.hexToColor("#818181"),
      textTheme: textTheme,
      hintColor: hintColor,
      buttonTheme: ButtonThemeData(),
    );
  }

  //===========================================================================================

  ThemeData getDarkTheme() {
    Color background = const Color(0xff281237);

    MaterialColor themeColor = const MaterialColor(
      0xffb583ce,
      <int, Color>{
        50: Color(0xFFF3E5F5),
        100: Color(0xFFE1BEE7),
        200: Color(0xFFCE93D8),
        300: Color(0xFFBA68C8),
        400: Color(0xFFAB47BC),
        500: Color(0xffaa529d),
        600: Color(0xFF8E24AA),
        700: Color(0xFF7B1FA2),
        800: Color(0xFF6A1B9A),
        900: Color(0xFF4A148C),
      },
    );

    Color? topFontColor = Colors.white;
    Color hintColor = Colors.grey;

    double baseFontSize = settingProvider.fontSize;

    var textTheme = TextTheme(
      displaySmall: TextStyle(fontSize: baseFontSize - 2, fontFamily: 'Montserrat'),
      displayMedium: TextStyle(fontSize: baseFontSize, fontFamily: 'Montserrat'),
      displayLarge: TextStyle(fontSize: baseFontSize + 2, fontFamily: 'Montserrat'),
      headlineSmall: TextStyle(fontSize: baseFontSize - 2, fontFamily: 'Montserrat'),
      headlineMedium: TextStyle(fontSize: baseFontSize, fontFamily: 'Montserrat'),
      headlineLarge: TextStyle(fontSize: baseFontSize + 2, fontFamily: 'Montserrat'),
      titleSmall: TextStyle(fontSize: baseFontSize - 2, fontFamily: 'Montserrat'),
      titleMedium: TextStyle(fontSize: baseFontSize, fontFamily: 'Montserrat'),
      titleLarge: TextStyle(fontSize: baseFontSize + 2, fontFamily: 'Montserrat'),
      labelSmall: TextStyle(fontSize: baseFontSize - 2, fontFamily: 'Montserrat'),
      labelMedium: TextStyle(fontSize: baseFontSize, fontFamily: 'Montserrat'),
      labelLarge: TextStyle(fontSize: baseFontSize + 2, fontFamily: 'Montserrat'),
      bodyLarge: TextStyle(fontSize: baseFontSize + 2, height: 1.4),
      bodyMedium: TextStyle(fontSize: baseFontSize, height: 1.4),
      bodySmall: TextStyle(fontSize: baseFontSize - 2, height: 1.4),
    );
    var titleTextStyle = TextStyle(
      color: topFontColor,
      // color: Colors.black,
    );

    if (settingProvider.fontFamily != null) {
      textTheme = GoogleFonts.getTextTheme(settingProvider.fontFamily!, textTheme);
      titleTextStyle = GoogleFonts.getFont(settingProvider.fontFamily!, textStyle: titleTextStyle);
    }

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      platform: TargetPlatform.iOS,
      primarySwatch: themeColor,
      scaffoldBackgroundColor: Colors.grey[900],
      primaryColor: themeColor[500],
      appBarTheme: AppBarTheme(
        // color: Base.APPBAR_COLOR,
        backgroundColor: background,
        titleTextStyle: titleTextStyle,
        elevation: 0,
      ),
      dividerColor: Colors.grey[200],
      cardColor: Colors.black,
      canvasColor: Colors.grey[900],
      // indicatorColor: ColorsUtil.hexToColor("#818181"),
      textTheme: textTheme,
      hintColor: hintColor,
    );
  }

  void setGetTimeAgoDefaultLocale(Locale? locale) {
    String? localeName = Intl.defaultLocale;
    if (locale != null) {
      localeName = LocaleUtil.getLocaleKey(locale);
    }

    if (StringUtil.isNotBlank(localeName)) {
      if (GetTimeAgoSupportLocale.containsKey(localeName)) {
        GetTimeAgo.setDefaultLocale(localeName!);
      } else if (localeName == "zh_tw") {
        GetTimeAgo.setDefaultLocale("zh_tr");
      }
    }
  }
}

final Map<String, int> GetTimeAgoSupportLocale = {
  'ar': 1,
  'en': 1,
  'es': 1,
  'fr': 1,
  'hi': 1,
  'pt': 1,
  'br': 1,
  'zh': 1,
  'zh_tr': 1,
  'ja': 1,
  'oc': 1,
  'ko': 1,
  'de': 1,
  'id': 1,
  'tr': 1,
  'ur': 1,
  'vi': 1,
};
