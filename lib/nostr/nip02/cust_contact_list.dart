import 'contact.dart';

class CustContactList {
  final Map<String, Contact> _contacts;

  final Map<String, int> _followedTags;

  final Map<String, int> _followedCommunitys;

  final Map<String, int> _followedEvents;

  CustContactList()
      : _contacts = {},
        _followedTags = {},
        _followedCommunitys = {},
        _followedEvents = {};

  factory CustContactList.fromJson(List<dynamic> tags) {
    Map<String, Contact> _contacts = {};
    Map<String, int> _followedTags = {};
    Map<String, int> _followedCommunitys = {};
    Map<String, int> _followedEvents = {};
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
        final contact = Contact(publicKey: tag[1], petname: petname);
        _contacts[contact.publicKey] = contact;
      } else if (t == "t" && length > 1) {
        var tagName = tag[1];
        _followedTags[tagName] = 1;
      } else if (t == "a" && length > 1) {
        var id = tag[1];
        _followedCommunitys[id] = 1;
      } else if (t == "e" && length > 1){
        var id = tag[1];
        _followedEvents[id] = 1;
      } else {
        print("unknown tag $t : ${tag[1]}");
      }
    }
    return CustContactList._(_contacts, _followedTags, _followedCommunitys, _followedEvents);
  }

  CustContactList._(
      this._contacts, this._followedTags, this._followedCommunitys, this._followedEvents);

  List<dynamic> toJson() {
    List<dynamic> result = [];
    for (Contact contact in _contacts.values) {
      result.add(["p", contact.publicKey, contact.url, contact.petname]);
    }
    for (var followedTag in _followedTags.keys) {
      result.add(["t", followedTag]);
    }
    for (var id in _followedCommunitys.keys) {
      result.add(["a", id]);
    }
    for (var id in _followedEvents.keys) {
      result.add(["e", id]);
    }
    return result;
  }

  void add(Contact contact) {
    _contacts[contact.publicKey] = contact;
  }

  Contact? get(String publicKey) {
    return _contacts[publicKey];
  }

  Contact? remove(String publicKey) {
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
    return _followedTags.containsKey(tagName);
  }

  void addTag(String tagName) {
    _followedTags[tagName] = 1;
  }

  void removeTag(String tagName) {
    _followedTags.remove(tagName);
  }

  int totalFollowedTags() {
    return _followedTags.length;
  }

  Iterable<String> tagList() {
    return _followedTags.keys;
  }

  bool containsCommunity(String id) {
    return _followedCommunitys.containsKey(id);
  }

  void addCommunity(String id) {
    _followedCommunitys[id] = 1;
  }

  void removeCommunity(String id) {
    _followedCommunitys.remove(id);
  }

  int totalFollowedCommunities() {
    return _followedCommunitys.length;
  }

  Iterable<String> followedCommunitiesList() {
    return _followedCommunitys.keys;
  }

  Iterable<String> followedEventsList() {
    return _followedEvents.keys;
  }

  static CustContactList? fromDB(List<Map<String, Object?>> fromDB) {
    Map<String, Contact> _contacts = {};
    Map<String, int> _followedCommunitys = {};
    Map<String, int> _followedTags = {};
    Map<String, int> _followedEvents = {};
    fromDB.forEach((map) {
      Object? object = map['contact'];
      if (object != null && object is String) {
        String contact = object.toString();
        if (map['petname'] == Contact.PETNAME_TAG) {
          _followedTags[contact] = 1;
        } else if (map['petname'] == Contact.PETNAME_COMMUNITY) {
          _followedCommunitys[contact] = 1;
        } else if (map['petname'] == Contact.PETNAME_EVENT) {
          _followedEvents[contact] = 1;
        } else {
          String url = (map['relay'] ?? '').toString();
          if (url=='null') {
            url = '';
          }
          try {
            _contacts[contact] = Contact(
                publicKey: contact,
                url: url,
                petname: "${map['petname']}");
          } catch (e) {
            print(e);
          }
        }
      }
    });
    return CustContactList._(_contacts, _followedTags, _followedCommunitys, _followedEvents);
  }
}
