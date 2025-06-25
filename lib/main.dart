import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:amberflutter/amberflutter.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart'
    as FlutterCacheManager;
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:get_time_ago/get_time_ago.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/single_child_widget.dart'; // Added for SingleChildWidget
import 'package:intl/intl.dart';
import 'package:ndk/config/bootstrap_relays.dart';
import 'package:ndk/entities.dart';
import 'package:ndk/ndk.dart';
import 'package:ndk/shared/helpers/relay_helper.dart';
import 'package:ndk_amber/data_layer/data_sources/amber_flutter.dart';
import 'package:ndk_amber/data_layer/repositories/signers/amber_event_signer.dart';
import 'package:ndk_objectbox/data_layer/db/object_box/db_object_box.dart';
import 'package:ndk_rust_verifier/ndk_rust_verifier.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:protocol_handler/protocol_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:window_manager/window_manager.dart';
import 'package:yana/nostr/nip07/extension_event_signer.dart';
import 'package:yana/nostr/nip19/nip19.dart';
import 'package:yana/nostr/nip19/nip19_tlv.dart';
import 'package:yana/provider/badge_definition_provider.dart';
import 'package:yana/router/user/media_servers_router.dart';
import 'package:yana/utils/router_path.dart';
import 'package:yana/provider/community_info_provider.dart';
import 'package:yana/provider/custom_emoji_provider.dart';
import 'package:yana/provider/follow_new_event_provider.dart';
import 'package:yana/provider/new_notifications_provider.dart';
import 'package:yana/provider/nwc_provider.dart';
import 'package:yana/router/login/login_router.dart';
import 'package:yana/router/relays/relay_info_router.dart';
import 'package:yana/router/search/search_router.dart';
import 'package:yana/router/setting/wallet_settings_router.dart';
import 'package:yana/router/user/followed_router.dart';
import 'package:yana/router/user/followed_tags_list_router.dart';
import 'package:yana/router/user/mute_list_router.dart';
import 'package:yana/router/user/relay_list_router.dart';
import 'package:yana/router/user/relay_set_router.dart';
import 'package:yana/router/user/user_history_contact_list_router.dart';
import 'package:yana/router/user/user_zap_list_router.dart';
import 'package:yana/router/wallet/nwc_router.dart';
import 'package:yana/router/wallet/transactions_router.dart';
import 'package:yana/router/wallet/wallet_receive.dart';
import 'package:yana/router/wallet/wallet_receive_invoice.dart';
import 'package:yana/router/wallet/wallet_router.dart';
import 'package:yana/router/wallet/wallet_send.dart';
import 'package:yana/router/wallet/wallet_send_confirm.dart';
import 'package:yana/utils/image/cache_manager_builder.dart';
import 'package:yana/utils/platform_util.dart';
import 'package:go_router/go_router.dart';

import '/js/js_helper.dart' as js;
import 'config/app_features.dart';
import 'i18n/i18n.dart';
import 'nostr/client_utils/keys.dart';
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
import 'utils/string_util.dart';
import 'utils/theme_style.dart';

late SharedPreferences sharedPreferences;

late SettingProvider settingProvider;

late MetadataProvider metadataProvider;

late ContactListProvider? contactListProvider;

late FollowEventProvider? followEventProvider;

late FollowNewEventProvider? followNewEventProvider;

late NotificationsProvider? notificationsProvider;

late NewNotificationsProvider? newNotificationsProvider;

DMProvider? dmProvider;

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

late Map<String, WidgetBuilder>? routes; // Legacy routes map - will be removed
late GoRouter appRouter; // GoRouter instance

late WebViewProvider webViewProvider;

late CustomEmojiProvider customEmojiProvider;

late CommunityApprovedProvider communityApprovedProvider;

late CommunityInfoProvider communityInfoProvider;

NwcProvider? nwcProvider; // Made nullable

Map<String, dynamic>? fiatCurrencyRate;

AppLifecycleState appState = AppLifecycleState.resumed;

EventSigner? get loggedUserSigner => ndk.accounts.getLoggedAccount()?.signer;

AmberFlutterDS amberFlutterDS = AmberFlutterDS(Amberflutter());
late CacheManager cacheManager;
final logLevel = Logger.logLevels.debug;
final eventVerifier = RustEventVerifier();
Ndk ndk =
//Ndk.emptyBootstrapRelaysConfig();// = Ndk(
    Ndk(
  NdkConfig(
      eventVerifier: eventVerifier,
      cache: cacheManager,
      // eventOutFilters: [filterProvider],
      logLevel: logLevel),
);

late bool isExternalSignerInstalled;

RelaySet? feedRelaySet;
RelaySet? myInboxRelaySet;
RelaySet? myOutboxRelaySet;

List<String> searchRelays = [];

bool firstLogin = false;

late PackageInfo packageInfo;

// FlutterBackgroundService? backgroundService;

// late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

int c = 0;

const DEFAULT_BLOSSOM_SERVERS = [
  'https://nostr.download',
  'https://blossom.band',
  'https://cdn.hzrd149.com',
  'https://blossom.primal.net',
  'https://cdn.nostrcheck.me'
  'https://files.v0l.io',
];

