import 'dart:convert';

import 'package:dart_ndk/nips/nip01/event.dart';
import 'package:dart_ndk/nips/nip02/contact_list.dart';
import 'package:flutter/material.dart';
import 'package:yana/router/tag/topic_map.dart';

import '../main.dart';
import '../utils/string_util.dart';
import 'data_util.dart';

class ContactListProvider extends ChangeNotifier {
  static ContactListProvider? _contactListProvider;

  Nip01Event? _event;

  ContactList? contactList;

  static ContactListProvider getInstance() {
    if (_contactListProvider == null) {
      _contactListProvider = ContactListProvider();
      // _contactListProvider!.reload();
    }
    return _contactListProvider!;
  }

  void set(ContactList contactList) {
    this.contactList = contactList;
  }

  // void reload({Nostr? targetNostr}) {
  //   targetNostr ??= nostr;
  //
  //   String? pubkey;
  //   if (targetNostr != null) {
  //     pubkey = targetNostr.publicKey;
  //   }
  //
  //   var str = sharedPreferences.getString(DataKey.CONTACT_LISTS);
  //   if (StringUtil.isNotBlank(str)) {
  //     var jsonMap = jsonDecode(str!);
  //
  //     if (jsonMap is Map<String, dynamic>) {
  //       String? eventStr;
  //       if (StringUtil.isNotBlank(pubkey)) {
  //         eventStr = jsonMap[pubkey];
  //       } else if (jsonMap.length == 1) {
  //         eventStr = jsonMap.entries.first.value as String;
  //       }
  //
  //       if (eventStr != null) {
  //         var eventMap = jsonDecode(eventStr);
  //         _contactListProvider!._event = Nip01Event.fromJson(eventMap);
  //         _contactListProvider!._contactList =
  //             ContactList.fromJson(_contactListProvider!._event!.tags);
  //
  //         return;
  //       }
  //     }
  //   }
  //
  //   _contactListProvider!._contactList = ContactList();
  // }

  var subscriptId = StringUtil.rndNameStr(16);

  // void _onEvent(Nip01Event e) {
  //   if (e.kind == kind.EventKind.CONTACT_LIST) {
  //     if (_event == null || e.createdAt > _event!.createdAt) {
  //       _event = e;
  //       _contactList = ContactList.fromJson(e.tags);
  //       _saveAndNotify();
  //     }
  //   }
  // }

  void _saveAndNotify() {
    var eventJsonMap = _event!.toJson();
    var eventJsonStr = jsonEncode(eventJsonMap);

    var pubkey = nostr!.publicKey;
    Map<String, dynamic>? allJsonMap;

    var str = sharedPreferences.getString(DataKey.CONTACT_LISTS);
    if (StringUtil.isNotBlank(str)) {
      allJsonMap = jsonDecode(str!);
    }
    allJsonMap ??= {};

    allJsonMap[pubkey] = eventJsonStr;
    var jsonStr = jsonEncode(allJsonMap);

    sharedPreferences.setString(DataKey.CONTACT_LISTS, jsonStr);
    notifyListeners();


    contactList!.contacts.forEach((contact) { metadataProvider.update(contact!);});
    //followEventProvider.metadataUpdatedCallback(_contactList);
  }

  int total() {
    return contactList!.contacts.length;
  }

  Future<ContactList?> getContactList(String pubKey) async {
    return await relayManager.loadContactList(pubKey);
  }

  Future<void> addContact(String contact) async {
    /// TODO use dart_ndk
    // contactList!.contacts.add(contact.publicKey!);
    // _event = await nostr!.sendContactList(_contactList!);

    _saveAndNotify();
  }

  Future<void> removeContact(String pubKey) async{
    /// TODO use dart_ndk
    // contactList!.contacts.remove(pubKey);
    // _event = await nostr!.sendContactList(_contactList!);

    _saveAndNotify();
  }

  // Future<void> updateContacts(ContactList contactList) async {
  //   _contactList = contactList;
  //   _event = await nostr!.sendContactList(contactList);
  //
  //   _saveAndNotify();
  // }
  //

  List<String> contacts() {
    return contactList!=null ? contactList!.contacts : [];
  }

  void clear() {
    _event = null;
    contactList = null;

    notifyListeners();
  }

  bool containTag(String tag) {
    var list = TopicMap.getList(tag);
    if (list != null) {
      for (var t in list) {
        var exist = contactList!.followedTags!=null && contactList!.followedTags!.contains(t);
        if (exist) {
          return true;
        }
      }
      return false;
    } else {
      return contactList!.followedTags!=null && contactList!.followedTags!.contains(tag);
    }
  }

  Future<void> addTag(String tag) async {
    // _contactList!.addTag(tag);
    // _event = await nostr!.sendContactList(_contactList!);

    _saveAndNotify();
  }

  Future<void> removeTag(String tag) async {
    // _contactList!.removeTag(tag);
    // _event = await nostr!.sendContactList(_contactList!);

    _saveAndNotify();
  }

  // Iterable<String> tagList() {
  //   return _contactList!.tagList();
  // }

  bool containCommunity(String id) {
    return contactList!.followedCommunities!=null && contactList!.followedCommunities!.contains(id);
  }

  void addCommunity(String tag) async {
    // _contactList!.addCommunity(tag);
    // _event = await nostr!.sendContactList(_contactList!);

    _saveAndNotify();
  }

  void removeCommunity(String tag) async {
    // _contactList!.removeCommunity(tag);
    // _event = await nostr!.sendContactList(_contactList!);

    _saveAndNotify();
  }

  // int totalfollowedCommunities() {
  //   return _contactList!.totalFollowedCommunities();
  // }

  // Iterable<String> followedCommunitiesList() {
  //   return _contactList!.followedCommunitiesList();
  // }
}
