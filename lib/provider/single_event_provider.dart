import 'package:dart_ndk/nips/nip01/event.dart';
import 'package:dart_ndk/nips/nip01/filter.dart';
import 'package:flutter/material.dart';

import '../main.dart';
import '../nostr/event.dart';
import 'package:dart_ndk/nips/nip01/filter.dart';
import '../utils/later_function.dart';
import '../utils/string_util.dart';

class SingleEventProvider extends ChangeNotifier with LaterFunction {
  Map<String, Nip01Event> _eventsMap = {};

  List<String> _needUpdateIds = [];

  List<Nip01Event> _penddingEvents = [];

  Nip01Event? getEvent(String id) {
    var event = _eventsMap[id];
    if (event != null) {
      return event;
    }

    if (!_needUpdateIds.contains(id)) {
      _needUpdateIds.add(id);
    }
    later(_laterCallback, null);

    return null;
  }

  void _laterCallback() {
    if (_needUpdateIds.isNotEmpty) {
      _laterSearch();
    }

    if (_penddingEvents.isNotEmpty) {
      _handlePenddingEvents();
    }
  }

  void _handlePenddingEvents() {
    for (var event in _penddingEvents) {
      var oldEvent = _eventsMap[event.id];
      if (oldEvent != null) {
        if (event.sources.isNotEmpty &&
            !oldEvent.sources.contains(event.sources[0])) {
          oldEvent.sources.add(event.sources[0]);
        }
      } else {
        _eventsMap[event.id] = event;
      }

    }
    _penddingEvents.clear();
    notifyListeners();
  }

  void _onEvent(Nip01Event event) {
    _penddingEvents.add(event);
    later(_laterCallback, null);
  }

  void _laterSearch() async {
    if (_needUpdateIds.isEmpty || nostr==null) {
      return;
    }

    var filter = Filter(ids: _needUpdateIds);
    List<String> tempIds = [];
    tempIds.addAll(_needUpdateIds);
    if (myInboxRelays!=null) {
      Stream<Nip01Event> stream = await relayManager.requestRelays(
          myInboxRelays!.urls, filter, idleTimeout: 30);
      stream.listen((event) {
        _onEvent(event);
      });
    }
    // todo use dart_ndk
    // nostr!.query([filter.toMap()], _onEvent, id: subscriptId, onComplete: () {
    //   // log("singleEventProvider onComplete $tempIds");
    //   for (var id in tempIds) {
    //     _handingIds.remove(id);
    //   }
    // });

    // for (var id in _needUpdateIds) {
    //   _handingIds[id] = 1;
    // }
    _needUpdateIds.clear();
  }
}
