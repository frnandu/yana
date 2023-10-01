import 'package:sqflite/sqflite.dart';
import 'package:yana/nostr/relay_metadata.dart';

import 'db.dart';

class RelaysDB {
  // static Future<List<RelayMetadata>> all({DatabaseExecutor? db}) async {
  //   List<Metadata> objs = [];
  //   Database db = await DB.getCurrentDatabase();
  //   List<Map<String, dynamic>> list =
  //       await db.rawQuery("select * from relays");
  //   for (var i = 0; i < list.length; i++) {
  //     var json = list[i];
  //     objs.add(Metadata.fromJson(json));
  //   }
  //   return objs;
  // }

  static Future<List<RelayMetadata>> get(String pubKey, {DatabaseExecutor? db}) async {
    db = await DB.getDB(db);
    var list =
        await db.query("relay", where: "pub_key = ?", whereArgs: [pubKey]);
    if (list.isNotEmpty) {
      return RelayMetadata.fromJson(list[0]);
    }
    return List.empty();
  }

  static Future<int> insert(String pubKey, List<RelayMetadata> list, int updated_at, {DatabaseExecutor? db}) async {
    db = await DB.getDB(db);
    return await db.insert("relay", RelayMetadata.toFullJson(pubKey, list, updated_at));
  }

  static Future update(String pubKey, List<RelayMetadata> list, int updated_at, {DatabaseExecutor? db}) async {
    db = await DB.getDB(db);
    await db.update("relay", RelayMetadata.toFullJson(pubKey, list, updated_at),
        where: "pub_key = ?", whereArgs: [pubKey]);
  }

  static Future<void> deleteAll({DatabaseExecutor? db}) async {
    db = await DB.getDB(db);
    db.execute("delete from relay");
  }
}
