import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:yana/models/relays_db.dart';
import 'package:yana/nostr/relay_metadata.dart';

import '../nostr/event.dart';
import '../nostr/event_kind.dart' as kind;
import '../nostr/filter.dart';
import '../nostr/nostr.dart';

import '../nostr/relay.dart';
import '../utils/client_connected.dart';
import '../models/relay_status.dart';
import '../main.dart';
import '../utils/string_util.dart';
import 'data_util.dart';

class RelayProvider extends ChangeNotifier {
  static RelayProvider? _relayProvider;

  // TODO make mechanism for reloading if cached/DB list is too old
  static int RELOAD_RELAY_LIST_AFTER_THIS_SECONDS = 604800;

  List<String> relayAddrs = [];

  static const List<String> STATIC_RELAY_ADDRS = [
    "wss://relay.damus.io",
    "wss://nos.lol",
    "wss://nostr.wine",
    "wss://atlas.nostr.land",
    "wss://relay.orangepill.dev",
    "wss://relay.snort.social",
    "wss://relay.nostr.band", // for search (NIP-50)
  ];

  Map<String, RelayStatus> relayStatusMap = {};

  static RelayProvider getInstance() {
    if (_relayProvider == null) {
      _relayProvider = RelayProvider();
    }
    return _relayProvider!;
  }

  Future<void> getRelays(
      String pubKey, Function(List<RelayMetadata>) onComplete) async {
    List<RelayMetadata>? relays = await RelaysDB.get(pubKey);
    if (relays == null || relays.isEmpty) {
      loadRelayList(
        pubKey,
        (relays) {
          onComplete(relays);
        },
      );
    } else {
      onComplete(relays);
    }
  }

  Future<void> load(String? pubKey, Function onComplete) async {
    if (pubKey!=null) {
     relayProvider.getRelays(pubKey, (relays) {
       relayAddrs.clear();
       if (relays != null) {
         relayAddrs.addAll(relays.map((e) => e.addr,));
       }

       if (relayAddrs.isEmpty) {
         // init relays
         relayAddrs = List<String>.from(STATIC_RELAY_ADDRS);
       }
       onComplete();
     });
   }
  }

  RelayStatus? getRelayStatus(String addr) {
    return relayStatusMap[addr];
  }

  String relayNumStr() {
    var total = relayAddrs.length;

    int connectedNum = 0;
    var it = relayAddrs;
    for (var url in it) {
      RelayStatus? status = relayStatusMap[url];
      if (status != null && status.connected == ClientConneccted.CONNECTED) {
        connectedNum++;
      }
    }
    return "$connectedNum / $total";
  }

  int total() {
    return relayAddrs.length;
  }

  Future<Object> addRelays(Nostr nostr) async {
    for (var relayAddr in relayAddrs) {
      // log("begin to init $relayAddr");
      var custRelay = genRelay(relayAddr);
      try {
        await nostr.addRelay(custRelay, init: true);
      } catch (e) {
        log("relay $relayAddr add to pool error ${e.toString()}");
      }
    }
    return Object();
  }

  Future<Nostr> genNostr({String? privateKey, String? publicKey}) async {
    var _nostr = Nostr(privateKey: privateKey, publicKey: publicKey);
    // log("nostr init over");

    await addRelays(_nostr);

    // add initQuery
    contactListProvider.query(targetNostr: _nostr);
    contactListProvider.reload(targetNostr: _nostr);
    followEventProvider.doQuery(targetNostr: _nostr, initQuery: true);
    notificationsProvider.doQuery(targetNostr: _nostr, initQuery: true);
    Future.delayed(
        const Duration(seconds: 3),
        () => {
              dmProvider.initDMSessions(_nostr.publicKey).then((_) {
                // dmProvider.query(targetNostr: _nostr, subscribe: false);
              })
            });
    // .then((_) {
    //   dmProvider.query(targetNostr: _nostr, subscribe: true);
    // })
    // ;
    return _nostr;
  }

  void onRelayStatusChange() {
    notifyListeners();
  }

  void addRelay(String relayAddr) {
    if (!relayAddrs.contains(relayAddr)) {
      relayAddrs.add(relayAddr);
      _doAddRelay(relayAddr);
      _updateRelayToData();
    }
  }

  void _doAddRelay(String relayAddr, {bool init = false}) {
    var custRelay = genRelay(relayAddr);
    log("begin to init $relayAddr");
    nostr!.addRelay(custRelay, autoSubscribe: true, init: init);
  }

  void removeRelay(String relayAddr) {
    if (relayAddrs.contains(relayAddr)) {
      relayAddrs.remove(relayAddr);
      nostr!.removeRelay(relayAddr);

      _updateRelayToData();
    }
  }

  bool containRelay(String relayAddr) {
    return relayAddrs.contains(relayAddr);
  }

  int? updatedTime() {
    return sharedPreferences.getInt(DataKey.RELAY_UPDATED_TIME);
  }

