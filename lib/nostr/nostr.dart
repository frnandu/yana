import 'dart:async';
import 'dart:developer';

import 'package:bot_toast/bot_toast.dart';
import 'package:dart_ndk/nips/nip01/event.dart';
import 'package:dart_ndk/nips/nip01/filter.dart';
import 'package:flutter/foundation.dart';
import 'package:yana/main.dart';
import 'package:yana/nostr/relay_pool.dart';
import 'package:yana/nostr/subscription.dart';
import 'package:yana/utils/string_util.dart';

import 'client_utils/keys.dart';
import 'event.dart';
import 'event_kind.dart';
import 'nip02/contact_list.dart';
import 'relay.dart';

import '/js/js_helper.dart' as js;

@deprecated
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

  Future<Nip01Event?> sendLike(String id) async {
    Nip01Event event = Nip01Event(pubKey: _publicKey,
        kind:
        EventKind.REACTION,
        tags:
        [
          ["e", id]
        ],
        content:
        "+");
    return await sendEvent(event);
  }

  Future<Nip01Event?> deleteEvent(String eventId) async {
    Nip01Event event = Nip01Event(
        pubKey: _publicKey,
        kind: EventKind.EVENT_DELETION,
        tags: [
          ["e", eventId]
        ],
        content: "delete");
    return await sendEvent(event);
  }

  Future<Nip01Event?> sendRepost(String id,
      {String? relayAddr, String content = ""}) async {
    List<dynamic> tag = ["e", id];
    if (StringUtil.isNotBlank(relayAddr)) {
      tag.add(relayAddr);
    }
    Nip01Event event = Nip01Event(pubKey: _publicKey, kind: EventKind.REPOST, tags: [tag], content: content);
    return await sendEvent(event);
  }

  Future<Nip01Event?> sendTextNote(String text,
      [List<dynamic> tags = const []]) async {
    Nip01Event event = Nip01Event(pubKey: _publicKey, kind: EventKind.TEXT_NOTE, tags: tags, content: text);
    return await sendEvent(event);
  }

  Future<Nip01Event?> recommendServer(String url) async {
    if (!url.contains(RegExp(
        r'^(wss?:\/\/)([0-9]{1,3}(?:\.[0-9]{1,3}){3}|[^:]+):?([0-9]{1,5})?$'))) {
      throw ArgumentError.value(url, 'url', 'Not a valid relay URL');
    }
    final event = Nip01Event(pubKey: _publicKey, kind: EventKind.RECOMMEND_SERVER, tags: [], content:url);
    return await sendEvent(event);
  }

  Future<Nip01Event?> sendContactList(ContactList contacts) async {
    final tags = contacts.toJson();
    final event = Nip01Event(pubKey: _publicKey, kind: EventKind.CONTACT_LIST, tags: tags, content: "");
    return await sendEvent(event);
  }

  FutureOr<Nip01Event> sendEvent(Nip01Event event) async {
    // if (StringUtil.isBlank(_privateKey)) {
    //   // TODO to show Notice
    //   throw StateError("Private key is missing. Message can't be signed.");
    // }
    Nip01Event signedEvent = await signEvent(event);
    var result = _pool.send(["EVENT", signedEvent.toJson()]);
    if (result) {
      return signedEvent;
    }
    return event;
  }

  FutureOr<bool> sendRelayEvent(Nip01Event event, String relay) async {
    Relay r = relayProvider.genRelay(relay);
    await r.connectSync(() {

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

    Nip01Event signedEvent = await signEvent(event);
    return r.send(["EVENT", signedEvent.toJson()], reconnect: false);
  }

  Future<Nip01Event> signEvent(Nip01Event event) async {
    if (StringUtil.isNotBlank(_privateKey)) {
      event.sign(_privateKey!);
      return event;
    } else {
      // Event signedEvent = await js.signEventAsync(event);
      String sig = await js.signSchnorrAsync(event.id);
      event.sig = sig;
      Nip01Event signedEvent = event;
      if (kDebugMode) {
        BotToast.showText(text: signedEvent.toString());
        print("SIGNED EVENT: " + signedEvent.toString());
      }
      return signedEvent;
    }
  }

  Nip01Event broadcase(Nip01Event event) {
    _pool.send(["EVENT", event.toJson()]);
    return event;
  }

  void close() {
    _pool.removeAll();
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

  bool isEmpty() {
    return StringUtil.isBlank(privateKey) && StringUtil.isBlank(publicKey);
  }
}
