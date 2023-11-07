import 'dart:convert';

import 'package:dart_ndk/nips/nip01/event.dart';
import 'package:dart_ndk/nips/nip01/filter.dart';
import 'package:dart_ndk/nips/nip01/helpers.dart';
import 'package:dart_ndk/request.dart';
import 'package:flutter/material.dart';
import 'package:websocket_universal/websocket_universal.dart';

import '../main.dart';
import '../utils/later_function.dart';

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
    if (_needUpdateIds.isEmpty || loggedUserSigner==null) {
      return;
    }

    var filter = Filter(ids: _needUpdateIds);
    List<String> tempIds = [];
    tempIds.addAll(_needUpdateIds);

    // const connectionOptions = SocketConnectionOptions(
    //   timeoutConnectionMs: 30000, // connection fail timeout after 4000 ms
    //   skipPingMessages: true,
    //   pingRestrictionForce: true,
    // );
    // final textSocketHandler = IWebSocketHandler<String, String>.createClient(
    //   "wss://relay.damus.io", // Postman echo ws server
    //   SocketSimpleTextProcessor(),
    //   connectionOptions: connectionOptions
    // );
    //
    // textSocketHandler.incomingMessagesStream.listen((message) {
    //   List<dynamic> eventJson = json.decode(message);
    //   if (eventJson[0] == 'EVENT') {
    //     // print('> webSocket  got text message from server: "$message" ');
    //     Nip01Event event = Nip01Event.fromJson(eventJson[2]);
    //     _onEvent(event);
    //     textSocketHandler.disconnect("");
    //     textSocketHandler.close();
    //   }
    // });
    // await textSocketHandler.connect();
    // List<dynamic> request = ["REQ", Helpers.getRandomString(10), filter.toMap()];
    // final encoded = jsonEncode(request);
    // textSocketHandler.sendMessage(encoded);

    if (myInboxRelaySet!=null) {
      NostrRequest request = await relayManager.requestRelays(
          myInboxRelaySet!.urls, filter, timeout: 2);
      request.stream.listen((event) {
        _onEvent(event);
      });
    }
    _needUpdateIds.clear();
  }
}
