import 'dart:convert';

import 'package:bip340/bip340.dart';
import 'package:ndk/ndk.dart';
import 'package:ndk/domain_layer/entities/nip_01_event.dart';
import 'package:ndk/presentation_layer/request_response.dart';
import 'package:ndk/shared/nips/nip04/nip04.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:yana/models/wallet_transaction.dart';
import 'package:yana/nostr/nip47/nwc_notification.dart';
import 'package:yana/utils/rates.dart';

import '../main.dart';
import '../nostr/event_kind.dart';
import '../nostr/nip47/nwc_command.dart';
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
  String? receivingInvoice;
  Function(NwcNotification)? settledInvoiceCallback;

  List<String> permissions = [];
  List<String> notifications = []; // payment_received payment_sent
  List<WalletTransaction> transactions = [];

  Future<void> init() async {
    // TODO make this multi account aware
    String? perms = sharedPreferences.getString(DataKey.NWC_PERMISSIONS);
    if (StringUtil.isNotBlank(perms)) {
      permissions = perms!.split(" ");
      if (permissions.length == 1) {
        permissions = permissions[0].split(",");
      }
    }
    uri = await settingProvider.getNwc();
    secret = await settingProvider.getNwcSecret();
    if (StringUtil.isNotBlank(uri) && StringUtil.isNotBlank(secret)) {
      walletPubKey = sharedPreferences.getString(DataKey.NWC_PUB_KEY);
      relay = sharedPreferences.getString(DataKey.NWC_RELAY);
      await connect(uri!);
    }
  }

  bool get canListTransaction =>
      permissions.contains(NwcCommand.LIST_TRANSACTIONS);

  Future<void> reload() async {
    await init();
    notifyListeners();
  }

  int? get getBalance => balance;

  bool get canMakeInvoice => permissions.contains(NwcCommand.MAKE_INVOICE);

  bool get canPayInvoice => permissions.contains(NwcCommand.PAY_INVOICE);

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
      EasyLoading.showError("missing relay parameter",
          duration: const Duration(seconds: 5));
      return;
    }
    if (StringUtil.isBlank(secret)) {
      EasyLoading.showError("missing secret parameter",
          duration: const Duration(seconds: 5));
      return;
    }
    if (StringUtil.isBlank(walletPubKey)) {
      EasyLoading.showError("missing pubKey from connection uri",
          duration: const Duration(seconds: 5));
      return;
    }
    relay = Uri.decodeFull(relay!);
    await settingProvider.setNwc(nwc);
    await settingProvider.setNwcSecret(secret!);
    var filter = Filter(kinds: [NwcKind.INFO_REQUEST], authors: [walletPubKey!]);
    RelayManager relayManager = RelayManager();
    // if (relayManager.webSockets[relay]!=null) {
    //  ndk.relayManager().webSockets[relay]!.disconnect("a");
    //  ndk.relayManager().webSockets[relay]!.close();
    // }
    await ndk.relayManager().reconnectRelay(relay, force: true);
    ndk.query(relays: [relay], filters: [filter])
        .stream
        .listen((event) async {
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
      permissions = event.content.split(" ");
      if (permissions.length == 1) {
        permissions = permissions[0].split(",");
      }
      if (permissions.contains(NwcCommand.GET_INFO)) {
        await requestGetInfo(walletPubKey!, relay!, secret!);
      }
      if (permissions.contains(NwcCommand.GET_BALANCE) && balance == null) {
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

  Future<void> requestGetInfo(
      String walletPubKey, String relay, String secret) async {
    if (StringUtil.isNotBlank(walletPubKey) &&
        StringUtil.isNotBlank(relay) &&
        StringUtil.isNotBlank(secret)) {
      EventSigner nwcSigner = Bip340EventSigner(secret!, getPublicKey(secret!));

      var encrypted = Nip04.encrypt(
          secret!, walletPubKey!, '{"method":"${NwcCommand.GET_INFO}"}');

      var tags = [
        ["p", walletPubKey]
      ];
      final event = Nip01Event(
          pubKey: nwcSigner!.getPublicKey(),
          kind: NwcKind.REQUEST,
          tags: tags,
          content: encrypted);

      var filter = Filter(
          kinds: [NwcKind.RESPONSE],
          authors: [walletPubKey!],
          eTags: [event.id]);
      // RelayManager relayManager = RelayManager();
      await ndk.relayManager().reconnectRelay(relay, force: true);

      NdkResponse sub = ndk.subscription(relays: [relay!], filters: [filter]);

      sub.stream.listen((event) async {
        await ndk.closeSubscription(sub.requestId);
        await onGetInfo(event);
      });
      await ndk.broadcastEvent(event, [relay!], signer: nwcSigner);
    }
  }

  Future<void> onGetInfo(Nip01Event event) async {
    if (event.kind == NwcKind.RESPONSE &&
        StringUtil.isNotBlank(event.content) &&
        StringUtil.isNotBlank(secret) &&
        StringUtil.isNotBlank(walletPubKey)) {
      var decrypted = Nip04.decrypt(secret!, walletPubKey!, event.content);
      Map<String, dynamic> data;
      data = json.decode(decrypted);
      if (data != null &&
          data.containsKey("result") &&
          data['result_type'] == NwcCommand.GET_INFO) {
        Map<String, dynamic> result = data['result'];
        if (result['notifications'] != null) {
          notifications = List<String>.from(
              result['notifications'].map((e) => e.toString()));
          if (notifications != null && notifications.isNotEmpty) {
            await subscribeToNotifications();
          }
        }
        notifyListeners();
      } else if (data != null && data.containsKey("error")) {
        var error = data['error']['code'];
        if (error == "UNAUTHORIZED") {
          await disconnect();
          notifyListeners();
        }
      }
    }
  }

  Future<void> requestBalance(
      String walletPubKey, String relay, String secret) async {
    if (StringUtil.isNotBlank(walletPubKey) &&
        StringUtil.isNotBlank(relay) &&
        StringUtil.isNotBlank(secret)) {
      fiatCurrencyRate = await RatesUtil.coinbase("usd");

      EventSigner nwcSigner = Bip340EventSigner(secret!, getPublicKey(secret!));

      var encrypted = Nip04.encrypt(
          secret!, walletPubKey!, '{"method":"${NwcCommand.GET_BALANCE}"}');

      var tags = [
        ["p", walletPubKey]
      ];
      final event = Nip01Event(
          pubKey: nwcSigner!.getPublicKey(),
          kind: NwcKind.REQUEST,
          tags: tags,
          content: encrypted);

      var filter = Filter(
          kinds: [NwcKind.RESPONSE],
          authors: [walletPubKey!],
          eTags: [event.id]);
      // RelayManager relayManager = RelayManager();
      await ndk.relayManager().reconnectRelay(relay, force: true);

      NdkResponse balanceSubscription = ndk.subscription(relays: [relay], filters: [filter]);

      balanceSubscription.stream.listen((event) async {
        await ndk.closeSubscription(balanceSubscription.requestId);
        await onGetBalanceResponse(event);
      });
      await ndk.relayManager().broadcastEvent(event, [relay!], nwcSigner);
    } else {
      var filter =
          Filter(kinds: [NwcKind.INFO_REQUEST], authors: [walletPubKey!]);
      if (await ndk.relayManager().connectRelay(relay!)) {
        ndk.query(relays: [relay!],  filters: [filter])
            .stream
            .listen((event) {
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
        if (permissions.contains(NwcCommand.LIST_TRANSACTIONS)) {
          requestListTransactions();
        }
        notifyListeners();
      } else if (data != null && data.containsKey("error")) {
        var error = data['error']['code'];
        if (error == "UNAUTHORIZED") {
          await disconnect();
          notifyListeners();
        }
      }
    }
  }

  Future<void> requestListTransactions(
      {int limit = 20, int offset = 0, bool unpaid = false}) async {
    if (StringUtil.isNotBlank(walletPubKey) &&
        StringUtil.isNotBlank(relay) &&
        StringUtil.isNotBlank(secret)) {
      fiatCurrencyRate = await RatesUtil.coinbase("usd");
      EventSigner nwcSigner = Bip340EventSigner(secret!, getPublicKey(secret!));

      var content =
          '{"method":"${NwcCommand.LIST_TRANSACTIONS}", "params":{ "limit": $limit, "offset":$offset, "unpaid":$unpaid }}';
      var encrypted = Nip04.encrypt(secret!, walletPubKey!, content);

      var tags = [
        ["p", walletPubKey]
      ];
      final event = Nip01Event(
          pubKey: nwcSigner.getPublicKey(),
          kind: NwcKind.REQUEST,
          tags: tags,
          content: encrypted);

      var filter = Filter(
          kinds: [NwcKind.RESPONSE],
          authors: [walletPubKey!],
          eTags: [event.id]);
      // RelayManager relayManager = RelayManager();
      await ndk.relayManager().reconnectRelay(relay!, force: true);

      NdkResponse subscription = ndk.subscription(relays: [relay!], filters: [filter]);

      subscription.stream.listen((event) async {
        await ndk.closeSubscription(subscription.requestId);
        await onGetListTransactions(event);
      });
      await ndk.relayManager().broadcastEvent(event, [relay!], nwcSigner);
    } else {
      var filter =
          Filter(kinds: [NwcKind.INFO_REQUEST], authors: [walletPubKey!]);
      if (await ndk.relayManager().connectRelay(relay!)) {
        ndk.query(relays: [relay!], filters: [filter])
            .stream
            .listen((event) {
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
          data.containsKey("result")) {
        var list = data["result"]["transactions"];
        transactions = [];
        if (list != null) {
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
      } else if (data != null && data.containsKey("error")) {
        var error = data['error']['code'];
        if (error == "UNAUTHORIZED") {
          await disconnect();
          notifyListeners();
        }
      }
    }
  }

  Future<void> payInvoice(String invoice, String? eventId,
      Function(NwcNotification?) onZapped) async {
    if (StringUtil.isNotBlank(walletPubKey) &&
        StringUtil.isNotBlank(relay) &&
        StringUtil.isNotBlank(secret)) {
      EventSigner nwcSigner = Bip340EventSigner(secret!, getPublicKey(secret!));

      payInvoiceEventId = eventId;

      var encrypted = Nip04.encrypt(secret!, walletPubKey!,
          '{"method":"${NwcCommand.PAY_INVOICE}", "params": { "invoice":"${invoice}"}}');
      var tags = [
        ["p", walletPubKey]
      ];
      final event = Nip01Event(
          pubKey: nwcSigner!.getPublicKey(),
          kind: NwcKind.REQUEST,
          tags: tags,
          content: encrypted);
      var filter = Filter(
          kinds: [NwcKind.RESPONSE],
          authors: [walletPubKey!],
          eTags: [event.id]);
      NdkResponse subscription = ndk.subscription(relays: [relay], filters: [filter]);

      subscription.stream.listen((event) async {
        await ndk.closeSubscription(subscription.requestId);
        await onPayInvoiceResponse(event, onZapped);
      });
      await ndk.relayManager().broadcastEvent(event, [relay!], nwcSigner);
      // TODO use dart_ndk
      // nwcNostr!.queryRelay2(filter.toMap(), relay!, onPayInvoiceResponse, onZapped: onZapped);
      // TODO use dart_ndk
      // await nwcNostr!.sendRelayEvent(event, relay!);
    } else {
      EasyLoading.showError("missing pubKey and/or relay for connecting",
          duration: const Duration(seconds: 5));
    }
  }

  Future<void> onPayInvoiceResponse(
      Nip01Event event, Function(NwcNotification?) onZapped) async {
    if (event.kind == NwcKind.RESPONSE &&
        StringUtil.isNotBlank(event.content) &&
        StringUtil.isNotBlank(secret) &&
        StringUtil.isNotBlank(walletPubKey)) {
      var decrypted = Nip04.decrypt(secret!, walletPubKey!, event.content);
      Map<String, dynamic> data;
      data = json.decode(decrypted);
      if (data.containsKey("result") &&
          data['result_type'] == NwcCommand.PAY_INVOICE) {
        String? preImage = data['result']['preimage'];
        if (payInvoiceEventId != null) {
          EasyLoading.showSuccess("Zap payed",
              duration: const Duration(seconds: 2));
          String payInvoiceEventId = this.payInvoiceEventId!;
          var filter = Filter(
              kinds: [EventKind.ZAP_RECEIPT], eTags: [payInvoiceEventId!]);
          Nip01Event? zapReceipt;
          NdkResponse subscription = ndk.subscription(relays: myInboxRelaySet!.urls.toList()..add(relay!), filters: [filter]);
          subscription.stream.listen((event) async {
            await ndk.closeSubscription(subscription.requestId);
            if (zapReceipt == null || zapReceipt!.createdAt < event.createdAt) {
              zapReceipt = event;
              eventReactionsProvider.addZap(payInvoiceEventId!, event);
            }
          });
          // await eventReactionsProvider.subscription(payInvoiceEventId!, null, [EventKind.ZAP_RECEIPT]);
        }
        NwcNotification notification = NwcNotification(
            type: NwcNotification.OUTGOING,
            invoice: "",
            preimage: preImage!,
            paymentHash: "",
            amount: 0,
            feesPaid: data['result']['fees_paid']??0,
            createdAt: 0,
            settledAt: 0,
            metadata: {});
        notifyListeners();
        requestBalance(walletPubKey!, relay!, secret!);
        onZapped(notification);
      } else if (data != null && data.containsKey("error")) {
        onZapped(null);
        EasyLoading.showError("error ${data['error'].toString()}",
            duration: const Duration(seconds: 5));
      }
    }
    payInvoiceEventId = null;
  }

  Future<void> makeInvoice(
      int amount,
      String? description,
      String? description_hash,
      int expiry,
      Function(String) onCreatedInvoice,
      Function(NwcNotification)? settledInvoiceCallback) async {
    if (StringUtil.isNotBlank(walletPubKey) &&
        StringUtil.isNotBlank(relay) &&
        StringUtil.isNotBlank(secret)) {
      EventSigner nwcSigner = Bip340EventSigner(secret!, getPublicKey(secret!));

      String makeInvoice =
          '{"method":"${NwcCommand.MAKE_INVOICE}", "params": { "amount":${amount}, "description" : "${description}", "expiry":${expiry}}}';
      var encrypted = Nip04.encrypt(secret!, walletPubKey!, makeInvoice);
      var tags = [
        ["p", walletPubKey]
      ];
      final event = Nip01Event(
          pubKey: nwcSigner!.getPublicKey(),
          kind: NwcKind.REQUEST,
          tags: tags,
          content: encrypted);
      var filter = Filter(
          kinds: [NwcKind.RESPONSE],
          authors: [walletPubKey!],
          eTags: [event.id]);
      NdkResponse subscription = ndk.subscription(relays: myInboxRelaySet!.urls.toList()..add(relay!), filters: [filter]);
      subscription.stream.listen((event) async {
        await ndk.closeSubscription(subscription.requestId);
        await onMakeInvoiceResponse(event, onCreatedInvoice);
      });
      this.settledInvoiceCallback = settledInvoiceCallback;
      await ndk.relayManager().broadcastEvent(event, [relay!], nwcSigner);
    } else {
      EasyLoading.showError("missing pubKey and/or relay for connecting",
          duration: const Duration(seconds: 5));
    }
  }

  Future<void> onMakeInvoiceResponse(
      Nip01Event event, Function(String) onCreatedInvoice) async {
    if (event.kind == NwcKind.RESPONSE &&
        StringUtil.isNotBlank(event.content) &&
        StringUtil.isNotBlank(secret) &&
        StringUtil.isNotBlank(walletPubKey)) {
      var decrypted = Nip04.decrypt(secret!, walletPubKey!, event.content);
      Map<String, dynamic> data;
      data = json.decode(decrypted);
      if (data != null &&
          data.containsKey("result") &&
          data['result_type'] == NwcCommand.MAKE_INVOICE) {
        receivingInvoice = data['result']['invoice'];
        if (receivingInvoice != null) {
          onCreatedInvoice(receivingInvoice!);
          notifyListeners();
        }
      } else if (data != null && data.containsKey("error")) {
        EasyLoading.showError("error ${data['error'].toString()}",
            duration: const Duration(seconds: 5));
      }
    }
  }

  Future<void> subscribeToNotifications() async {
    if (StringUtil.isNotBlank(walletPubKey) &&
        StringUtil.isNotBlank(relay) &&
        StringUtil.isNotBlank(secret)) {
      var filter =
          Filter(kinds: [NwcKind.NOTIFICATION], authors: [walletPubKey!]);
      await ndk.relayManager().reconnectRelay(relay!, force: true);

      NdkResponse subscription = ndk.subscription(relays: [relay!], filters: [filter]);
      subscription.stream.listen((event) async {
        await onNotification(event);
      });
    }
  }

  Future<void> onNotification(Nip01Event event) async {
    if (event.kind == NwcKind.NOTIFICATION &&
        StringUtil.isNotBlank(event.content) &&
        StringUtil.isNotBlank(secret) &&
        StringUtil.isNotBlank(walletPubKey)) {
      var decrypted = Nip04.decrypt(secret!, walletPubKey!, event.content);
      Map<String, dynamic> data;
      data = json.decode(decrypted);
      if (data != null &&
          data.containsKey("notification_type") &&
          data['notification_type'] == NwcNotification.PAYMENT_RECEIVED &&
          data['notification'] != null) {
        NwcNotification notification =
            NwcNotification.fromMap(data['notification']);
        if (notification.type == NwcNotification.INCOMING) {
          if (receivingInvoice != null &&
              receivingInvoice == notification.invoice &&
              settledInvoiceCallback != null) {
            settledInvoiceCallback!(notification);
            receivingInvoice = null;
            settledInvoiceCallback = null;
          } else {
            EasyLoading.showSuccess(
                "Payment received ${notification.amount / 1000} sats (fees:${notification.feesPaid / 1000})",
                duration: const Duration(seconds: 2));
          }
        } else {
          EasyLoading.showSuccess(
              "Payment type=${notification.type} amount=${(notification.amount / 1000).round()} sats (fees:${(notification.feesPaid / 1000).round()})",
              duration: const Duration(seconds: 2));
        }
        notifyListeners();
        requestBalance(walletPubKey!, relay!, secret!);
      } else if (data != null && data.containsKey("error")) {
        EasyLoading.showError("error ${data['error'].toString()}",
            duration: const Duration(seconds: 5));
      }
    }
  }
}
