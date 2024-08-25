import 'package:ndk/shared/nips/nip01/helpers.dart';
import 'package:flutter/material.dart';
import 'package:get_time_ago/get_time_ago.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:yana/main.dart';
import 'package:yana/models/wallet_transaction.dart';
import 'package:yana/provider/nwc_provider.dart';

import '../../utils/base.dart';

class TransactionItemComponent extends StatefulWidget {
  final WalletTransaction transaction;

  const TransactionItemComponent({super.key, required this.transaction});

  @override
  State<StatefulWidget> createState() {
    return _TransactionItemComponent();
  }
}

final formatter = NumberFormat('#,###');

class _TransactionItemComponent extends State<TransactionItemComponent> {
  TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var _nwcProvider = Provider.of<NwcProvider>(context);
    var themeData = Theme.of(context);

    bool outgoing = widget.transaction.type == "outgoing";
    var time = "";
    try {
      time = widget.transaction.settled_at != null ? GetTimeAgo.parse(DateTime.fromMillisecondsSinceEpoch(widget.transaction.settled_at! * 1000), pattern: "dd.MM.yyyy") : "";
    } catch (e) {}
    double? fiatAmount = fiatCurrencyRate != null ? ((widget.transaction.amount / 100000000000) * fiatCurrencyRate!["value"] * 100 ).truncateToDouble() / 100 : null;
    return Container(
        margin: const EdgeInsets.only(left: Base.BASE_PADDING, right: Base.BASE_PADDING, top: Base.BASE_PADDING),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: ShapeDecoration(
          color: themeData.cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              // margin: const EdgeInsets.only(right: Base.BASE_PADDING),
              // width: 32,
              // height: 32,
              child:  Text(
                outgoing ?"↗":"↙",
                style: TextStyle(
                  color: outgoing ? const Color(0xffD44E7D) : const Color(0xFF47A66D),
                  fontSize: 32,
                  fontWeight: FontWeight.w400,
                ),
              )
              // decoration: ShapeDecoration(
              //   image: const DecorationImage(
              //     image: NetworkImage("https://via.placeholder.com/32x32"),
              //     fit: BoxFit.fill,
              //   ),
              //   shape: RoundedRectangleBorder(
              //     borderRadius: BorderRadius.circular(480),
              //   ),
              // ),
            ),
            const SizedBox(width: 16),
            Expanded(
                child: Column(
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            Helpers.isNotBlank(widget.transaction.description) ? widget.transaction.description! : (outgoing ? "Sent " : "Received "),
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              // color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              overflow: TextOverflow.ellipsis,
                              // height: 0.12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      alignment: Alignment.bottomLeft,
                      child: Text(time,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF7A7D81),
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            // height: 0.11,
                          )),
                    )
                  ],
                )),
            const SizedBox(width: 8),
            Container(
                child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,

              children: [
                Row(children: [
                  Text(
                    '${outgoing ? "-" : "+"}${formatter.format(widget.transaction.amount  ~/ 1000).replaceAll(',', ' ')}',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: outgoing ? const Color(0xFFE26842) : const Color(0xFF47A66D),
                      fontSize: 14,
                      fontFamily: 'Geist.Mono',
                      fontWeight: FontWeight.w400,
                      // height: 0.12,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'sats',
                    style: TextStyle(
                      color: Color(0xFF7A7D81),
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      height: 0.12,
                    ),
                  ),
                ]),
                Container(
                  width:100,
                  alignment: Alignment.bottomRight,
                  child: Text(
                    fiatAmount==null? "" : fiatAmount < 0.01 ? "< 0.01 ${fiatCurrencyRate?["unit"]}" : "~${fiatAmount.toStringAsFixed(2)} ${fiatCurrencyRate?["unit"]}",
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      color: Color(0xFF7A7D81),
                      fontSize: 12,
                      fontFamily: 'Geist.Mono',
                      fontWeight: FontWeight.w400,
                      // height: 0.11,
                    ),
                  ),
                )
              ],
            ))
          ],
        ));
  }
}
