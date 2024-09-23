import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ndk/ndk.dart';
import 'package:ndk/shared/nips/nip25/reactions.dart';
import 'package:yana/provider/data_util.dart';

import '../main.dart';
import '../models/event_mem_box.dart';
import '../nostr/event_kind.dart' as kind;
import '../utils/peddingevents_later_function.dart';

class NotificationsProvider extends ChangeNotifier with PenddingEventsLaterFunction {
  late int _initTime;

  int? timestamp;
  late EventMemBox eventBox;

  NotificationsProvider() {
    _initTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    eventBox = EventMemBox();
    timestamp = sharedPreferences.getInt(DataKey.NOTIFICATIONS_TIMESTAMP);
  }

  void setTimestampToNewestAndSave() {
    if (eventBox.newestEvent != null) {
      timestamp = eventBox.newestEvent!.createdAt;
      sharedPreferences.setInt(DataKey.NOTIFICATIONS_TIMESTAMP, timestamp!);
      // DateTime a = DateTime.fromMillisecondsSinceEpoch(timestamp!*1000);
      // print("NOTIFICATION WRITTEN TIMESTAMP: $a");
    }
  }

  Future<void> loadCached() async {
    List<Nip01Event>? cachedEvents = cacheManager.loadEvents(kinds: notificationsProvider.queryEventKinds(), pTag: loggedUserSigner!.getPublicKey());
    print("NOTIFICATIONS loaded ${cachedEvents.length} events from cache DB");
    onEvents(cachedEvents, saveToCache: false);
  }

  void refresh() {
    _initTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    eventBox.clear();
    timestamp = null;
    startSubscription();
    sharedPreferences.remove(DataKey.NOTIFICATIONS_TIMESTAMP);
    newNotificationsProvider.clear();
  }

  void deleteEvent(String id) {
    var result = eventBox.delete(id);
    if (result) {
      notifyListeners();
    }
  }

  int lastTime() {
    return _initTime;
  }

  List<int> queryEventKinds() {
    List<int> kinds = [
      Nip01Event.TEXT_NODE_KIND,
      kind.EventKind.LONG_FORM,
    ];
    if (settingProvider.notificationsReactions) {
      kinds.add(Reaction.KIND);
    }
    if (settingProvider.notificationsReposts) {
      kinds.add(kind.EventKind.REPOST);
      kinds.add(kind.EventKind.GENERIC_REPOST);
    }
    if (settingProvider.notificationsZaps) {
      kinds.add(kind.EventKind.ZAP_RECEIPT);
    }
    return kinds;
  }

  NdkResponse? subscription;

  void startSubscription({bool refreshed = false}) async {
    if (subscription != null) {
      ndk.relays.closeSubscription(subscription!.requestId);
    }
    int? since;
    if (!refreshed) {
      var newestPost = eventBox.newestEvent;
      if (newestPost != null) {
        since = newestPost!.createdAt;
      }
    }

    if (myInboxRelaySet != null) {
      var filter = Filter(kinds: queryEventKinds(), since: since, pTags: [loggedUserSigner!.getPublicKey()], limit: 100);

      await ndk.relays.reconnectRelays(myInboxRelaySet!.urls);

      subscription = ndk.requests.subscription(name:"notifications-sub", filters: [filter], relaySet: myInboxRelaySet!);
      subscription!.stream.listen((event) {
        onEvent(event);
      });
    }
  }

  void onEvent(Nip01Event event) {
    later(event, (list) {
      onEvents(list, saveToCache: true);
    }, null);
  }

  void onEvents(List<Nip01Event> list, {bool saveToCache = true}) {
    list = list.where((element) => element.pubKey != loggedUserSigner?.getPublicKey()).toList();
    List<Nip01Event> toSave = [];
    for (Nip01Event event in list) {
      if (
        // event.kind!=kind.EventKind.ZAP_RECEIPT &&
          (event.pTags.length==1 || event.pTags.any((tagValues) => tagValues.contains(loggedUserSigner!.getPublicKey()) && tagValues.contains("mention")))
        ) {
        if (timestamp != null && event.createdAt > timestamp!) {
          newNotificationsProvider.handleEvent(event, null);
        } else {
          var result = eventBox.addList([event]);
          if (result) {
            toSave.add(event);
          }
        }
      }
    }
    if (toSave.isNotEmpty) {
      if (saveToCache) {
        cacheManager.saveEvents(toSave);
      }
      notifyListeners();
    }
  }

  void clear() {
    eventBox.clear();
    notifyListeners();
  }

  void mergeNewEvent() {
    var allEvents = newNotificationsProvider.eventMemBox.all();

    eventBox.addList(allEvents);

    // sort
    eventBox.sort();

    newNotificationsProvider.clear();
    setTimestampToNewestAndSave();
    // update ui
    notifyListeners();
  }
}
