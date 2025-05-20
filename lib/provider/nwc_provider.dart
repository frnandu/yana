import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:ndk/domain_layer/usecases/nwc/consts/nwc_method.dart';
import 'package:ndk/domain_layer/usecases/nwc/consts/transaction_type.dart';
import 'package:ndk/domain_layer/usecases/nwc/nwc_notification.dart';
import 'package:ndk/ndk.dart';

import '../main.dart';
import '../utils/rates.dart';
import '../utils/string_util.dart';

class NwcProvider extends ChangeNotifier {
  static const int BTC_IN_SATS = 100000000;

  NwcConnection? connection;

  GetBalanceResponse? cachedBalanceResponse;
  ListTransactionsResponse? cachedListTransactionsResponse;

  // TODO REFRESH balance/transactions if timestamp too old
  int? lastBalanceTimestamp;
  int? lastListTransactionsTimestamp;

  List<TransactionResult>? get transactions =>
      cachedListTransactionsResponse?.transactions;

  static const String BOLT11_PREFIX = "lnbc";
  static const String NWC_PROTOCOL_PREFIX = "nostr+walletconnect://";

  Future<void> init() async {
    String? uri = await settingProvider.getNwc();
    if (StringUtil.isNotBlank(uri) && connection == null) {
      await connect(uri!, doGetInfo: false);
    }
  }

  bool get canListTransaction =>
      connection != null &&
      connection!.permissions.contains(NwcMethod.LIST_TRANSACTIONS.name);

  /// get wallet balance in sats
  int? get getBalance => cachedBalanceResponse?.balanceSats;

  bool get canMakeInvoice =>
      connection != null &&
      connection!.permissions.contains(NwcMethod.MAKE_INVOICE.name);

  bool get canPayInvoice =>
      connection != null &&
      connection!.permissions.contains(NwcMethod.PAY_INVOICE.name);

  /// is the wallet connected
  bool get isConnected =>
      connection != null && connection!.permissions.isNotEmpty;

  /// connect the wallet
  Future<void> connect(String nwc,
      {Function(String?)? onConnect,
      Function(String?)? onError,
      bool? doGetInfo = true}) async {
    nwc = nwc.replaceAll("yana:", "nostr+walletconnect:");
    await ndk.nwc.connect(nwc,
            doGetInfoMethod: doGetInfo!,
            // This below is needed if we want to connect to Primal wallet
            // useETagForEachRequest: true,
            // ignoreCapabilitiesCheck: true,
            onError: onError)
        .then((connection) async {
      this.connection = connection;
      settingProvider.setNwc(nwc);
      await refreshWallet();
      if (onConnect != null) {
        onConnect.call(connection.uri.lud16);
      }
      connection.notificationStream.stream.listen((notification) async {
        if (notification.type == NwcNotification.kPaymentReceived) {
          await refreshWallet();
        }
      });
      notifyListeners();
    });
  }

  Future<void> refreshWallet({bool? force = false}) async {
    if (connection != null) {
      // TODO check timestamps to not refresh too often and when force=false
      if (connection!.permissions.contains(NwcMethod.GET_BALANCE.name)) {
        cachedBalanceResponse = await ndk.nwc.getBalance(connection!);
        fiatCurrencyRate =
            await RatesUtil.fiatCurrency(settingProvider.currency!);
      }
      if (connection!.permissions.contains(NwcMethod.LIST_TRANSACTIONS.name)) {
        cachedListTransactionsResponse =
            await ndk.nwc.listTransactions(connection!, unpaid: false);
      }
    }
  }

  Future<ListTransactionsResponse> listTransactions(
      {int? from,
      int? until,
      int? limit,
      int? offset,
      required bool unpaid,
      TransactionType? type}) async {
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
    await settingProvider.setNwc(null);
    if (connection != null) {
      await ndk.nwc.disconnect(connection!);
      connection = null;
    }
    cachedBalanceResponse = null;
    cachedListTransactionsResponse = null;
    notifyListeners();
  }

  Future<PayInvoiceResponse?> payInvoice(String invoice) async {
    if (connection != null &&
        connection!.permissions.contains(NwcMethod.PAY_INVOICE.name)) {
      try {
        PayInvoiceResponse response =
            await ndk.nwc.payInvoice(connection!, invoice: invoice);
        if (response.preimage != '') {
          await refreshWallet();
          notifyListeners();
          return response;
        }
      } catch (e) {
        EasyLoading.showError(e.toString(),
            duration: const Duration(seconds: 5));
        Logger.log.e(e);
        return null;
      }
    }
    EasyLoading.showError("missing pubKey and/or relay for connecting",
        duration: const Duration(seconds: 5));
    return null;
  }

  Future<MakeInvoiceResponse?> makeInvoice(int amountSats, String? description,
      String? description_hash, int expiry) async {
    if (connection != null &&
        connection!.permissions.contains(NwcMethod.MAKE_INVOICE.name)) {
      return await ndk.nwc.makeInvoice(connection!, amountSats: amountSats);
    } else {
      EasyLoading.showError("missing pubKey and/or relay for connecting",
          duration: const Duration(seconds: 5));
      return null;
    }
  }
}
