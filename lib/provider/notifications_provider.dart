import 'package:dart_ndk/nips/nip01/event.dart';
import 'package:flutter/material.dart';

import '../nostr/event_kind.dart' as kind;
import '../nostr/event.dart';
import '../nostr/filter.dart';
import '../nostr/nostr.dart';
import '../models/event_mem_box.dart';
import '../main.dart';
import '../utils/peddingevents_later_function.dart';
import '../utils/string_util.dart';

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
      kind.EventKind.TEXT_NOTE,
      kind.EventKind.REACTION,
      kind.EventKind.REPOST,
      kind.EventKind.GENERIC_REPOST,
      kind.EventKind.ZAP,
      kind.EventKind.LONG_FORM,
    ];
  }

  String? subscribeId;

  void doQuery({Nostr? targetNostr, bool initQuery = false, int? until}) {
    targetNostr ??= nostr!;
    var filter = Filter(
      kinds: queryEventKinds(),
      until: until ?? _initTime,
      limit: 50,
      p: [targetNostr.publicKey],
    );

    if (subscribeId != null) {
      try {
        targetNostr.unsubscribe(subscribeId!);
      } catch (e) {}
    }

    subscribeId = _doQueryFunc(targetNostr, filter, initQuery: initQuery);
  }

  String _doQueryFunc(Nostr targetNostr, Filter filter,
      {bool initQuery = false}) {
    var subscribeId = StringUtil.rndNameStr(12);
    if (initQuery) {
      // TODO use dart_ndk
      // targetNostr.addInitQuery([filter.toJson()], onEvent, id: subscribeId);
    } else {
      if (!eventBox.isEmpty()) {
        var activeRelays = targetNostr.activeRelays();
        var oldestCreatedAts =
            eventBox.oldestCreatedAtByRelay(activeRelays, _initTime);
        Map<String, List<Map<String, dynamic>>> filtersMap = {};
        for (var relay in activeRelays) {
          var oldestCreatedAt = oldestCreatedAts.createdAtMap[relay.url];
          if (oldestCreatedAt != null) {
            filter.until = oldestCreatedAt;
            filtersMap[relay.url] = [filter.toJson()];
          }
        }
        // TODO use dart_ndk
        // targetNostr.queryByFilters(filtersMap, onEvent, id: subscribeId);
      } else {
        // TODO use dart_ndk
        // targetNostr.query([filter.toJson()], onEvent, id: subscribeId);
      }
    }
    return subscribeId;
  }

  void onEvent(Nip01Event event) {
    later(event, (list) {
      list = list.where((element) => element.pubKey != nostr?.publicKey).toList();
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