// @pragma('vm:entry-point')
// void onStart(ServiceInstance service) async {
//   DartPluginRegistrant.ensureInitialized();
//   GestureBinding.instance.resamplingEnabled = true;
//
//   if (service is AndroidServiceInstance) {
//     service.on('setAsForeground').listen((event) {
//       service.setAsForegroundService();
//     });
//
//     service.on('setAsBackground').listen((event) {
//       service.setAsBackgroundService();
//     });
//   }
//
//   service.on('stopService').listen((event) {
//     service.stopSelf();
//   });
//
//   // await initProvidersAndStuff();
//   SettingProvider ss = await SettingProvider.getInstance();
//   if (!ss.backgroundService) {
//     service.stopSelf();
//   } else {
//     Timer.periodic(const Duration(seconds: 60), (timer) {
//       if (service is AndroidServiceInstance) {
//         AwesomeNotifications().getAppLifeCycle().then((value) async {
//           if (value.toString() != "NotificationLifeCycle.Foreground" &&
//               myInboxRelaySet != null) {
//             appState = AppLifecycleState.inactive;
//             ndk.relays.allowReconnectRelays = true;
//             await ndk.relays.reconnectRelays(myInboxRelaySet!.urls);
//             await newNotificationsProvider.queryNew();
//             ndk.relays.allowReconnectRelays = false;
//             // List<String> requestIdsToClose =
//             //     ndk.relays.globalState.inFlightRequests.keys.toList();
//             // for (var id in requestIdsToClose) {
//               // try {
//               //   ndk.requests.closeSubscription(id);
//               // } catch (e) {
//               //   print(e);
//               // }
//             // }
//             await ndk.relays.closeAllTransports();
//           }
//         });
//       }
//     });
//   }
// }

// Future<void> initProvidersAndStuff() async {
//   sharedPreferences = await DataUtil.getInstance();
//   metadataProvider = await MetadataProvider.getInstance();
//   relayProvider = RelayProvider.getInstance();
//
//   settingProvider = await SettingProvider.getInstance();
//   if (StringUtil.isNotBlank(settingProvider.key)) {
//     try {
//       String? key = settingProvider.key;
//       if (StringUtil.isNotBlank(key)) {
//         bool isPrivate = settingProvider.isPrivateKey;
//         String publicKey = isPrivate ? getPublicKey(key!) : key!;
//         EventSigner eventSigner = settingProvider.isExternalSignerKey
//             ? AmberEventSigner(
//                 publicKey: publicKey, amberFlutterDS: amberFlutterDS)
//             : isPrivate || !PlatformUtil.isWeb()
//                 ? Bip340EventSigner(
//                     privateKey: isPrivate ? key : null, publicKey: publicKey)
//                 : Nip07EventSigner(await js.getPublicKeyAsync());
//         await ndk.destroy();
//         ndk = Ndk(NdkConfig(
//             eventVerifier: eventVerifier,
//             cache: cacheManager,
//             eventSigner: eventSigner,
//             // eventOutFilters: [filterProvider],
//             logLevel: logLevel));
//       }
//       //
//       // loggedUserSigner = Bip340EventSigner(settingProvider.key!, getPublicKey(settingProvider.key!));
//       // filterProvider = FilterProvider.getInstance();
//       //    ndk.relays.eventFilters.add(filterProvider);
//       IsarCacheManager dbCacheManager = IsarCacheManager();
//       await dbCacheManager.init(
//           directory: PlatformUtil.isWeb()
//               ? isar.Isar.sqliteInMemory
//               : (await getApplicationDocumentsDirectory()).path);
//       // DbObjectBox dbCacheManager = DbObjectBox();
//       // cacheManager = dbCacheManager;
//       // TODO uncomment this
//       // dbCacheManager.eventFilter = filterProvider;
//       //ndk.relays.eventVerifier = HybridEventVerifier();
//
//       if (myInboxRelaySet == null) {
//         await ndk.relays.reconnectRelays(ndk.relays.globalState.relays.keys);
//         UserRelayList? userRelayList = await ndk.userRelayLists
//             .getSingleUserRelayList(loggedUserSigner!.getPublicKey());
//         if (userRelayList != null) {
//           createMyRelaySets(userRelayList);
//         }
//       }
//       // await ndk.relays.connect(urls: userRelayList != null ? userRelayList.urls :ndk.relays.DEFAULT_BOOTSTRAP_RELAYS);
//       // await relayProvider!.loadRelays(loggedUserSigner!.getPublicKey(), () {
//       //   relayProvider.addRelays(nostr!).then((bla) {
//       notificationsProvider = NotificationsProvider();
//       dmProvider = DMProvider();
//       newNotificationsProvider = NewNotificationsProvider();
//       //   });
//       // });
//       // log("nostr init over");
//     } catch (e) {
//       print(e);
//       // var index = settingProvider.privateKeyIndex;
//       // if (index != null) {
//       //   settingProvider.removeKey(index);
//       // }
//     }
//   }
// }

