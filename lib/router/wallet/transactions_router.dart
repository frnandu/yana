import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ndk/domain_layer/usecases/nwc/responses/list_transactions_response.dart';
import 'package:provider/provider.dart';
import 'package:yana/main.dart';
import 'package:yana/provider/nwc_provider.dart';
import 'package:yana/router/wallet/transaction_item_component.dart';

import '../../../ui/appbar4stack.dart';

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
    var appBar = AppBar(
        leading: GestureDetector(
          onTap: () {
            context.pop();
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
        title: const Text("Transactions"));
    Widget main = RefreshIndicator(
        onRefresh: () async {
          ListTransactionsResponse? response =
              await nwcProvider?.listTransactions(limit: 20, unpaid: true);
          if (response != null) {
            _nwcProvider.listTransactionsResponse = response;
          }
        },
        child: Selector<NwcProvider, List<TransactionResult>?>(
            builder: (context, transactions, child) {
          if (transactions == null || transactions.isEmpty) {
            return Container();
          }

          var filteredTransactions = transactions
              .where((t) =>
                  t.type == "outgoing" ||
                  (t.type == "incoming" && t.settledAt != null))
              .toList();

          return filteredTransactions.isNotEmpty
              ? ListView.builder(
                  itemBuilder: (context, index) {
                    final transaction = filteredTransactions[index];
                    return TransactionItemComponent(
                      transaction: transaction,
                    );
                  },
                  itemCount: filteredTransactions.length,
                )
              : Container();
        }, selector: (context, _provider) {
          return _provider.transactions;
        }));

    return Scaffold(
      appBar: appBar,
      body: main,
    );
  }
}
