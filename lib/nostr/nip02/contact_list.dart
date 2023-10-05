import 'package:isar/isar.dart';

import '../../main.dart';
import '../../models/db.dart';
import 'contact.dart';

part 'contact_list.g.dart';

@collection
class ContactList {
  static Map<String, ContactList> cached = {};

  Id id = Isar.autoIncrement;

  @Index(type: IndexType.hash)
  String? pub_key;

  List<Contact>? contacts = [];

  Map<String, Contact> _contacts = {};

  final List<String> followedTags;

  final List<String> followedCommunitys;

  final List<String> followedEvents;

  int? timestamp;

  ContactList()
      : _contacts = {},
        contacts = [],
        followedTags = [],
        followedCommunitys = [],
        followedEvents = [];

  static Future<ContactList?> loadFromDB(String pubKey) async {
    ContactList? list = cached[pubKey];
    list ??= await DB
        .getIsar()
        .contactLists
        .filter()
        .pub_keyEqualTo(pubKey)
        .findFirst();
    return list;
  }

  static Future writeToDB(ContactList list) async {
    cached.putIfAbsent(list.pub_key!, () => list);
    if (nostr != null && nostr!.publicKey == list.pub_key! ||
        contactListProvider.getContact(list.pub_key!) != null) {
      if (list.contacts!.isEmpty &&
          list.followedCommunitys.isEmpty &&
          list.followedTags.isEmpty &&
          list.followedEvents.isEmpty) {
        return 0;
      }
      return await DB.getIsar().writeTxn(() async {
        return await DB.getIsar().contactLists.putByIndex("pub_key", list);
      });

      // db = await DB.getDB(db);
      // await db!.delete("contact",where: "pub_key = ?", whereArgs: [pubKey]);
      // return await insert(pubKey, list, updated_at);
    }
    return 0;
  }

  static ContactList fromJson(List<dynamic> tags) {
    ContactList list = ContactList();
    for (List<dynamic> tag in tags) {
      var length = tag.length;
      if (length == 0) {
        continue;
      }

      var t = tag[0];
      if (t == "p") {
        String url = "";
        String petname = "";
        if (length > 2) {
          url = tag[2];
        }
        if (length > 3) {
          petname = tag[3];
        }
        final contact = Contact.full(publicKey: tag[1], petname: petname);
        list.add(contact);
      } else if (t == "t" && length > 1) {
        var tagName = tag[1];
        list.addTag(tagName);
      } else if (t == "a" && length > 1) {
        var id = tag[1];
        list.addCommunity(id);
      } else if (t == "e" && length > 1) {
        var id = tag[1];
        list.addEvent(id);
      } else {
        print("unknown tag $t : ${tag[1]}");
      }
    }
    return list;
  }

  ContactList._(this._contacts, this.followedTags, this.followedCommunitys,
      this.followedEvents);

  List<dynamic> toJson() {
    List<dynamic> result = [];
    for (Contact contact in _contacts.values) {
      result.add(["p", contact.publicKey, contact.url, contact.petname]);
    }
    for (var followedTag in followedTags) {
      result.add(["t", followedTag]);
    }
    for (var id in followedCommunitys) {
      result.add(["a", id]);
    }
    for (var id in followedEvents) {
      result.add(["e", id]);
    }
    return result;
  }

  void add(Contact contact) {
    _contacts[contact.publicKey!] = contact;
    contacts!.add(contact);
  }

  Contact? getContact(String publicKey) {
    if (_contacts == null || _contacts.isEmpty) {
      if (contacts != null && contacts!.isNotEmpty) {
        for (Contact contact in contacts!) {
          _contacts[contact.publicKey!] = contact;
        }
      }
    }
    return _contacts[publicKey];
  }

  Contact? remove(String publicKey) {
    Contact? c = _contacts[publicKey];
    if (c != null && contacts != null) {
      contacts!.remove(c);
    }
    return _contacts.remove(publicKey);
  }

  Iterable<Contact> list() {
    return _contacts.values;
  }

  bool isEmpty() {
    return _contacts.isEmpty;
  }

  int total() {
    return _contacts.length;
  }

  void clear() {
    _contacts.clear();
  }

  bool containsTag(String tagName) {
    return followedTags.contains(tagName);
  }

  void addTag(String tagName) {
    followedTags.add(tagName);
  }

  void addEvent(String id) {
    followedEvents.add(id);
  }

  void removeTag(String tagName) {
    followedTags.remove(tagName);
  }

  int totalFollowedTags() {
    return followedTags.length;
  }

  Iterable<String> tagList() {
    return followedTags;
  }

  bool containsCommunity(String id) {
    return followedCommunitys.contains(id);
  }

  void addCommunity(String id) {
    followedCommunitys.add(id);
  }

  void removeCommunity(String id) {
    followedCommunitys.remove(id);
  }

  int totalFollowedCommunities() {
    return followedCommunitys.length;
  }

  Iterable<String> followedCommunitiesList() {
    return followedCommunitys;
  }

  Iterable<String> followedEventsList() {
    return followedEvents;
  }

// static CustContactList? fromDB(List<Map<String, Object?>> fromDB) {
//   Map<String, Contact> _contacts = {};
//   Map<String, int> _followedCommunitys = {};
//   Map<String, int> _followedTags = {};
//   Map<String, int> _followedEvents = {};
//   fromDB.forEach((map) {
//     Object? object = map['contact'];
//     if (object != null && object is String) {
//       String contact = object.toString();
//       if (map['petname'] == Contact.PETNAME_TAG) {
//         _followedTags[contact] = 1;
//       } else if (map['petname'] == Contact.PETNAME_COMMUNITY) {
//         _followedCommunitys[contact] = 1;
//       } else if (map['petname'] == Contact.PETNAME_EVENT) {
//         _followedEvents[contact] = 1;
//       } else {
//         String url = (map['relay'] ?? '').toString();
//         if (url == 'null') {
//           url = '';
//         }
//         try {
//           _contacts[contact] = Contact.full(
//               publicKey: contact, url: url, petname: "${map['petname']}");
//         } catch (e) {
//           print(e);
//         }
//       }
//     }
//   });
//   return CustContactList._(
//       _contacts, _followedTags, _followedCommunitys, _followedEvents);
// }
}
