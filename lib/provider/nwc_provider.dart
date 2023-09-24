import 'dart:convert';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:yana/nostr/event_kind.dart';

import '../main.dart';
import '../nostr/event.dart';
import '../nostr/filter.dart';
import '../nostr/nip04/nip04.dart';
import '../nostr/nip47/nwc_commands.dart';
import '../nostr/nip47/nwc_kind.dart';
import '../nostr/nostr.dart';
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
    if (nostr!=null) {
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
    await _init();
    notifyListeners();
  }

  int? get getBalance => balance;

  bool get isConnected =>
      permissions != null &&
      permissions.isNotEmpty &&
      StringUtil.isNotBlank(secret);

  Future<void> connect(String nwc) async {
    nwc = nwc.replaceAll("yana:", "nostr+walletconnect:");
    Uri uri = Uri.parse(nwc.replaceAll("nostr+walletconnect:", "https:"));
    String? walletPubKey = uri.host;
    String? relay = uri.queryParameters['relay'];
    secret = uri.queryParameters['secret'];
    // String? lud16 = uri.queryParameters['lub16'];
    if (StringUtil.isBlank(relay)) {
      BotToast.showText(text: "missing relay parameter");
      return;
    }
    if (StringUtil.isBlank(secret)) {
      BotToast.showText(text: "missing secret parameter");
      return;
    }
    if (StringUtil.isBlank(walletPubKey)) {
      BotToast.showText(text: "missing pubKey from connection uri");
      return;
    }
    relay = Uri.decodeFull(relay!);
    await settingProvider.setNwc(nwc);
    await settingProvider.setNwcSecret(secret!);
    var filter = Filter(kinds: [NwcKind.INFO_REQUEST], authors: [walletPubKey!]);
    nostr!.queryRelay(filter.toJson(), relay!, onEventInfo);
    // walletPubKey = pubKey;
    // this.relay = relay;
    // permissions = ["get_balance","pay_invoice"];
    // await requestBalance();
  }

  Future<void> onEventInfo(Event event) async {
    if (event.kind == NwcKind.INFO_REQUEST &&
        StringUtil.isNotBlank(event.content)) {
      walletPubKey = event.pubKey;
      relay = event.sources[0];
      sharedPreferences.setString(DataKey.NWC_PERMISSIONS, event.content);
      sharedPreferences.setString(DataKey.NWC_RELAY, relay!);
      sharedPreferences.setString(DataKey.NWC_PUB_KEY, walletPubKey!);
      permissions = event.content.split(",");
      if (permissions.contains(NwcCommand.GET_BALANCE)) {
        await requestBalance();
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
  Future<void> requestBalance() async {
    if (StringUtil.isNotBlank(walletPubKey) &&
        StringUtil.isNotBlank(relay) &&
        StringUtil.isNotBlank(secret)) {
      Nostr nwcNostr = Nostr(privateKey: secret);

      var agreement = NIP04.getAgreement(secret!);
      var encrypted =
      NIP04.encrypt('{"method":"get_balance"}', agreement, walletPubKey!);
      var tags = [
        ["p", walletPubKey]
      ];
      final event =
      Event(nwcNostr!.publicKey, NwcKind.REQUEST, tags, encrypted);
      await nwcNostr!.sendRelayEvent(event, relay!);
      var filter = Filter(
          kinds: [NwcKind.RESPONSE], authors: [walletPubKey!], e: [event.id]);
      nwcNostr!.queryRelay(filter.toJson(), relay!, onGetBalanceResponse);
    } else {
      BotToast.showText(text: "missing pubKey and/or relay for connecting");
    }
  }

  void onGetBalanceResponse(Event event) async {
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
          data['result_type'] == 'get_balance') {
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
      Nostr nwcNostr = Nostr(privateKey: secret);

      payInvoiceEventId = eventId;

      var agreement = NIP04.getAgreement(secret!);
      var encrypted =
          NIP04.encrypt('{"method":"pay_invoice", "params": { "invoice":"${invoice}"}}', agreement, walletPubKey!);
      var tags = [
        ["p", walletPubKey]
      ];
      final event =
          Event(nwcNostr!.publicKey, NwcKind.REQUEST, tags, encrypted);
      var filter = Filter(
          kinds: [NwcKind.RESPONSE], authors: [walletPubKey!], e: [event.id]);
      nwcNostr!.queryRelay2(filter.toJson(), relay!, onPayInvoiceResponse, onZapped: onZapped);
      await nwcNostr!.sendRelayEvent(event, relay!);
    } else {
      BotToast.showText(text: "missing pubKey and/or relay for connecting");
    }
  }

  Future<void> onPayInvoiceResponse(Event event, Function(bool) onZapped) async {
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
          data['result_type'] == 'pay_invoice') {
        var preImage = data['result']['preimage'];
        BotToast.showText(text: "Zap payed");
        if (payInvoiceEventId!=null) {
          eventReactionsProvider.update(payInvoiceEventId!, EventKind.ZAP);
        }
        notifyListeners();
        await requestBalance();
        onZapped(true);
      } else if (data!=null && data.containsKey("error")){
        onZapped(false);
        BotToast.showText(text: "error: ${data['error'].toString()}");
      }
    }
    payInvoiceEventId = null;
  }
}
