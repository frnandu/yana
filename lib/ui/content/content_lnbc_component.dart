import 'package:flutter/material.dart';
import 'package:yana/utils/lightning_util.dart';

import '../../i18n/i18n.dart';
import '../../main.dart';
import '../../nostr/nip57/zap_num_util.dart';
import '../../utils/base.dart';

class ContentLnbcComponent extends StatelessWidget {
  final String lnbc;

  const ContentLnbcComponent({super.key, required this.lnbc});

  @override
  Widget build(BuildContext context) {
    var s = I18n.of(context);
    var themeData = Theme.of(context);
    var hintColor = themeData.hintColor;
    var cardColor = themeData.cardColor;
    double largeFontSize = 20;

    var numStr = s.Any;
    var num = ZapNumUtil.getNumFromStr(lnbc);
    if (num > 0) {
      numStr = num.toString();
    }

    return Container(
      margin: const EdgeInsets.all(Base.BASE_PADDING),
      padding: const EdgeInsets.all(Base.BASE_PADDING * 2),
      decoration: BoxDecoration(
        color: cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            offset: const Offset(0, 0),
            blurRadius: 10,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            alignment: Alignment.topLeft,
            padding: const EdgeInsets.only(bottom: Base.BASE_PADDING),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  width: 1,
                  color: hintColor,
                ),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  child: const Icon(
                    Icons.bolt,
                    color: Colors.orange,
                  ),
                ),
                Text(s.Lightning_Invoice),
              ],
            ),
          ),
          // Container(
          //   alignment: Alignment.bottomLeft,
          //   padding: EdgeInsets.only(top: Base.BASE_PADDING),
          //   child: Text("Wallet of Satoshi"),
          // ),
          Container(
            margin: const EdgeInsets.only(
              top: Base.BASE_PADDING,
              bottom: Base.BASE_PADDING,
            ),
            child: Row(
              children: [
                Container(
                  margin: EdgeInsets.only(right: Base.BASE_PADDING_HALF),
                  child: Text(
                    numStr,
                    style: TextStyle(
                      fontSize: largeFontSize,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Text(
                  "sats",
                  style: TextStyle(
                    fontSize: largeFontSize,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: double.maxFinite,
            child: InkWell(
              onTap: () async {
                // call to pay
                bool sendWithWallet = false;
                if (await nwcProvider.isConnected) {
                  int? balance = await nwcProvider.getBalance;
                  if (balance!=null && balance > 10) {
                    await nwcProvider.payInvoice(lnbc);
                    sendWithWallet = true;
                  }
                }
                LightningUtil.goToPay(context, lnbc);
              },
              child: Container(
                color: Colors.black,
                height: 50,
                alignment: Alignment.center,
                child: Text(
                  s.Pay,
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
