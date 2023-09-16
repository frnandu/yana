import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:yana/nostr/relay_info_util.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../utils/client_connected.dart';
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

  WebSocketChannel? _wsChannel;

  Future<bool> connect({bool checkInfo = true}) async {
    try {
      relayStatus.connected = ClientConneccted.CONNECTING;
      info = checkInfo ? await RelayInfoUtil.get(url) : null;

      // Relay must support NIP-15 and NIP-20, but NIP-15 had merger into NIP-01
      if (info == null || info!.nips.contains(20)) {
        return connectSync();
      }
    } catch (e) {
      _onError(e.toString(), reconnect: true);
    }
    return false;
  }

  bool connectSync() {
    final wsUrl = Uri.parse(url);
    _wsChannel = WebSocketChannel.connect(wsUrl);
    log("Connected $url");
    _wsChannel!.stream.listen((message) {
      if (onMessage != null) {
        final List<dynamic> json = jsonDecode(message);
        onMessage!.call(this, json);
      }
    }, onError: (error) async {
      print(error);
      _onError("Websocket error $url", reconnect: true);
    }, onDone: () {
      _onError("Websocket stream closed by remote:  $url", reconnect: true);
    });
    relayStatus.connected = ClientConneccted.CONNECTED;
    if (relayStatusCallback != null) {
      relayStatusCallback!();
    }
    return true;
  }

  bool send(List<dynamic> message, { bool reconnect = true}) {
    if (_wsChannel != null &&
        relayStatus.connected == ClientConneccted.CONNECTED) {
      try {
        final encoded = jsonEncode(message);
        _wsChannel!.sink.add(encoded);
        return true;
      } catch (e) {
        _onError(e.toString(), reconnect: reconnect);
      }
    } else {
      if (kDebugMode) {
        print("Relay $url (status:+${relayStatus.connected} , _wsChannel " +
            (_wsChannel == null ? "NULL!!" : "not null") +
            ") is NOT CONNECTED!!! while trying to send message ");
      }
    }
    return false;
  }

  Future<void> disconnect() async {
    try {
      final oldWsChannel = _wsChannel;
      _wsChannel = null;
      await oldWsChannel!.sink.close();
    } catch (e) {}
  }

  void _onError(String errMsg, {bool reconnect = false}) {
    log("relay error in $url : $errMsg");
    relayStatus.error++;
    relayStatus.connected = ClientConneccted.UN_CONNECT;
    if (relayStatusCallback != null) {
      relayStatusCallback!();
    }
    disconnect();

    if (reconnect) {
      Future.delayed(Duration(seconds: 30), () {
        connect(checkInfo: info!=null);
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
      send(["CLOSE", id]);
      return true;
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

    saveQuery(subscription);

    try {
      return send(subscription.toJson());
    } catch (err) {
      log(err.toString());
      relayStatus.error++;
    }

    return false;
  }
}
