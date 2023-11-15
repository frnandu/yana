import 'dart:io';

import 'package:dart_ndk/models/pubkey_mapping.dart';
import 'package:dart_ndk/models/relay_set.dart';
import 'package:dart_ndk/models/user_relay_list.dart';
import 'package:dart_ndk/nips/nip51/nip51.dart';
import 'package:dart_ndk/nips/nip65/read_write_marker.dart';
import 'package:dart_ndk/read_write.dart';
import 'package:dart_ndk/relay.dart';
import 'package:dart_ndk/relay_manager.dart';
import 'package:flutter/material.dart';

import '../main.dart';

class RelayProvider extends ChangeNotifier {
  static RelayProvider? _relayProvider;

  static RelayProvider getInstance() {
    _relayProvider ??= RelayProvider();
    return _relayProvider!;
  }

  int? getFeedRelayState(String url) {
    String? cleanedUrl = Relay.clean(url);
    if (cleanedUrl == null) {
      return WebSocket.closed;
    }
    return relayManager.isRelayConnecting(cleanedUrl)
        ? WebSocket.connecting
        : relayManager.isRelayConnected(cleanedUrl)
            ? WebSocket.open
            : WebSocket.closed;
  }

  String relayNumStr() {
    Set<String> set = {};
    set.addAll(myInboxRelaySet!.urls);
    set.addAll(myOutboxRelaySet!.urls);
    String result =
        "${relayManager.getConnectedRelays(set).length}/${set.length}";
    // result +=",${relayManager.webSockets.keys.where((element) => relayManager.isWebSocketOpen(element)).length}";
    // String result =
    //     "${nostr!.activeRelays().length}/${nostr!.allRelays().length}";
    if (settingProvider.gossip == 1 &&
        feedRelaySet != null &&
        feedRelaySet!.urls.isNotEmpty) {
      result += " (feed ${feedRelaysNumStr()})";
    }
    return result;
  }

  String feedRelaysNumStr() {
    if (feedRelaySet != null) {
      return "${relayManager.getConnectedRelays(feedRelaySet!.urls).length}/${feedRelaySet!.urls.length}";
    }
    return "";
  }

  Nip51RelaySet? getNip51RelaySet(String name) {
    Nip51RelaySet? r = relayManager.getCachedNip51RelaySet(loggedUserSigner!.getPublicKey(), name);
    if (r==null) {
      relayManager.getSingleNip51RelaySet(loggedUserSigner!.getPublicKey(), name);
    }
    return r;
  }

  void onRelayStatusChange() {
    notifyListeners();
  }

  Future<void> addRelay(String relayAddr) async {
    ReadWriteMarker marker = ReadWriteMarker.readWrite;
    if (myOutboxRelaySet != null &&
        !myOutboxRelaySet!.urls.contains(relayAddr)) {
      UserRelayList userRelayList = await relayManager.broadcastAddNip65Relay(
          relayAddr, marker, myOutboxRelaySet!.urls, loggedUserSigner!);
      createMyRelaySets(userRelayList);
      await relayManager.saveRelaySet(myOutboxRelaySet!);
      await relayManager.saveRelaySet(myInboxRelaySet!);
      await relayManager.connect(urls: userRelayList.urls);
      notifyListeners();
    }
  }

  Future<void> removeRelay(String url) async {
    UserRelayList? userRelayList = await relayManager.broadcastRemoveNip65Relay(
        url, myOutboxRelaySet!.urls, loggedUserSigner!);
    if (userRelayList != null) {
      createMyRelaySets(userRelayList);
      await cacheManager.saveRelaySet(myOutboxRelaySet!);
      await cacheManager.saveRelaySet(myInboxRelaySet!);
      await relayManager.connect(urls: userRelayList.urls);
      notifyListeners();
    }
  }

  Future<void> updateMarker(String url, ReadWriteMarker marker) async {
    Set<String> relays = {};
    relays.addAll(RelayManager.DEFAULT_BOOTSTRAP_RELAYS);
    relays.addAll(myOutboxRelaySet!.urls);

    UserRelayList? userRelayList =
        await relayManager.broadcastUpdateNip65RelayMarker(
            url, marker, relays, loggedUserSigner!);

    if (userRelayList != null) {
      createMyRelaySets(userRelayList);

      await cacheManager.saveRelaySet(myOutboxRelaySet!);
      await cacheManager.saveRelaySet(myInboxRelaySet!);
      notifyListeners();
    }
  }

  UserRelayList? getUserRelayList(String publicKey) {
    return cacheManager.loadUserRelayList(loggedUserSigner!.getPublicKey());
//    userRelayList ??= await relayManager.getSingleUserRelayList(loggedUserSigner!.getPublicKey(), forceRefresh: true);
  }

  Future<RelaySet> recalculateFeedRelaySet() async {
    RelaySet newRelaySet =
        await relayManager.calculateRelaySet(
        name: "feed",
        ownerPubKey: loggedUserSigner!.getPublicKey(),
        pubKeys: contactListProvider.contacts(),
        direction: RelayDirection.outbox,
        relayMinCountPerPubKey: settingProvider.followeesRelayMinCount
    );
    if (newRelaySet.urls.isNotEmpty) {
      feedRelaySet = newRelaySet;
      feedRelaySet!.name = "feed";
      feedRelaySet!.pubKey = loggedUserSigner!.getPublicKey();
      await relayManager.saveRelaySet(feedRelaySet!);
      // followEventProvider.refreshPosts();
      notifyListeners();
    }
    return newRelaySet;
  }

  List<String> getBlockedRelays() {
    return relayManager.blockedRelays;
  }

  List<String> getSearchRelays() {
    return searchRelays;
  }

// Relay genRelay(String relayAddr) {
//   var relayStatus = relayStatusMap[relayAddr];
//   if (relayStatus == null) {
//     relayStatus = RelayStatus(relayAddr);
//     relayStatusMap[relayAddr] = relayStatus;
//   }
//
//   return Relay(
//     relayAddr,
//     relayStatus,
//     access: WriteAccess.readWrite,
//   )..relayStatusCallback = onRelayStatusChange;
// }

// Future<void> setRelayListAndUpdate(
//     List<String> addrs, String? privKey) async {
//   relayStatusMap.clear();
//
//   relayAddrs.clear();
//   relayAddrs.addAll(addrs);
//   _updateRelayToData(upload: false);
//
//   if (StringUtil.isNotBlank(privKey)) {
//     if (nostr != null) {
//       nostr!.close();
//     }
//     nostr = Nostr(privateKey: privKey);
//
//     // reconnect all client
//     for (var relayAddr in relayAddrs) {
//       var custRelay = genRelay(relayAddr);
//       try {
//         await nostr!.addRelay(custRelay, autoSubscribe: true);
//       } catch (e) {
//         log("relay $relayAddr add to pool error ${e.toString()}");
//       }
//     }
//   }
// }
}
