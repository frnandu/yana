import 'package:isar/isar.dart';
import 'package:sqflite/sqflite.dart';
import 'package:yana/main.dart';

import '../nostr/nip02/contact_list.dart';
import 'db.dart';

class ContactsDB {
  // static Future<int> insert(String pubKey, CustContactList list, int updated_at,
  //     {DatabaseExecutor? db}) async {
  //   cached.putIfAbsent(pubKey, () => list);
  //   if (nostr != null && nostr!.publicKey == pubKey ||
  //       contactListProvider.getContact(pubKey) != null) {
  //     db = await DB.getDB(db);
  //     list.list().forEach((contact) async {
  //       await db!.insert("contact", contact.toDB(pubKey), conflictAlgorithm: ConflictAlgorithm.replace);
  //     });
  //     list.tagList().forEach((tag) async {
  //       await db!.insert(
  //           "contact", Contact.toDBFromValues(pubKey, tag, Contact.PETNAME_TAG, null), conflictAlgorithm: ConflictAlgorithm.replace);
  //     });
  //     list.followedCommunitiesList().forEach((community) async {
  //       await db!.insert("contact",
  //           Contact.toDBFromValues(pubKey, community, Contact.PETNAME_COMMUNITY, null), conflictAlgorithm: ConflictAlgorithm.replace);
  //     });
  //     list.followedEventsList().forEach((event) async {
  //       await db!.insert("contact",
  //           Contact.toDBFromValues(pubKey, event, Contact.PETNAME_EVENT, null), conflictAlgorithm: ConflictAlgorithm.replace);
  //     });
  //     return list.total() +
  //         list.totalFollowedTags() +
  //         list.totalFollowedCommunities();
  //   }
  //   return 0;
  // }
  //
  // static Future<void> deleteAll({DatabaseExecutor? db}) async {
  //   cached.clear();
  //   db = await DB.getDB(db);
  //   db.execute("delete from contact");
  // }
}