Future<void> initRelays({bool newKey = false}) async {
  if (!AppFeatures.enableSocial) {
    return;
  }
  // EasyLoading.dismiss();
  // EasyLoading.showToast("connecting to bootstrap relays...",
  //     dismissOnTap: true,
  //     duration: const Duration(seconds: 15),
  //     maskType: EasyLoadingMaskType.black);
  // await ndk.relays.reconnectRelays(ndk.relays.globalState.relays.keys);

  // CacheManager cache = MemCacheManager();
  // final Ndk ndk2 = Ndk(
  //   NdkConfig(
  //     eventVerifier: Bip340EventVerifier(),
  //     cache: cache,
  //     eventOutFilters:  [filterProvider]
  //   ),
  // );
  //
  // UserRelayList? cached = await cache.loadUserRelayList('30782a8323b7c98b172c5a2af7206bb8283c655be6ddce11133611a03d5f1177');
  //
  // final UserRelayList? response = await ndk2.userRelayLists.getSingleUserRelayList(
  //     '30782a8323b7c98b172c5a2af7206bb8283c655be6ddce11133611a03d5f1177');
  //
  // // read entity
  // print("RELAYS:");
  // print(response?.relays.length ?? "no relays");
  // print(response!.toNip65());

//   await for (final event in (ndk.requests.query(
// //                timeout: missingPubKeys.length > 1 ? 10 : 3,
//       timeout: const Duration(seconds:3),
//       filters: [
//         Filter(
//             authors: [loggedUserSigner!.getPublicKey()],
//             kinds: [Nip65.kKind, ContactList.kKind])
//       ])).stream) {
//     print("$event");
//   }

  // await ndk.userRelayLists.loadMissingRelayListsFromNip65OrNip02([loggedUserSigner!.getPublicKey()],
  //   onProgress: (stepName, count, total) {
  //     print("step $stepName, count $count total $total");
  //   });
  // await EasyLoading.dismiss();
  // await EasyLoading.showToast("Searching for relay list...",
  //     dismissOnTap: true,
  //     duration: const Duration(seconds: 15),
  //     maskType: EasyLoadingMaskType.black);
  // UserRelayList? userRelayList =
  //     await cacheManager.loadUserRelayList(loggedUserSigner!.getPublicKey());

  UserRelayList? userRelayList = await ndk.userRelayLists
      .getSingleUserRelayList(loggedUserSigner!.getPublicKey());
  if (userRelayList == null) {
    int now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    userRelayList = UserRelayList(
        pubKey: loggedUserSigner!.getPublicKey(),
        relays: {
          for (String url in DEFAULT_BOOTSTRAP_RELAYS)
            url: ReadWriteMarker.readWrite
        },
        createdAt: now,
        refreshedTimestamp: now);
  }
  createMyRelaySets(userRelayList);
  // await EasyLoading.dismiss();
  // await EasyLoading.showToast("Connecting to your relays...",
  //     dismissOnTap: true,
  //     duration: const Duration(seconds: 15),
  //     maskType: EasyLoadingMaskType.black);

  ndk.lists.getSingleNip51List(Nip51List.kMute, loggedUserSigner!).then(
    (list) {
      filterProvider.muteList = list;
      //ndk.relays.eventFilters.add(filterProvider);
      ndk.relays.globalState.blockedRelays = {};
      ndk.lists
          .getSingleNip51List(Nip51List.kBlockedRelays, loggedUserSigner!)
          .then(
        (blockedRelays) {
          if (blockedRelays != null) {
            ndk.relays.globalState.blockedRelays =
                blockedRelays.allRelays.toSet();
            relayProvider.notifyListeners();
          }
          searchRelays = [];
          ndk.lists
              .getSingleNip51List(Nip51List.kSearchRelays, loggedUserSigner!)
              .then((searchRelaySet) {
            if (searchRelaySet != null) {
              searchRelays = searchRelaySet.allRelays;
              for (var url in searchRelays) {
                ndk.relays.reconnectRelay(url,
                    connectionSource: ConnectionSource.nip51Search);
              }
              relayProvider.notifyListeners();
            }
          });
        },
      );
    },
  );

  // await EasyLoading.dismiss();
  // await EasyLoading.showToast("Loading contact list...",
  //     dismissOnTap: true,
  //     duration: const Duration(seconds: 15),
  //     maskType: EasyLoadingMaskType.black);
  ContactList? contactList = !newKey
      ? await ndk.follows.getContactList(loggedUserSigner!.getPublicKey())
      : null;
  if (contactList != null) {
    for (var element in contactList.contacts) {
      metadataProvider.getMetadata(element);
    }

    print("Loaded ${contactList.contacts.length} contacts...");
    if (settingProvider.gossip == 1) {
      feedRelaySet = await cacheManager.loadRelaySet(
          "feed", loggedUserSigner!.getPublicKey());
      if (feedRelaySet == null) {
        // EasyLoading.showToast(
        //     "Calculating feed relays from contact's outboxes...",
        //     dismissOnTap: true,
        //     duration: const Duration(seconds: 15),
        //     maskType: EasyLoadingMaskType.black);

        feedRelaySet = await ndk.relaySets.calculateRelaySet(
            name: "feed",
            ownerPubKey: loggedUserSigner!.getPublicKey(),
            pubKeys: contactList.contacts,
            direction: RelayDirection.outbox,
            relayMinCountPerPubKey: settingProvider.followeesRelayMinCount);
        await cacheManager.saveRelaySet(feedRelaySet!);
      } else {
        final startTime = DateTime.now();
        print("connecting ${feedRelaySet!.relaysMap.length} relays");
        List<bool> connected = await Future.wait(feedRelaySet!.relaysMap.keys
            .map((url) => ndk.relays.reconnectRelay(url,
                connectionSource: ConnectionSource.unknown)));
        final endTime = DateTime.now();
        final duration = endTime.difference(startTime);
        print(
            "CONNECTED ${connected.where((element) => element).length} , ${connected.where((element) => !element).length} FAILED took ${duration.inMilliseconds} ms");
      }
    }
  }
  // await EasyLoading.dismiss();

  followEventProvider?.startSubscriptions();
  if (AppFeatures.enableNotifications && notificationsProvider != null) {
    notificationsProvider?.loadCached().then(
      (value) {
        notificationsProvider?.startSubscription();
      },
    );
  }
  if (dmProvider != null) {
    dmProvider!.initDMSessions(loggedUserSigner!.getPublicKey());
  }
  metadataProvider.notifyListeners();
  // try {
  //   if (PlatformUtil.isAndroid() || PlatformUtil.isIOS()) {
  //     initBackgroundService(settingProvider.backgroundService);
  //   }
  // } catch (e) {}
}

Future<List<String>> getInboxRelays(String pubKey) async {
  List<String> urlsToBroadcast = [];
  UserRelayList? userRelayList =
      await ndk.userRelayLists.getSingleUserRelayList(pubKey);
  if (userRelayList != null) {
    urlsToBroadcast = userRelayList.readUrls.toList();
  }
  return urlsToBroadcast;
}

