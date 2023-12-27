import 'package:dart_ndk/nips/nip01/helpers.dart';
import 'package:flutter/material.dart';
import 'package:get_time_ago/get_time_ago.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:yana/main.dart';
import 'package:yana/models/wallet_transaction.dart';
import 'package:yana/provider/nwc_provider.dart';
import 'package:yana/utils/base.dart';

import '../../../ui/appbar4stack.dart';
import '../../utils/number_format_util.dart';
import '../../utils/router_path.dart';
import '../../utils/router_util.dart';

class TransactionsRouter extends StatefulWidget {
  const TransactionsRouter({super.key});

  @override
  State<StatefulWidget> createState() {
    return _TransactionsRouter();
  }
}

class _TransactionsRouter extends State<TransactionsRouter> {
  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    // nwcProvider.reload();
  }
  ScrollController scrollController = ScrollController();
  // scrollController.addListener(() {
  // widget.scrollCallback.call(scrollController.position.userScrollDirection);
  // });

  @override
  Widget build(BuildContext context) {
    var _nwcProvider = Provider.of<NwcProvider>(context);

    var themeData = Theme.of(context);
    var cardColor = themeData.cardColor;

    Color? appbarBackgroundColor = Colors.transparent;

    var oldAppBar = Appbar4Stack(
      title: Selector<NwcProvider, bool>(
        builder: (context, isConnected, child) {
          String title = "Transactions";
          return Container(
            alignment: Alignment.center,
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: "Geist",
                fontSize: 20,
              ),
            ),
          );
        },
        selector: (context, _provider) {
          return _provider.isConnected;
        },
      ),
      backgroundColor: appbarBackgroundColor,
    );
    var appBar =
    AppBar(
      leading: GestureDetector(
        onTap: () {
          RouterUtil.back(context);
        },
        child: Icon(
          Icons.arrow_back_ios,
          color: themeData.appBarTheme.titleTextStyle!.color,
        ),
      ),
      // actions: [
      //   GestureDetector(
      //     onTap: addToCommunity,
      //     child: Container(
      //       margin: const EdgeInsets.only(
      //         left: Base.BASE_PADDING,
      //         right: Base.BASE_PADDING,
      //       ),
      //       child: Icon(
      //         Icons.add,
      //         color: themeData.appBarTheme.titleTextStyle!.color,
      //       ),
      //     ),
      //   )
      // ],
      title: const Text("Transactions")
    );
    Widget main =
      RefreshIndicator(
              onRefresh: () async {
                nwcProvider.requestListTransactions();
              },
              child: Selector<NwcProvider, List<WalletTransaction>>(
                builder: (context, transactions, child) {
                  return transactions!=null && transactions.isNotEmpty ? ListView.builder(
                    itemBuilder: (context, index) {
                      WalletTransaction t = transactions[index];
                      bool outgoing = t.type == "outgoing";
                      var time = "";
                      try {
                        time = t.settled_at!=null?GetTimeAgo.parse(
                            DateFormat("yyyy-MM-ddTHH:mm:ss.SSSSSSSSZ").parseUtc(t.settled_at!)):"";
                        // 2023-12-21T01:36:39.97766341Z
                      } catch (e) {}
                      return Row(children: [
                        Text(outgoing ? ' ↑ ' : ' ↓ ', style: TextStyle(color: outgoing? Colors.red:Colors.green),),
                        Text(Helpers.isNotBlank(t.description)?t.description!:(outgoing?" Sent ":" Received ")),
                        Text(" ${outgoing? "-": "+"}${(t.amount / 1000).toInt()} ", style: TextStyle(color: outgoing? Colors.red:Colors.green)),
                        Text("${time}")
                      ]);
                    },
                    itemCount: transactions.length,
                  ) : Container();
                },
              selector: (context, _provider) {
                return _provider.transactions;
              }
            ));

    return Scaffold(
      appBar: appBar,
      body: main,
    );
  }
}
