import 'package:ndk/domain_layer/entities/read_write.dart';
import 'package:ndk/domain_layer/entities/relay_set.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:yana/nostr/nip47/nwc_notification.dart';

import '../../i18n/i18n.dart';
import '../../main.dart';
import '../../utils/lightning_util.dart';
import '../../utils/string_util.dart';
import 'zap.dart';

class ZapAction {
  static Future<void> handleZap(BuildContext context, int sats, String pubkey,
      {String? eventId, String? pollOption, String? comment, required Function(NwcNotification?) onZapped}) async {
    var s = I18n.of(context);
    // EasyLoading.sho.showLoading();
    var invoiceCode = await _doGenInvoiceCode(context, sats, pubkey,
        eventId: eventId, pollOption: pollOption, comment: comment);

    if (StringUtil.isBlank(invoiceCode)) {
      EasyLoading.showError(s.Gen_invoice_code_error, duration: const Duration(seconds: 5));
      return;
    }
    bool sendWithWallet = false;
    if (nwcProvider.isConnected) {
      int? balance = await nwcProvider.getBalance;
      if (balance!=null && balance > 10) {
        await nwcProvider.payInvoice(invoiceCode!, eventId, onZapped);
        sendWithWallet = true;
      }
    }
    if (!sendWithWallet) {
      await LightningUtil.goToPay(context, invoiceCode!);
//      await eventReactionsProvider.subscription(eventId!, null, EventKind.ZAP_RECEIPT);
      onZapped(null);
    }
  }

  static Future<String?> genInvoiceCode(
      BuildContext context, int sats, String pubkey,
      {String? eventId, String? pollOption, String? comment}) async {
    try {
      return await _doGenInvoiceCode(context, sats, pubkey,
          eventId: eventId, pollOption: pollOption, comment: comment);
    } catch (e) {
      print(e);
    }
  }

  static Future<String?> _doGenInvoiceCode(
      BuildContext context, int sats, String pubkey,
      {String? eventId, String? pollOption, String? comment}) async {
    var s = I18n.of(context);
    var metadata = await metadataProvider.getMetadata(pubkey);
    if (metadata == null) {
      EasyLoading.show(status: s.Metadata_can_not_be_found);
      return null;
    }

    // lud06 like: LNURL1DP68GURN8GHJ7MRW9E6XJURN9UH8WETVDSKKKMN0WAHZ7MRWW4EXCUP0XPURJCEKXVERVDEJXCMKYDFHV43KX2HK8GT
    // lud16 like: pavol@rusnak.io
    // but some people set lud16 to lud06
    String? lnurl = metadata.lud06;
    String? lud16Link;

    if (StringUtil.isBlank(lnurl)) {
      if (StringUtil.isNotBlank(metadata.lud16)) {
        lnurl = Zap.getLnurlFromLud16(metadata.lud16!);
      }
    }
    if (StringUtil.isBlank(lnurl)) {
      EasyLoading.show(status: "Lnurl ${s.not_found}");
      return null;
    }
    // check if user set wrong
    if (lnurl!.contains("@")) {
      lnurl = Zap.getLnurlFromLud16(metadata.lud16!);
    }

    if (StringUtil.isBlank(lud16Link)) {
      if (StringUtil.isNotBlank(metadata.lud16)) {
        lud16Link = Zap.getLud16LinkFromLud16(metadata.lud16!);
      }
    }
    if (StringUtil.isBlank(lud16Link)) {
      if (StringUtil.isNotBlank(metadata.lud06)) {
        lud16Link = Zap.decodeLud06Link(metadata.lud06!);
      }
    }

    Set<String> relays = {};
    relays.addAll(myOutboxRelaySet!.urls.toList());
    if (settingProvider.inboxForReactions == 1) {
      RelaySet inboxRelaySet = await ndk.relaySets
          .calculateRelaySet(
          name: "replyInboxRelaySet",
          ownerPubKey: loggedUserSigner!.getPublicKey(),
          pubKeys: [pubkey],
          direction: RelayDirection.inbox,
          relayMinCountPerPubKey: settingProvider
              .broadcastToInboxMaxCount);
      relays.addAll(inboxRelaySet.urls.toSet());
      relays.removeWhere((element) => ndk.relays.globalState.blockedRelays.contains(element));
    }

    return await Zap.getInvoiceCode(
      lud16Link: lud16Link!,
      sats: sats,
      recipientPubkey: pubkey,
      relays: relays,
      eventId: eventId,
      pollOption: pollOption,
      comment: comment,
    );
  }
}
