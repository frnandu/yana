import 'dart:convert';

import 'package:dart_ndk/models/relay_set.dart';
import 'package:dart_ndk/nips/nip01/metadata.dart';
import 'package:flutter/material.dart';
import 'package:yana/utils/nip05status.dart';

import '../main.dart';
import '../utils/later_function.dart';
import '../utils/string_util.dart';

class MetadataProvider extends ChangeNotifier with LaterFunction {

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
    if (StringUtil.isNotBlank(str) && contactListProvider.contactList!=null) {
      List<Metadata?> metadatas = cacheManager.loadMetadatas(contactListProvider.contactList!.contacts);
      for (var metadata in metadatas) {
        if (metadata!=null && metadata.matchesSearch(str)) {
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
  }

  List<String> _needUpdatePubKeys = [];

  void update(String pubkey) {
    if (!_needUpdatePubKeys.contains(pubkey)) {
      _needUpdatePubKeys.add(pubkey);
    }
    later(_laterCallback, null);
  }

  Metadata? getMetadata(String pubKey) {
    var metadata = cacheManager.loadMetadata(pubKey);
    if (metadata != null) {
      return metadata;
    }

    if (!_needUpdatePubKeys.contains(pubKey)) {
      _needUpdatePubKeys.add(pubKey);
    }
    later(_laterCallback, null);
    return null;
  }

  void getMostRecentMetadata(String pubKey, Function(Metadata) onReady) {
    var metadata = cacheManager.loadMetadata(pubKey);
    if (metadata != null) {
      onReady(metadata);
    } else {
      /// TODO use dart_ndk
      // nostr!.query([
      //   Filter(kinds: [Metadata.kind], authors: [pubKey], limit: 1)
      //       .toMap()
      // ], (event) {
      //   var existing = _metadataCache[event.pubKey];
      //   if (existing == null ||
      //       existing.updatedAt == null ||
      //       existing.updatedAt! < event.createdAt) {
      //     handleEvent(event);
      //   }
      // }, onComplete: () {
      //   var metadata = _metadataCache[pubKey];
      //   if (metadata != null) {
      //     onEvent(metadata);
      //   }
      // });
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

  void _laterSearch() async {
    if (_needUpdatePubKeys.isEmpty) {
      return;
    }
    RelaySet? relaySet = settingProvider.gossip == 1 && feedRelaySet!=null ? feedRelaySet : myInboxRelaySet;
    if (relaySet!=null) {
      await relayManager.loadMissingMetadatas(
        _needUpdatePubKeys,
        relaySet
      );
      _needUpdatePubKeys.clear();

      notifyListeners();
    }
  }

  void clear() {
    cacheManager.removeAllMetadatas();
  }
}
