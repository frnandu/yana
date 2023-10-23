import 'dart:convert';

import 'package:dart_ndk/nips/nip01/event.dart';
import 'package:dart_ndk/nips/nip01/metadata.dart';
import 'package:dart_ndk/nips/nip01/filter.dart';
import 'package:flutter/material.dart';
import 'package:yana/nostr/nip05/nip05_validor.dart';
import 'package:yana/utils/nip05status.dart';

import '../main.dart';
import '../nostr/event.dart';
import '../nostr/event_kind.dart' as kind;
import '../utils/later_function.dart';
import '../utils/string_util.dart';

class MetadataProvider extends ChangeNotifier with LaterFunction {
  Map<String, Metadata> _metadataCache = {};

  Map<String, int> _handingPubkeys = {};

  static MetadataProvider? _metadataProvider;

  static Future<MetadataProvider> getInstance() async {
    if (_metadataProvider == null) {
      _metadataProvider = MetadataProvider();

      // var list = await Metadata.loadAllFromDB();
      // for (var md in list) {
      //   if (md.valid == Nip05Status.NIP05_NOT_VALIDED) {
      //     md.valid = null;
      //   }
      //   _metadataProvider!._metadataCache[md.pubKey!] = md;
      // }
      // lazyTimeMS begin bigger and request less
      _metadataProvider!.laterTimeMS = 500;
    }

    return _metadataProvider!;
  }

  List<Metadata> findUser(String str, {int? limit = 5}) {
    List<Metadata> list = [];
    if (StringUtil.isNotBlank(str)) {
      var values = _metadataCache.values;
      for (var metadata in values) {
        if (metadata.matchesSearch(str)) {
          list.add(metadata);

          if (limit != null && list.length >= limit) {
            break;
          }
        }
      }
    }
    return list;
  }

  void _laterCallback() {
    if (_needUpdatePubKeys.isNotEmpty) {
      _laterSearch();
    }

    if (_penddingEvents.isNotEmpty) {
      _handlePenddingEvents();
    }
  }

  List<String> _needUpdatePubKeys = [];

  void update(String pubkey) {
    if (!_needUpdatePubKeys.contains(pubkey)) {
      _needUpdatePubKeys.add(pubkey);
    }
    later(_laterCallback, null);
  }

  Metadata? getMetadata(String pubkey) {
    var metadata = _metadataCache[pubkey];
    if (metadata != null) {
      return metadata;
    }

    if (!_needUpdatePubKeys.contains(pubkey) &&
        !_handingPubkeys.containsKey(pubkey)) {
      _needUpdatePubKeys.add(pubkey);
    }
    later(_laterCallback, null);
    return null;
  }

  void getMostRecentMetadata(String pubkey, Function(Metadata) onEvent) {
    var metadata = _metadataCache[pubkey];
    if (metadata != null) {
      onEvent(metadata);
    } else {
      nostr!.query([
        Filter(kinds: [Metadata.kind], authors: [pubkey], limit: 1)
            .toMap()
      ], (event) {
        var existing = _metadataCache[event.pubKey];
        if (existing == null ||
            existing.updatedAt == null ||
            existing.updatedAt! < event.createdAt) {
          handleEvent(event);
        }
      }, onComplete: () {
        var metadata = _metadataCache[pubkey];
        if (metadata != null) {
          onEvent(metadata);
        }
      });
    }
  }

  int getNip05Status(String pubkey) {
    // var metadata = getMetadata(pubkey);
    // if (metadata == null) {
    //   return Nip05Status.METADATA_NOT_FOUND;
    // } else if (StringUtil.isBlank(metadata.nip05)) {
    //   return Nip05Status.NIP05_NOT_FOUND;
    // } else if (metadata.valid == null) {
    //   Nip05Validor.valid(metadata.nip05!, pubkey).then((valid) async {
    //     if (valid != null) {
    //       if (valid) {
    //         metadata.valid = Nip05Status.NIP05_VALIDED;
    //         await Metadata.writeToDB(metadata);
    //       } else {
    //         // only update cache, next open app vill valid again
    //         metadata.valid = Nip05Status.NIP05_NOT_VALIDED;
    //       }
    //       notifyListeners();
    //     }
    //   });
    //
    //   return Nip05Status.NIP05_NOT_VALIDED;
    // } else if (metadata.valid! == Nip05Status.NIP05_VALIDED) {
    //   return Nip05Status.NIP05_VALIDED;
    // }
    return Nip05Status.NIP05_NOT_FOUND;
  }

  List<Nip01Event> _penddingEvents = [];

  void _handlePenddingEvents() {
    for (var event in _penddingEvents) {
      if (StringUtil.isBlank(event.content)) {
        continue;
      }
      _handingPubkeys.remove(event.pubKey);

      var jsonObj = jsonDecode(event.content);
      var md = Metadata.fromJson(jsonObj);
      md.pubKey = event.pubKey;
      md.updatedAt = event.createdAt;

      // TODO
      //Metadata.writeToDB(md);
      _metadataCache[md.pubKey!] = md;
    }
    _penddingEvents.clear();

    notifyListeners();
  }

  void _onEvent(Nip01Event event) {
    _penddingEvents.add(event);
    later(_laterCallback, null);
  }

  void _laterSearch() async {
    if (_needUpdatePubKeys.isEmpty) {
      return;
    }

    // List<Map<String, dynamic>> filters = [];
    // for (var pubkey in _needUpdatePubKeys) {
    //   var filter =
    //       Filter(kinds: [kind.EventKind.METADATA], authors: [pubkey], limit: 1);
    //   filters.add(filter.toMap());
    //   if (filters.length > 11) {
    //     nostr!.query(filters, _onEvent);
    //     filters.clear();
    //   }
    // }
    // if (filters.isNotEmpty) {
    //   nostr!.query(filters, _onEvent);
    // }
    if (myInboxRelays!=null) {
      Stream<Nip01Event> stream = await relayManager.requestRelays(
          myInboxRelays!.items.map((e) => e.url).toList(), Filter(
          kinds: [Metadata.kind], authors: _needUpdatePubKeys));
      stream.listen((event) {
        _onEvent(event);
      });

      for (var pubkey in _needUpdatePubKeys) {
        _handingPubkeys[pubkey] = 1;
      }
      _needUpdatePubKeys.clear();
    }
  }

  void clear() {
    _metadataCache.clear();
    // TODO
    //Metadata.deleteAllFromDB();
  }

  Metadata handleEvent(Event event) {
    _handingPubkeys.remove(event.pubKey);

    var jsonObj = jsonDecode(event.content);
    var md = Metadata.fromJson(jsonObj);
    md.pubKey = event.pubKey;
    md.updatedAt = event.createdAt;

    // TODO
    //Metadata.writeToDB(md);
    _metadataCache[md.pubKey!] = md;
    return md;
  }
}
