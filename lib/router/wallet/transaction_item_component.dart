import 'package:dart_ndk/nips/nip01/helpers.dart';
import 'package:flutter/material.dart';
import 'package:get_time_ago/get_time_ago.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:yana/models/wallet_transaction.dart';
import 'package:yana/provider/nwc_provider.dart';

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
    return Row(children: [
      Text(outgoing ? ' ↑ ' : ' ↓ ', style: TextStyle(color: outgoing? Colors.red:Colors.green),),
      Text(Helpers.isNotBlank(widget.transaction.description)?widget.transaction.description!:(outgoing?" Sent ":" Received ")),
      Text(" ${outgoing? "-": "+"}${(widget.transaction.amount / 1000).toInt()} ", style: TextStyle(color: outgoing? Colors.red:Colors.green)),
      Text(time)]);
  }
}

