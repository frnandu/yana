import 'package:sqflite/sqflite.dart';
import 'package:yana/main.dart';
import 'package:yana/nostr/relay_metadata.dart';

import '../nostr/nip02/contact.dart';
import '../nostr/nip02/cust_contact_list.dart';
import 'db.dart';

class ContactsDB {
  static Map<String, CustContactList> cached = {};

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

  static Future<CustContactList?> get(String pubKey,
      {DatabaseExecutor? db}) async {
    CustContactList? list = cached[pubKey];
    if (list == null) {
      db = await DB.getDB(db);
      var fromDB =
          await db.query("contact", where: "pub_key = ?", whereArgs: [pubKey]);
      if (fromDB.isNotEmpty) {
        list = CustContactList.fromDB(fromDB);
      }
    }
    return list;
  }

  static Future<int> insert(String pubKey, CustContactList list, int updated_at,
      {DatabaseExecutor? db}) async {
    cached.putIfAbsent(pubKey, () => list);
    if (nostr != null && nostr!.publicKey == pubKey ||
        contactListProvider.getContact(pubKey) != null) {
      db = await DB.getDB(db);
      list.list().forEach((contact) async {
        await db!.insert("contact", contact.toDB(pubKey), conflictAlgorithm: ConflictAlgorithm.replace);
      });
      list.tagList().forEach((tag) async {
        await db!.insert(
            "contact", Contact.toDBFromValues(pubKey, tag, Contact.PETNAME_TAG, null), conflictAlgorithm: ConflictAlgorithm.replace);
      });
      list.followedCommunitiesList().forEach((community) async {
        await db!.insert("contact",
            Contact.toDBFromValues(pubKey, community, Contact.PETNAME_COMMUNITY, null), conflictAlgorithm: ConflictAlgorithm.replace);
      });
      list.followedEventsList().forEach((event) async {
        await db!.insert("contact",
            Contact.toDBFromValues(pubKey, event, Contact.PETNAME_EVENT, null), conflictAlgorithm: ConflictAlgorithm.replace);
      });
      return list.total() +
          list.totalFollowedTags() +
          list.totalFollowedCommunities();
    }
    return 0;
  }

  static Future update(String pubKey, CustContactList list, int updated_at,
      {DatabaseExecutor? db}) async {
    cached.putIfAbsent(pubKey, () => list);
    if (nostr != null && nostr!.publicKey == pubKey ||
        contactListProvider.getContact(pubKey) != null) {
      db = await DB.getDB(db);
      await db!.delete("contact",where: "pub_key = ?", whereArgs: [pubKey]);
      return await insert(pubKey, list, updated_at);
    }
    return 0;
  }

  static Future<void> deleteAll({DatabaseExecutor? db}) async {
    cached.clear();
    db = await DB.getDB(db);
    db.execute("delete from contact");
  }
}
