import 'dart:convert';
import 'dart:io';

import 'package:bip340/bip340.dart';
import 'package:dart_ndk/nips/nip01/bip340_event_signer.dart';
import 'package:dart_ndk/nips/nip01/event.dart';
import 'package:dart_ndk/nips/nip01/event_signer.dart';
import 'package:dart_ndk/nips/nip01/filter.dart';
import 'package:dart_ndk/nips/nip01/helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:yana/nostr/event_kind.dart';

import '../main.dart';
import '../nostr/nip04/nip04.dart';
import '../nostr/nip47/nwc_commands.dart';
import '../nostr/nip47/nwc_kind.dart';
import '../utils/string_util.dart';
import 'data_util.dart';

class NwcProvider extends ChangeNotifier {
  static NwcProvider? _nwcProvider;

  String? uri;
  String? secret;
  String? walletPubKey;
  String? relay;
  int? balance;
  int? maxAmount;
  String? payInvoiceEventId;

  List<String> permissions = [];

  static Future<NwcProvider> getInstance() async {
    _nwcProvider ??= NwcProvider();
    if (loggedUserSigner!=null) {
      await _nwcProvider!._init();
    }
    return _nwcProvider!;
  }

  Future<void> _init() async {
    // TODO make this multi account aware
    String? perms = sharedPreferences.getString(DataKey.NWC_PERMISSIONS);
    if (StringUtil.isNotBlank(perms)) {
      permissions = perms!.split(",");
    }
    uri = await settingProvider.getNwc();
    secret = await settingProvider.getNwcSecret();
    if (StringUtil.isNotBlank(uri) && StringUtil.isNotBlank(secret)) {
      walletPubKey = sharedPreferences.getString(DataKey.NWC_PUB_KEY);
      relay = sharedPreferences.getString(DataKey.NWC_RELAY);
      await connect(uri!);
    }
  }

  Future<void> reload() async {
    // await _init();
    // notifyListeners();
  }

  int? get getBalance => balance;

  bool get isConnected =>
      permissions != null &&
      permissions.isNotEmpty &&
      StringUtil.isNotBlank(secret);

  Future<void>  connect(String nwc) async {
    nwc = nwc.replaceAll("yana:", "nostr+walletconnect:");
    Uri uri = Uri.parse(nwc.replaceAll("nostr+walletconnect:", "https:"));
    String? walletPubKey = uri.host;
    String? relay = uri.queryParameters['relay'];
    secret = uri.queryParameters['secret'];
    // String? lud16 = uri.queryParameters['lub16'];
    if (StringUtil.isBlank(relay)) {
      EasyLoading.show(status: "missing relay parameter");
      return;
    }
    if (StringUtil.isBlank(secret)) {
      EasyLoading.show(status: "missing secret parameter");
      return;
    }
    if (StringUtil.isBlank(walletPubKey)) {
      EasyLoading.show(status: "missing pubKey from connection uri");
      return;
    }
    relay = Uri.decodeFull(relay!);
    await settingProvider.setNwc(nwc);
    await settingProvider.setNwcSecret(secret!);
    var filter = Filter(kinds: [NwcKind.INFO_REQUEST], authors: [walletPubKey!]);
    // if (await relayManager.connectRelay(relay)) {
    //   (await relayManager.requestRelays([relay], filter)).stream.listen((event) {
    //     onEventInfo.call(event);
    //   });
    // }
    // TODO use dart_ndk
    // nostr!.queryRelay(filter.toMap(), relay!, onEventInfo);
    // walletPubKey = pubKey;
    // this.relay = relay;
    // permissions = ["get_balance","pay_invoice"];
    await requestBalance(walletPubKey, relay, secret!);
  }

  Future<void> onEventInfo(Nip01Event event) async {
    if (event.kind == NwcKind.INFO_REQUEST &&
        StringUtil.isNotBlank(event.content)) {
      walletPubKey = event.pubKey;
      relay = event.sources[0];
      sharedPreferences.setString(DataKey.NWC_PERMISSIONS, event.content);
      sharedPreferences.setString(DataKey.NWC_RELAY, relay!);
      sharedPreferences.setString(DataKey.NWC_PUB_KEY, walletPubKey!);
      permissions = event.content.split(",");
      if (permissions.contains(NwcCommand.GET_BALANCE)) {
        await requestBalance(walletPubKey!, relay!, secret!);
      }
      notifyListeners();
    }
  }

