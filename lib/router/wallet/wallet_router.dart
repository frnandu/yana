import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:dart_ndk/nips/nip01/helpers.dart';
import 'package:flutter/material.dart';
import 'package:get_time_ago/get_time_ago.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:yana/main.dart';
import 'package:yana/models/wallet_transaction.dart';
import 'package:yana/provider/nwc_provider.dart';
import 'package:yana/router/wallet/transaction_item_component.dart';
import 'package:yana/utils/base.dart';

import '../../../ui/appbar4stack.dart';
import '../../utils/number_format_util.dart';
import '../../utils/router_path.dart';
import '../../utils/router_util.dart';

class WalletRouter extends StatefulWidget {
  const WalletRouter({super.key});

  @override
  State<StatefulWidget> createState() {
    return _WalletRouter();
  }
}

class _WalletRouter extends State<WalletRouter> {
  TextEditingController nwcInputController = TextEditingController();

  ScrollController scrollController = ScrollController();

  String formatBitcoinNumber(double bitcoin) {
    // Convert the number to a string with 2 decimal places
    String bitcoinString = bitcoin.toStringAsFixed(2);

    // Split the string into parts before and after the decimal point
    List<String> parts = bitcoinString.split('.');

    // Add spaces every three digits before the decimal point
    String formattedIntegerPart = parts[0].splitMapJoin(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), onMatch: (m) => '${m[1]} ', onNonMatch: (n) => n);

    // Combine the formatted integer part and the decimal part with 1 space
    String formattedBitcoin = '$formattedIntegerPart.${parts[1]}';

