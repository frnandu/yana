import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ndk/ndk.dart';
import 'package:ndk/shared/logger/logger.dart';

import '../main.dart';
import '../models/event_reactions.dart';
import '../utils/later_function.dart';
import '../utils/when_stop_function.dart';

class EventReactionsProvider extends ChangeNotifier
    with LaterFunction, WhenStopFunction {
  int update_time = 1000 * 60 * 10;

  Map<String, EventReactions> _eventReactionsMap = {};
  Map<String, List<Nip01Event>> _repliesMap = {};
  // Map<String, NdkResponse> subscriptions = {};

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

    /// TODO refresh after some time or use subscriptions
    if (replies == null || force) {
      /// TODO use other relaySet if gossip
      NdkResponse response = ndk.requests.query(
          name: "event-reations-thread-replies",
          timeout: 5,
          relaySet: myInboxRelaySet,
          filters: [
            Filter(eTags: [id], kinds: [Nip01Event.TEXT_NODE_KIND])
          ],
      // TODO which relays for thread replies???? depends on event author + relay hints from event maybe?
      //    relaySet: myInboxRelaySet!
      );
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
    notifyListeners();
  }

  Future<void> subscription(
      String eventId, String? pubKey, List<int>? kinds) async {
    var filter = kinds != null
        ? Filter(eTags: [eventId], kinds: kinds)
        : Filter(eTags: [eventId]);

    RelaySet? relaySet;

    // if (settingProvider.gossip == 1 && pubKey != null) {
    //   relaySet = await ndk.calculateRelaySet(
    //       name: "reactions-feed",
    //       ownerPubKey: pubKey!,
    //       pubKeys: [pubKey!],
    //       direction: RelayDirection.inbox,
    //       relayMinCountPerPubKey: 5);
    //   if (myInboxRelaySet != null) {
    //     relaySet.addMoreRelays(myInboxRelaySet!.relaysMap);
    //   }
    // } else {
      relaySet = myInboxRelaySet;
    // }
    if (relaySet == null) {
      return;
    }
    // print(
    //     "---------------- reactions subscriptions: ${subscriptions.length}");
    NdkResponse response = ndk.requests.query(
        name: "event-reactions",
        timeout: 5,
        filters: [filter],
        explicitRelays: myInboxRelaySet?.urls
    );//, relaySet:  relaySet);
    // subscriptions[eventId] = response;

    response.stream.timeout(const Duration(seconds: 10)).listen((event) {
      _handleSingleEvent2(event);
    }).onError((error) {
      Logger.log.f("!!!!!!!!!!!!!!!!!!! $error");
    });
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
      er.access(now);
    }
    return er;
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

  void clear() {
    _eventReactionsMap.clear();
  }
}
