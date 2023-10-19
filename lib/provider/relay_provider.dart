import 'dart:developer';
import 'dart:io';

import 'package:dart_ndk/nips/nip01/event.dart';
import 'package:dart_ndk/relay.dart';
import 'package:flutter/material.dart';
import 'package:yana/models/relay_list.dart';
import 'package:yana/nostr/relay_metadata.dart';

import '../main.dart';
import '../models/relay_status.dart';
import '../nostr/event_kind.dart' as kind;
import '../nostr/nostr.dart';
import '../utils/string_util.dart';
import 'data_util.dart';

class RelayProvider extends ChangeNotifier {
  static RelayProvider? _relayProvider;

  // TODO make mechanism for reloading if cached/DB list is too old
  static int RELOAD_RELAY_LIST_AFTER_THIS_SECONDS = 604800;

  List<String> relayAddrs = [];

  static const List<String> STATIC_RELAY_ADDRS = [
    "wss://relay.damus.io",
    "wss://purplepag.es",
    "wss://nos.lol",
    "wss://nostr.wine",
    "wss://atlas.nostr.land",
    "wss://relay.orangepill.dev",
    "wss://relay.snort.social",
    "wss://relay.nostr.band", // for search (NIP-50)
  ];

  Map<String, RelayStatus> relayStatusMap = {};

  static RelayProvider getInstance() {
    _relayProvider ??= RelayProvider();
    return _relayProvider!;
  }

  RelayStatus? getRelayStatus(String addr) {
    return relayStatusMap[addr];
  }

  int? getFeedRelayState(String url) {
    String? cleanedUrl = Relay.clean(url);
    if (cleanedUrl==null) {
      return WebSocket.closed;
    }
    return relayManager.isRelayConnecting(cleanedUrl) ?
      WebSocket.connecting :
        relayManager.isRelayConnected(cleanedUrl) ? WebSocket.open : WebSocket.closed;
  }

  String relayNumStr() {
    Set<String> set = {};
    set.addAll(myInboxRelays!.map.keys);
    set.addAll(myOutboxRelays!.map.keys);
    String result = "${relayManager.getConnectedRelays(set).length}/${set.length}";
    // String result =
    //     "${nostr!.activeRelays().length}/${nostr!.allRelays().length}";
    if (settingProvider.gossip == 1 && feedRelaySet != null && feedRelaySet!.map.isNotEmpty) {
      result += " (feed ${feedRelaysNumStr()})";
    }
    return result;
  }

  String feedRelaysNumStr() {
    if (feedRelaySet != null) {
      return "${relayManager.getConnectedRelays(feedRelaySet!.map.keys.toList()).length}/${feedRelaySet!.map.keys.length}";
    }
    return "";
  }

  int total() {
    return relayAddrs.length;
  }

  void onRelayStatusChange() {
    notifyListeners();
  }

  Future<void> addRelay(String relayAddr) async {
    if (!relayAddrs.contains(relayAddr)) {
      relayAddrs.add(relayAddr);
      // await _doAddRelay(relayAddr);
      await _updateRelayToData();
    }
  }

  Future<void> removeRelay(String relayAddr) async {
    if (relayAddrs.contains(relayAddr)) {
      relayAddrs.remove(relayAddr);
      relayStatusMap.remove(relayAddr);
      nostr!.removeRelay(relayAddr);

      await _updateRelayToData();
    }
  }

  bool containRelay(String relayAddr) {
    return relayAddrs.contains(relayAddr);
  }

  int? updatedTime() {
    return sharedPreferences.getInt(DataKey.RELAY_UPDATED_TIME);
  }

  Future<void> _updateRelayToData(
      {bool upload = true,
      List<String> broadcastToRelays = STATIC_RELAY_ADDRS}) async {
    // sharedPreferences.setInt(DataKey.RELAY_UPDATED_TIME,
    //     DateTime.now().millisecondsSinceEpoch ~/ 1000);
    //
    // List<RelayMetadata> relays = [];
    // // update to relay
    // if (upload) {
    //   List<dynamic> tags = [];
    //   for (var addr in relayAddrs) {
    //     tags.add(["r", addr, ""]);
    //     relays.add(RelayMetadata.full(url: addr, read: true, write: true));
    //   }
    //
    //   Set<String> uniqueRelays = Set<String>.from(broadcastToRelays);
    //   uniqueRelays.addAll(relayAddrs);
    //   var tempNostr =
    //       Nostr(privateKey: nostr!.privateKey, publicKey: nostr!.publicKey);
    //
    //   uniqueRelays.forEach((relayAddr) {
    //     Relay r = Relay(
    //       relayAddr,
    //       RelayStatus(relayAddr),
    //       access: WriteAccess.readWrite,
    //     );
    //     try {
    //       tempNostr.addRelay(r, checkInfo: false);
    //     } catch (e) {
    //       log("relay $relayAddr add to temp nostr for broadcasting of nip065 relay list: ${e.toString()}");
    //     }
    //   });
    //
    //   var event = Nip01Event(pubKey:
    //       tempNostr!.publicKey, kind: kind.EventKind.RELAY_LIST_METADATA, tags: tags, content: "");
    //   tempNostr!.sendEvent(event);
    //   int now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    //   try {
    //     await RelayList.writeToDB(nostr!.publicKey, relays, now);
    //   } catch (e) {
    //     print(e);
    //   }
    // }
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

  void clear() {
    relayStatusMap.clear();
  }
}
