import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:ndk/domain_layer/usecases/nwc/consts/nwc_method.dart';
import 'package:ndk/domain_layer/usecases/nwc/consts/transaction_type.dart';
import 'package:ndk/domain_layer/usecases/nwc/nwc_notification.dart';
import 'package:ndk/ndk.dart';
import 'package:ndk/shared/logger/logger.dart';

import '../main.dart';
import '../utils/rates.dart';
import '../utils/string_util.dart';
import 'data_util.dart';

class NwcProvider extends ChangeNotifier {
  static const int BTC_IN_SATS = 100000000;

  static NwcProvider? _nwcProvider;

  NwcConnection? connection;

  // String? uri;
  // String? secret;
  // String? walletPubKey;
  // String? relay;
  GetBalanceResponse? cachedBalanceResponse;
  ListTransactionsResponse? cachedListTransactionsResponse;

  // TODO REFRESH balance/transactions if timestamp too old
  int? lastBalanceTimestamp;
  int? lastListTransactionsTimestamp;

  // String? payInvoiceEventId;
  // String? receivingInvoice;
  // Function(NwcNotification)? paymentReceivedCallback;

  List<TransactionResult>? get transactions => cachedListTransactionsResponse?.transactions;

  static const String BOLT11_PREFIX = "lnbc";
  static const String NWC_PROTOCOL_PREFIX = "nostr+walletconnect://";

  // NdkResponse? subscription;
  // EventSigner? nwcSigner;

  Future<void> init() async {
    // TODO make this multi account aware
    String? perms = sharedPreferences.getString(DataKey.NWC_PERMISSIONS);
    // if (StringUtil.isNotBlank(perms)) {
    //   permissions = perms!.split(" ");
    //   if (permissions.length == 1) {
    //     permissions = permissions[0].split(",");
    //   }
    // }
    String? uri = await settingProvider.getNwc();
    if (StringUtil.isNotBlank(uri)) {
      await connect(uri!, doGetInfo: false);
    }
    // secret = await settingProvider.getNwcSecret();
    // if (StringUtil.isNotBlank(uri) && StringUtil.isNotBlank(secret)) {
    //   walletPubKey = sharedPreferences.getString(DataKey.NWC_PUB_KEY);
    //   relay = sharedPreferences.getString(DataKey.NWC_RELAY);
    //   await connect(uri!);
    // }
  }

  bool get canListTransaction => connection != null && connection!.permissions.contains(NwcMethod.LIST_TRANSACTIONS.name);

  /// get wallet balance in sats
  int? get getBalance => cachedBalanceResponse?.balanceSats;

  bool get canMakeInvoice => connection != null && connection!.permissions.contains(NwcMethod.MAKE_INVOICE.name);

  bool get canPayInvoice => connection != null && connection!.permissions.contains(NwcMethod.PAY_INVOICE.name);

  /// is the wallet connected
  bool get isConnected => connection != null && connection!.permissions.isNotEmpty;

  /// connect the wallet
  Future<void> connect(String nwc, {Function(String?)? onConnect, Function(String?)? onError, bool? doGetInfo = true}) async {
    nwc = nwc.replaceAll("yana:", "nostr+walletconnect:");
    await ndk.nwc.connect(nwc, doGetInfoMethod: doGetInfo!).then((connection) async {
      this.connection = connection;
      await refreshWallet();
      if (onConnect != null) {
        onConnect.call(connection.uri.lud16);
      }
      connection.notificationStream.stream.listen((notification) async {
        // print("NOTIFICATION $notification");
        if (notification.type == NwcNotification.PAYMENT_RECEIVED) {
          // if (receivingInvoice != null && receivingInvoice == notification.invoice && settledInvoiceCallback != null) {
          //   settledInvoiceCallback!(notification);
          //   receivingInvoice = null;
          //   settledInvoiceCallback = null;
          // } else {
          //   if (paymentReceivedCallback != null) {
          //     paymentReceivedCallback!.call(notification);
          //   } else {
          //     EasyLoading.showSuccess("Payment received ${notification.amount / 1000} sats (fees:${notification.feesPaid / 1000})",
          //         duration: const Duration(seconds: 2));
          //   }
          // }
          await refreshWallet();
        }
      });
      notifyListeners();
    });

    // Uri uri = Uri.parse(nwc.replaceAll("nostr+walletconnect:", "https:"));
    // String? walletPubKey = uri.host;
    // String? relay = uri.queryParameters['relay'];
    // secret = uri.queryParameters['secret'];
    // String? lud16 = uri.queryParameters['lud16'];
    // if (lud16 != null) {
    //   Metadata? metadata = await metadataProvider.getMetadata(
    //       loggedUserSigner!.getPublicKey());
    //   if (metadata != null && metadata.lud16 != lud16) {
    //
    //   }
    // }
    // if (StringUtil.isBlank(relay)) {
    //   EasyLoading.showError("missing relay parameter",
    //       duration: const Duration(seconds: 5));
    //   return;
    // }
    // if (StringUtil.isBlank(secret)) {
    //   EasyLoading.showError("missing secret parameter",
    //       duration: const Duration(seconds: 5));
    //   return;
    // }
    // if (StringUtil.isBlank(walletPubKey)) {
    //   EasyLoading.showError("missing pubKey from connection uri",
    //       duration: const Duration(seconds: 5));
    //   return;
    // }
    // relay = Uri.decodeFull(relay!);
    // await settingProvider.setNwc(nwc);
    // await settingProvider.setNwcSecret(secret!);
    // var filter = Filter(kinds: [NwcKind.INFO_REQUEST], authors: [walletPubKey]);
    // // await ndk.relays.reconnectRelay(relay);
    //
    // ndk.requests
    //     .query(
    //     name: "nwc-info",
    //     explicitRelays: [relay],
    //     filters: [filter],
    //     cacheRead: false,
    //     cacheWrite: false)
    //     .stream
    //     .timeout(const Duration(seconds: 10), onTimeout: (sink) {
    //   onError?.call("timed out...");
    // })
    //     .listen((event) async {
    //   await onInfoRequest(event, onConnect, lud16);
    // });
  }

