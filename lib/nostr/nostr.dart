import 'dart:async';
import 'dart:developer';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/foundation.dart';
import 'package:yana/main.dart';
import 'package:yana/nostr/relay_pool.dart';
import 'package:yana/nostr/subscription.dart';
import 'package:yana/utils/string_util.dart';

import 'client_utils/keys.dart';
import 'event.dart';
import 'event_kind.dart';
import 'nip02/cust_contact_list.dart';
import 'relay.dart';

import '/js/js_helper.dart' as js;

class Nostr {
  String? _privateKey;

  late String _publicKey;

  late RelayPool _pool;

  Nostr({
    String? privateKey,
    String? publicKey,
  }) {
    if (StringUtil.isNotBlank(privateKey)) {
      _privateKey = privateKey!;
      _publicKey = StringUtil.isNotBlank(publicKey)
          ? publicKey!
          : getPublicKey(privateKey);
    } else {
      assert(publicKey != null);

      _privateKey = privateKey;
      _publicKey = publicKey!;
    }
    _pool = RelayPool(this);
  }

  String? get privateKey => _privateKey;

  String get publicKey => _publicKey;

  Future<Event?> sendLike(String id) async {
    Event event = Event(
        _publicKey,
        EventKind.REACTION,
        [
          ["e", id]
        ],
        "+");
    return await sendEvent(event);
  }

  Future<Event?> deleteEvent(String eventId) async {
    Event event = Event(
        _publicKey,
        EventKind.EVENT_DELETION,
        [
          ["e", eventId]
        ],
        "delete");
    return await sendEvent(event);
  }

  Future<Event?> deleteEvents(List<String> eventIds) async {
    List<List<dynamic>> tags = [];
    for (var eventId in eventIds) {
      tags.add(["e", eventId]);
    }

    Event event = Event(_publicKey, EventKind.EVENT_DELETION, tags, "delete");
    return await sendEvent(event);
  }

  Future<Event?> sendRepost(String id,
      {String? relayAddr, String content = ""}) async {
    List<dynamic> tag = ["e", id];
    if (StringUtil.isNotBlank(relayAddr)) {
      tag.add(relayAddr);
    }
    Event event = Event(_publicKey, EventKind.REPOST, [tag], content);
    return await sendEvent(event);
  }

  Future<Event?> sendTextNote(String text,
      [List<dynamic> tags = const []]) async {
    Event event = Event(_publicKey, EventKind.TEXT_NOTE, tags, text);
    return await sendEvent(event);
  }

  Future<Event?> recommendServer(String url) async {
    if (!url.contains(RegExp(
        r'^(wss?:\/\/)([0-9]{1,3}(?:\.[0-9]{1,3}){3}|[^:]+):?([0-9]{1,5})?$'))) {
      throw ArgumentError.value(url, 'url', 'Not a valid relay URL');
    }
    final event = Event(_publicKey, EventKind.RECOMMEND_SERVER, [], url);
    return await sendEvent(event);
  }

  Future<Event?> sendContactList(CustContactList contacts) async {
    final tags = contacts.toJson();
    final event = Event(_publicKey, EventKind.CONTACT_LIST, tags, "");
    return await sendEvent(event);
  }

  FutureOr<Event> sendEvent(Event event) async {
    // if (StringUtil.isBlank(_privateKey)) {
    //   // TODO to show Notice
    //   throw StateError("Private key is missing. Message can't be signed.");
    // }
    Event signedEvent = await signEvent(event);
    var result = _pool.send(["EVENT", signedEvent.toJson()]);
    if (result) {
      return signedEvent;
    }
    return event;
  }

  FutureOr<bool> sendRelayEvent(Event event, String relay) async {
    Relay r = relayProvider.genRelay(relay);
    r.connectSync(() {

    });
    // r.onMessage = (Relay relay, List<dynamic> json) async {
    //   final messageType = json[0];
    //   if (messageType == 'EVENT') {
    //     final subId = json[1] as String;
    //     try {
    //       final event = Event.fromJson(json[2]);
    //       // List<bool> bools =
    //       if (event.isValid && await event.isSigned) {
    //         onEvent(event);
    //       }
    //     } catch (err) {
    //       log(err.toString());
    //     }
    //   }
    // };

    Event signedEvent = await signEvent(event);
    return r.send(["EVENT", signedEvent.toJson()], reconnect: false);
  }

