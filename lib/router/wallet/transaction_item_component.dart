import 'package:dart_ndk/nips/nip01/helpers.dart';
import 'package:flutter/material.dart';
import 'package:get_time_ago/get_time_ago.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
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

class _TransactionItemComponent extends State<TransactionItemComponent> {
  TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var _nwcProvider = Provider.of<NwcProvider>(context);

    bool outgoing = widget.transaction.type == "outgoing";
    var time = "";
    try {
      time = widget.transaction.settled_at!=null?GetTimeAgo.parse(DateTime.fromMillisecondsSinceEpoch(widget.transaction.settled_at!*1000)):"";
      // 2023-12-21T01:36:39.97766341Z
    } catch (e) {}
    return Container(
      margin: const EdgeInsets.only(left: Base.BASE_PADDING, right: Base.BASE_PADDING, top: Base.BASE_PADDING),
      // width: 342,
      // height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: ShapeDecoration(
        color: Color(0xFF131313),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Container(
              height: 40,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: ShapeDecoration(
                      image: DecorationImage(
                        image: NetworkImage("https://via.placeholder.com/32x32"),
                        fit: BoxFit.fill,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(480),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        // width: 228,
                        child: Text(
                          Helpers.isNotBlank(widget.transaction.description)?widget.transaction.description!:(outgoing?" Sent ":" Received "),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontFamily: 'Geist',
                            fontWeight: FontWeight.w400,
                            // height: 0.12,
                          ),
                        ),
                      ),
                      SizedBox(
                        // width: 228,
                        child: Text(time,
                          style: const TextStyle(
                            color: Color(0xFF7A7D81),
                            fontSize: 12,
                            fontFamily: 'Geist',
                            fontWeight: FontWeight.w400,
                            // height: 0.11,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Container(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 58,
                        height: 22,
                        child: Text(
                          '${outgoing? "-": "+"}${(widget.transaction.amount / 1000).toInt()} ',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            color: outgoing? const Color(0xFFE26842):const Color(0xFF47A66D),
                            fontSize: 14,
                            fontFamily: 'Geist',
                            fontWeight: FontWeight.w400,
                            height: 0.12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'sats',
                        style: TextStyle(
                          color: Color(0xFF7A7D81),
                          fontSize: 14,
                          fontFamily: 'Geist',
                          fontWeight: FontWeight.w400,
                          height: 0.12,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 90,
                  child: Text(
                    '\$0.11',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: Color(0xFF7A7D81),
                      fontSize: 12,
                      fontFamily: 'Geist',
                      fontWeight: FontWeight.w400,
                      height: 0.11,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
    // return Row(children: [
    //   Text(outgoing ? ' ↑ ' : ' ↓ ', style: TextStyle(color: outgoing? Colors.red:Colors.green),),
    //   Text(Helpers.isNotBlank(widget.transaction.description)?widget.transaction.description!:(outgoing?" Sent ":" Received ")),
    //   Text(" ${outgoing? "-": "+"}${(widget.transaction.amount / 1000).toInt()} ", style: TextStyle(color: outgoing? Colors.red:Colors.green)),
    //   Text(time)]);
  }
}



