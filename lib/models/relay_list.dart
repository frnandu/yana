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

  // List<String>? read;
  //
  // List<String>? write;

  int? timestamp;

  static Map<String, List<RelayMetadata>> cached = {};

  // static Future<List<RelayMetadata>> all({DatabaseExecutor? db}) async {
  //   List<Metadata> objs = [];
  //   Database db = await DB.getCurrentDatabase();
  //   List<Map<String, dynamic>> list =
  //       await db.rawQuery("select * from relays");
  static Future<List<RelayMetadata>?> get(String pubKey,
      {DatabaseExecutor? db, bool useCache = true}) async {
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
      // db = await DB.getDB(db);
      // var fromDB =
      //     await db.query("relay", where: "pub_key = ?", whereArgs: [pubKey]);
      if (relayList != null) {
        // Set<String> all = {};
        // if (relays.read != null) {
        //   all.addAll(relays.read!);
        // }
        // if (relays.write != null) {
        //   all.addAll(relays.write!);
        // }
        // List<RelayMetadata> list = all
        //     .map((e) => RelayMetadata(e,
        //         read: relays.read != null && relays.read!.contains(e),
        //         write: relays.write != null && relays.write!.contains(e)))
        //     .toList();
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

  //   for (var i = 0; i < list.length; i++) {
  //     var json = list[i];
  //     objs.add(Metadata.fromJson(json));
  //   }
  //   return objs;
  // }

  static Future<int> put(
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
  // static Future<void> deleteAll({DatabaseExecutor? db}) async {
  //   cached.clear();
  //   db = await DB.getDB(db);
  //   await db.database.transaction((txn) async {
  //     txn.execute("delete from relay");
  //   });
  // }
}