  Future<Event> signEvent(Event event) async {
    if (StringUtil.isNotBlank(_privateKey)) {
      event.sign(_privateKey!);
      return event;
    } else {
      // Event signedEvent = await js.signEventAsync(event);
      String sig = await js.signSchnorrAsync(event.id);
      event.sig = sig;
      Event signedEvent = event;
      if (kDebugMode) {
        BotToast.showText(text: signedEvent.toString());
        print("SIGNED EVENT: " + signedEvent.toString());
      }
      return signedEvent;
    }
  }

  Event broadcase(Event event) {
    _pool.send(["EVENT", event.toJson()]);
    return event;
  }

  void close() {
    _pool.removeAll();
  }

  void addInitQuery(List<Map<String, dynamic>> filters, Function(Event) onEvent,
      {String? id, Function? onComplete}) {
    _pool.addInitQuery(filters, onEvent, id: id, onComplete: onComplete);
  }

  String subscribe(List<Map<String, dynamic>> filters, Function(Event) onEvent,
      {String? id}) {
    return _pool.subscribe(filters, onEvent, id: id);
  }

  void unsubscribe(String id) {
    _pool.unsubscribe(id);
  }

  String query(List<Map<String, dynamic>> filters, Function(Event) onEvent,
      {String? id, Function? onComplete}) {
    return _pool.query(filters, onEvent, id: id, onComplete: onComplete);
  }

  String queryRelay(
      Map<String, dynamic> filter, String relay, Function(Event) onEvent,
      {String? id}) {
    Relay r = relayProvider.genRelay(relay);
    r.connectSync(() {

    });
    r.onMessage = (Relay relay, List<dynamic> json) async {
      final messageType = json[0];
      if (messageType == 'EVENT') {
        try {
          final event = Event.fromJson(json[2]);
          if (event.isValid && await event.isSigned) {
            event.sources = [relay.url];
            onEvent(event);
          }
        } catch (err) {
          log(err.toString());
        }
      }
    };
    Subscription subscription = Subscription([filter], onEvent, id);
    r.doQuery(subscription);
    return subscription.id;
  }

  String queryRelay2(Map<String, dynamic> filter, String relay,
      Function(Event, Function(bool)) onEvent,
      {String? id, required Function(bool) onZapped}) {
    Relay r = relayProvider.genRelay(relay);
    r.connectSync(() {

    });
    r.onMessage = (Relay relay, List<dynamic> json) async {
      final messageType = json[0];
      if (messageType == 'EVENT') {
        try {
          final event = Event.fromJson(json[2]);
          if (event.isValid && await event.isSigned) {
            event.sources = [relay.url];
            onEvent(event, onZapped);
          }
        } catch (err) {
          log(err.toString());
        }
      }
    };
    Subscription subscription = Subscription([filter], onEvent, id);
    r.doQuery(subscription);
    return subscription.id;
  }

  String queryByFilters(Map<String, List<Map<String, dynamic>>> filtersMap,
      Function(Event) onEvent,
      {String? id, Function? onComplete}) {
    return _pool.queryByFilters(filtersMap, onEvent,
        id: id, onComplete: onComplete);
  }

  Future<bool> addRelay(
    Relay relay, {
    bool autoSubscribe = false,
    bool connect = true,
    bool init = false,
    bool checkInfo = true,
  }) async {
    return await _pool.add(relay,
        autoSubscribe: autoSubscribe, connect: connect, init: init, checkInfo: checkInfo);
  }

  void removeRelay(String url) {
    _pool.remove(url);
  }

  List<Relay> activeRelays() {
    return _pool.activeRelays();
  }

  List<Relay> allRelays() {
    return _pool.allRelays();
  }

  Relay? getRelay(String url) {
    return _pool.getRelay(url);
  }

  @pragma('vm:entry-point')
  Future<void> checkAndReconnectRelays() async {
    await _pool.checkAndReconnectRelays();
  }

  void checkAndReconnectRelaysSync() {
    _pool.checkAndReconnectRelaysSync();
  }

  bool isEmpty() {
    return StringUtil.isBlank(privateKey) && StringUtil.isBlank(publicKey);
  }
}
