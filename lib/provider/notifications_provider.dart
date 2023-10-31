import 'dart:async';

import 'package:dart_ndk/nips/nip01/event.dart';
import 'package:dart_ndk/nips/nip01/filter.dart';
import 'package:dart_ndk/nips/nip25/reactions.dart';
import 'package:dart_ndk/request.dart';
import 'package:flutter/material.dart';

import '../main.dart';
import '../models/event_mem_box.dart';
import '../nostr/event_kind.dart' as kind;
import '../utils/peddingevents_later_function.dart';

class NotificationsProvider extends ChangeNotifier
    with PenddingEventsLaterFunction {
  late int _initTime;

  late EventMemBox eventBox;

  NotificationsProvider() {
    _initTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    eventBox = EventMemBox();
  }

  void refresh() {
    _initTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    eventBox.clear();
    doQuery();
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

  void doQuery() async {
    if (subscription != null) {
      await relayManager.closeNostrRequest(subscription!);
    }

    if (myInboxRelaySet!=null) {
      var filter = Filter(
          kinds: queryEventKinds(),
          pTags: [loggedUserSigner!.getPublicKey()],
          limit: 100);
      // await relayManager.reconnectRelays(myInboxRelaySet!.urls);

      subscription = await relayManager!.subscription(
          filter, myInboxRelaySet!);
      subscription!.stream.listen((event) {
        onEvent(event);
      });
    }
  }

  // void doQuery({Nostr? targetNostr, bool initQuery = false, int? until}) {
  //   targetNostr ??= nostr!;
  //   var filter = Filter(
  //     kinds: queryEventKinds(),
  //     until: until ?? _initTime,
  //     limit: 50,
  //     pTags: [targetNostr.publicKey],
  //   );
  //
  //   if (subscribeId != null) {
  //     try {
  //       targetNostr.unsubscribe(subscribeId!);
  //     } catch (e) {}
  //   }
  //
  //   subscribeId = _doQueryFunc(targetNostr, filter, initQuery: initQuery);
  // }

  // String _doQueryFunc(Nostr targetNostr, Filter filter,
  //     {bool initQuery = false}) {
  //   var subscribeId = StringUtil.rndNameStr(12);
  //   if (initQuery) {
  //     // TODO use dart_ndk
  //     // targetNostr.addInitQuery([filter.toMap()], onEvent, id: subscribeId);
  //   } else {
  //     if (!eventBox.isEmpty()) {
  //       var activeRelays = targetNostr.activeRelays();
  //       var oldestCreatedAts =
  //           eventBox.oldestCreatedAtByRelay(activeRelays, _initTime);
  //       Map<String, List<Map<String, dynamic>>> filtersMap = {};
  //       for (var relay in activeRelays) {
  //         var oldestCreatedAt = oldestCreatedAts.createdAtMap[relay.url];
  //         if (oldestCreatedAt != null) {
  //           filter.until = oldestCreatedAt;
  //           filtersMap[relay.url] = [filter.toMap()];
  //         }
  //       }
  //       // TODO use dart_ndk
  //       // targetNostr.queryByFilters(filtersMap, onEvent, id: subscribeId);
  //     } else {
  //       // TODO use dart_ndk
  //       // targetNostr.query([filter.toMap()], onEvent, id: subscribeId);
  //     }
  //   }
  //   return subscribeId;
  // }

  void onEvent(Nip01Event event) {
    later(event, (list) {
      list = list
          .where(
              (element) => element.pubKey != loggedUserSigner?.getPublicKey())
          .toList();
      var result = eventBox.addList(list);
      if (result) {
        notifyListeners();
      }
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

    // update ui
    notifyListeners();
  }
}
