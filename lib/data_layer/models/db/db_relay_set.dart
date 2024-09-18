// ignore_for_file: unnecessary_overrides

import 'package:isar/isar.dart';
import 'package:ndk/entities.dart';
import 'package:ndk/ndk.dart';


part 'db_relay_set.g.dart';

@Collection(inheritance: false)
class DbRelaySet extends RelaySet {
  @override
  String get id => super.id;

  @override
  String get name => super.name;

  @override
  String get pubKey => super.pubKey;

  @override
  RelayDirection get direction => super.direction;

  @override
  int get relayMinCountPerPubkey => super.relayMinCountPerPubkey;

  List<DbRelaySetItem> get items => super
      .relaysMap
      .entries
      .map((entry) => DbRelaySetItem(entry.key, dbPubkeyMappings(entry.value)))
      .toList();

  static List<DbPubkeyMapping> dbPubkeyMappings(List<PubkeyMapping> mappings) {
    return mappings
        .map(
          (e) => DbPubkeyMapping(pubKey: e.pubKey, marker: e.rwMarker.name),
        )
        .toList();
  }

  DbRelaySet(
      {required super.name,
      required super.pubKey,
      required List<DbRelaySetItem> items,
      required super.direction,
      required super.relayMinCountPerPubkey})
      : super(relaysMap: {for (var e in items) e.url: e.pubKeyMappings});

  DbRelaySet.fromRelaySet(RelaySet set)
      : super(
            name: set.name,
            pubKey: set.pubKey,
            relaysMap: set.relaysMap,
            direction: set.direction,
            relayMinCountPerPubkey: set.relayMinCountPerPubkey);
}

@Embedded(inheritance: false)
class DbPubkeyMapping extends PubkeyMapping {
  @override
  String get pubKey => super.pubKey;

  String get marker => super.rwMarker.name;

  DbPubkeyMapping({required super.pubKey, required String marker})
      : super(rwMarker: fromName(marker));

  static ReadWriteMarker fromName(String name) {
    if (name == ReadWriteMarker.readOnly.name) {
      return ReadWriteMarker.readOnly;
    } else if (name == ReadWriteMarker.writeOnly.name) {
      return ReadWriteMarker.writeOnly;
    }
    return ReadWriteMarker.readWrite;
  }
}

@embedded
class DbRelaySetItem {
  String url;
  List<DbPubkeyMapping> pubKeyMappings;

  DbRelaySetItem(this.url, this.pubKeyMappings);
}
