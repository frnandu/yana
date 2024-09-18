import 'package:isar/isar.dart';
import 'package:ndk/ndk.dart';

part 'db_contact_list.g.dart';

@Collection(inheritance: true)
class DbContactList extends ContactList {
  DbContactList({required super.pubKey, required super.contacts});

  String get id => pubKey;

  static DbContactList fromContactList(ContactList contactList) {
    DbContactList dbContactList = DbContactList(
      pubKey: contactList.pubKey,
      contacts: contactList.contacts,
    );
    dbContactList.createdAt = contactList.createdAt;
    dbContactList.loadedTimestamp = contactList.loadedTimestamp;
    dbContactList.sources = contactList.sources;
    dbContactList.followedCommunities = contactList.followedCommunities;
    dbContactList.followedTags = contactList.followedTags;
    dbContactList.followedEvents = contactList.followedEvents;
    dbContactList.contactRelays = contactList.contactRelays;
    dbContactList.petnames = contactList.petnames;
    return dbContactList;
  }

// static DbContactList fromNip02ContactList(Nip02ContactList nip02contactList) {
  //   List<Contact> contacts = nip02contactList.contacts.map((contact) {
  //     int idx = nip02contactList.contacts.indexOf(contact);
  //     String? relay = nip02contactList.contactRelays.length > idx ? nip02contactList.contactRelays[idx] : null;
  //     if (relay != null && Helpers.isBlank(relay)) {
  //       relay = null;
  //     }
  //     String? petname = nip02contactList.petnames.length > idx ? nip02contactList.petnames[idx] : null;
  //     if (petname != null && Helpers.isBlank(petname)) {
  //       petname = null;
  //     }
  //     return Contact(contact, relay, petname);
  //   }).toList();
  //
  //   return DbContactList(
  //       nip02contactList.pubKey,
  //       contacts,
  //       nip02contactList.createdAt,
  //       DateTime
  //           .now()
  //           .millisecondsSinceEpoch ~/ 1000
  //   );
  // }
}
//
// @embedded
// class Contact {
//   String pubKey;
//   String? petname;
//   String? relay;
//
//   Contact(this.pubKey, this.petname, this.relay);
// }
