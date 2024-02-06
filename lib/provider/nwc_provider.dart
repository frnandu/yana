import 'dart:convert';

import 'package:bip340/bip340.dart';
import 'package:dart_ndk/dart_ndk.dart';
import 'package:dart_ndk/nips/nip01/bip340_event_signer.dart';
import 'package:dart_ndk/nips/nip01/event.dart';
import 'package:dart_ndk/nips/nip01/event_signer.dart';
import 'package:dart_ndk/nips/nip01/filter.dart';
import 'package:dart_ndk/nips/nip04/nip04.dart';
import 'package:dart_ndk/request.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get_time_ago/get_time_ago.dart';
import 'package:intl/intl.dart';
import 'package:yana/models/wallet_transaction.dart';
import 'package:yana/utils/rates.dart';

import '../main.dart';
import '../nostr/event_kind.dart';
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
  List<WalletTransaction> transactions = [];

  Future<void> init() async {
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

  bool get canListTransaction => permissions.contains(NwcCommand.LIST_TRANSACTIONS);

  Future<void> reload() async {
    await init();
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
      EasyLoading.showError("missing relay parameter", duration: const Duration(seconds: 5));
      return;
    }
    if (StringUtil.isBlank(secret)) {
      EasyLoading.showError("missing secret parameter", duration: const Duration(seconds: 5));
      return;
    }
    if (StringUtil.isBlank(walletPubKey)) {
      EasyLoading.showError("missing pubKey from connection uri", duration: const Duration(seconds: 5));
      return;
    }
    relay = Uri.decodeFull(relay!);
    await settingProvider.setNwc(nwc);
    await settingProvider.setNwcSecret(secret!);
    var filter = Filter(kinds: [NwcKind.INFO_REQUEST], authors: [walletPubKey!]);
    RelayManager relayManager = RelayManager(isWeb: kIsWeb);
    // if (relayManager.webSockets[relay]!=null) {
    //   relayManager.webSockets[relay]!.disconnect("a");
    //   relayManager.webSockets[relay]!.close();
    // }
    await relayManager.reconnectRelay(relay, force: true);
    (await relayManager.requestRelays([relay!], filter)).stream.listen((event) async {
      await onEventInfo.call(event);
    });
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
      if (permissions.contains(NwcCommand.GET_BALANCE) && balance==null) {
        await requestBalance(walletPubKey!, relay!, secret!);
      }
      if (permissions.contains(NwcCommand.LIST_TRANSACTIONS)) {
        await requestListTransactions();
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
      fiatCurrencyRate = await RatesUtil.coinbase("usd");

      EventSigner nwcSigner = Bip340EventSigner(secret!, getPublicKey(secret!));

      var encrypted = Nip04.encrypt(secret!,walletPubKey!,  '{"method":"${NwcCommand.GET_BALANCE}"}');

      var tags = [
        ["p", walletPubKey]
      ];
      final event = Nip01Event(pubKey: nwcSigner!.getPublicKey(), kind: NwcKind.REQUEST, tags: tags, content: encrypted);

      var filter = Filter(
          kinds: [NwcKind.RESPONSE], authors: [walletPubKey!], eTags: [event.id]);
      // RelayManager relayManager = RelayManager();
      await relayManager.reconnectRelay(relay, force: true);

      NostrRequest balanceSubscription = await relayManager.requestRelays([relay!], filter, closeOnEOSE: false);
      balanceSubscription.stream.listen((event) async {
        await relayManager.closeNostrRequest(balanceSubscription);
        await onGetBalanceResponse(event);
      });
      await relayManager.broadcastEvent(event, [relay!], nwcSigner);
    } else {
      var filter = Filter(kinds: [NwcKind.INFO_REQUEST], authors: [walletPubKey!]);
      if (await relayManager.connectRelay(relay!)) {
        (await relayManager.requestRelays([relay!], filter)).stream.listen((event) {
          onEventInfo.call(event);
        });
      }
    }
  }

  Future<void> onGetBalanceResponse(Nip01Event event) async {
    if (event.kind == NwcKind.RESPONSE &&
        StringUtil.isNotBlank(event.content) &&
        StringUtil.isNotBlank(secret) &&
        StringUtil.isNotBlank(walletPubKey)) {
      var decrypted = Nip04.decrypt(secret!, walletPubKey!, event.content);
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

  Future<void> requestListTransactions({int limit=20, int offset=0, bool unpaid=false}) async {
    if (StringUtil.isNotBlank(walletPubKey) &&
        StringUtil.isNotBlank(relay) &&
        StringUtil.isNotBlank(secret)) {
      fiatCurrencyRate = await RatesUtil.coinbase("usd");
      EventSigner nwcSigner = Bip340EventSigner(secret!, getPublicKey(secret!));

      var content = '{"method":"${NwcCommand.LIST_TRANSACTIONS}", "params":{ "limit": $limit, "offset":$offset, "unpaid":$unpaid }}';
      var encrypted = Nip04.encrypt(secret!,walletPubKey!, content );

      var tags = [
        ["p", walletPubKey]
      ];
      final event = Nip01Event(pubKey: nwcSigner!.getPublicKey(), kind: NwcKind.REQUEST, tags: tags, content: encrypted);

      var filter = Filter(
          kinds: [NwcKind.RESPONSE], authors: [walletPubKey!], eTags: [event.id]);
      // RelayManager relayManager = RelayManager();
      await relayManager.reconnectRelay(relay!, force: true);

      NostrRequest subscription = await relayManager.requestRelays([relay!], filter, closeOnEOSE: false);
      subscription.stream.listen((event) async {
        await relayManager.closeNostrRequest(subscription);
        await onGetListTransactions(event);
      });
      await relayManager.broadcastEvent(event, [relay!], nwcSigner);
    } else {
      var filter = Filter(kinds: [NwcKind.INFO_REQUEST], authors: [walletPubKey!]);
      if (await relayManager.connectRelay(relay!)) {
        (await relayManager.requestRelays([relay!], filter)).stream.listen((event) {
          onEventInfo.call(event);
        });
      }
    }
  }

  Future<void> onGetListTransactions(Nip01Event event) async {
    if (event.kind == NwcKind.RESPONSE &&
        StringUtil.isNotBlank(event.content) &&
        StringUtil.isNotBlank(secret) &&
        StringUtil.isNotBlank(walletPubKey)) {
      var decrypted = Nip04.decrypt(secret!, walletPubKey!, event.content);
      Map<String, dynamic> data;
      data = json.decode(decrypted);
      if (data != null &&
          data['result_type'] == NwcCommand.LIST_TRANSACTIONS &&
          data.containsKey("result")
          ) {
        var list = data["result"]["transactions"];
        transactions = [];
        if (list!=null) {
          for (var t in list) {
            transactions.add(WalletTransaction.fromJson(t));
            // bool outgoing = t["type"] == "outgoing";
            // var time = "";
            // try {
            //   time = GetTimeAgo.parse(
            //       DateFormat("yyyy-MM-ddTHH:mm:ss.SSSSSSSSZ").parseUtc(
            //           t["settled_at"]));
            //   // 2023-12-21T01:36:39.97766341Z
            // } catch (e) {}
            //   transactions.add(
            //       "${outgoing ? "↑" : "↓"} ${t["description"]} ${outgoing
            //           ? "-"
            //           : "+"}${(t["amount"] / 1000).toInt()} ${time}");
          }
          // TODO set transactions
          notifyListeners();
        }
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

      var encrypted =
        Nip04.encrypt(secret!, walletPubKey!, '{"method":"${NwcCommand.PAY_INVOICE}", "params": { "invoice":"${invoice}"}}');
      var tags = [
        ["p", walletPubKey]
      ];
      final event = Nip01Event(pubKey: nwcSigner!.getPublicKey(), kind: NwcKind.REQUEST, tags: tags, content: encrypted);
      var filter = Filter(
          kinds: [NwcKind.RESPONSE], authors: [walletPubKey!], eTags: [event.id]);

      NostrRequest subscription = await relayManager.requestRelays([relay!], filter, closeOnEOSE: false);
      subscription.stream.listen((event) async {
        await relayManager.closeNostrRequest(subscription);
        await onPayInvoiceResponse(event, onZapped);
      });
      await relayManager.broadcastEvent(event, [relay!], nwcSigner);
      // TODO use dart_ndk
      // nwcNostr!.queryRelay2(filter.toMap(), relay!, onPayInvoiceResponse, onZapped: onZapped);
      // TODO use dart_ndk
      // await nwcNostr!.sendRelayEvent(event, relay!);
    } else {
      EasyLoading.showError("missing pubKey and/or relay for connecting", duration: const Duration(seconds: 5));
    }
  }

  Future<void> onPayInvoiceResponse(Nip01Event event, Function(bool) onZapped) async {
    if (event.kind == NwcKind.RESPONSE &&
        StringUtil.isNotBlank(event.content) &&
        StringUtil.isNotBlank(secret) &&
        StringUtil.isNotBlank(walletPubKey)) {
      var decrypted = Nip04.decrypt(secret!, walletPubKey!, event.content);
      Map<String, dynamic> data;
      data = json.decode(decrypted);
      if (data != null &&
          data.containsKey("result") &&
          data['result_type'] == NwcCommand.PAY_INVOICE) {
        var preImage = data['result']['preimage'];
        EasyLoading.showSuccess("Zap payed", duration: const Duration(seconds: 2));
        if (payInvoiceEventId!=null) {
          String payInvoiceEventId = this.payInvoiceEventId!;
          var filter = Filter(
              kinds: [EventKind.ZAP_RECEIPT], eTags: [payInvoiceEventId!]);
          Nip01Event? zapReceipt;
          NostrRequest subscription = await relayManager.requestRelays(myInboxRelaySet!.urls.toList()..add(relay!), filter, closeOnEOSE: false);
          subscription.stream.listen((event) async {
            await relayManager.closeNostrRequest(subscription);
            if (zapReceipt==null || zapReceipt!.createdAt < event.createdAt) {
              zapReceipt = event;
              eventReactionsProvider.addZap(payInvoiceEventId!, event);
            }
          });
          // await eventReactionsProvider.subscription(payInvoiceEventId!, null, [EventKind.ZAP_RECEIPT]);
        }
        notifyListeners();
        requestBalance(walletPubKey!, relay!, secret!);
        onZapped(true);
      } else if (data!=null && data.containsKey("error")){
        onZapped(false);
        EasyLoading.showError("error ${data['error'].toString()}", duration: const Duration(seconds: 5));
      }
    }
    payInvoiceEventId = null;
  }
}