  //
  // Future<void> onInfoRequest(Nip01Event event, Function? onConnect,
  //     String? lud16) async {
  //   if (event.kind == NwcKind.INFO_REQUEST &&
  //       StringUtil.isNotBlank(event.content)) {
  //     walletPubKey = event.pubKey;
  //     relay = event.sources[0];
  //     nwcSigner = Bip340EventSigner(privateKey: secret!, publicKey: getPublicKey(secret!));
  //     sharedPreferences.setString(DataKey.NWC_PERMISSIONS, event.content);
  //     sharedPreferences.setString(DataKey.NWC_RELAY, relay!);
  //     sharedPreferences.setString(DataKey.NWC_PUB_KEY, walletPubKey!);
  //     permissions = event.content.split(" ");
  //     if (permissions.length == 1) {
  //       permissions = permissions[0].split(",");
  //     }
  //     await subscribeToNotificationsAndResponses();
  //
  //     if (permissions.contains(NwcCommand.GET_INFO)) {
  //       await requestGetInfo();
  //     }
  //     if (permissions.contains(NwcCommand.GET_BALANCE) && balance == null) {
  //       await requestBalance();
  //     }
  //     if (permissions.contains(NwcCommand.LIST_TRANSACTIONS)) {
  //       await requestListTransactions();
  //     }
  //     if (onConnect != null) {
  //       onConnect.call(lud16);
  //     }
  //     notifyListeners();
  //   }
  // }

  /// disconnect the wallet
  Future<void> refreshWallet() async {
    if (connection != null) {
      if (connection!.permissions.contains(NwcMethod.GET_BALANCE.name)) {
        cachedBalanceResponse = await ndk.nwc.getBalance(connection!);
        fiatCurrencyRate = await RatesUtil.fiatCurrency(settingProvider.currency!);
      }
      if (connection!.permissions.contains(NwcMethod.LIST_TRANSACTIONS.name)) {
        cachedListTransactionsResponse = await ndk.nwc.listTransactions(connection!, unpaid: false);
      }
    }
  }

  Future<ListTransactionsResponse> listTransactions({int? from, int? until, int? limit, int? offset, required bool unpaid, TransactionType? type}) async {
    return await ndk.nwc.listTransactions(
      connection!,
      unpaid: false,
      from: from,
      until: until,
      limit: limit,
      offset: offset,
      type: type,
    );
  }

  /// disconnect the wallet
  Future<void> disconnect() async {
    // sharedPreferences.setString(DataKey.NWC_PERMISSIONS, "");
    await settingProvider.setNwc(null);
    // await settingProvider.setNwcSecret(null);
    // sharedPreferences.remove(DataKey.NWC_PERMISSIONS);
    // sharedPreferences.remove(DataKey.NWC_RELAY);
    // sharedPreferences.remove(DataKey.NWC_PUB_KEY);
    // if (subscription != null) {
    //   ndk.requests.closeSubscription(subscription!.requestId);
    //   subscription = null;
    // }
    if (connection != null) {
      await ndk.nwc.disconnect(connection!);
      connection = null;
    }
    cachedBalanceResponse = null;
    cachedListTransactionsResponse = null;
    // maxAmount = null;
    // uri = null;
    // permissions = [];
    // nwcSigner = null;
    notifyListeners();
  }

