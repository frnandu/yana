import 'dart:io';

import 'package:dart_ndk/models/pubkey_mapping.dart';
import 'package:dart_ndk/models/user_relay_list.dart';
import 'package:dart_ndk/nips/nip65/read_write_marker.dart';
import 'package:dart_ndk/relay.dart';
import 'package:flutter/material.dart';

import '../main.dart';
import '../models/relay_status.dart';
import 'data_util.dart';

class RelayProvider extends ChangeNotifier {
  static RelayProvider? _relayProvider;

  static RelayProvider getInstance() {
    _relayProvider ??= RelayProvider();
    return _relayProvider!;
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
    set.addAll(myInboxRelaySet!.urls);
    set.addAll(myOutboxRelaySet!.urls);
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

  void onRelayStatusChange() {
    notifyListeners();
  }

  Future<void> addRelay(String relayAddr) async {
    ReadWriteMarker marker = ReadWriteMarker.readWrite;
    if (myOutboxRelaySet!=null && !myOutboxRelaySet!.urls.contains(relayAddr)) {
      await relayManager.broadcastAddNip65Relay(
          relayAddr, marker, myOutboxRelaySet!.urls,
          loggedUserSigner!);
      myOutboxRelaySet!.relaysMap[relayAddr] = [PubkeyMapping(pubKey: loggedUserSigner!.getPublicKey(), rwMarker: marker)];
      await relayManager.saveRelaySet(myOutboxRelaySet!);
      myInboxRelaySet!.relaysMap[relayAddr] = [PubkeyMapping(pubKey: loggedUserSigner!.getPublicKey(), rwMarker: marker)];
      await relayManager.saveRelaySet(myInboxRelaySet!);
      await relayManager
          .reconnectRelays(myOutboxRelaySet!.urls);
      await relayManager
          .reconnectRelays(myInboxRelaySet!.urls);
      notifyListeners();
    }
  }

  Future<void> removeRelay(String relayAddr) async {
    if (myOutboxRelaySet!=null && myOutboxRelaySet!.urls.contains(relayAddr)) {
      UserRelayList? userRelayList = await relayManager.broadcastRemoveNip65Relay(
          relayAddr, myOutboxRelaySet!.urls,
          loggedUserSigner!);
      if (userRelayList!=null) {
        if (myOutboxRelaySet!.urls.contains(relayAddr)) {
          myOutboxRelaySet!.relaysMap.remove(relayAddr);
          await cacheManager.saveRelaySet(myOutboxRelaySet!);
        }
        if (myInboxRelaySet!.urls.contains(relayAddr)) {
          myInboxRelaySet!.relaysMap.remove(relayAddr);
          await cacheManager.saveRelaySet(myInboxRelaySet!);
        }
        notifyListeners();
      }
    }
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