Future<List<String>> broadcastUrls(String? reactionInboxPubKey) async {
  List<String> urlsToBroadcast = [];
  if (settingProvider.inboxForReactions == 1 && reactionInboxPubKey != null) {
    urlsToBroadcast = await getInboxRelays(reactionInboxPubKey);
    if (urlsToBroadcast.length > settingProvider.broadcastToInboxMaxCount) {
      urlsToBroadcast = urlsToBroadcast
          .take(settingProvider.broadcastToInboxMaxCount)
          .toList();
    }
  }
  if (urlsToBroadcast.isEmpty) {
    urlsToBroadcast = myOutboxRelaySet!.urls.toList();
  }
  return urlsToBroadcast;
}

void createMyRelaySets(UserRelayList userRelayList) {
  print("FROM USER RELAY LIST: ");
  for (var entry in userRelayList.relays.entries) {
    print("  - ${entry.key} : ${entry.value}");
  }

  Map<String, List<PubkeyMapping>> inbox = {
    for (var item
        in userRelayList.relays.entries.where((entry) => entry.value.isRead))
      cleanRelayUrl(item.key) ?? item.key: [
        PubkeyMapping(pubKey: userRelayList.pubKey, rwMarker: item.value)
      ]
  };
  Map<String, List<PubkeyMapping>> outbox = {
    for (var item
        in userRelayList.relays.entries.where((entry) => entry.value.isWrite))
      cleanRelayUrl(item.key) ?? item.key: [
        PubkeyMapping(pubKey: userRelayList.pubKey, rwMarker: item.value)
      ]
  };
  myInboxRelaySet = RelaySet(
      name: "inbox",
      pubKey: userRelayList.pubKey,
      relayMinCountPerPubkey: inbox.length,
      direction: RelayDirection.inbox,
      relaysMap: inbox,
      notCoveredPubkeys: []);
  myOutboxRelaySet = RelaySet(
      name: "outbox",
      pubKey: userRelayList.pubKey,
      relayMinCountPerPubkey: outbox.length,
      direction: RelayDirection.outbox,
      relaysMap: outbox);
  print("GENERATED INBOX: ");
  for (var entry in myInboxRelaySet!.relaysMap.entries) {
    print("  - ${entry.key} : ${entry.value.first.rwMarker}");
  }
  print("GENERATED OUTBOX: ");
  for (var entry in myOutboxRelaySet!.relaysMap.entries) {
    print("  - ${entry.key} : ${entry.value.first.rwMarker}");
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  packageInfo = await PackageInfo.fromPlatform();
  try {
    await protocolHandler.register(NwcProvider.NWC_PROTOCOL_PREFIX);
    await protocolHandler.register('lightning');
    await protocolHandler.register('yana');
    await protocolHandler.register('nostr');
  } catch (err) {
    print(err);
  }

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
  if (!PlatformUtil.isTableModeWithoutSetting()) {
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
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);
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

  if (AppFeatures.enableSocial) {
    contactListProvider = ContactListProvider.getInstance();
    followEventProvider = FollowEventProvider();
    followNewEventProvider = FollowNewEventProvider();
  } else {
    contactListProvider = null;
    followEventProvider = null;
    followNewEventProvider = null;
  }

  if (AppFeatures.enableNotifications) {
    notificationsProvider = NotificationsProvider();
    newNotificationsProvider = NewNotificationsProvider();

    // Set up callbacks to avoid circular dependency
    notificationsProvider!.clearNewNotifications = () {
      newNotificationsProvider?.clear();
    };

    notificationsProvider!.handleNewNotification = (Nip01Event event) {
      newNotificationsProvider?.handleEvent(event, null);
    };

    notificationsProvider!.mergeNewEvents = () {
      var allEvents = newNotificationsProvider?.eventMemBox?.all() ?? [];
      notificationsProvider!.eventBox.addList(allEvents);
      // sort
      notificationsProvider!.eventBox.sort();
      newNotificationsProvider?.clear();
      notificationsProvider!.setTimestampToNewestAndSave();
      // update ui
      notificationsProvider!.notifyListeners();
    };
  } else {
    notificationsProvider = null;
    newNotificationsProvider = null;
  }
  if (AppFeatures.enableDm) {
    dmProvider = DMProvider();
  }
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
  if (AppFeatures.enableWallet) {
    nwcProvider = NwcProvider();
  } else {
    nwcProvider = null; // Ensure it's null when wallet is disabled
  }

  // IsarCacheManager dbCacheManager = IsarCacheManager();
  DbObjectBox dbCacheManager = DbObjectBox();
  try {
    await dbCacheManager.dbRdy;
    // await dbCacheManager.init(
    //     directory: PlatformUtil.isWeb()
    //         ? isar.Isar.sqliteInMemory
    //         : (await getApplicationDocumentsDirectory()).path);
    cacheManager = dbCacheManager;
  } catch (e) {
    cacheManager = MemCacheManager();
    print(e);
  }

  final amber = Amberflutter();
  isExternalSignerInstalled =
      Platform.isAndroid && await amber.isAppInstalled();

  String? key = settingProvider.key;
  if (StringUtil.isNotBlank(key)) {
    bool isPrivate = settingProvider.isPrivateKey;
    String publicKey = isPrivate ? getPublicKey(key!) : key!;
    EventSigner? eventSigner;
    if (settingProvider.isExternalSignerKey && isExternalSignerInstalled) {
      eventSigner = AmberEventSigner(
          publicKey: publicKey, amberFlutterDS: amberFlutterDS);
    } else {
      eventSigner = isPrivate || !PlatformUtil.isWeb()
          ? Bip340EventSigner(
              privateKey: isPrivate ? key : null, publicKey: publicKey)
          : Nip07EventSigner(await js.getPublicKeyAsync());
    }
    ndk.accounts.loginExternalSigner(signer: eventSigner);
  }
  if (loggedUserSigner == null && !AppFeatures.isWalletOnly) {
    String priv = generatePrivateKey();
    await settingProvider.addAndChangeKey(priv, true, false, updateUI: false);
    String publicKey = getPublicKey(priv);
    ndk.accounts.loginPrivateKey(pubkey: publicKey, privkey: priv);
  }
  if (loggedUserSigner != null) {
    followEventProvider?.loadCachedFeed();
    initRelays();
    if (AppFeatures.enableWallet) {
      nwcProvider?.init(); // Use null-aware access
    }
  }

  AppFeatures.printActiveFeatures(); // Optional: Print features for this flavor
  runApp(MyApp());
}

Future<bool> checkBackgroundPermission() async {
  bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
  if (!isAllowed) {
    bool allowed = await AwesomeNotifications()
        .requestPermissionToSendNotifications(permissions: [
      NotificationPermission.Vibration,
      NotificationPermission.Badge,
      NotificationPermission.Light,
      NotificationPermission.Sound,
      NotificationPermission.PreciseAlarms,
    ]).then((value) {
      print(value);
      return false;
    });
    if (!allowed) {
      return false;
    }
  }
  return true;
}

Future<void> initBackgroundService(bool startOnBoot) async {
  if (!AppFeatures.enableNotifications) {
    return;
  }
  // await AndroidAlarmManager.initialize();
  // const int helloAlarmID = 0;
  // await AndroidAlarmManager.periodic(const Duration(seconds: 10), helloAlarmID, printHello, wakeup: true, exact: true, allowWhileIdle: true, rescheduleOnReboot: true);
  if (!settingProvider.backgroundService) {
    return;
  }
  await checkBackgroundPermission();
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
    onNotificationCreatedMethod:
        NewNotificationsProvider.onNotificationCreatedMethod,
  );

  /// OPTIONAL, using custom notification channel id
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'yana-service', // id
    'Background service (can be hidden)', // title
    showBadge: false,
    description:
        'This channel is needed to be running in order for the system not to kill all used for important notifications.',
    // description
    importance: Importance.low, // importance must be at low or higher level
  );

  var flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  // if (startOnBoot) {
  // backgroundService = FlutterBackgroundService();
  // await flutterLocalNotificationsPlugin
  //     .resolvePlatformSpecificImplementation<
  //         AndroidFlutterLocalNotificationsPlugin>()
  //     ?.createNotificationChannel(channel);
  //
  // await backgroundService!.configure(
  //   androidConfiguration: AndroidConfiguration(
  //     onStart: onStart,
  //     autoStart: false,
  //     autoStartOnBoot: startOnBoot,
  //     isForegroundMode: true,
  //     notificationChannelId: 'yana-service',
  //     initialNotificationTitle: 'Background service',
  //     initialNotificationContent:
  //         'Needed for de-googled notifications. You can hide this: long-press -> settings -> Notification categories',
  //     foregroundServiceNotificationId: 888,
  //   ),
  //   iosConfiguration: IosConfiguration(
  //     autoStart: false,
  //     onForeground: onStart,
  //     // you have to enable background fetch capability on xcode project
  //     // onBackground: onIosBackground,
  //   ),
  // );
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
// await for (var data in port) {
//   print("ISOLATE data received " + data.toString());
//   // `data` is the message received.
// }
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

  String? _handleNostrUrl(String url) {
    RegExpMatch? match = Nip19.nip19regex.firstMatch(url);

    if (match != null) {
      var key = match.group(2)! + match.group(3)!;

      if (Nip19.isPubkey(key)) {
        // Handle npub - go to user profile
        if (key.length > Nip19.NPUB_LENGTH) {
          key = key.substring(0, Nip19.NPUB_LENGTH);
        }
        String pubkey = Nip19.decode(key);
        if (AppFeatures.enableSocial) {
          return "${RouterPath.USER}?pubkey=$pubkey";
        }
      } else if (Nip19.isNoteId(key)) {
        // Handle note - go to thread detail
        if (key.length > Nip19.NOTEID_LENGTH) {
          key = key.substring(0, Nip19.NOTEID_LENGTH);
        }
        String noteId = Nip19.decode(key);
        if (AppFeatures.enableSocial) {
          return "${RouterPath.THREAD_DETAIL}?id=$noteId";
        }
      } else if (NIP19Tlv.isNprofile(key)) {
        // Handle nprofile - go to user profile
        var nprofile = NIP19Tlv.decodeNprofile(key);
        if (nprofile != null && AppFeatures.enableSocial) {
          return "${RouterPath.USER}?pubkey=${nprofile.pubkey}";
        }
      } else if (NIP19Tlv.isNrelay(key)) {
        // Handle nrelay - go to relay info
        var nrelay = NIP19Tlv.decodeNrelay(key);
        String? relayUrl = nrelay != null ? cleanRelayUrl(nrelay.addr) : null;
        if (relayUrl != null) {
          return "${RouterPath.RELAY_INFO}?url=$relayUrl";
        }
      } else if (NIP19Tlv.isNevent(key)) {
        // Handle nevent - go to thread detail
        var nevent = NIP19Tlv.decodeNevent(key);
        if (nevent != null && AppFeatures.enableSocial) {
          return "${RouterPath.THREAD_DETAIL}?id=${nevent.id}";
        }
      } else if (NIP19Tlv.isNaddr(key)) {
        // Handle naddr
        var naddrData = NIP19Tlv.decodeNaddr(key);
        if (naddrData != null && AppFeatures.enableSocial) {
          if (StringUtil.isNotBlank(naddrData.id) &&
              naddrData.kind == Nip01Event.kTextNodeKind) {
            return "${RouterPath.THREAD_DETAIL}?id=${naddrData.id}";
          } else if (StringUtil.isNotBlank(naddrData.author) &&
              naddrData.kind == Metadata.kKind) {
            return "${RouterPath.USER}?pubkey=${naddrData.author}";
          }
        }
      }
    }

    // If we can't handle the nostr URL, go to index
    return RouterPath.INDEX;
  }

  @override
  Widget build(BuildContext context) {
    Locale? _locale;
    if (StringUtil.isNotBlank(settingProvider.i18n)) {
      for (var item in I18n.delegate.supportedLocales) {
        if (item.languageCode == settingProvider.i18n &&
            item.countryCode == settingProvider.i18nCC) {
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

    // Initialize GoRouter with proper route configuration
    appRouter = GoRouter(
      initialLocation: RouterPath.INDEX,
      redirect: (context, state) {
        // Handle nostr: URLs similar to the old onGenerateInitialRoutes logic
        final fullPath = state.uri.toString();
        if (fullPath.startsWith("nostr:")) {
          return _handleNostrUrl(fullPath);
        }
        return null; // No redirect needed
      },
      routes: [
        GoRoute(
          path: RouterPath.INDEX,
          builder: (context, state) => AppFeatures.isWalletOnly ? WalletRouter(showAppBar: true) : IndexRouter(reload: reload),
          routes: <RouteBase>[
            GoRoute(
              path: RouterPath.USER_RELAYS,
              builder: (context, state) => const UserRelayRouter(),
            ),
            GoRoute(
              path: RouterPath.THREAD_DETAIL,
              builder: (context, state) {
                // Get thread id from query parameters
                String? threadId = state.uri.queryParameters['id'];
                return ThreadDetailRouter(eventId: threadId);
              },
            ),
            GoRoute(
              path: RouterPath.EVENT_DETAIL,
              builder: (context, state) => const EventDetailRouter(),
            ),
            GoRoute(
              path: RouterPath.TAG_DETAIL,
              builder: (context, state) => const TagDetailRouter(),
            ),
            if (AppFeatures.enableSocial) ...[
              GoRoute(
                path: RouterPath.USER,
                builder: (context, state) {
                  // Get pubkey from query parameters
                  String? pubkey = state.uri.queryParameters['pubkey'];
                  return UserRouter(pubKey: pubkey);
                },
              ),
              GoRoute(
                path: RouterPath.PROFILE_EDITOR,
                builder: (context, state) => const ProfileEditorRouter(),
              ),
              GoRoute(
                path: RouterPath.USER_CONTACT_LIST,
                builder: (context, state) => const UserContactListRouter(),
              ),
              GoRoute(
                path: RouterPath.USER_HISTORY_CONTACT_LIST,
                builder: (context, state) => UserHistoryContactListRouter(),
              ),
              GoRoute(
                path: RouterPath.USER_ZAP_LIST,
                builder: (context, state) => const UserZapListRouter(),
              ),
              GoRoute(
                path: RouterPath.FOLLOWED_TAGS_LIST,
                builder: (context, state) => const FollowedTagsListRouter(),
              ),
              GoRoute(
                path: RouterPath.FOLLOWED,
                builder: (context, state) => FollowedRouter(),
              ),
              GoRoute(
                path: RouterPath.FOLLOWED_COMMUNITIES,
                builder: (context, state) => const FollowedCommunitiesRouter(),
              ),
              GoRoute(
                path: RouterPath.COMMUNITY_DETAIL,
                builder: (context, state) => const CommunityDetailRouter(),
              ),
              GoRoute(
                path: RouterPath.RELAY_SET,
                builder: (context, state) => const RelaySetRouter(),
              ),
              GoRoute(
                path: RouterPath.RELAY_LIST,
                builder: (context, state) => const RelayListRouter(),
              ),
              GoRoute(
                path: RouterPath.MEDIA_SERVERS,
                builder: (context, state) => const MediaServersRouter(),
              ),
              GoRoute(
                path: RouterPath.MUTE_LIST,
                builder: (context, state) => const MuteListRouter(),
              ),
              if (AppFeatures.enableDm)
                GoRoute(
                  path: RouterPath.DM_DETAIL,
                  builder: (context, state) => const DMDetailRouter(),
                ),
              GoRoute(
                path: RouterPath.NOTICES,
                builder: (context, state) => const NoticeRouter(),
              ),
              if (AppFeatures.enableSearch)
                GoRoute(
                  path: RouterPath.SEARCH,
                  builder: (context, state) => const SearchRouter(),
                ),
              GoRoute(
                path: RouterPath.KEY_BACKUP,
                builder: (context, state) => const KeyBackupRouter(),
              ),
              // Conditional wallet routes
              if (AppFeatures.enableWallet) ...[
                GoRoute(
                  path: RouterPath.WALLET,
                  builder: (context, state) => const WalletRouter(),
                ),
                GoRoute(
                  path: RouterPath.WALLET_TRANSACTIONS,
                  builder: (context, state) => const TransactionsRouter(),
                ),
                GoRoute(
                  path: RouterPath.WALLET_RECEIVE,
                  builder: (context, state) => const WalletReceiveRouter(),
                ),
                GoRoute(
                  path: RouterPath.WALLET_RECEIVE_INVOICE,
                  builder: (context, state) => const WalletReceiveInvoiceRouter(),
                ),
                GoRoute(
                  path: RouterPath.WALLET_SEND,
                  builder: (context, state) => const WalletSendRouter(),
                ),
                GoRoute(
                  path: RouterPath.WALLET_SEND_CONFIRM,
                  builder: (context, state) => const WalletSendConfirmRouter(),
                ),
                GoRoute(
                  path: RouterPath.NWC,
                  builder: (context, state) => const NwcRouter(),
                ),
                GoRoute(
                  path: RouterPath.SETTINGS_WALLET,
                  builder: (context, state) => const WalletSettingsRouter(),
                ),
              ],
              GoRoute(
                path: RouterPath.RELAYS,
                builder: (context, state) => const RelaysRouter(),
              ),
              GoRoute(
                path: RouterPath.SETTING,
                builder: (context, state) => SettingRouter(indexReload: reload),
              ),
              GoRoute(
                path: RouterPath.QRSCANNER,
                builder: (context, state) => const QRScannerRouter(),
              ),
              GoRoute(
                path: RouterPath.RELAY_INFO,
                builder: (context, state) => const RelayInfoRouter(),
              ),
              GoRoute(
                path: RouterPath.LOGIN,
                builder: (context, state) => const LoginRouter(canGoBack: true),
              ),
            ],
          ]
        ),
        GoRoute(
          path: '/dynamic',
          builder: (context, state) {
            return state.extra as Widget;
          },
        ),
      ],
    );

    // Routes are now handled by GoRouter - remove the old routes map

    List<SingleChildWidget> providerList = [
      ListenableProvider<SettingProvider>.value(value: settingProvider),
      ListenableProvider<MetadataProvider>.value(value: metadataProvider),
      ListenableProvider<IndexProvider>.value(value: indexProvider),
      if (AppFeatures.enableSocial && contactListProvider != null)
        ListenableProvider<ContactListProvider>.value(
            value: contactListProvider!),
      if (AppFeatures.enableSocial && followEventProvider != null)
        ListenableProvider<FollowEventProvider>.value(
            value: followEventProvider!),
      if (AppFeatures.enableSocial && followNewEventProvider != null)
        ListenableProvider<FollowNewEventProvider>.value(
            value: followNewEventProvider!),
      if (AppFeatures.enableNotifications && notificationsProvider != null)
        ListenableProvider<NotificationsProvider>.value(
            value: notificationsProvider!),
      if (AppFeatures.enableNotifications && newNotificationsProvider != null)
        ListenableProvider<NewNotificationsProvider>.value(
            value: newNotificationsProvider!),
      if (dmProvider != null)
        ListenableProvider<DMProvider?>.value(value: dmProvider),
      ListenableProvider<EventReactionsProvider>.value(
          value: eventReactionsProvider),
      ListenableProvider<NoticeProvider>.value(value: noticeProvider),
      ListenableProvider<SingleEventProvider>.value(value: singleEventProvider),
      ListenableProvider<RelayProvider>.value(value: relayProvider),
      ListenableProvider<FilterProvider>.value(value: filterProvider),
      ListenableProvider<LinkPreviewDataProvider>.value(
          value: linkPreviewDataProvider),
      ListenableProvider<BadgeDefinitionProvider>.value(
          value: badgeDefinitionProvider),
      ListenableProvider<PcRouterFakeProvider>.value(
          value: pcRouterFakeProvider),
      ListenableProvider<WebViewProvider>.value(value: webViewProvider),
      ListenableProvider<CustomEmojiProvider>.value(value: customEmojiProvider),
      ListenableProvider<CommunityApprovedProvider>.value(
          value: communityApprovedProvider),
      ListenableProvider<CommunityInfoProvider>.value(
          value: communityInfoProvider),
    ];

    if (AppFeatures.enableWallet && nwcProvider != null) {
      providerList
          .add(ListenableProvider<NwcProvider?>.value(value: nwcProvider));
    }

    return MultiProvider(
      providers: providerList,
      child: SafeArea(
        child: HomeComponent(
          locale: _locale,
          theme: defaultTheme,
          child: Sizer(
            builder: (context, orientation, deviceType) {
              return MaterialApp.router(
                routerConfig: appRouter,
                builder: EasyLoading.init(),
                locale: _locale,
                title: packageInfo.appName,
                localizationsDelegates: const [
                  I18n.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                  FlutterQuillLocalizations.delegate,
                ],
                supportedLocales: I18n.delegate.supportedLocales,
                theme: defaultTheme,
                darkTheme: defaultDarkTheme,
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // SystemTimer.run();
  }

  @override
  void dispose() {
    super.dispose();
    // SystemTimer.stopTask();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState newState) async {
    super.didChangeAppLifecycleState(newState);

    if (newState == AppLifecycleState.resumed &&
        (appState == AppLifecycleState.paused ||
            appState == AppLifecycleState.hidden ||
            appState == AppLifecycleState.inactive)) {
      //now you know that your app went to the background and is back to the foreground
      if (loggedUserSigner != null) {
        // if (ndk.relays.allowReconnectRelays == false) {
        // if (backgroundService != null && settingProvider.backgroundService) {
        //   backgroundService!.invoke('stopService');
        // }
        ndk.relays.allowReconnectRelays = false;
        List<String> requestIdsToClose =
            ndk.relays.globalState.inFlightRequests.keys.toList();
        for (var id in requestIdsToClose) {
          // try {
          //   ndk.requests.closeSubscription(id);
          // } catch (e) {
          //   print(e);
          // }
        }
        // await ndk.relays.closeAllSockets();

        ndk.relays.allowReconnectRelays = true;

        // Set<String> urls = {};
        // urls.addAll(myInboxRelaySet!.urls);
        // if (settingProvider.gossip == 1 && feedRelaySet!=null) {
        //   urls.addAll(feedRelaySet!.urls);
        // }
        //
        // try {
        //   await ndk.relays.reconnectRelays(urls);
        //   // await ndk.relays.reconnectRelays(urls);
        // } catch (e) {
        //   print(e);
        // }

        followEventProvider?.startSubscriptions();
        if (AppFeatures.enableNotifications) {
          notificationsProvider?.startSubscription();
        }
        if (AppFeatures.enableWallet) {
          nwcProvider?.init(); // Use null-aware access
        }
      }
      // }
    }
    if ((newState == AppLifecycleState.paused ||
            newState == AppLifecycleState.hidden) &&
        appState == AppLifecycleState.resumed &&
        loggedUserSigner != null) {
      print("newState = ${newState} , appState = ${appState}");
      Future.delayed(const Duration(seconds: 5), () async {
        if (AppFeatures.enableNotifications) {
          NotificationLifeCycle value =
              await AwesomeNotifications().getAppLifeCycle();
          if (value.toString() != "NotificationLifeCycle.Foreground") {
            // if (backgroundService != null && settingProvider.backgroundService) {
            //   backgroundService!.startService();
            // }
            ndk.relays.allowReconnectRelays = false;
            List<String> requestIdsToClose =
                ndk.relays.globalState.inFlightRequests.keys.toList();
            for (var id in requestIdsToClose) {
              try {
                ndk.requests.closeSubscription(id);
              } catch (e) {
                print(e);
              }
            }

            await ndk.relays.closeAllTransports();

            // if (settingProvider.backgroundService) {
            //   backgroundService!.startService();
            // }
          }
        }
      });
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
        500: Color(0xffD44E7D),
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
      displaySmall: TextStyle(fontSize: baseFontSize - 2, fontFamily: 'Geist'),
      displayMedium: TextStyle(fontSize: baseFontSize, fontFamily: 'Geist'),
      displayLarge: TextStyle(fontSize: baseFontSize + 2, fontFamily: 'Geist'),
      headlineSmall: TextStyle(fontSize: baseFontSize - 2, fontFamily: 'Geist'),
      headlineMedium: TextStyle(fontSize: baseFontSize, fontFamily: 'Geist'),
      headlineLarge: TextStyle(fontSize: baseFontSize + 2, fontFamily: 'Geist'),
      titleSmall: TextStyle(fontSize: baseFontSize - 2, fontFamily: 'Geist'),
      titleMedium: TextStyle(fontSize: baseFontSize, fontFamily: 'Geist'),
      titleLarge: TextStyle(fontSize: baseFontSize + 2, fontFamily: 'Geist'),
      labelSmall: TextStyle(fontSize: baseFontSize - 2, fontFamily: 'Geist'),
      labelMedium: TextStyle(fontSize: baseFontSize, fontFamily: 'Geist'),
      labelLarge: TextStyle(fontSize: baseFontSize + 2, fontFamily: 'Geist'),
      bodyLarge: TextStyle(fontSize: baseFontSize + 2, height: 1.4),
      bodyMedium: TextStyle(fontSize: baseFontSize, height: 1.4),
      bodySmall: TextStyle(fontSize: baseFontSize - 2, height: 1.4),
    );
    var titleTextStyle = TextStyle(
      color: PlatformUtil.isPC() ? Colors.black : Colors.white,
    );

    if (settingProvider.fontFamily != null) {
      textTheme =
          GoogleFonts.getTextTheme(settingProvider.fontFamily!, textTheme);
      titleTextStyle = GoogleFonts.getFont(settingProvider.fontFamily!,
          textStyle: titleTextStyle);
    }

    return ThemeData(
      fontFamily: 'Geist',
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
        backgroundColor: const Color(0xFF131313),
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
        500: Color(0xffD44E7D),
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
      displaySmall: TextStyle(fontSize: baseFontSize - 2, fontFamily: 'Geist'),
      displayMedium: TextStyle(fontSize: baseFontSize, fontFamily: 'Geist'),
      displayLarge: TextStyle(fontSize: baseFontSize + 2, fontFamily: 'Geist'),
      headlineSmall: TextStyle(fontSize: baseFontSize - 2, fontFamily: 'Geist'),
      headlineMedium: TextStyle(fontSize: baseFontSize, fontFamily: 'Geist'),
      headlineLarge: TextStyle(fontSize: baseFontSize + 2, fontFamily: 'Geist'),
      titleSmall: TextStyle(fontSize: baseFontSize - 2, fontFamily: 'Geist'),
      titleMedium: TextStyle(fontSize: baseFontSize, fontFamily: 'Geist'),
      titleLarge: TextStyle(fontSize: baseFontSize + 2, fontFamily: 'Geist'),
      labelSmall: TextStyle(fontSize: baseFontSize - 2, fontFamily: 'Geist'),
      labelMedium: TextStyle(fontSize: baseFontSize, fontFamily: 'Geist'),
      labelLarge: TextStyle(fontSize: baseFontSize + 2, fontFamily: 'Geist'),
      bodyLarge: TextStyle(fontSize: baseFontSize + 2, height: 1.4),
      bodyMedium: TextStyle(fontSize: baseFontSize, height: 1.4),
      bodySmall: TextStyle(fontSize: baseFontSize - 2, height: 1.4),
    );
    var titleTextStyle = TextStyle(
      color: topFontColor,
      // color: Colors.black,
    );

    if (settingProvider.fontFamily != null) {
      textTheme =
          GoogleFonts.getTextTheme(settingProvider.fontFamily!, textTheme);
      titleTextStyle = GoogleFonts.getFont(settingProvider.fontFamily!,
          textStyle: titleTextStyle);
    }

    return ThemeData(
      fontFamily: 'Geist',
      useMaterial3: true,
      brightness: Brightness.dark,
      platform: TargetPlatform.iOS,
      primarySwatch: themeColor,
      scaffoldBackgroundColor: Colors.grey[900],
      primaryColor: themeColor[500],
      appBarTheme: AppBarTheme(
        // color: Base.APPBAR_COLOR,
        backgroundColor: const Color(0xFF131313),
        // backgroundColor: background,
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
