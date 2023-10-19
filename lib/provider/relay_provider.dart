import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:dart_ndk/nips/nip01/event.dart';
import 'package:flutter/material.dart';
import 'package:yana/models/relay_list.dart';
import 'package:yana/nostr/nip02/contact_list.dart';
import 'package:yana/nostr/relay_metadata.dart';
import 'package:yana/provider/setting_provider.dart';

import '../main.dart';
import '../models/relay_status.dart';
import '../nostr/event.dart';
import '../nostr/event_kind.dart' as kind;
import '../nostr/filter.dart';
import '../nostr/nip02/contact.dart';
import '../nostr/nostr.dart';
import '../nostr/relay.dart';
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

  Future<void> getRelays(String pubKey, Function(List<RelayMetadata>) onRelays,
      {bool forceWriteToDB = false, int? timeoutSeconds}) async {
    List<RelayMetadata>? relays = await RelayList.loadFromDB(pubKey);
    bool loaded = false;
    if (relays == null || relays.isEmpty) {
      await loadRelayAndContactList(pubKey, forceWriteToDB: forceWriteToDB,
          onRelays: (relays) {
        if (!loaded) {
          loaded = true;
          onRelays(relays);
        }
      });
      if (timeoutSeconds != null) {
        Future.delayed(Duration(seconds: timeoutSeconds), () {
          if (!loaded) {
            loaded = true;
            onRelays([]);
          }
        });
      }
    } else {
      onRelays(relays);
    }
  }

  Future<void> getContacts(String pubKey, Function(ContactList) onContacts,
      {int? timeoutSeconds}) async {
    ContactList? contactList = await ContactList.loadFromDB(pubKey);
    bool loaded = false;
    if (contactList == null) {
      await loadRelayAndContactList(pubKey, onContacts: (list) {
        if (!loaded) {
          loaded = true;
          onContacts(list);
        }
      });
      if (timeoutSeconds != null) {
        Future.delayed(Duration(seconds: timeoutSeconds), () {
          if (!loaded) {
            loaded = true;
            onContacts(ContactList());
          }
        });
      }
    } else {
      onContacts(contactList);
    }
  }

  Future<void> loadRelays(String? pubKey, Function onComplete) async {
    print("Loading relays for logged user...");
    bool loading = false;
    if (pubKey != null) {
      await relayProvider.getRelays(pubKey, forceWriteToDB: true,
          (relays) async {
        if (!loading) {
          loading = true;
          relayAddrs.clear();
          if (relays != null) {
            relayAddrs.addAll(relays.map(
              (e) => e.url!,
            ));
          }

          if (relayAddrs.isEmpty) {
            // init relays
            relayAddrs = List<String>.from(STATIC_RELAY_ADDRS);
          }
          print("Loaded ${relays.length} relays for logged user...");
          onComplete();
        }
      });
    }
  }

  bool loadingGossipRelays = false;

  // Future<void> buildNostrFromContactsRelays(
  //     String pubKey,
  //     ContactList contactList,
  //     int takeCountForEachContact,
  //     Function(Nostr) onComplete) async {
  //   int i = 0;
  //   Map<String, Set<String>> pubKeysByRelayUrl = {};
  //   Map<String, List<RelayMetadata>> nip65s = {};
  //   bool canLoadRelays = true;
  //   for (Contact contact in contactList.list()) {
  //     await relayProvider
  //         .getRelays(timeoutSeconds: 3, contact.publicKey!, (relays) async {
  //           if (canLoadRelays) {
  //             relays
  //                 .where((element) =>
  //             (element.write == null || element.write!) &&
  //                 element.isValidWss)
  //                 .map((e) => e.addr)
  //                 .forEach((r) {
  //               String? adr = Relay.clean(r!);
  //               if (adr == null) {
  //                 return;
  //               }
  //               ;
  //               if (pubKeysByRelayUrl[adr] == null) {
  //                 pubKeysByRelayUrl[adr] = {};
  //               }
  //               pubKeysByRelayUrl[adr]!.add(contact.publicKey!);
  //               nip65s[contact.publicKey!] = relays;
  //             });
  //             print(
  //                 "Loaded ${relays.length} relays for contact ${contact
  //                     .publicKey} $i/${contactList
  //                     .list()
  //                     .length}");
  //           }
  //         })
  //         .timeout(const Duration(seconds: 10))
  //         .onError((error, stackTrace) async {
  //           print(
  //               "Couldn't get relays for ${contact.publicKey!} in 3 seconds....");
  //         });
  //   }
  //   canLoadRelays = false;
  //
  //   onComplete(await createNostrFromFollowRelaysMap(
  //       contactList, pubKey, pubKeysByRelayUrl, nip65s));
  // }

  Future<Nostr> createNostrFromFollowRelaysMap(
      ContactList contactList,
      String pubKey,
      Map<String, Set<String>> pubKeysByRelayUrl,
      Map<String, List<RelayMetadata>> nip65s) async {
    Nostr buildingNostr = Nostr(privateKey: null, publicKey: pubKey);
    Map<String, Set<String>> pubKeyRelaysMap = {};
    int i = 0;
    int min = settingProvider.followeesRelayMinCount;
    for (String url in pubKeysByRelayUrl.keys) {
      i++;
      if (!pubKeysByRelayUrl[url]!.any((pub_key) =>
          pubKeyRelaysMap[pub_key] == null ||
          pubKeyRelaysMap[pub_key]!.length < min)) {
        continue;
      }
      print(" Relay ${i} / ${pubKeysByRelayUrl.length}");
      Relay relay = Relay(
        url,
        RelayStatus(url),
        access: WriteAccess.readWrite,
      );
      bool connected = await buildingNostr!
          .addRelay(relay, connect: true, checkInfo: false)
          .onError((error, stackTrace) => false);
      if (connected && relay.isActive()) {
        print(
            "+++++ Relay ${url} with ${pubKeysByRelayUrl[url]!.length} pubKeys is connected...");
        for (String pubKey in pubKeysByRelayUrl[url]!) {
          Set<String>? relays = pubKeyRelaysMap[pubKey];
          if (relays == null) {
            relays = {};
            pubKeyRelaysMap[pubKey] = relays;
          }
          relays.add(url);
        }
        print(
            "Contacts filled ${pubKeyRelaysMap.length}/ ${contactList.list().length}");
      } else {
        buildingNostr.removeRelay(url);
        print(
            "----- Relay ${url} with ${pubKeysByRelayUrl[url]!.length} pubKeys is NOT connected...");
      }
    }

    for (Contact contact in contactList.list()) {
      int relays = pubKeyRelaysMap[contact.publicKey] != null
          ? pubKeyRelaysMap[contact.publicKey]!.length
          : 0;
      if (relays == 0) {
        print("contact ${contact.publicKey} has $relays connected relays !!!");
        if (nip65s[contact.publicKey] != null) {
          nip65s[contact.publicKey]!.forEach((metadata) {
            Relay? r = buildingNostr.getRelay(metadata.url!);
            print(
                "    relay ${metadata.url} active = ${r!=null? r.isActive(): false}");
          });
        }
      }
    }

    List<MapEntry<String, Set<String>>> sortedEntries =
        pubKeysByRelayUrl!.entries.toList();

    sortedEntries.sort((a, b) => b.value.length.compareTo(a.value.length));

    followRelays = [];

    for (var entry in sortedEntries) {
      followRelays!
          .add(RelayMetadata.full(url: entry.key, count: entry.value.length));
    }
    return buildingNostr;
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

  Future<Object> addRelays(Nostr nostr) async {
    List<Future<bool>> futures = [];
    for (var relayAddr in relayAddrs) {
      print("addRelays going for genRelay($relayAddr)....");
      var custRelay = genRelay(relayAddr);
      try {
        print("addRelays going for addRelay($relayAddr)....");
        futures.add(nostr.addRelay(custRelay, init: false, checkInfo: true));
      } catch (e) {
        log("relay $relayAddr add to pool error ${e.toString()}");
      }
    }
    final startTime = DateTime.now();
    await Future.wait(futures).onError((error, stackTrace) => List.of([]));
    final endTime = DateTime.now();
    final duration = endTime.difference(startTime);
    print(
        "addRelays for ${relayAddrs.length} parallel Future.wait(futures) took:${duration.inMilliseconds} ms");
    return Object();
  }

  // Future<Nostr> genNostr({String? privateKey, String? publicKey}) async {
  //   var loggedUserNostr = Nostr(privateKey: privateKey, publicKey: publicKey);
  //   print("getNostr going for addRelays....");
  //   await addRelays(loggedUserNostr);
  //
  //   // print("getNostr going for getContacts....");
  //   // await getContacts(loggedUserNostr.publicKey, (contactList) async {
  //   //   print("getNostr GOT ${contactList.contacts!.length} contacts....");
  //   //   contactListProvider.set(contactList);
  //   //   if (settingProvider.gossip == 1) {
  //   //     print("getNostr going for buildNostrFromContactsRelays....");
  //   //     await buildNostrFromContactsRelays(
  //   //       loggedUserNostr.publicKey,
  //   //       contactList,
  //   //       settingProvider.followeesRelayMinCount ??
  //   //           SettingProvider.DEFAULT_FOLLOWEES_RELAY_MIN_COUNT,
  //   //       (builtNostr) {
  //   //         if (followsNostr == null) {
  //   //           followsNostr = builtNostr;
  //   //           // add logged user's configured read relays
  //   //           // loggedUserNostr!
  //   //           //     .activeRelays()
  //   //           //     .where((relay) => relay.access != WriteAccess.writeOnly)
  //   //           //     .forEach((relay) {
  //   //           //   followsNostr!.addRelay(relay, connect: true);
  //   //           // });
  //   //           print(
  //   //               "getNostr going for followEventProvider.doQuery() with followNostr SET....");
  //   //           followEventProvider.doQuery();
  //   //         }
  //   //       },
  //   //     );
  //   //   } else {
  //   //     print(
  //   //         "getNostr going for followEventProvider.doQuery() with nostr....");
  //   //     nostr = loggedUserNostr;
  //   //     followEventProvider.doQuery();
  //   //   }
  //   // });
  //   // add initQuery
  //   // contactListProvider.query(targetNostr: _nostr);
  //   // contactListProvider.reload(targetNostr: _nostr);
  //   notificationsProvider.doQuery(
  //       targetNostr: loggedUserNostr, initQuery: true);
  //   // Future.delayed(
  //   //     const Duration(seconds: 3),
  //   //     () => {
  //   //           dmProvider.initDMSessions(loggedUserNostr.publicKey).then((_) {
  //   //             // dmProvider.query(targetNostr: _nostr, subscribe: false);
  //   //           })
  //   //         });
  //   // .then((_) {
  //   //   dmProvider.query(targetNostr: _nostr, subscribe: true);
  //   // })
  //   // ;
  //   return loggedUserNostr;
  // }

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
        relays.add(RelayMetadata.full(url: addr, read: true, write: true));
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

      var event = Nip01Event(pubKey:
          tempNostr!.publicKey, kind: kind.EventKind.RELAY_LIST_METADATA, tags: tags, content: "");
      tempNostr!.sendEvent(event);
      int now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      try {
        await RelayList.writeToDB(nostr!.publicKey, relays, now);
      } catch (e) {
        print(e);
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

  void clear() {
    relayStatusMap.clear();
    if (staticForRelaysAndMetadataNostr != null) {
      staticForRelaysAndMetadataNostr!.close();
      staticForRelaysAndMetadataNostr = null;
    }
  }

  Future<void> initStaticForRelaysAndMetadataNostr(String pubKey) async {
    if (staticForRelaysAndMetadataNostr == null) {
      List<Future<bool>> futures = [];
      Set<String> uniqueRelays =
          Set<String>.from(RelayProvider.STATIC_RELAY_ADDRS);
      uniqueRelays.addAll(relayProvider.relayAddrs);
      staticForRelaysAndMetadataNostr = Nostr(publicKey: pubKey);

      for (String relayAddr in uniqueRelays) {
        Relay r = Relay(
          relayAddr,
          RelayStatus(relayAddr),
          access: WriteAccess.readWrite,
        );
        try {
          futures.add(
              staticForRelaysAndMetadataNostr!.addRelay(r, checkInfo: false));
        } catch (e) {
          log("relay $relayAddr add to temp nostr for getting nip065 relay list: ${e.toString()}");
        }
      }
      final startTime = DateTime.now();
      await Future.wait(futures).onError((error, stackTrace) => List.of([]));
      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);
      print(
          "initStaticForRelaysAndMetadataNostr addRelays for ${relayAddrs.length} parallel Future.wait(futures) took:${duration.inMilliseconds} ms");
    }
  }

  Future<void> loadRelayAndContactList(String pubKey,
      {Function(List<RelayMetadata>)? onRelays,
      Function(ContactList)? onContacts,
      bool forceWriteToDB = false}) async {
    await initStaticForRelaysAndMetadataNostr(pubKey);
    var filter = Filter(
        authors: [pubKey],
        limit: 2,
        kinds: [
          kind.EventKind.RELAY_LIST_METADATA,
          kind.EventKind.CONTACT_LIST
        ]);
    List<Future> futures = staticForRelaysAndMetadataNostr!
        .allRelays()
        .map(
          (e) => e.future!,
        )
        .toList();

    await Future.wait(futures).onError((error, stackTrace) {
      return List.of([]);
    }).then((sockets) {
      Event? relaysEvent;
      Event? contactsEvent;
      print(
          "loading from staticForRelaysAndMetadataNostr: $staticForRelaysAndMetadataNostr, contacts and relays for $pubKey");
      staticForRelaysAndMetadataNostr!.query(
          id: StringUtil.rndNameStr(16), [filter.toJson()], (event) async {
        // print(
        //     "RECEIVED event kind ${event.kind} going to process, staticForRelaysAndMetadataNostr: $staticForRelaysAndMetadataNostr");

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
                    relays!.add(RelayMetadata.full(
                        url: value, read: read, write: write));
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
                    relays!.add(RelayMetadata.full(
                        url: entry.key.toString(), read: read, write: write));
                  }
                }
              } catch (e) {
                print(e);
              }
            }
          }
          if (relays != null && relays.isNotEmpty) {
            try {
              await RelayList.writeToDB(pubKey, relays, relaysEvent!.createdAt,
                  forceWrite: forceWriteToDB);
            } catch (e) {
              print(e);
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
          contactsEvent = event;
          ContactList contactList = ContactList.fromJson(event.tags);
          contactList.pub_key = event.pubKey;
          contactList.timestamp = event.createdAt;
          await ContactList.writeToDB(contactList);
          if (onContacts != null) {
            onContacts(contactList);
          }
        }
      });
    });
  }
}