  Future<void> disconnect() async {
    sharedPreferences.setString(DataKey.NWC_PERMISSIONS, "");
    await settingProvider.setNwc(null);
    await settingProvider.setNwcSecret(null);
    sharedPreferences.remove(DataKey.NWC_PERMISSIONS);
    sharedPreferences.remove(DataKey.NWC_RELAY);
    sharedPreferences.remove(DataKey.NWC_PUB_KEY);
    balance = null;
    maxAmount = null;
    uri = null;
    permissions = [];
    notifyListeners();
  }
  Future<void> requestBalance(String walletPubKey, String relay, String secret) async {
    if (StringUtil.isNotBlank(walletPubKey) &&
        StringUtil.isNotBlank(relay) &&
        StringUtil.isNotBlank(secret)) {
      EventSigner nwcSigner = Bip340EventSigner(secret!, getPublicKey(secret!));

      var agreement = NIP04.getAgreement(secret!);
      var encrypted =
      NIP04.encrypt('{"method":"${NwcCommand.GET_BALANCE}"', agreement, walletPubKey!);
      var tags = [
        ["p", walletPubKey]
      ];
      await relayManager.reconnectRelay(relay!);
      final event = Nip01Event(pubKey: nwcSigner!.getPublicKey(), kind: NwcKind.REQUEST, tags: tags, content: encrypted);

      var filter = Filter(
          kinds: [NwcKind.RESPONSE], authors: [walletPubKey!], eTags: [event.id]);
      var webSocket = await WebSocket.connect(relay!);
      webSocket.listen((event) {
        print(event);
      });
      List<dynamic> request = ["REQ", Helpers.getRandomString(10), filter.toMap()];
      final encoded = jsonEncode(request);
      webSocket.add(encoded);

      await relayManager.broadcastEvent(event, [relay!], nwcSigner);


      // final event =
      // Event(nwcNostr!.publicKey, NwcKind.REQUEST, tags, encrypted);
      // await nwcNostr!.sendRelayEvent(event, relay!);
      // var filter = Filter(
      //     kinds: [NwcKind.RESPONSE], authors: [walletPubKey!], e: [event.id]);
      // nwcNostr!.queryRelay(filter.toJson(), relay!, onGetBalanceResponse);

      // (await relayManager.requestRelays([relay!], filter, idleTimeout: 20, groupIdletimeout: 21)).stream.listen(onGetBalanceResponse);

      // await nwcNostr!.sendRelayEvent(event, relay!);
      // nwcNostr!.queryRelay(filter.toMap(), relay!, onGetBalanceResponse);

    } else {
      var filter = Filter(kinds: [NwcKind.INFO_REQUEST], authors: [walletPubKey!]);
      if (await relayManager.connectRelay(relay!)) {
        (await relayManager.requestRelays([relay!], filter)).stream.listen((event) {
          onEventInfo.call(event);
        });
      }
      // EasyLoading.show(status: "missing pubKey and/or relay for connecting");
    }
  }

  void onGetBalanceResponse(Nip01Event event) async {
    if (event.kind == NwcKind.RESPONSE &&
        StringUtil.isNotBlank(event.content) &&
        StringUtil.isNotBlank(secret) &&
        StringUtil.isNotBlank(walletPubKey)) {
      var agreement = NIP04.getAgreement(secret!);
      var decrypted = NIP04.decrypt(event.content, agreement, walletPubKey!);
      Map<String, dynamic> data;
      data = json.decode(decrypted);
      if (data != null &&
          data.containsKey("result") &&
          data['result_type'] == NwcCommand.GET_BALANCE) {
        balance = data['result']['balance'];
        if (balance != null) {
          balance = balance! ~/ 1000;
        }
        maxAmount = data['result']['max_amount'];
        if (maxAmount != null) {
          maxAmount = maxAmount! ~/ 1000;
        }
        notifyListeners();
      } else if (data!=null && data.containsKey("error")) {
        var error = data['error']['code'];
        if (error == "UNAUTHORIZED") {
          await disconnect();
          notifyListeners();
        }
      }
    }
  }

  Future<void> payInvoice(String invoice, String? eventId, Function(bool) onZapped) async {
    if (StringUtil.isNotBlank(walletPubKey) &&
        StringUtil.isNotBlank(relay) &&
        StringUtil.isNotBlank(secret)) {
      EventSigner nwcSigner = Bip340EventSigner(secret!, getPublicKey(secret!));

      payInvoiceEventId = eventId;

      var agreement = NIP04.getAgreement(secret!);
      var encrypted =
          NIP04.encrypt('{"method":"${NwcCommand.PAY_INVOICE}", "params": { "invoice":"${invoice}"}}', agreement, walletPubKey!);
      var tags = [
        ["p", walletPubKey]
      ];
      final event =
      Nip01Event(pubKey: nwcSigner!.getPublicKey(), kind: NwcKind.REQUEST, tags: tags, content: encrypted);
      var filter = Filter(
          kinds: [NwcKind.RESPONSE], authors: [walletPubKey!], eTags: [event.id]);
      // TODO use dart_ndk
      // nwcNostr!.queryRelay2(filter.toMap(), relay!, onPayInvoiceResponse, onZapped: onZapped);
      // TODO use dart_ndk
      // await nwcNostr!.sendRelayEvent(event, relay!);
    } else {
      EasyLoading.show(status: "missing pubKey and/or relay for connecting");
    }
  }

  Future<void> onPayInvoiceResponse(Nip01Event event, Function(bool) onZapped) async {
    if (event.kind == NwcKind.RESPONSE &&
        StringUtil.isNotBlank(event.content) &&
        StringUtil.isNotBlank(secret) &&
        StringUtil.isNotBlank(walletPubKey)) {
      var agreement = NIP04.getAgreement(secret!);
      var decrypted = NIP04.decrypt(event.content, agreement, walletPubKey!);
      Map<String, dynamic> data;
      data = json.decode(decrypted);
      if (data != null &&
          data.containsKey("result") &&
          data['result_type'] == NwcCommand.PAY_INVOICE) {
        var preImage = data['result']['preimage'];
        EasyLoading.show(status: "Zap payed");
        if (payInvoiceEventId!=null) {
          await eventReactionsProvider.subscription(payInvoiceEventId!, null, EventKind.ZAP_RECEIPT);
        }
        notifyListeners();
        await requestBalance(walletPubKey!, relay!, secret!);
        onZapped(true);
      } else if (data!=null && data.containsKey("error")){
        onZapped(false);
        EasyLoading.show(status: "error: ${data['error'].toString()}");
      }
    }
    payInvoiceEventId = null;
  }
}