  /// request get info from wallet
  // Future<void> requestGetInfo() async {
  //   if (isConnected) {
  //     var encrypted = Nip04.encrypt(
  //         secret!, walletPubKey!, '{"method":"${NwcCommand.GET_INFO}"}');
  //
  //     List<List<String>> tags = [
  //       ["p", walletPubKey!]
  //     ];
  //     final event = Nip01Event(
  //         pubKey: nwcSigner!.getPublicKey(),
  //         kind: NwcKind.REQUEST,
  //         tags: tags,
  //         content: encrypted);
  //     await ndk.relays.reconnectRelay(relay!, connectionSource: ConnectionSource.EXPLICIT);
  //     NdkBroadcastResponse response = ndk.broadcast.broadcast(nostrEvent: event, specificRelays: [relay!], customSigner: nwcSigner!);
  //     await response.broadcastDoneFuture;
  //   }
  // }

  /// request balance from wallet
  // Future<void> requestBalance() async {
  //   if (isConnected) {
  //     try {
  //       fiatCurrencyRate =
  //       await RatesUtil.fiatCurrency(settingProvider.currency!);
  //
  //       var encrypted = Nip04.encrypt(
  //           secret!, walletPubKey!, '{"method":"${NwcCommand.GET_BALANCE}"}');
  //
  //       List<List<String>> tags = [
  //         ["p", walletPubKey!]
  //       ];
  //       final event = Nip01Event(
  //           pubKey: nwcSigner!.getPublicKey(),
  //           kind: NwcKind.REQUEST,
  //           tags: tags,
  //           content: encrypted);
  //       await ndk.relays.reconnectRelay(relay!, connectionSource: ConnectionSource.EXPLICIT);
  //       NdkBroadcastResponse response = ndk.broadcast.broadcast(nostrEvent: event, specificRelays: [relay!], customSigner: nwcSigner!);
  //       await response.broadcastDoneFuture;
  //     } catch (e) {
  //       print(e);
  //       Logger.log.e(e);
  //     }
  //   }
  // }

  // /// request list of transactions
  // Future<void> requestListTransactions(
  //     {int limit = 100, int offset = 0, bool unpaid = false}) async {
  //   if (isConnected) {
  //     try {
  //       fiatCurrencyRate =
  //       await RatesUtil.fiatCurrency(settingProvider.currency!);
  //
  //       var content =
  //           '{"method":"${NwcCommand
  //           .LIST_TRANSACTIONS}", "params":{ "limit": $limit, "offset":$offset, "unpaid":$unpaid }}';
  //       var encrypted = Nip04.encrypt(secret!, walletPubKey!, content);
  //
  //       List<List<String>> tags = [
  //         ["p", walletPubKey!]
  //       ];
  //       final event = Nip01Event(
  //           pubKey: nwcSigner!.getPublicKey(),
  //           kind: NwcKind.REQUEST,
  //           tags: tags,
  //           content: encrypted);
  //
  //       await ndk.relays.reconnectRelay(relay!, connectionSource: ConnectionSource.EXPLICIT);
  //       NdkBroadcastResponse response = ndk.broadcast.broadcast(nostrEvent: event, specificRelays: [relay!], customSigner: nwcSigner!);
  //       await response.broadcastDoneFuture;
  //     } catch (e) {
  //       print(e);
  //       Logger.log.e(e);
  //     }
  //   }
  // }

  Future<PayInvoiceResponse?> payInvoice(String invoice) async {
    if (connection != null && connection!.permissions.contains(NwcMethod.PAY_INVOICE.name)) {
      try {
        PayInvoiceResponse response = await ndk.nwc.payInvoice(connection!, invoice: invoice);
        if (response.preimage != '') {
          await refreshWallet();
          notifyListeners();
          return response;
        }
      } catch (e) {
        EasyLoading.showError(e.toString(), duration: const Duration(seconds: 5));
        Logger.log.e(e);
        return null;
      }
    }
    EasyLoading.showError("missing pubKey and/or relay for connecting", duration: const Duration(seconds: 5));
    return null;
  }

  Future<MakeInvoiceResponse?> makeInvoice(int amountSats, String? description, String? description_hash, int expiry) async {
    if (connection != null && connection!.permissions.contains(NwcMethod.MAKE_INVOICE.name)) {
      return await ndk.nwc.makeInvoice(connection!, amountSats: amountSats);
    } else {
      EasyLoading.showError("missing pubKey and/or relay for connecting", duration: const Duration(seconds: 5));
      return null;
    }
  }
}
