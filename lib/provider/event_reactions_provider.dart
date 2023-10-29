import 'dart:async';

import 'package:dart_ndk/models/relay_set.dart';
import 'package:dart_ndk/nips/nip01/event.dart';
import 'package:dart_ndk/nips/nip01/filter.dart';
import 'package:dart_ndk/read_write.dart';
import 'package:flutter/material.dart';

import '../models/event_reactions.dart';
import '../main.dart';
import '../utils/later_function.dart';
import '../utils/when_stop_function.dart';

class EventReactionsProvider extends ChangeNotifier
    with LaterFunction, WhenStopFunction {
  int update_time = 1000 * 60 * 10;

  Map<String, EventReactions> _eventReactionsMap = {};
  Map<String, StreamSubscription<Nip01Event>> subscriptions = {};

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

  Future<StreamSubscription<Nip01Event>> subscription(String id, String? pubKey, int? kind) async {
    var filter = kind!=null ? Filter(eTags: [id], kinds: [kind]) : Filter(eTags: [id]);

    RelaySet? relaySet;

    if (settingProvider.gossip == 1) {
      relaySet = await relayManager.calculateRelaySet(
          name: "reactions-feed",
          ownerPubKey: pubKey!,
          pubKeys: [pubKey!],
          direction: RelayDirection.inbox,
          relayMinCountPerPubKey: 5
      );
      relaySet.addMoreRelays(myInboxRelaySet!.relaysMap);
    } else {
      relaySet = myInboxRelaySet;
    }
    Stream<Nip01Event> stream = await relayManager!.subscription(filter, relaySet!, splitRequestsByPubKeyMappings: settingProvider.gossip == 1);
    StreamSubscription<Nip01Event> sub = stream.listen((event) {
          _handleSingleEvent2(event);
        });
    subscriptions[id] = sub;
    return sub;
    // TODO should use other relays inbox for pubKey....
  }

  EventReactions? get(Nip01Event event, {bool forceSubscription=false}) {
    var er = _eventReactionsMap[event.id];
    if (er == null) {
      // plan to pull
      subscription(event.id, event.pubKey, null);
      // _penddingIds[id] = 1;
      // // later(laterFunc, null);
      // whenStop(laterFunc);
      // // set a empty er to avoid pull many times
      er = EventReactions(event.id);
      _eventReactionsMap[event.id] = er;
    } else {
      if (forceSubscription && subscriptions[event.id]==null) {
        subscription(event.id, event.pubKey, null);
      }
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

  void removePendding(String id) async {
    _penddingIds.remove(id);
    if (subscriptions[id]!=null) {
      await subscriptions[id]!.cancel();
      subscriptions.remove(id);
    }
  }

  void clear() {
    _eventReactionsMap.clear();
  }
}
