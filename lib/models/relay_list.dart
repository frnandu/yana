import 'package:isar/isar.dart';
import 'package:sqflite/sqflite.dart';
import 'package:yana/main.dart';
import 'package:yana/nostr/relay_metadata.dart';

import 'db.dart';

part 'relay_list.g.dart';

@collection
class RelayList {
  Id id = Isar.autoIncrement;

  @Index(type: IndexType.hash)
  String? pub_key;

  List<RelayMetadata>? relays;

  int? timestamp;

  static Map<String, List<RelayMetadata>> cached = {};

  static Future<List<RelayMetadata>?> loadFromDB(String pubKey,
      {bool useCache = true}) async {
    List<RelayMetadata>? list = useCache ? cached[pubKey] : null;
    if (list == null) {
      final startTime = DateTime.now();
      final relayList = await DB
          .getIsar()
          .relayLists
          .filter()
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
        contactListProvider.getContact(pubKey) != null) {
      RelayList relayList = RelayList();
      relayList.pub_key = pubKey;
      relayList.relays = list;
      relayList.timestamp = updated_at;

      await DB.getIsar().writeTxn(() async {
        await DB.getIsar().relayLists.putByIndex("pub_key", relayList!);
      });
    }
    return 0;
  }
}
