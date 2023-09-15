import 'dart:convert';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';

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
  int? balance;
  int? maxAmount;

  List<String> permissions = [];

  static NwcProvider getInstance() {
    _nwcProvider ??= NwcProvider();
    return _nwcProvider!;
  }

  Future<void> _init() async {
    // TODO make this multi account aware
    String? perms = sharedPreferences.getString(DataKey.NWC_PERMISSIONS);
    if (StringUtil.isNotBlank(perms)) {
      permissions = perms!.split(",");
    }
    uri = await settingProvider.getNwc();
    if (StringUtil.isNotBlank(uri)) {
      await requestBalance();
    }
  }

  Future<void> reload() async {
    await _init();
    notifyListeners();
  }

  int? get getBalance => balance;

  bool get isConnected => permissions!=null && permissions.isNotEmpty && StringUtil.isNotBlank(secret);

  Future<void> requestBalance() async {
    String? walletPubKey = sharedPreferences.getString(DataKey.NWC_PUB_KEY);
    String? relay = sharedPreferences.getString(DataKey.NWC_RELAY);
    String? secret = await settingProvider.getNwcSecret();
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
          kinds: [NwcKind.RESPONSE], authors: [walletPubKey], e: [event.id]);
      nwcNostr!.queryRelay(filter.toJson(), relay!, onGetBalanceResponse);
    } else {
      BotToast.showText(text: "missing pubKey and/or relay for connectiong");
    }
  }

  // static RegExp nwcRegExp =
  //     RegExp(r'^nostr\+walletconnect:\/\/([ZA-ZZa-z0-9_]+)\?(.*)');
  // static RegExp relayRegExp = RegExp(
  //     r'^(wss?:\/\/)([0-9]{1,3}(?:\.[0-9]{1,3}){3}|[^:]+):?([0-9]{1,5})?$');
  //
  // Map<String, String> parseQueryString(String input) {
  //   Map<String, String> resultMap = {};
  //   List<String> pairs = input.split('&');
  //
  //   for (String pair in pairs) {
  //     List<String> keyValue = pair.split('=');
  //     if (keyValue.length == 2) {
  //       String key = keyValue[0];
  //       String value = keyValue[1];
  //       resultMap[key] = value;
  //     }
  //   }
  //   return resultMap;
  // }

  Future<void> connect(String nwc) async {
    Uri uri = Uri.parse(nwc.replaceAll("nostr+walletconnect:", "https:"));
    // var match = nwcRegExp.firstMatch(nwc);
    // if (match != null) {
    // String? pubKey = match!.group(1);
    // String? params = match!.group(2);
    String? pubKey = uri.host;
    // String? params = match!.group(2);
    // if (StringUtil.isNotBlank(params)) {
    //   Map<String, String> map = parseQueryString(params!);
    // String? relay = map['relay'];
    // String? secret = map['secret'];
    // String? lud16 = map['lub16'];
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
    if (StringUtil.isBlank(pubKey)) {
      BotToast.showText(text: "missing pubKey from connection uri");
      return;
    }
    await settingProvider.setNwcSecret(secret!);
    var filter = Filter(kinds: [NwcKind.INFO_REQUEST], authors: [pubKey!]);
    nostr!.queryRelay(filter.toJson(), relay!, onEventInfo);
  }

  Future<void> onEventInfo(Event event) async {
    if (event.kind == NwcKind.INFO_REQUEST &&
        StringUtil.isNotBlank(event.content)) {
      sharedPreferences.setString(DataKey.NWC_PERMISSIONS, event.content);
      sharedPreferences.setString(DataKey.NWC_RELAY, event.sources[0]);
      sharedPreferences.setString(DataKey.NWC_PUB_KEY, event.pubKey);
      // setState(() {
      permissions = event.content.split(",");
      // });
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
    // setState(() {
      balance = null;
      maxAmount = null;
      uri = null;
      // controller.text = "";
      permissions = [];
    // });
    notifyListeners();
  }

  void onGetBalanceResponse(Event event) async {
    if (event.kind == NwcKind.RESPONSE &&
        StringUtil.isNotBlank(event.content)) {
      String? secret = await settingProvider.getNwcSecret();
      var agreement = NIP04.getAgreement(secret!);
      String? walletPubKey = sharedPreferences.getString(DataKey.NWC_PUB_KEY);
      var decrypted = NIP04.decrypt(event.content, agreement, walletPubKey!);
      Map<String, dynamic> data;
      data = json.decode(decrypted);
      if (data != null &&
          data.containsKey("result") &&
          data['result_type'] == 'get_balance') {
        // setState(() {
        balance = data['result']['balance'];
        if (balance != null) {
          balance = balance! ~/ 1000;
        }
        maxAmount = data['result']['max_amount'];
        if (maxAmount != null) {
          maxAmount = maxAmount! ~/ 1000;
        }
        // });
        notifyListeners();
      }
    }
  }

  void payInvoice() {}
}
