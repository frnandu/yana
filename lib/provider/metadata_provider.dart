import 'package:flutter/material.dart';
import 'package:ndk/config/bootstrap_relays.dart';
import 'package:ndk/entities.dart';

import '../main.dart';
import '../utils/later_function.dart';
import '../utils/string_util.dart';

class MetadataProvider extends ChangeNotifier with LaterFunction {
  static MetadataProvider? _metadataProvider;

  static Future<MetadataProvider> getInstance() async {
    if (_metadataProvider == null) {
      _metadataProvider = MetadataProvider();
      _metadataProvider!.laterTimeMS = 500;
    }

    return _metadataProvider!;
  }

  void _laterCallback() {
    if (_needUpdateMetadatas.isNotEmpty) {
      _loadNeedingUpdateMetadatas();
    }
  }

  List<String> _needUpdateMetadatas = [];

  void update(String pubkey) {
    if (!_needUpdateMetadatas.contains(pubkey)) {
      _needUpdateMetadatas.add(pubkey);
    }
    later(_laterCallback, null);
  }

  Future<Metadata?> getMetadata(String pubKey) async {
    var metadata = await cacheManager.loadMetadata(pubKey);
    if (metadata != null) {
      return metadata;
    }
    if (!_needUpdateMetadatas.contains(pubKey)) {
      _needUpdateMetadatas.add(pubKey);
    }
    later(_laterCallback, null);
    return null;
  }

  static const NIP05_NEEDS_UPDATE_DURATION = const Duration(days: 7);

  Future<bool?> isNip05Valid(Metadata metadata) async {
    if (StringUtil.isNotBlank(metadata.nip05)) {
      // Nip05 nip05 = await ndk.nip05.check(nip05: metadata.nip05!, pubkey: metadata.pubKey);
      return false;//nip05.valid;
    }
    return null;
  }

  bool loading = false;

  void _loadNeedingUpdateMetadatas() async {
    if (_needUpdateMetadatas.isEmpty || loading) {
      return;
    }
    RelaySet? relaySet = settingProvider.gossip == 1 && feedRelaySet != null ? feedRelaySet : myInboxRelaySet;
    if (relaySet != null) {
      loading = true;
      List<Metadata> loaded = await ndk.metadata.loadMetadatas(_needUpdateMetadatas, relaySet, onLoad: (metadata) {
        _needUpdateMetadatas.remove(metadata.pubKey);
        notifyListeners();
      });
      // for(String pubKey in _needUpdateMetadatas) {
      //   await cacheManager.saveMetadata(Metadata(pubKey: pubKey));
      // }
      _needUpdateMetadatas.clear();
      loading = false;

      if (loaded.isNotEmpty) {
        notifyListeners();
      }
    }
  }

  void clear() {
    cacheManager.removeAllMetadatas();
  }

  Future<void> updateLud16IfEmpty(String? lud16) async {
    if (loggedUserSigner!=null) {
      Metadata? metadata = await metadataProvider.getMetadata(loggedUserSigner!.getPublicKey());
      if (metadata!=null) {
        if (StringUtil.isNotBlank(lud16) && StringUtil.isBlank(metadata.lud16)) {
          metadata.lud16 = lud16;
          await ndk.metadata.broadcastMetadata(
              metadata, specificRelays: myInboxRelaySet!.urls);
        }
      } else {
        metadata ??= Metadata(pubKey: loggedUserSigner!.getPublicKey(), lud16: lud16);
        metadata = await ndk.metadata.broadcastMetadata(metadata, specificRelays: DEFAULT_BOOTSTRAP_RELAYS);
        await cacheManager.saveMetadata(metadata);
        notifyListeners();
      }
    }
  }
}
