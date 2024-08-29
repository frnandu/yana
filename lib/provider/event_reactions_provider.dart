import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ndk/ndk.dart';

import '../main.dart';
import '../models/event_reactions.dart';
import '../utils/later_function.dart';
import '../utils/when_stop_function.dart';

class EventReactionsProvider extends ChangeNotifier
    with LaterFunction, WhenStopFunction {
  int update_time = 1000 * 60 * 10;

  Map<String, EventReactions> _eventReactionsMap = {};
  Map<String, List<Nip01Event>> _repliesMap = {};
  Map<String, NdkResponse> subscriptions = {};

  EventReactionsProvider() {
    laterTimeMS = 2000;
    whenStopMS = 500;
  }

  List<EventReactions> allReactions() {
    return _eventReactionsMap.values.toList();
  }

  void addRepost(String id) {
    var er = _eventReactionsMap[id];
    if (er != null) {
      er = er.clone();
      er.repostNum++;
      _eventReactionsMap[id] = er;
      notifyListeners();
    }
  }

  void addLike(String id, Nip01Event likeEvent) {
    var er = _eventReactionsMap[id];
    if (er != null) {
      er = er.clone();
      er.onEvent(likeEvent);
      _eventReactionsMap[id] = er;
      notifyListeners();
    }
  }

  void deleteLike(String id) {
    var er = _eventReactionsMap[id];
    if (er != null) {
      er = er.clone();
      if (er.myLikeEvents != null) {
        var length = er.myLikeEvents!.length;
        er.likeNum -= length;
      } else {
        er.likeNum--;
      }
      er.myLikeEvents = null;
      _eventReactionsMap[id] = er;
      notifyListeners();
    }
  }

  Future<List<Nip01Event>> getThreadReplies(String id,
      {bool force = false}) async {
    var replies = _repliesMap[id];

    /// TODO refresh after some time
    if (replies == null || force) {
      /// TODO use other relaySet if gossip
      NdkResponse response = ndk.requests.query(
          idPrefix: "event-reations-",
          filters: [
            Filter(eTags: [id], kinds: [Nip01Event.TEXT_NODE_KIND])
          ],
          relaySet: myInboxRelaySet!);
      Map<String, Nip01Event> map = {};
      await for (final event in response.stream) {
        if (map[event.id] == null ||
            map[event.id]!.createdAt < event.createdAt) {
          map[event.id] = event;
        }
      }
      replies = map.values.toList();
      _repliesMap[id] = replies;
      if (_eventReactionsMap[id] != null) {
        _eventReactionsMap[id]!.replies = replies;
      }
    }
    return replies;
  }

  void addZap(String id, Nip01Event zapReceipt) {
    var er = _eventReactionsMap[id];
    if (er != null) {
      er = er.clone();
      er.onEvent(zapReceipt);
      _eventReactionsMap[id] = er;
      notifyListeners();
    }
  }

  void addReply(String id, Nip01Event reply) {
    if (_repliesMap[id] != null) {
      _repliesMap[id]!.add(reply);
    }
  }

  Future<void> subscription(
      String eventId, String? pubKey, List<int>? kinds) async {
    var filter = kinds != null
        ? Filter(eTags: [eventId], kinds: kinds)
        : Filter(eTags: [eventId]);

    RelaySet? relaySet;

    if (settingProvider.gossip == 1 && pubKey != null) {
      relaySet = await ndk.calculateRelaySet(
          name: "reactions-feed",
          ownerPubKey: pubKey!,
          pubKeys: [pubKey!],
          direction: RelayDirection.inbox,
          relayMinCountPerPubKey: 5);
      if (myInboxRelaySet != null) {
        relaySet.addMoreRelays(myInboxRelaySet!.relaysMap);
      }
    } else {
      relaySet = myInboxRelaySet;
    }
    if (relaySet == null) {
      return;
    }
    // print(
    //     "---------------- reactions subscriptions: ${subscriptions.length}");
    // NdkResponse response = ndk.query(filters: [filter], relaySet:  relaySet);
    // subscriptions[eventId] = response;
    //
    // response.stream.listen((event) {
    //   _handleSingleEvent2(event);
    // });
    // TODO should use other relays inbox for pubKey....
  }

  EventReactions? get(String id,
      {String? pubKey, bool forceSubscription = false, List<int>? kinds}) {
    var er = _eventReactionsMap[id];
    if (er == null) {
      // plan to pull
      // subscription(event.id, event.pubKey, null);
      // _penddingIds[id] = 1;
      // // later(laterFunc, null);
      // whenStop(laterFunc);
      // // set a empty er to avoid pull many times
      er = EventReactions(id);
      _eventReactionsMap[id] = er;
      subscription(id, pubKey, kinds);
      return er;
    } else {
      // if (requests[id] == null) {
      //   subscription(id, pubKey, kinds);
      // }
      // if (forceSubscription && requests[event.id] == null) {
      //   subscription(event.id, event.pubKey, null);
      // }
      var now = DateTime.now();
      // check dataTime if need to update
      // if (now.millisecondsSinceEpoch - er.dataTime.millisecondsSinceEpoch >
      //     update_time) {
      //   _penddingIds[id] = 1;
      //   // later(laterFunc, null);
      //   whenStop(laterFunc);
      // }
      // set the access time, remove cache base on this time.
      er.access(now);
    }
    return er;
  }

  void laterFunc() {
    if (_penddingIds.isNotEmpty) {
      _doPull();
    }
    if (_penddingEvents.isNotEmpty) {
      _handleEvent();
    }
  }

  Map<String, int> _penddingIds = {};

  void _doPull() {
    if (_penddingIds.isEmpty) {
      return;
    }

    var filter = Filter(eTags: _penddingIds.keys.toList());
    _penddingIds.clear();
// TODO use dart_ndk
//    nostr!.query([filter.toMap()], onEvent);
  }

  void addEventAndHandle(Nip01Event event) {
    onEvent(event);
    laterFunc();
  }

  void onEvent(Nip01Event event) {
    _penddingEvents.add(event);
  }

  void onEvents(List<Nip01Event> events) {
    _penddingEvents.addAll(events);
  }

  List<Nip01Event> _penddingEvents = [];

  void _handleEvent() {
    bool updated = false;

    for (var event in _penddingEvents) {
      updated = updated || _handleSingleEvent(event);
    }
    _penddingEvents.clear();

    if (updated) {
      notifyListeners();
    }
  }

  bool _handleSingleEvent(Nip01Event event) {
    bool updated = false;
    for (var tag in event.tags) {
      if (tag.length > 1) {
        var tagType = tag[0] as String;
        if (tagType == "e") {
          var id = tag[1] as String;
          var er = _eventReactionsMap[id];
          if (er == null) {
            er = EventReactions(id);
            _eventReactionsMap[id] = er;
          } else {
            er = er.clone();
            _eventReactionsMap[id] = er;
          }

          if (er.onEvent(event)) {
            updated = true;
          }
        }
      }
    }
    return updated;
  }

  bool _handleSingleEvent2(Nip01Event event) {
    bool updated = false;
    for (var tag in event.tags) {
      if (tag.length > 1) {
        var tagType = tag[0] as String;
        if (tagType == "e") {
          var id = tag[1] as String;
          var er = _eventReactionsMap[id];
          if (er == null) {
            er = EventReactions(id);
            _eventReactionsMap[id] = er;
          } else {
            er = er.clone();
            _eventReactionsMap[id] = er;
          }

          if (er.onEvent(event)) {
            updated = true;
          }
        }
      }
    }
    if (updated) {
      notifyListeners();
    }
    return updated;
  }

  void removePendding(String eventId) async {
    // _penddingIds.remove(eventId);
    if (subscriptions[eventId] != null) {
      ndk.relays.closeSubscription(subscriptions[eventId]!.requestId);
      subscriptions.remove(eventId);
    }
  }

  void clear() {
    _eventReactionsMap.clear();
  }
}
