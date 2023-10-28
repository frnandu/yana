import 'dart:async';

import 'package:dart_ndk/nips/nip01/event.dart';
import 'package:dart_ndk/nips/nip01/filter.dart';
import 'package:flutter/foundation.dart';

import '../main.dart';
import '../models/event_mem_box.dart';
import '../nostr/event_kind.dart' as kind;
import '../utils/find_event_interface.dart';
import '../utils/peddingevents_later_function.dart';

class FollowEventProvider extends ChangeNotifier
    with PenddingEventsLaterFunction
    implements FindEventInterface {
  late int _initTime;
  StreamSubscription<Nip01Event>? _streamSubscription;


  late EventMemBox postsAndRepliesBox; // posts and replies
  late EventMemBox postsBox;

  FollowEventProvider() {
    _initTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    postsAndRepliesBox =
        EventMemBox(sortAfterAdd: false); // sortAfterAdd by call
    postsBox = EventMemBox(sortAfterAdd: false);
  }

  @override
  List<Nip01Event> findEvent(String str, {int? limit = 5}) {
    return postsAndRepliesBox.findEvent(str, limit: limit);
  }

  List<Nip01Event> eventsByPubkey(String pubkey) {
    return postsAndRepliesBox.listByPubkey(pubkey);
  }

  void refreshPosts({List<String>? fallbackContacts}) {
    _initTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    postsBox.clear();
    postsAndRepliesBox.clear();
    doQuery(fallbackContacts: fallbackContacts);

    followNewEventProvider.clearPosts();
  }

  void refreshReplies() {
    _initTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    postsBox.clear();
    postsAndRepliesBox.clear();
    doQuery();

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

  void doQuery ({int? until, List<String>? fallbackContacts}) {
    if (until!=null) {
      loadMore(until: until);
    } else {
      load(fallbackContacts: fallbackContacts);
    }
  }

  void load({List<String>? fallbackContacts}) async {
    if (_streamSubscription!=null) {
      await _streamSubscription!.cancel();
    }

    List<String>? contactsForFeed = contactListProvider.contacts();

    if (contactsForFeed == null || contactsForFeed.isEmpty) {
      if (kDebugMode) {
        print("CONTACT LIST empty, can not get follow content");
      }
      if (fallbackContacts!=null && fallbackContacts.isNotEmpty) {
        contactsForFeed = fallbackContacts;
      } else {
        return;
      }
    }
    var filter = Filter(
      kinds: queryEventKinds(),
      authors: contactsForFeed..add(nostr!.publicKey),
      limit: 20,
    );
    // TODO
    //addTagCommunityFilter([filter.toMap()], queriyTags);
    if (settingProvider.gossip == 1 && feedRelaySet!=null) {
      await relayManager
          .reconnectRelays(feedRelaySet!.urls);
    } else {
      await relayManager.reconnectRelays(myInboxRelaySet!.urls);
    }

    Stream<Nip01Event> stream = await relayManager!.subscription(
        filter, (feedRelaySet!=null && settingProvider.gossip==1)? feedRelaySet! : myInboxRelaySet!);
    _streamSubscription = stream.listen((event) {
      // if (event.pubKey == nostr!.publicKey) {
      //   print("event.createdAt:${DateTime.fromMillisecondsSinceEpoch(event.createdAt*1000)}");
        onEvent(event);
      // }
    });
  }

  void loadMore({required int until}) async {

    List<String>? contactList = contactListProvider.contacts();

    if (contactList == null || contactList.isEmpty) {
      if (kDebugMode) {
        print("CONTACT LIST empty, can not get follow content");
      }
      return;
    }
    var filter = Filter(
      kinds: queryEventKinds(),
      authors: contactList..add(nostr!.publicKey),
      until: until,
      limit: 20,
    );

    if (!postsAndRepliesBox.isEmpty()) {
      Nip01Event? event = postsAndRepliesBox.oldestEvent;
      if (event!=null) {
        filter.until = event.createdAt;
        filter.since = event.createdAt - 60 * 60 * 24;
      }
    }
    // TODO
    //addTagCommunityFilter([filter.toMap()], queriyTags);
    if (settingProvider.gossip == 1 && feedRelaySet!=null) {
      await relayManager
          .reconnectRelays(feedRelaySet!.urls);
    } else {
      await relayManager.reconnectRelays(myInboxRelaySet!.urls);
    }

    Stream<Nip01Event> stream = await relayManager!.query(
        filter, (feedRelaySet!=null && settingProvider.gossip==1)? feedRelaySet! : myInboxRelaySet!);
    _streamSubscription = stream.listen((event) {
      // if (event.pubKey == nostr!.publicKey) {
      print("event.createdAt from loadMore:${DateTime.fromMillisecondsSinceEpoch(event.createdAt*1000)}");
      onEvent(event);
      // }
    });
  }

  void doUnscribe() {
    if (_streamSubscription!=null) {
      _streamSubscription!.cancel().then((value) {
      },);
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
          addedReplies = postsAndRepliesBox.add(e);
        } else {
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
