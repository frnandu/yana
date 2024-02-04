import 'dart:convert';
import 'dart:io';

import 'package:dart_ndk/models/relay_set.dart';
import 'package:dart_ndk/models/user_relay_list.dart';
import 'package:dart_ndk/nips/nip51/nip51.dart';
import 'package:dart_ndk/nips/nip65/read_write_marker.dart';
import 'package:dart_ndk/read_write.dart';
import 'package:dart_ndk/relay.dart';
import 'package:dart_ndk/relay_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

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
    if (myInboxRelaySet!=null) {
      set.addAll(myInboxRelaySet!.urls);
    }
    if (myOutboxRelaySet!=null) {
      set.addAll(myOutboxRelaySet!.urls);
    }
    String result = "${relayManager.getConnectedRelays(set).length}/${set.length}";
    // result +=",${relayManager.webSockets.keys.where((element) => relayManager.isWebSocketOpen(element)).length}";
    // String result =
    //     "${nostr!.activeRelays().length}/${nostr!.allRelays().length}";
    if (settingProvider.gossip == 1 && feedRelaySet != null && feedRelaySet!.urls.isNotEmpty) {
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

  Future<Nip51Set?> getNip51RelaySet(String name) async {
    Nip51Set? r = await relayManager.getCachedNip51RelaySet(name, loggedUserSigner!);
    if (r == null) {
      relayManager.getSingleNip51RelaySet(name, loggedUserSigner!);
    }
    return r;
  }

  Future<Nip51List?> getNip51List(int kind) async {
    Nip51List? r = await relayManager.getCachedNip51List(kind, loggedUserSigner!);
    if (r == null) {
      relayManager.getSingleNip51List(kind, loggedUserSigner!);
    }
    return r;
  }

  void onRelayStatusChange() {
    notifyListeners();
  }

  Future<void> addRelay(String relayAddr) async {
    ReadWriteMarker marker = ReadWriteMarker.readWrite;
    if (myOutboxRelaySet != null && !myOutboxRelaySet!.urls.contains(relayAddr) && myInboxRelaySet!=null && !myInboxRelaySet!.urls.contains(relayAddr)) {
      UserRelayList userRelayList = await relayManager.broadcastAddNip65Relay(relayAddr, marker, myOutboxRelaySet!.urls, loggedUserSigner!);
      createMyRelaySets(userRelayList);
      await relayManager.saveRelaySet(myOutboxRelaySet!);
      await relayManager.saveRelaySet(myInboxRelaySet!);
      await relayManager.connect(urls: userRelayList.urls);
      notifyListeners();
    }
  }

  Future<void> removeRelay(String url) async {
    UserRelayList? userRelayList = await relayManager.broadcastRemoveNip65Relay(url, myOutboxRelaySet!.urls, loggedUserSigner!);
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

    UserRelayList? userRelayList = await relayManager.broadcastUpdateNip65RelayMarker(url, marker, relays, loggedUserSigner!);

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
    RelaySet newRelaySet = await relayManager.calculateRelaySet(
        name: "feed",
        ownerPubKey: loggedUserSigner!.getPublicKey(),
        pubKeys: contactListProvider.contacts(),
        direction: RelayDirection.outbox,
        relayMinCountPerPubKey: settingProvider.followeesRelayMinCount);
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

  List<String>? relaysFromApi;
  Map<int,List<String>?> relaysFromApiByNip = {};

  Uri relaysApiUri = Uri.parse("https://api.nostr.watch/v1/online").replace(scheme: 'https');

  Future<bool> fetchRelaysFromApi() async {
    try {
      var response = await http.get(relaysApiUri);

      if (response.body != null) {
        final data = jsonDecode(
            utf8.decode(response.bodyBytes)) as List<dynamic>;
        if (data != null) {
          relaysFromApi = data.map((e) => e.toString(),).toList();
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    return false;
  }

  Future<List<String>?> fetchRelaysFromApiByNip(int nip) async {
    try {
      Uri relaysApiUri = Uri.parse("https://api.nostr.watch/v1/nip/${nip}").replace(scheme: 'https');
      var response = await http.get(relaysApiUri);

      if (response.body != null) {
        final data = jsonDecode(
            utf8.decode(response.bodyBytes)) as List<dynamic>;
        if (data != null) {
          return data.map((e) => e.toString(),).toList();
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    return null;
  }


  Future<List<String>> findRelays(String text, {int? nip}) async {
    if (text.trim().isNotEmpty) {
      List<String>? relays;
      if (nip==null) {
        if (relaysFromApi == null) {
          await fetchRelaysFromApi();
        }
        relays = relaysFromApi;
      } else {
        relays = relaysFromApiByNip[nip];
        if (relays==null) {
          relaysFromApiByNip[nip] =  await fetchRelaysFromApiByNip(nip);
        }
        relays = relaysFromApiByNip[nip];
      }
      Set<String> set = {};
      set.addAll(relays!);
      return set
          .where((element) =>
              text.length>=3 &&
              element.replaceAll("wss://", "").replaceAll("ws://", "").contains(text) ||
                  element.replaceAll("wss://", "").replaceAll("ws://", "").startsWith(text) ||
                  element.startsWith(text)
      )
          .toList();
    }
    return [];
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
