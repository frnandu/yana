import 'dart:async';

import 'package:dart_ndk/nips/nip01/event.dart';
import 'package:dart_ndk/nips/nip01/filter.dart';
import 'package:dart_ndk/nips/nip25/reactions.dart';
import 'package:dart_ndk/request.dart';
import 'package:flutter/material.dart';
import 'package:yana/provider/data_util.dart';

import '../main.dart';
import '../models/event_mem_box.dart';
import '../nostr/event_kind.dart' as kind;
import '../utils/peddingevents_later_function.dart';

class NotificationsProvider extends ChangeNotifier
    with PenddingEventsLaterFunction {
  late int _initTime;

  int? timestamp;
  late EventMemBox eventBox;

  NotificationsProvider() {
    _initTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    eventBox = EventMemBox();
    timestamp = sharedPreferences.getInt(DataKey.NOTIFICATIONS_TIMESTAMP);
  }

  void setTimestampToNewestAndSave() {
    if (eventBox.newestEvent!=null) {
      timestamp = eventBox.newestEvent!.createdAt;
      sharedPreferences.setInt(
          DataKey.NOTIFICATIONS_TIMESTAMP, timestamp!);
      // DateTime a = DateTime.fromMillisecondsSinceEpoch(timestamp!*1000);
      // print("NOTIFICATION WRITTEN TIMESTAMP: $a");
    }
  }

  void refresh() {
    _initTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    eventBox.clear();
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
    return [
      Nip01Event.TEXT_NODE_KIND,
      Reaction.KIND,
      kind.EventKind.REPOST,
      kind.EventKind.GENERIC_REPOST,
      kind.EventKind.ZAP_RECEIPT,
      kind.EventKind.LONG_FORM,
    ];
  }

  NostrRequest? subscription;

  void startSubscription() async {
    if (subscription != null) {
      await relayManager.closeNostrRequest(subscription!);
    }

    if (myInboxRelaySet!=null) {
      var filter = Filter(
          kinds: queryEventKinds(),
          pTags: [loggedUserSigner!.getPublicKey()],
          limit: 100);

      await relayManager.reconnectRelays(myInboxRelaySet!.urls);

      subscription = await relayManager!.subscription(
          filter, myInboxRelaySet!);
      subscription!.stream.listen((event) {
        onEvent(event);
      });
    }
  }

  void onEvent(Nip01Event event) {
    later(event, (list) {
      list = list
          .where(
              (element) => element.pubKey != loggedUserSigner?.getPublicKey())
          .toList();
      list.forEach((event) {
        if (timestamp!=null && event.createdAt > timestamp!) {
          newNotificationsProvider.handleEvent(event);
        } else {
          var result = eventBox.addList([event]);
          if (result) {
            notifyListeners();
          }
        }
      });
    }, null);
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
    notificationsProvider.setTimestampToNewestAndSave();
    // update ui
    notifyListeners();
  }
}
