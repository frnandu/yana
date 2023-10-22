import 'package:isar/isar.dart';
import 'package:yana/models/db.dart';
import 'package:yana/nostr/relay_metadata.dart';

import '../main.dart';

part 'relay_list.g.dart';

@collection
class RelayList {

  @Index(hash: true)
  String? pub_key;

  String get id => pub_key!;

  List<RelayMetadata>? relays;

  int? timestamp;

  static Map<String, List<RelayMetadata>> cached = {};

  static Future<List<RelayMetadata>?> loadFromDB(String pubKey,
      {bool useCache = true}) async {
    List<RelayMetadata>? list = useCache ? cached[pubKey] : null;
    if (list == null) {
      final startTime = DateTime.now();
      final relayList = DB
          .getIsar()
          .relayLists
          .where()
          .pub_keyEqualTo(pubKey)
          .findFirst();
      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);
      if (relayList != null) {
        list = relayList.relays;
        print("LOADED ${relayList.relays!.length} relays from DATABASE for $pubKey took ${duration.inMilliseconds} ms");
        cached[pubKey] = list!;
      } else {
        cached[pubKey] = [];
      }
    } else {
      print("LOADED ${list!.length} relays from MEMORY for $pubKey");
    }
    return list;
  }

  static Future<int> writeToDB(
      String pubKey, List<RelayMetadata> list, int updated_at, {bool forceWrite = false}) async {
    cached[pubKey] = list;
    if (forceWrite || nostr != null && nostr!.publicKey == pubKey ||
        contactListProvider.contacts().contains(pubKey)) {
      RelayList relayList = RelayList();
      relayList.pub_key = pubKey;
      relayList.relays = list;
      relayList.timestamp = updated_at;

      await DB.getIsar().writeAsync((isar) {
        isar.relayLists.put(relayList!);
      });
    }
    return 0;
  }
}
