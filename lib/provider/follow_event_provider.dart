import 'dart:async';

import 'package:dart_ndk/nips/nip01/event.dart';
import 'package:dart_ndk/nips/nip01/filter.dart';
import 'package:dart_ndk/request.dart';
import 'package:flutter/foundation.dart';
import 'package:yana/provider/data_util.dart';

import '../main.dart';
import '../models/event_mem_box.dart';
import '../nostr/event_kind.dart' as kind;
import '../utils/find_event_interface.dart';
import '../utils/peddingevents_later_function.dart';

class FollowEventProvider extends ChangeNotifier
    with PenddingEventsLaterFunction
    implements FindEventInterface {
  late int _initTime;
  NostrRequest? subscription;

  int? postsTimestamp;
  int? repliesTimestamp;

  late EventMemBox postsAndRepliesBox; // posts and replies
  late EventMemBox postsBox;

  FollowEventProvider() {
    _initTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    postsAndRepliesBox =
        EventMemBox(sortAfterAdd: false); // sortAfterAdd by call
    postsBox = EventMemBox(sortAfterAdd: false);
    postsTimestamp = sharedPreferences.getInt(DataKey.FEED_POSTS_TIMESTAMP);
    repliesTimestamp = sharedPreferences.getInt(DataKey.FEED_REPLIES_TIMESTAMP);
  }

  @override
  List<Nip01Event> findEvent(String str, {int? limit = 5}) {
    return postsAndRepliesBox.findEvent(str, limit: limit);
  }

  List<Nip01Event> eventsByPubkey(String pubkey) {
    return postsAndRepliesBox.listByPubkey(pubkey);
  }

  List<String> FALLBACK_TAGS_FOR_EMPTY_CONTACT_LIST = [
    "grownostr",
    "plebchain",
    "welcome",
    "introductions",
    "cofeechain",
    "photography"
  ];

  void refreshPosts() {
    _initTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    postsBox.clear();
    postsAndRepliesBox.clear();
    postsTimestamp = null;
    sharedPreferences.remove(DataKey.FEED_POSTS_TIMESTAMP);

    doQuery(fallbackTags: FALLBACK_TAGS_FOR_EMPTY_CONTACT_LIST);

    followNewEventProvider.clearPosts();
  }

  void refreshReplies() {
    _initTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    postsBox.clear();
    postsAndRepliesBox.clear();
    repliesTimestamp = null;
    sharedPreferences.remove(DataKey.FEED_REPLIES_TIMESTAMP);

    doQuery(fallbackTags: FALLBACK_TAGS_FOR_EMPTY_CONTACT_LIST);

    followNewEventProvider.clearReplies();
  }

  int lastTime() {
    return _initTime;
  }

  void deleteEvent(String id) {
    postsBox.delete(id);
    var result = postsAndRepliesBox.delete(id);
    if (result) {
      notifyListeners();
    }
  }

  List<int> queryEventKinds() {
    return [
      Nip01Event.TEXT_NODE_KIND,
      kind.EventKind.REPOST,
      kind.EventKind.GENERIC_REPOST,
      kind.EventKind.LONG_FORM,
      kind.EventKind.FILE_HEADER,
      kind.EventKind.POLL,
    ];
  }

  void doQuery(
      {int? until,
      List<String>? fallbackContacts,
      List<String>? fallbackTags }) {
    if (until != null) {
      loadMore(until: until, fallbackTags: fallbackTags ?? FALLBACK_TAGS_FOR_EMPTY_CONTACT_LIST);
    } else {
      load(fallbackContacts: fallbackContacts, fallbackTags: fallbackTags ?? FALLBACK_TAGS_FOR_EMPTY_CONTACT_LIST);
    }
  }

  void load(
      {List<String>? fallbackContacts, List<String>? fallbackTags}) async {
    if (subscription != null) {
      await relayManager.closeNostrRequest(subscription!);
    }

    List<String> contactsForFeed = contactListProvider.contacts();
    var filter = Filter(
      kinds: queryEventKinds(),
      authors: contactsForFeed, //..add(loggedUserSigner!.getPublicKey()),
      limit: 20,
    );

    if (contactsForFeed == null || contactsForFeed.isEmpty) {
      if (kDebugMode) {
        print("CONTACT LIST empty, can not get follow content");
      }
      filter.authors = null;
      if (fallbackContacts != null && fallbackContacts.isNotEmpty) {
        filter.authors = fallbackContacts;
      } else if (fallbackTags != null && fallbackTags.isNotEmpty) {
        filter.tTags = fallbackTags;
      } else {
        return;
      }
    }
    // List<String> tags = contactListProvider.followedTags();
    // if (tags.isNotEmpty) {
    //   filter.tTags = tags;
    // }
    // List<String> communities = contactListProvider.followedCommunities();
    // if (communities.isNotEmpty) {
    //   filter.aTags = communities;
    // }
    if (settingProvider.gossip == 1 && feedRelaySet != null) {
      await relayManager.reconnectRelays(feedRelaySet!.urls);
    } else {
      await relayManager.reconnectRelays(myInboxRelaySet!.urls);
    }

    subscription = await relayManager!.subscription(
        filter,
        (feedRelaySet != null && settingProvider.gossip == 1)
            ? feedRelaySet!
            : myInboxRelaySet!,
        splitRequestsByPubKeyMappings: settingProvider.gossip == 1);
    subscription!.stream.listen((event) {
      // if (event.pubKey == loggedUserSigner!.getPublicKey()) {
      //   print("event.createdAt:${DateTime.fromMillisecondsSinceEpoch(event.createdAt*1000)}");
      onEvent(event);
      // }
    });
  }

  void loadMore({required int until, List<String>? fallbackTags}) async {

    List<String> contactsForFeed = contactListProvider.contacts();
    var filter = Filter(
      kinds: queryEventKinds(),
      authors: contactsForFeed, //..add(loggedUserSigner!.getPublicKey()),
      until: until,
      limit: 20,
    );

    if (contactsForFeed == null || contactsForFeed.isEmpty) {
      if (kDebugMode) {
        print("CONTACT LIST empty, can not get follow content");
      }
      filter.authors = null;
      if (fallbackTags != null && fallbackTags.isNotEmpty) {
        filter.tTags = fallbackTags;
      } else {
        return;
      }
    }


    if (!postsAndRepliesBox.isEmpty()) {
      Nip01Event? event = postsAndRepliesBox.oldestEvent;
      if (event != null) {
        filter.until = event.createdAt;
        filter.since = event.createdAt - 60 * 60 * 24;
      }
    }
    // TODO
    //addTagCommunityFilter([filter.toMap()], queriyTags);
    if (settingProvider.gossip == 1 && feedRelaySet != null) {
      await relayManager.reconnectRelays(feedRelaySet!.urls);
    } else {
      await relayManager.reconnectRelays(myInboxRelaySet!.urls);
    }

    subscription = await relayManager!.query(
        filter,
        (feedRelaySet != null && settingProvider.gossip == 1)
            ? feedRelaySet!
            : myInboxRelaySet!);
    subscription!.stream.listen((event) {
      // if (event.pubKey == loggedUserSigner!.getPublicKey()) {
      print(
          "event.createdAt from loadMore:${DateTime.fromMillisecondsSinceEpoch(event.createdAt * 1000)}");
      onEvent(event);
      // }
    });
  }

  void doUnscribe() {
    if (subscription != null) {
      relayManager.closeNostrRequest(subscription!);
    }
  }

  static List<Map<String, dynamic>> addTagCommunityFilter(
      List<Map<String, dynamic>> filters, bool queriyTags) {
    // if (queriyTags && filters.isNotEmpty) {
    //   var filter = filters[0];
    //   // tags filter
    //   {
    //     var tagFilter = Map<String, dynamic>.from(filter);
    //     tagFilter.remove("authors");
    //     // handle tag with TopicMap
    //     var tagList = contactListProvider.tagList().toList();
    //     List<String> queryTagList = [];
    //     for (var tag in tagList) {
    //       var list = TopicMap.getList(tag);
    //       if (list != null) {
    //         queryTagList.addAll(list);
    //       } else {
    //         queryTagList.add(tag);
    //       }
    //     }
    //     if (queryTagList.isNotEmpty) {
    //       tagFilter["#t"] = queryTagList;
    //       filters.add(tagFilter);
    //     }
    //   }
    //   // community filter
    //   {
    //     var communityFilter = Map<String, dynamic>.from(filter);
    //     communityFilter.remove("authors");
    //     var communityList =
    //         contactListProvider.followedCommunitiesList().toList();
    //     if (communityList.isNotEmpty) {
    //       communityFilter["#a"] = communityList;
    //       filters.add(communityFilter);
    //     }
    //   }
    // }
    return filters;
  }

  // check if is posts (no tag e and not Mentions, TODO handle NIP27)
  static bool eventIsPost(Nip01Event event) {
    bool isPosts = true;
    var tagLength = event.tags.length;
    for (var i = 0; i < tagLength; i++) {
      var tag = event.tags[i];
      if (tag.length > 0 && tag[0] == "e") {
        if (event.content.contains("[$i]")) {
          continue;
        }

        isPosts = false;
        break;
      }
    }

    return isPosts;
  }

  void mergeNewPostAndReplyEvents() {
    var postAndRepliesEvents =
        followNewEventProvider.eventPostsAndRepliesMemBox.all();

    postsAndRepliesBox.addList(postAndRepliesEvents);

    // sort
    postsAndRepliesBox.sort();
    repliesTimestamp = null;
    sharedPreferences.remove(DataKey.FEED_REPLIES_TIMESTAMP);

    followNewEventProvider.clearReplies();

    // update ui
    notifyListeners();
  }

  void mergeNewPostEvents() {
    var postEvents = followNewEventProvider.eventPostsMemBox.all();

    postsBox.addList(postEvents);

    // sort
    postsBox.sort();

    followNewEventProvider.clearPosts();
    postsTimestamp = null;
    sharedPreferences.remove(DataKey.FEED_POSTS_TIMESTAMP);

    // update ui
    notifyListeners();
  }

  void onEvent(Nip01Event event) {
    if (postsAndRepliesBox.isEmpty()) {
      laterTimeMS = 200;
    } else {
      laterTimeMS = 500;
    }
    later(event, (list) {
      // var e = event;
      bool addedPosts = false;
      bool addedReplies = false;
      for (var e in list) {
        bool isPosts = eventIsPost(e);
        if (!isPosts) {
          if (repliesTimestamp!=null && list.first.createdAt > repliesTimestamp!) {
            followNewEventProvider.handleEvents(list);
            return;
          }
          addedReplies = postsAndRepliesBox.add(e);
        } else {
          if (postsTimestamp!=null && list.first.createdAt > postsTimestamp!) {
            followNewEventProvider.handleEvents(list);
            return;
          }
          addedPosts = postsBox.add(e);
        }
      }
      if (addedReplies) {
        print("Received ${list.length} events, some new replies");
        postsAndRepliesBox.sort();
      }
      if (addedPosts) {
        print("Received ${list.length} events, some new posts");
        postsBox.sort();
      }

      if (addedPosts || addedReplies) {
        notifyListeners();
      }
    }, null);
  }

  void clear() {
    postsAndRepliesBox.clear();
    postsBox.clear();
    doUnscribe();
    notifyListeners();
  }

// void metadataUpdatedCallback(ContactList? _contactList) {
//   if (firstLogin ||
//       (postsAndRepliesBox.isEmpty() &&
//           _contactList != null &&
//           !_contactList.isEmpty())) {
//     doQuery();
//   }
//
//   if (firstLogin && _contactList != null && _contactList.list().length > 10) {
//     firstLogin = false;
//   }
// }
}