  void _updateRelayToData(
      {bool upload = true,
      List<String> broadcastToRelays = STATIC_RELAY_ADDRS}) {
    sharedPreferences.setInt(DataKey.RELAY_UPDATED_TIME,
        DateTime.now().millisecondsSinceEpoch ~/ 1000);

    List<RelayMetadata> relays = [];
    // update to relay
    if (upload) {
      List<dynamic> tags = [];
      for (var addr in relayAddrs) {
        tags.add(["r", addr, ""]);
        relays.add(RelayMetadata(addr, true, true));
      }

      Set<String> uniqueRelays = Set<String>.from(broadcastToRelays);
      uniqueRelays.addAll(relayAddrs);
      var tempNostr =
          Nostr(privateKey: nostr!.privateKey, publicKey: nostr!.publicKey);

      uniqueRelays.forEach((relayAddr) {
        Relay r = Relay(
          relayAddr,
          RelayStatus(relayAddr),
          access: WriteAccess.readWrite,
        );
        try {
          tempNostr.addRelay(r, checkInfo: false);
        } catch (e) {
          log("relay $relayAddr add to temp nostr for broadcasting of nip065 relay list: ${e.toString()}");
        }
      });

      var event = Event(
          tempNostr!.publicKey, kind.EventKind.RELAY_LIST_METADATA, tags, "");
      tempNostr!.sendEvent(event);
      int now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      try {
        RelaysDB.insert(nostr!.publicKey, relays, now);
      } catch (e) {
        RelaysDB.update(nostr!.publicKey, relays, now);
      }
    }
  }

  Relay genRelay(String relayAddr) {
    var relayStatus = relayStatusMap[relayAddr];
    if (relayStatus == null) {
      relayStatus = RelayStatus(relayAddr);
      relayStatusMap[relayAddr] = relayStatus;
    }

    return Relay(
      relayAddr,
      relayStatus,
      access: WriteAccess.readWrite,
    )..relayStatusCallback = onRelayStatusChange;
  }

  void setRelayListAndUpdate(List<String> addrs, String? privKey) {
    relayStatusMap.clear();

    relayAddrs.clear();
    relayAddrs.addAll(addrs);
    _updateRelayToData(upload: false);

    if (StringUtil.isNotBlank(privKey)) {
      if (nostr != null) {
        nostr!.close();
      }
      nostr = Nostr(privateKey: privKey);

      // reconnect all client
      for (var relayAddr in relayAddrs) {
        var custRelay = genRelay(relayAddr);
        try {
          nostr!.addRelay(custRelay, autoSubscribe: true);
        } catch (e) {
          log("relay $relayAddr add to pool error ${e.toString()}");
        }
      }
    }
  }

  void checkAndReconnect() {
    // reconnect all client
    for (var relayAddr in relayAddrs) {
      var custRelay = genRelay(relayAddr);
      try {
        nostr!.addRelay(custRelay, autoSubscribe: true);
      } catch (e) {
        log("relay $relayAddr add to pool error ${e.toString()}");
      }
    }
  }

  void clear() {
    // sharedPreferences.remove(DataKey.RELAY_LIST);
    relayStatusMap.clear();
    //load();
  }

  void loadRelayList(String pubKey, Function(List<RelayMetadata>) onComplete) {
    Set<String> uniqueRelays =
        Set<String>.from(RelayProvider.STATIC_RELAY_ADDRS);
    uniqueRelays.addAll(relayProvider.relayAddrs);
    var tempNostr =
        Nostr(publicKey: pubKey);

    uniqueRelays.forEach((relayAddr) {
      Relay r = Relay(
        relayAddr,
        RelayStatus(relayAddr),
        access: WriteAccess.readWrite,
      );
      try {
        tempNostr.addRelay(r, checkInfo: false);
      } catch (e) {
        log("relay $relayAddr add to temp nostr for getting nip065 relay list: ${e.toString()}");
      }
    });

    Event? relaysEvent;
    var filter = Filter(
        authors: [pubKey],
        limit: 1,
        kinds: [
          kind.EventKind.RELAY_LIST_METADATA,
          kind.EventKind.CONTACT_LIST
        ]);
    tempNostr!.query(id: StringUtil.rndNameStr(16), [filter.toJson()], (event) async {
      if ((relaysEvent != null && event.createdAt > relaysEvent!.createdAt) ||
          relaysEvent == null || event.kind == kind.EventKind.RELAY_LIST_METADATA) {
        List<RelayMetadata>? relays = [];
        if (event.kind == kind.EventKind.RELAY_LIST_METADATA) {
          relaysEvent = event;
          for (var tag in relaysEvent!.tags) {
            if (tag is List<dynamic>) {
              var length = tag.length;
              bool write = true;
              bool read = true;
              if (length > 1) {
                var name = tag[0];
                var value = tag[1];
                if (name == "r") {
                  if (length > 2) {
                    var operType = tag[2];
                    if (operType == "read") {
                      write = false;
                    } else if (operType == "write") {
                      read = false;
                    }
                  }
                  relays!.add(RelayMetadata(value, read, write));
                }
              }
            }
          }
        } else {
          if (StringUtil.isNotBlank(event.content)) {
            try {
              Map<String, dynamic> json = jsonDecode(event.content);
              if (json.entries.isNotEmpty) {
                relaysEvent = event;
                for (var entry in json.entries) {
                  bool write = true;
                  bool read = true;
                  write = entry.value["write"];
                  read = entry.value["read"];
                  relays!.add(RelayMetadata(entry.key.toString(), read, write));
                }
              }
            } catch (e) {
              print(e);
            }
          }
        }
        if (relays!=null && relays.isNotEmpty) {
          try {
            await RelaysDB.insert(pubKey, relays, relaysEvent!.createdAt);
          } catch (e) {
            await RelaysDB.update(pubKey, relays, relaysEvent!.createdAt);
          }
          onComplete(relays);
        }
      }
    });
  }
}
