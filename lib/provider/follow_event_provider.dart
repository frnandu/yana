import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:ndk/ndk.dart';
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
  NdkResponse? subscription;
  NdkResponse? subscriptionTags;
  NdkResponse? subscriptionCommunities;
  NdkResponse? subscriptionEvents;

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
    // DateTime? a = postsTimestamp!=null ? DateTime.fromMillisecondsSinceEpoch(postsTimestamp!*1000) : null;
    // print("POSTS READ TIMESTAMP: $a");
    // DateTime? b = repliesTimestamp!=null ? DateTime.fromMillisecondsSinceEpoch(repliesTimestamp!*1000) : null;
    // print("REPLIES READ TIMESTAMP: $b");
  }

  Future<void> loadCachedFeed() async {
    if (contactListProvider == null) return;
    List<String> contactsForFeed = await contactListProvider!.contacts();
    List<Nip01Event>? cachedEvents = await cacheManager.loadEvents(
        pubKeys: contactsForFeed, kinds: queryEventKinds());
    print("FOLLOW loaded ${cachedEvents.length} events from cache DB");
    onEvents(cachedEvents, saveToCache: false);
    // if (postsBox.newestEvent != null) {
    //   DateTime? a = DateTime.fromMillisecondsSinceEpoch(postsBox.newestEvent!.createdAt * 1000);
    //   print("   newest POST date is $a");
    // }
    // if (postsAndRepliesBox.newestEvent != null) {
    //   DateTime? a = DateTime.fromMillisecondsSinceEpoch(postsAndRepliesBox.newestEvent!.createdAt * 1000);
    //   print("   newest REPLY date is $a");
    // }
  }

  Future<void> startSubscriptions() async {
    int? since;
    var newestPost = postsBox.newestEvent;
    if (newestPost != null) {
      since = newestPost!.createdAt;
    }
    var newestReply = postsAndRepliesBox.newestEvent;
    if (newestReply != null &&
        (since == null || newestReply!.createdAt > since)) {
      since = newestReply!.createdAt;
    }
    // await contactListProvider.loadContactList(loggedUserSigner!.getPublicKey());
    subscribe(since: since, fallbackTags: FALLBACK_TAGS_FOR_EMPTY_CONTACT_LIST);
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
    cacheManager.removeAllEvents();
    subscribe(fallbackTags: FALLBACK_TAGS_FOR_EMPTY_CONTACT_LIST);

    followNewEventProvider?.clearPosts();
  }

  void refreshReplies() {
    _initTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    postsBox.clear();
    postsAndRepliesBox.clear();
    repliesTimestamp = null;
    sharedPreferences.remove(DataKey.FEED_REPLIES_TIMESTAMP);

    cacheManager.removeAllEvents();
    subscribe(fallbackTags: FALLBACK_TAGS_FOR_EMPTY_CONTACT_LIST);

    followNewEventProvider?.clearReplies();
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
      Nip01Event.kTextNodeKind,
      kind.EventKind.REPOST,
      kind.EventKind.GENERIC_REPOST,
      kind.EventKind.LONG_FORM,
      kind.EventKind.FILE_HEADER,
      kind.EventKind.POLL,
    ];
  }

  void subscribe(
      {int? since,
      List<String>? fallbackContacts,
      List<String>? fallbackTags}) async {
    doUnscribe();

    if (contactListProvider == null) return;
    ContactList? contactList = await contactListProvider!
        .getContactList(loggedUserSigner!.getPublicKey());
    List<String> contactsForFeed =
        contactList != null ? contactList.contacts : [];

    var filter = Filter(
      kinds: queryEventKinds(),
      since: since,
      // tTags: contactList?.followedTags,
      // aTags: contactList?.followedCommunities,
      // eTags: contactList?.followedEvents,
      authors: contactsForFeed, //..add(loggedUserSigner!.getPublicKey()),
      limit: since != null ? null : 100,
    );

    if (contactsForFeed == null || contactsForFeed.isEmpty) {
      if (kDebugMode) {
        print("CONTACT LIST empty, can not get follow content");
      }
      filter.authors = null;
      if (fallbackContacts != null && fallbackContacts.isNotEmpty) {
        filter.authors = fallbackContacts;
      } else if (fallbackTags != null && fallbackTags.isNotEmpty) {
        filter.setTag("#t", fallbackTags);
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
      await ndk.relays.reconnectRelays(feedRelaySet!.urls);
    } else {
      await ndk.relays.reconnectRelays(myInboxRelaySet!.urls);
    }
    subscription = ndk.requests.subscription(
        name: "feed-sub",
        filters: [filter],
        relaySet: (feedRelaySet != null && settingProvider.gossip == 1)
            ? feedRelaySet!
            : myInboxRelaySet!);
    // splitRequestsByPubKeyMappings: settingProvider.gossip == 1);
    subscription!.stream.listen((event) {
      onEvent(event);
    });

    // if (contactList != null) {
    //   if (contactList.followedTags.isNotEmpty) {
    //     subscriptionTags = await ndk.relays.subscription(
    //         Filter(
    //           kinds: queryEventKinds(),
    //           since: since,
    //           tTags: contactList?.followedTags,
    //           limit: since != null ? null : 100,
    //         ),
    //         myInboxRelaySet!,
    //         splitRequestsByPubKeyMappings: false);
    //     subscriptionTags!.stream.listen((event) {
    //       onEvent(event);
    //     });
    //   }
    //   if (contactList.followedCommunities.isNotEmpty) {
    //     subscriptionCommunities = await ndk.relays.subscription(
    //         Filter(
    //           kinds: queryEventKinds(),
    //           since: since,
    //           aTags: contactList?.followedCommunities,
    //           limit: since != null ? null : 100,
    //         ),
    //         myInboxRelaySet!,
    //         splitRequestsByPubKeyMappings: false);
    //     subscriptionCommunities!.stream.listen((event) {
    //       onEvent(event);
    //     });
    //   }
    //   if (contactList.followedEvents.isNotEmpty) {
    //     subscriptionEvents = await ndk.relays.subscription(
    //         Filter(
    //           kinds: queryEventKinds(),
    //           since: since,
    //           eTags: contactList?.followedEvents,
    //           limit: since != null ? null : 100,
    //         ),
    //         myInboxRelaySet!,
    //         splitRequestsByPubKeyMappings: false);
    //     subscriptionEvents!.stream.listen((event) {
    //       onEvent(event);
    //     });
    //   }
    // }
  }

  void queryOlder({required int until, List<String>? fallbackTags}) async {
    if (contactListProvider == null) return;
    ContactList? contactList = await contactListProvider!
        .getContactList(loggedUserSigner!.getPublicKey());
    List<String> contactsForFeed = await contactListProvider!.contacts();
    var filter = Filter(
      kinds: queryEventKinds(),
      authors: contactsForFeed,
      //..add(loggedUserSigner!.getPubliNdkResponsecKey()),
      until: until,
      limit: 100,
    );

    if (contactsForFeed == null || contactsForFeed.isEmpty) {
      if (kDebugMode) {
        print("CONTACT LIST empty, can not get follow content");
      }
      filter.authors = null;
      if (fallbackTags != null && fallbackTags.isNotEmpty) {
        filter.setTag("#t", fallbackTags);
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
    if (settingProvider.gossip == 1 && feedRelaySet != null) {
      await ndk.relays.reconnectRelays(feedRelaySet!.urls);
    } else {
      await ndk.relays.reconnectRelays(myInboxRelaySet!.urls);
    }

    ndk.requests
        .query(
            filters: [filter],
            relaySet: (feedRelaySet != null && settingProvider.gossip == 1)
                ? feedRelaySet!
                : myInboxRelaySet!)
        .stream
        .listen((event) {
          onEvent(event);
        });

    ndk.requests
        .query(
            name: "feed-old-tags",
            filters: [
              Filter(
                  kinds: queryEventKinds(),
                  tTags: contactList?.followedTags,
                  until: until,
                  limit: 100)
            ],
            relaySet: myInboxRelaySet!)
        .stream
        .listen((event) {
      onEvent(event);
    });
    ndk.requests
        .query(
            name: "feed-old-communities",
            filters: [
              Filter(
                  kinds: queryEventKinds(),
                  aTags: contactList?.followedCommunities,
                  until: until,
                  limit: 100)
            ],
            relaySet: myInboxRelaySet!)
        .stream
        .listen((event) {
      onEvent(event);
    });
    ndk.requests
        .query(
            name: "feed-old-events",
            filters: [
              Filter(
                  kinds: queryEventKinds(),
                  eTags: contactList?.followedEvents,
                  until: until,
                  limit: 100)
            ],
            relaySet: myInboxRelaySet!)
        .stream
        .listen((event) {
      onEvent(event);
    });
  }

  void doUnscribe() {
    if (subscription != null) {
      ndk.requests.closeSubscription(subscription!.requestId);
    }
    if (subscriptionTags != null) {
      ndk.requests.closeSubscription(subscriptionTags!.requestId);
    }
    if (subscriptionCommunities != null) {
      ndk.requests.closeSubscription(subscriptionCommunities!.requestId);
    }
    if (subscriptionEvents != null) {
      ndk.requests.closeSubscription(subscriptionEvents!.requestId);
    }
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
        followNewEventProvider?.eventPostsAndRepliesMemBox.all() ?? [];

    postsAndRepliesBox.addList(postAndRepliesEvents);

    // sort
    postsAndRepliesBox.sort();
    repliesTimestamp = null;
    setRepliesTimestampToNewestAndSave();

    followNewEventProvider?.clearReplies();

    // update ui
    notifyListeners();
  }

  void mergeNewPostEvents() {
    var postEvents = followNewEventProvider?.eventPostsMemBox.all() ?? [];

    postsBox.addList(postEvents);

    // sort
    postsBox.sort();

    followNewEventProvider?.clearPosts();
    postsTimestamp = null;
    setPostsTimestampToNewestAndSave();

    // update ui
    notifyListeners();
  }

  void onEvent(Nip01Event event) {
    if (postsAndRepliesBox.isEmpty()) {
      laterTimeMS = 200;
    } else {
      laterTimeMS = 500;
    }
    onEvents([event]);
    // later(event, onEvents, null);
  }

  void onEvents(List<Nip01Event> list, {bool saveToCache = true}) {
    // var e = event;
    bool addedPosts = false;
    bool addedReplies = false;
    List<Nip01Event> toSave = [];
    for (var e in list) {
      bool isPosts = eventIsPost(e);
      if (!isPosts) {
        if (repliesTimestamp != null && e.createdAt > repliesTimestamp!) {
          followNewEventProvider?.handleEvents([e]);
          return;
        }
        addedReplies = postsAndRepliesBox.add(e);
      } else {
        if (postsTimestamp != null && e.createdAt > postsTimestamp!) {
          followNewEventProvider?.handleEvents([e]);
          return;
        }
        addedPosts = postsBox.add(e);
      }
      if (saveToCache && (addedReplies || addedPosts)) {
        toSave.add(e);
      }
    }
    if (addedReplies) {
      // print("Received ${list.length} events FROM ${saveToCache ? "RELAYS" : "CACHE"}, some new replies");
      postsAndRepliesBox.sort();
    }
    if (addedPosts) {
      // print("Received ${list.length} events FROM ${saveToCache ? "RELAYS" : "CACHE"}, some new posts");
      postsBox.sort();
    }

    if (addedPosts || addedReplies) {
      if (toSave.isNotEmpty) {
        cacheManager.saveEvents(toSave);
        //   contactListProvider.contacts().then((contacts) {
        //     cacheManager.loadEvents(pubKeys:  contacts, kinds: [toSave.first.kind]).then((a) {
        //       print(a);
        //       a.forEach((e) {
        //         if (!contacts.contains(e.pubKey)) {
        //           final metadata = metadataProvider.getMetadata(e.pubKey).then((
        //               m) {
        //             // print(m);
        //           });
        //         }
        //       });
        //     });
        //   });
      }
      notifyListeners();
    }
  }

  void setPostsTimestampToNewestAndSave() {
    if (postsTimestamp == null && postsBox.newestEvent != null) {
      postsTimestamp = postsBox.newestEvent!.createdAt;
      sharedPreferences.setInt(DataKey.FEED_POSTS_TIMESTAMP, postsTimestamp!);
      DateTime a = DateTime.fromMillisecondsSinceEpoch(postsTimestamp! * 1000);
      print("POSTS WRITTEN TIMESTAMP: $a");
    }
  }

  void setRepliesTimestampToNewestAndSave() {
    if (repliesTimestamp == null && postsAndRepliesBox.newestEvent != null) {
      repliesTimestamp = postsAndRepliesBox.newestEvent!.createdAt;
      sharedPreferences.setInt(
          DataKey.FEED_REPLIES_TIMESTAMP, repliesTimestamp!);
      DateTime a =
          DateTime.fromMillisecondsSinceEpoch(repliesTimestamp! * 1000);
      print("REPLIES WRITTEN TIMESTAMP: $a");
    }
  }

  void clear() {
    postsAndRepliesBox.clear();
    postsBox.clear();
    doUnscribe();
    notifyListeners();
  }
}
