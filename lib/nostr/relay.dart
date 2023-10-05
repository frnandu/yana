import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:yana/main.dart';
import 'package:yana/nostr/relay_info_util.dart';

import '../models/relay_status.dart';
import 'relay_info.dart';
import 'subscription.dart';

enum WriteAccess { readOnly, writeOnly, readWrite }

class Relay {
  final String url;

  RelayStatus relayStatus;

  WriteAccess access;

  RelayInfo? info;

  FutureOr<void> Function(Relay, List<dynamic>)? onMessage;

  // quries
  final Map<String, Subscription> _queries = {};

  Relay(this.url, this.relayStatus, {this.access = WriteAccess.readWrite}) {}

  // WebSocketChannel? _wsChannel;
  WebSocket? webSocket;

  Future<bool> connect({bool checkInfo = true}) async {
    try {
      info = checkInfo ? await RelayInfoUtil.get(url) : null;
      return await connectSync(() {});
    } catch (e) {
      _onError(e.toString(), reconnect: false);
    }
    return false;
  }

  bool isActive() {
    return webSocket != null && webSocket!.readyState == WebSocket.open;
  }

  bool isConnecting() {
    return webSocket != null && webSocket!.readyState == WebSocket.connecting ||
        relayStatus.connecting;
  }

  bool send(List<dynamic> message, {bool reconnect = true}) {
    if (isActive()) {
      try {
        final encoded = jsonEncode(message);
        webSocket!.add(encoded);
        return true;
      } catch (e) {
        _onError(e.toString(), reconnect: reconnect);
      }
    } else {
      if (kDebugMode) {
        print("Relay $url (status:+${webSocket!.readyState} , _wsChannel " +
            (webSocket == null ? "NULL!!" : "not null") +
            ") is NOT CONNECTED!!! while trying to send message ");
      }
    }
    return false;
  }

  Future<WebSocket>? future;

  Future<bool> connectSync(Function? onError) async {
    try {
      relayStatus.connecting = true;
      future = WebSocket.connect(url).timeout(const Duration(seconds: 3)).onError((error, stackTrace) {
        relayStatus.connecting = false;
        print("could not connect to relay $url error:$error");
        throw Exception();
      });
      webSocket = await future;

      // .onError((error, stackTrace) {
      //   print("Websocket error while connecting $url : $error  ");
      //   // _onError("Websocket error while connecting $url : $error  ", reconnect: false);
      //   relayStatus.connecting = false;
      // }));
      relayProvider.notifyListeners();
      webSocket!.listen((message) {
        if (onMessage != null) {
          final List<dynamic> json = jsonDecode(message);
          onMessage!.call(this, json);
        }
      }, onError: (error) async {
        _onError("Websocket error $url", reconnect: false);
        if (onError != null) {
          onError();
        }
      }, onDone: () {
        _onError("Websocket stream closed by remote:  $url", reconnect: false);
      });
    } catch (e) {
      return false;
    }
    if (relayStatusCallback != null) {
      relayStatusCallback!();
    }
    return true;
  }

  Future<void> disconnect() async {
    try {
      final oldWsChannel = webSocket;
      webSocket = null;
      await oldWsChannel!.close();
    } catch (e) {}
  }

  void _onError(String errMsg, {bool reconnect = false}) {
    // log("relay error in $url : $errMsg");
    relayStatus.error++;
    relayProvider.notifyListeners();
    if (relayStatusCallback != null) {
      relayStatusCallback!();
    }
    disconnect();

    if (reconnect && nostr != null) {
      Future.delayed(const Duration(seconds: 30), () {
        connect(checkInfo: info != null);
      });
    }
  }

  void saveQuery(Subscription subscription) {
    _queries[subscription.id] = subscription;
  }

  bool checkAndCompleteQuery(String id) {
    // all subscription should be close
    var sub = _queries.remove(id);
    if (sub != null) {
      if (isActive()) {
        send(["CLOSE", id]);
        return true;
      }
    }
    return false;
  }

  bool checkQuery(String id) {
    return _queries[id] != null;
  }

  Subscription? getRequestSubscription(String id) {
    return _queries[id];
  }

  Function? relayStatusCallback;

  bool doQuery(Subscription subscription) {
    if (access == WriteAccess.writeOnly) {
      return false;
    }
    if (subscription.filters != null) {
      bool a =
          subscription.filters.any((element) => element.containsKey("search"));
      if (a && info != null && !info!.nips.contains(50)) {
        return false;
      }
    }

    saveQuery(subscription);

    try {
      return send(subscription.toJson());
    } catch (err) {
      // log(err.toString());
      relayStatus.error++;
    }

    return false;
  }

  static RegExp RELAY_URL_REGEX = RegExp(
      r'^(wss?:\/\/)([0-9]{1,3}(?:\.[0-9]{1,3}){3}|[^:]+):?([0-9]{1,5})?$');

  static String? clean(String adr) {
    if (adr.endsWith("/")) {
      adr = adr.substring(0, adr.length - 1);
    }
    if (adr.contains("%")) {
      adr = Uri.decodeComponent(adr);
    }
    adr = adr.trim();
    if (!adr.contains(RELAY_URL_REGEX)) {
      return null;
    }
    return adr;
  }
}
