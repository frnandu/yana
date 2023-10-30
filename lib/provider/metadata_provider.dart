import 'package:dart_ndk/models/relay_set.dart';
import 'package:dart_ndk/nips/nip01/metadata.dart';
import 'package:dart_ndk/nips/nip05/nip05.dart';
import 'package:flutter/material.dart';

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
    if (_needUpdateNip05s.isNotEmpty) {
      _loadNeedingUpdateNip05s();
    }
  }

  List<String> _needUpdateMetadatas = [];
  List<Metadata> _needUpdateNip05s = [];

  void update(String pubkey) {
    if (!_needUpdateMetadatas.contains(pubkey)) {
      _needUpdateMetadatas.add(pubkey);
    }
    later(_laterCallback, null);
  }

  Metadata? getMetadata(String pubKey) {
    var metadata = cacheManager.loadMetadata(pubKey);
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

  bool? isNip05Valid(Metadata metadata) {
    if (StringUtil.isNotBlank(metadata.nip05)) {
      Nip05? nip05 = cacheManager.loadNip05(metadata.pubKey);
      if (nip05==null || nip05.needsUpdate(NIP05_NEEDS_UPDATE_DURATION)) {
        if (!_needUpdateNip05s.contains(metadata)) {
          _needUpdateNip05s.add(metadata);
          later(_laterCallback, null);
          return null;
        }
      }
      return nip05?.valid;
    }
    return null;
  }

  void _loadNeedingUpdateMetadatas() async {
    if (_needUpdateMetadatas.isEmpty) {
      return;
    }
    RelaySet? relaySet = settingProvider.gossip == 1 && feedRelaySet!=null ? feedRelaySet : myInboxRelaySet;
    if (relaySet!=null) {
      List<Metadata> loaded = await relayManager.loadMissingMetadatas(
        _needUpdateMetadatas,
        relaySet,
        splitRequestsByPubKeyMappings: settingProvider.gossip == 1
      );
      _needUpdateMetadatas.clear();

      if (loaded.isNotEmpty) {
        notifyListeners();
      }
    }
  }

  void _loadNeedingUpdateNip05s() async {
    if (_needUpdateNip05s.isEmpty) {
      return;
    }
    List<Nip05> toSave = [];

    List<Metadata> doCheck = List.of(_needUpdateNip05s);
    for (var metadata in doCheck) {
      Nip05? nip05 = cacheManager.loadNip05(metadata.pubKey);
      bool valid = await Nip05.check(metadata.nip05!, metadata.pubKey);
      nip05 ??= Nip05(pubKey: metadata.pubKey, nip05: metadata.nip05!, valid: valid, updatedAt: DateTime.now().millisecondsSinceEpoch ~/1000);
      nip05.valid= valid;
      toSave.add(nip05);
    }
    await cacheManager.saveNip05s(toSave);
    _needUpdateNip05s.clear();
    notifyListeners();
  }

  void clear() {
    cacheManager.removeAllMetadatas();
    cacheManager.removeAllNip05s();
  }
}