    return formattedBitcoin;
  }

  @override
  Widget build(BuildContext context) {
    var _nwcProvider = Provider.of<NwcProvider>(context);

    var themeData = Theme.of(context);

    Color? appbarBackgroundColor = Colors.transparent;

    var appBar = Appbar4Stack(
      title: Selector<NwcProvider, bool>(
        builder: (context, isConnected, child) {
          String title = "Connect a Wallet";
          if (isConnected) {
            title = "Nostr Wallet Connect";
          }
          return Container(
            alignment: Alignment.center,
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: "Geist.Mono",
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

    Widget main = Selector<NwcProvider, bool>(
      builder: (context, isConnected, child) {
        List<Widget> list = [];
        if (isConnected) {
          list.add(Selector<NwcProvider, int?>(
            builder: (context, balance, child) {
              if (balance != null) {
                double? fiatAmount = fiatCurrencyRate != null ? ((balance / 100000000) * fiatCurrencyRate!["value"]) : null;

                return Container(
                    margin: const EdgeInsets.only(top: Base.BASE_PADDING * 4, bottom: Base.BASE_PADDING * 2),
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: [
                      Row(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.end, crossAxisAlignment: CrossAxisAlignment.center, children: [
                        const Text("₿", style: TextStyle(color: Color(0xFF7A7D81), fontSize: 30, fontFamily: 'Geist.Mono')),
                        const SizedBox(width: 4),
                        NumberFormatUtil.formatBitcoinAmount(balance / 100000000, TextStyle(color: themeData.focusColor, fontSize: 30, fontFamily: 'Geist.Mono'),
                            const TextStyle(color: Color(0xffD44E7D), fontSize: 30, fontFamily: 'Geist.Mono')),
                        const Text(" sats", style: TextStyle(color: Color(0xffD44E7D), fontSize: 24, fontWeight: FontWeight.w100)),
                      ]),
                      Container(
                          margin: const EdgeInsets.only(top: Base.BASE_PADDING * 2, bottom: Base.BASE_PADDING * 2),
                          child: Text(
                              fiatAmount! < 0.01 ? "< ${fiatCurrencyRate?["unit"]}0.01" : "~${fiatCurrencyRate?["unit"]}${fiatAmount.toStringAsFixed(2)}",
                              style: const TextStyle(color: Color(0xFF7A7D81), fontSize: 16, fontFamily: 'Geist.Mono')))
                    ]));
              }
              return Container();
            },
            selector: (context, _provider) {
              return _provider.getBalance;
            },
          ));
          if (_nwcProvider.canPayInvoice || nwcProvider.canMakeInvoice) {
            list.add(Row(children: [
              _nwcProvider.canMakeInvoice
                  ? Expanded(
                      child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () async {
                            RouterUtil.router(context, RouterPath.WALLET_RECEIVE);
                            //
                            // confettiController.play();
                            // //_nwcProvider.onPayInvoiceResponse(event, onZapped)
                          },
                          child: Container(
                            width: 150,
                            margin: const EdgeInsets.all(Base.BASE_PADDING),
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.all(Radius.circular(10.0)),
                              border: Border.all(
                                width: 1,
                                color: const Color(0xffD44E7D),
                              ),
                            ),
                            child: Container(alignment: Alignment.center, margin: const EdgeInsets.all(Base.BASE_PADDING), child: const Text("↙  Receive")),
                          )))
                  : Container(),
              _nwcProvider.canPayInvoice
                  ? Expanded(
                      child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () async {
                            // TODO choose recipient
                          },
                          child: Container(
                            alignment: Alignment.center,
                            margin: const EdgeInsets.all(Base.BASE_PADDING),
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.all(Radius.circular(10.0)),
                              border: Border.all(
                                width: 1,
                                color: const Color(0xffD44E7D),
                              ),
                            ),
                            child: Container(alignment: Alignment.center, margin: const EdgeInsets.all(Base.BASE_PADDING), child: const Text("↗  Send")),
                            //             size: 25, color: themeData.iconTheme.color)
                          )))
                  : Container()
            ]));
          }

          if (nwcProvider.canListTransaction) {
            list.add(const SizedBox(height: 16));
            list.add(Expanded(
                child: Selector<NwcProvider, List<WalletTransaction>>(builder: (context, transactions, child) {
              return transactions != null && transactions.isNotEmpty
                  ? ListView.builder(
                      itemBuilder: (context, index) {
                        return TransactionItemComponent(transaction: transactions[index]);
                      },
                      itemCount: transactions.length,
                    )
                  : Container();
            }, selector: (context, _provider) {
              return _provider.transactions;
            })));
            // list.add(RefreshIndicator(
            //   onRefresh: () async {
            //     nwcProvider.requestListTransactions();
            //   },
            //   child: Selector<NwcProvider, List<WalletTransaction>>(
            //     builder: (context, transactions, child) {
            //       return transactions!=null && transactions.isNotEmpty ? Column(
            //         children: transactions.take(10).map((t) {
            //           bool outgoing = t.type == "outgoing";
            //           var time = "";
            //           try {
            //             time = t.settled_at!=null?GetTimeAgo.parse(DateTime.fromMillisecondsSinceEpoch(t.settled_at!*1000)):"";
            //             // 2023-12-21T01:36:39.97766341Z
            //           } catch (e) {}
            //           return Row(children: [
            //             Text(outgoing ? ' ↑ ' : ' ↓ ', style: TextStyle(color: outgoing? Colors.red:Colors.green),),
            //             Text(Helpers.isNotBlank(t.description)?t.description!:(outgoing?" Sent ":" Received ")),
            //             Text(" ${outgoing? "-": "+"}${(t.amount / 1000).toInt()} ", style: TextStyle(color: outgoing? Colors.red:Colors.green)),
            //             Text("${time}")
            //           ]);
            //         }).toList(),
            //       ) : Container();
            //     },
            //   selector: (context, _provider) {
            //     return _provider.transactions;
            //   }
            // )));
          }
          list.add(GestureDetector(
              onTap: () {
                RouterUtil.router(context, RouterPath.WALLET_TRANSACTIONS);
              },
              // child:
              // Expanded(
              child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Container(
                    margin: const EdgeInsets.only(top: Base.BASE_PADDING),
                    padding: const EdgeInsets.all(Base.BASE_PADDING),
                    height: 60.0,
                    // decoration: const BoxDecoration(
                    //     gradient: LinearGradient(
                    //         colors: [Color(0xffFFDE6E), Colors.orange]),
                    //     borderRadius: BorderRadius.all(Radius.circular(20.0))),
                    child: const Center(
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('List all transactions >>',
                                  style: TextStyle(color: Colors.white))
                            ])),
                  ))
            // ),
          ));

          // list.add(Text(
          //     "One-tap Zaps will now be sent from this wallet, no confirmation will be asked."));

          // list.add(Container(margin: const EdgeInsets.all(200)));
          list.add(MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () async {
                    nwcInputController.text = "";
                    await nwcProvider.disconnect();
                  },
                  child: Container(
                    margin: EdgeInsets.all(Base.BASE_PADDING),
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(20.0)),
                      border: Border.all(
                        width: 1,
                        color: themeData.hintColor,
                      ),
                    ),
                    child: Container(alignment: Alignment.center, margin: const EdgeInsets.all(Base.BASE_PADDING), child: const Text("Disconnect wallet")),
                  ))));
        } else {
          list.add(GestureDetector(
              onTap: () {
                RouterUtil.router(context, RouterPath.NWC);
              },
              // child:
              // Expanded(
              child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Container(
                    margin: const EdgeInsets.only(top: Base.BASE_PADDING),
                    padding: const EdgeInsets.all(Base.BASE_PADDING),
                    height: 60.0,
                    decoration: const BoxDecoration(
                        gradient: LinearGradient(colors: [Color(0xffFFDE6E), Colors.orange]), borderRadius: BorderRadius.all(Radius.circular(20.0))),
                    child: Center(
                        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Container(margin: const EdgeInsets.only(right: Base.BASE_PADDING), child: Image.asset("assets/imgs/nwc.png")),
                      const Text('Nostr Wallet Connect', style: TextStyle(color: Colors.black))
                    ])),
                  ))
              // ),
              ));
          // list.add(Row(children: [
          //   Expanded(
          //       child: MouseRegion(
          //     cursor: SystemMouseCursors.click,
          //     child: Container(
          //         margin: const EdgeInsets.only(top: Base.BASE_PADDING * 2),
          //         padding: const EdgeInsets.all(Base.BASE_PADDING),
          //         height: 60.0,
          //         decoration: const BoxDecoration(
          //             gradient: LinearGradient(colors: [Color(0xff8bd7f9), Color(0xff174697)]), borderRadius: BorderRadius.all(Radius.circular(20.0))),
          //         child: Center(
          //             child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          //           Container(
          //               margin: const EdgeInsets.only(right: Base.BASE_PADDING),
          //               child: ClipRRect(borderRadius: BorderRadius.circular(5.0), child: Image.asset("assets/imgs/lndhub.png"))),
          //           const Text('LndHub Connect', style: TextStyle(color: Colors.white)),
          //           Text('  (soon)', style: TextStyle(color: themeData.hintColor, fontFamily: "Geist", fontSize: 12))
          //         ]))),
          //   )),
          // ]));
          // list.add(Row(children: [
          //   Expanded(
          //       child: MouseRegion(
          //     cursor: SystemMouseCursors.click,
          //     child: Container(
          //         margin: const EdgeInsets.only(top: Base.BASE_PADDING * 2),
          //         padding: const EdgeInsets.all(Base.BASE_PADDING),
          //         height: 60.0,
          //         decoration: const BoxDecoration(
          //             gradient: LinearGradient(colors: [Color(0xff0f0f0f), Color(0xff0f0f0f)]), borderRadius: BorderRadius.all(Radius.circular(20.0))),
          //         child: Center(
          //             child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          //           Container(
          //               margin: const EdgeInsets.only(right: Base.BASE_PADDING),
          //               child: ClipRRect(borderRadius: BorderRadius.circular(5.0), child: Image.asset("assets/imgs/greenlight.png"))),
          //           const Text('', style: TextStyle(color: Colors.white)),
          //           Text('  (soon)', style: TextStyle(color: themeData.hintColor, fontFamily: "Geist", fontSize: 12))
          //         ]))),
          //   )),
          // ]));

          // TODO Lndhub wallet connect

          // const Text("Wallet Connect URI (NWC)"),
          // Container(
          //   margin: const EdgeInsets.only(left: Base.BASE_PADDING),
          //   child: Image.asset("assets/imgs/alby.png", width: 30, height: 30),
          // ),
          // Container(
          //     margin: const EdgeInsets.only(left: Base.BASE_PADDING),
          //     child: GestureDetector(
          //         behavior: HitTestBehavior.translucent,
          //         onTap: scanNWC,
          //         child: Icon(Icons.qr_code_scanner,
          //             size: 25, color: themeData.iconTheme.color)))
        }
        return Column(
          // mainAxisSize: MainAxisSize.min,
          children: list,
        );
      },
      selector: (context, _provider) {
        return _provider.isConnected;
      },
    );

    var appBarNew = AppBar(
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
        title: const Text("Wallet"));

    return Scaffold(
      appBar: appBarNew,
      backgroundColor: themeData.cardColor,
      body: main
    );

    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: mediaDataCache.size.width,
            height: mediaDataCache.size.height - mediaDataCache.padding.top,
            margin: EdgeInsets.only(top: mediaDataCache.padding.top),
            child: Container(
              color: themeData.cardColor,
              child: Center(
                child:
                    //main
                    Container(width: mediaDataCache.size.width * 0.8, child: main),
              ),
            ),
          ),
          Positioned(
            top: mediaDataCache.padding.top,
            child: Container(
              width: mediaDataCache.size.width,
              child: appBar,
            ),
          ),
        ],
      ),
    );
  }
}
