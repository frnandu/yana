import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:yana/models/contacts_db.dart';
import 'package:yana/models/relays_db.dart';
import 'package:yana/nostr/nip02/cust_contact_list.dart';
import 'package:yana/nostr/relay_metadata.dart';
import 'package:yana/provider/setting_provider.dart';

import '../main.dart';
import '../models/relay_status.dart';
import '../nostr/event.dart';
import '../nostr/event_kind.dart' as kind;
import '../nostr/filter.dart';
import '../nostr/nostr.dart';
import '../nostr/relay.dart';
import '../utils/client_connected.dart';
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
      String pubKey, Function(List<RelayMetadata>) onRelays) async {
    List<RelayMetadata>? relays = await RelaysDB.get(pubKey);
    bool loaded = false;
    if (relays == null || relays.isEmpty) {
      loadRelayAndContactList(pubKey, onRelays: (relays) {
        loaded = true;
        onRelays(relays);
      });
      Future.delayed(
        const Duration(seconds: 3),
        () {
          if (!loaded) {
            onRelays([]);
          }
        },
      );
    } else {
      onRelays(relays);
    }
  }

  Future<void> getContacts(
      String pubKey, Function(CustContactList) onContacts) async {
    CustContactList? contactList = await ContactsDB.get(pubKey);
    bool loaded = false;
    if (contactList == null) {
      loadRelayAndContactList(pubKey, onContacts: (list) {
        loaded = true;
        onContacts(list);
      });
      Future.delayed(
        Duration(seconds: 5),
        () {
          if (!loaded) {
            onContacts(CustContactList());
          }
        },
      );
    } else {
      onContacts(contactList);
    }
  }

  Future<void> loadRelays(String? pubKey, Function onComplete) async {
    // print("Loading relays for logged user...");
    if (pubKey != null) {
      await relayProvider.getRelays(pubKey, (relays) {
        relayAddrs.clear();
        if (relays != null) {
          relayAddrs.addAll(relays.map(
            (e) => e.addr,
          ));
        }

        if (relayAddrs.isEmpty) {
          // init relays
          relayAddrs = List<String>.from(STATIC_RELAY_ADDRS);
        }
        // print("Loaded ${relays.length} relays for logged user...");
        onComplete();
      });
    }
  }

  Future<void> buildNostrFromContactsRelays(
      String pubKey,
      CustContactList contactList,
      int takeCountForEachContact,
      Function(Nostr) onComplete) async {
    Nostr nostr = Nostr(privateKey: null, publicKey: pubKey);
    int i = 0;
    Map<String, int> followRelaysMap = {};
    contactList.list().forEach((contact) async {
      await relayProvider.getRelays(contact.publicKey, (relays) {
        relays
            .where((element) =>
                (element.write == null || element.write!) && element.isValidWss)
            .map((e) => e.addr)
            .take(takeCountForEachContact)
            .forEach((r) {
          String? adr = Relay.clean(r);
          if (adr==null) {
            return;
          }
          int? count = followRelaysMap![adr];
          if (count == null) {
            count = 1;
          } else {
            count++;
          }
          followRelaysMap![adr] = count;
          nostr!.addRelay(
              Relay(
                adr,
                RelayStatus(adr),
                access: WriteAccess.readWrite,
              ),
              connect: true,
              checkInfo: false);
        });
        i++;
        print(
            "Loaded ${relays.length} relays for contact ${contact.publicKey} $i/${contactList.list().length}");
        if (i == contactList.total()) {
          List<MapEntry<String, int>> sortedEntries =
              followRelaysMap!.entries.toList();

          sortedEntries.sort((a, b) => b.value.compareTo(a.value));

          followRelays = [];
          // Now, sortedEntries contains your Map entries sorted by values in descending order.

          for (var entry in sortedEntries) {
            followRelays!.add(RelayMetadata(entry.key, count: entry.value));
          }
          onComplete(nostr);
        }
      });
    });
  }

  RelayStatus? getRelayStatus(String addr) {
    return relayStatusMap[addr];
  }

  int? getFollowRelayState(String addr) {
    if (followsNostr != null) {
      Relay? r = followsNostr!.getRelay(addr);
      if (r==null) {
        return null;
      }
      return r!.webSocket != null? r!.webSocket!.readyState : (r.relayStatus.connecting ? WebSocket.connecting: WebSocket.closed) ;
    }
    return null;
  }

  String relayNumStr() {
    String result = "${nostr!.activeRelays().length}/${nostr!.allRelays().length}";
    if (settingProvider.gossip == 1 && followsNostr != null) {
      result += ", follows ${followRelayNumStr()}";
    }
    return result;
  }

  String followRelayNumStr() {
    if (followsNostr != null) {
      return "${followsNostr!.activeRelays().length}/${followsNostr!.allRelays().length}";
    }
    return "";
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
    var loggedUserNostr = Nostr(privateKey: privateKey, publicKey: publicKey);
    // log("nostr init over");

    await addRelays(loggedUserNostr);

    await getContacts(loggedUserNostr.publicKey, (contactList) async {
      contactListProvider.set(contactList);
      await buildNostrFromContactsRelays(
        loggedUserNostr.publicKey,
        contactList,
        settingProvider.followeesRelayMaxCount ??
            SettingProvider.DEFAULT_FOLLOWEES_RELAY_MAX_COUNT,
        (builtNostr) {
          if (followsNostr == null) {
            followsNostr = builtNostr;
            // add logged user's configured read relays
            loggedUserNostr!
                .activeRelays()
                .where((relay) => relay.access != WriteAccess.writeOnly)
                .forEach((relay) {
              followsNostr!.addRelay(relay, connect: true);
            });
            followEventProvider.doQuery();
          }
        },
      );
    });
    // add initQuery
    // contactListProvider.query(targetNostr: _nostr);
    // contactListProvider.reload(targetNostr: _nostr);
    notificationsProvider.doQuery(
        targetNostr: loggedUserNostr, initQuery: true);
    // Future.delayed(
    //     const Duration(seconds: 3),
    //     () => {
    //           dmProvider.initDMSessions(loggedUserNostr.publicKey).then((_) {
    //             // dmProvider.query(targetNostr: _nostr, subscribe: false);
    //           })
    //         });
    // .then((_) {
    //   dmProvider.query(targetNostr: _nostr, subscribe: true);
    // })
    // ;
    return loggedUserNostr;
  }

  void onRelayStatusChange() {
    notifyListeners();
  }

  Future<void> addRelay(String relayAddr) async {
    if (!relayAddrs.contains(relayAddr)) {
      relayAddrs.add(relayAddr);
      await _doAddRelay(relayAddr);
      await _updateRelayToData();
    }
  }

  Future<void> _doAddRelay(String relayAddr, {bool init = false}) async {
    var custRelay = genRelay(relayAddr);
    log("begin to init $relayAddr");
    await nostr!.addRelay(custRelay, autoSubscribe: true, init: init);
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
    sharedPreferences.setInt(DataKey.RELAY_UPDATED_TIME,
        DateTime.now().millisecondsSinceEpoch ~/ 1000);

    List<RelayMetadata> relays = [];
    // update to relay
    if (upload) {
      List<dynamic> tags = [];
      for (var addr in relayAddrs) {
        tags.add(["r", addr, ""]);
        relays.add(RelayMetadata(addr, read: true, write: true));
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
        await RelaysDB.insert(nostr!.publicKey, relays, now);
      } catch (e) {
        await RelaysDB.update(nostr!.publicKey, relays, now);
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

  Future<void> setRelayListAndUpdate(
      List<String> addrs, String? privKey) async {
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
          await nostr!.addRelay(custRelay, autoSubscribe: true);
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
    if (staticForRelaysAndMetadataNostr != null) {
      staticForRelaysAndMetadataNostr!.close();
      staticForRelaysAndMetadataNostr = null;
    }
    //load();
  }

  void loadRelayAndContactList(String pubKey,
      {Function(List<RelayMetadata>)? onRelays,
      Function(CustContactList)? onContacts}) {
    if (staticForRelaysAndMetadataNostr == null) {
      Set<String> uniqueRelays =
          Set<String>.from(RelayProvider.STATIC_RELAY_ADDRS);
      uniqueRelays.addAll(relayProvider.relayAddrs);
      staticForRelaysAndMetadataNostr = Nostr(publicKey: pubKey);

      uniqueRelays.forEach((relayAddr) async {
        Relay r = Relay(
          relayAddr,
          RelayStatus(relayAddr),
          access: WriteAccess.readWrite,
        );
        try {
          await staticForRelaysAndMetadataNostr!.addRelay(r, checkInfo: false);
        } catch (e) {
          log("relay $relayAddr add to temp nostr for getting nip065 relay list: ${e.toString()}");
        }
      });
    }

    Event? relaysEvent;
    Event? contactsEvent;
    var filter = Filter(
        authors: [pubKey],
        limit: 2,
        kinds: [
          kind.EventKind.RELAY_LIST_METADATA,
          kind.EventKind.CONTACT_LIST
        ]);
    staticForRelaysAndMetadataNostr!
        .query(id: StringUtil.rndNameStr(16), [filter.toJson()], (event) async {
      if (staticForRelaysAndMetadataNostr == null) {
        return;
      }
      if ((relaysEvent != null && event.createdAt > relaysEvent!.createdAt) ||
          relaysEvent == null) {
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
                  relays!.add(RelayMetadata(value, read: read, write: write));
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
                  relays!.add(RelayMetadata(entry.key.toString(),
                      read: read, write: write));
                }
              }
            } catch (e) {
              print(e);
            }
          }
        }
        if (relays != null && relays.isNotEmpty) {
          try {
            await RelaysDB.insert(pubKey, relays, relaysEvent!.createdAt);
          } catch (e) {
            await RelaysDB.update(pubKey, relays, relaysEvent!.createdAt);
          }
          if (onRelays != null) {
            onRelays(relays);
          }
        }
      }
      if (event.kind == kind.EventKind.CONTACT_LIST &&
          ((contactsEvent != null &&
                  event.createdAt > contactsEvent!.createdAt) ||
              contactsEvent == null)) {
        CustContactList contactList = CustContactList.fromJson(event.tags);
        contactsEvent = event;
        await ContactsDB.update(pubKey, contactList, contactsEvent!.createdAt);
        if (onContacts != null) {
          onContacts(contactList);
        }
      }
    });
  }
}
