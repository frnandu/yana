import 'package:ndk/config/bootstrap_relays.dart';
import 'package:ndk/ndk.dart';
import 'package:flutter/material.dart';
import 'package:ndk/shared/helpers/relay_helper.dart';

import '../main.dart';
import '../utils/later_function.dart';

class SingleEventProvider extends ChangeNotifier with LaterFunction {
  Map<String, Nip01Event> _eventsMap = {};

  List<String> _needUpdateIds = [];
  List<String> notFoundEventIds = [];

  List<Nip01Event> _penddingEvents = [];

  Nip01Event? getEvent(String id, {bool queryIfNotFound = true}) {
    var event = _eventsMap[id];
    if (event != null) {
      return event;
    }
    if (notFoundEventIds.contains(id)) {
      return null;
    }

    if (queryIfNotFound && !_needUpdateIds.contains(id)) {
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
        if (event.sources.isNotEmpty && !oldEvent.sources.contains(event.sources[0])) {
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
    if (_needUpdateIds.isEmpty || loggedUserSigner == null) {
      return;
    }

    Filter filter = Filter(ids: _needUpdateIds);
    List<String> tempIds = [];
    tempIds.addAll(_needUpdateIds);

    Set<String> urls =ndk.relays.bootstrapRelays.toSet();
    urls.addAll(DEFAULT_BOOTSTRAP_RELAYS);

    if (myInboxRelaySet != null) {
      myInboxRelaySet!.urls.forEach((element) {
        String? relay = cleanRelayUrl(element);
        if (relay != null) {
          urls.add(relay);
        }
      });
    }
    // NdkResponse response = ndk.requests.query(explicitRelays: urls.toList(), filters: [filter]);
    // response.stream.listen((event) {
    //   tempIds.remove(event.id);
    //   _onEvent(event);
    // }, onDone: () {
    //   notFoundEventIds.addAll(tempIds);
    // }, onError: (error) {
    //   print("$error onERROR for single event provider loading $filter");
    //   return;
    // });
    _needUpdateIds.clear();
  }
}
