import 'dart:convert';

import 'package:ndk/domain_layer/entities/contact_list.dart';
import 'package:ndk/domain_layer/entities/nip_01_event.dart';
import 'package:flutter/material.dart';
import 'package:yana/router/tag/topic_map.dart';

import '../main.dart';
import '../utils/string_util.dart';
import 'data_util.dart';

class ContactListProvider extends ChangeNotifier {
  static ContactListProvider? _contactListProvider;

  Nip01Event? _event;

  static ContactListProvider getInstance() {
    _contactListProvider ??= ContactListProvider();
    return _contactListProvider!;
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

  // void _onEvent(Nip01Event e) {
  //   if (e.kind == kind.EventKind.CONTACT_LIST) {
  //     if (_event == null || e.createdAt > _event!.createdAt) {
  //       _event = e;
  //       _contactList = ContactList.fromJson(e.tags);
  //       _saveAndNotify();
  //     }
  //   }
  // }

  // void _saveAndNotify() {
    // contactList!.contacts.forEach((contact) { metadataProvider.update(contact!);});
    //followEventProvider.metadataUpdatedCallback(_contactList);
  // }

  ContactList? getContactList(String pubKey) {
    return cacheManager.loadContactList(pubKey);
  }

  Future<ContactList?> loadContactList(String pubKey) async {
    return await ndk.getContactList(pubKey);
  }

  Future<void> addContact(String contact) async {
    await ndk.broadcastAddContact(contact, myOutboxRelaySet!.urls);

    notifyListeners();
  }

  Future<void> removeContact(String pubKey) async{
    await ndk.broadcastRemoveContact(pubKey, myOutboxRelaySet!.urls);
    notifyListeners();
  }

  List<String> contacts() {
    ContactList? contactList = getContactList(loggedUserSigner!.getPublicKey());
    return contactList!=null ? contactList!.contacts : [];
  }
  
  List<String> followedTags() {
    ContactList? contactList = getContactList(loggedUserSigner!.getPublicKey());
    return contactList!=null ? contactList!.followedTags : [];
  }

  List<String> followedCommunities() {
    ContactList? contactList = getContactList(loggedUserSigner!.getPublicKey());
    return contactList!=null ? contactList!.followedCommunities : [];
  }

  void clear() {
    _event = null;
    notifyListeners();
  }

  bool containTag(String tag) {
    ContactList? contactList = getContactList(loggedUserSigner!.getPublicKey());
    if (contactList!=null) {
      var list = TopicMap.getList(tag);
      if (list != null) {
        for (var t in list) {
          var exist = contactList!.followedTags != null && contactList!.followedTags!.contains(t);
          if (exist) {
            return true;
          }
        }
        return false;
      } else {
        return contactList!.followedTags != null && contactList!.followedTags!.contains(tag);
      }
    }
    return false;
  }

  Future<void> addTag(String tag) async {
    await ndk.broadcastAddFollowedTag(tag, myOutboxRelaySet!.urls);
    notifyListeners();
  }

  Future<void> removeTag(String tag) async {
    await ndk.broadcastRemoveFollowedTag(tag, myOutboxRelaySet!.urls);
    notifyListeners();
  }

  // Iterable<String> tagList() {
  //   return _contactList!.tagList();
  // }

  bool followsCommunity(String id) {
    ContactList? contactList = getContactList(loggedUserSigner!.getPublicKey());
    if (contactList!=null) {
      return contactList!.followedCommunities != null && contactList!.followedCommunities!.contains(id);
    }
    return false;
  }

  void addCommunity(String tag) async {
    await ndk.broadcastAddFollowedCommunity(tag, myOutboxRelaySet!.urls);
    notifyListeners();
  }

  void removeCommunity(String tag) async {
    await ndk.broadcastRemoveFollowedCommunity(tag, myOutboxRelaySet!.urls);
    notifyListeners();
  }
}
