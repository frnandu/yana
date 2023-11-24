import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yana/main.dart';
import 'package:yana/provider/nwc_provider.dart';
import 'package:yana/utils/base.dart';
import 'package:yana/utils/string_util.dart';

import '../../../i18n/i18n.dart';
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
  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    // nwcProvider.reload();
  }

  @override
  Widget build(BuildContext context) {
    var _nwcProvider = Provider.of<NwcProvider>(context);

    var themeData = Theme.of(context);
    var cardColor = themeData.cardColor;

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
                fontFamily: "Montserrat",
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
          Widget balance = Selector<NwcProvider, int?>(
            builder: (context, balance, child) {
              if (balance != null) {
                return Expanded(
                    child: Container(
                        margin: EdgeInsets.only(left: Base.BASE_PADDING),
                        alignment: Alignment.center,
                        child: Row(children: [
                          const Icon(
                            Icons.currency_bitcoin,
                            color: Colors.orange,
                            size: 40,
                          ),
                          NumberFormatUtil.formatBitcoinAmount(
                              balance / 100000000,
                              TextStyle(
                                  color: themeData.focusColor,
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold),
                              TextStyle(
                                  color: themeData.dividerColor,
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold)),
                          const Text(" sats",
                              style: TextStyle(
                                  fontSize: 30, fontWeight: FontWeight.w100)),
                        ])));
              }
              return Container();
            },
            selector: (context, _provider) {
              return _provider.getBalance;
            },
          );
          list.add(balance);
          list.add(Text(
              "One-tap Zaps will now be sent from this wallet, no confirmation will be asked."));

          // list.add(Row(children: [
          //   Expanded(
          //       child: GestureDetector(
          //           behavior: HitTestBehavior.translucent,
          //           onTap: () async {
          //             // TODO choose recipient
          //           },
          //           child: Container(
          //             width: 150,
          //             margin: const EdgeInsets.all(Base.BASE_PADDING),
          //             decoration: BoxDecoration(
          //               borderRadius:
          //                   const BorderRadius.all(Radius.circular(20.0)),
          //               border: Border.all(
          //                 width: 1,
          //                 color: themeData.hintColor,
          //               ),
          //             ),
          //             child:
          //               Container(
          //                   alignment: Alignment.center,
          //                   margin: const EdgeInsets.all(Base.BASE_PADDING),
          //                   child: const Text("Receive")),
          //           ))),
          //   Expanded(
          //       child: GestureDetector(
          //           behavior: HitTestBehavior.translucent,
          //           onTap: () async {
          //             // TODO choose recipient
          //           },
          //           child: Container(
          //             alignment: Alignment.center,
          //             margin: const EdgeInsets.all(Base.BASE_PADDING),
          //             decoration: BoxDecoration(
          //               borderRadius:
          //                   const BorderRadius.all(Radius.circular(20.0)),
          //               border: Border.all(
          //                 width: 1,
          //                 color: themeData.hintColor,
          //               ),
          //             ),
          //             child: Container(
          //                 alignment: Alignment.center,
          //                 margin: const EdgeInsets.all(Base.BASE_PADDING),
          //                 child: const Text("Send",
          //                     style: TextStyle(fontFamily: 'Monserrat'))),
          //             //             size: 25, color: themeData.iconTheme.color)
          //           )))
          // ]));
          list.add(Container(margin: const EdgeInsets.all(200)));
          list.add(MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () async {
                    controller.text = "";
                    await nwcProvider.disconnect();
                  },
                  child: Container(
                    margin: EdgeInsets.all(Base.BASE_PADDING),
                    decoration: BoxDecoration(
                      borderRadius:
                          const BorderRadius.all(Radius.circular(20.0)),
                      border: Border.all(
                        width: 1,
                        color: themeData.hintColor,
                      ),
                    ),
                    child: Container(
                        alignment: Alignment.center,
                        margin: const EdgeInsets.all(Base.BASE_PADDING),
                        child: const Text("Disconnect wallet")),
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
                        gradient: LinearGradient(
                            colors: [Color(0xffFFDE6E), Colors.orange]),
                        borderRadius: BorderRadius.all(Radius.circular(20.0))),
                    child: Center(
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                          Container(
                              margin: const EdgeInsets.only(
                                  right: Base.BASE_PADDING),
                              child: Image.asset("assets/imgs/nwc.png")),
                          const Text('Nostr Wallet Connect',
                              style: TextStyle(color: Colors.black))
                        ])),
                  ))
              // ),
              ));
          list.add(Row(children: [
            Expanded(
          child: MouseRegion(
          cursor: SystemMouseCursors.click,
              child: Container(
              margin: const EdgeInsets.only(top: Base.BASE_PADDING * 2),
              padding: const EdgeInsets.all(Base.BASE_PADDING),
              height: 60.0,
              decoration: const BoxDecoration(
                  gradient: LinearGradient(
                      colors: [Color(0xff8bd7f9), Color(0xff174697)]),
                  borderRadius: BorderRadius.all(Radius.circular(20.0))),
              child: Center(
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                    Container(
                        margin: const EdgeInsets.only(right: Base.BASE_PADDING),
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(5.0),
                            child: Image.asset("assets/imgs/lndhub.png"))),
                    const Text('LndHub Connect',
                        style: TextStyle(color: Colors.white)),
                    Text('  (soon)',
                        style: TextStyle(
                            color: themeData.hintColor,
                            fontFamily: "Montserrat",
                            fontSize: 12))
                  ]))),
            )),
          ]));
          list.add(Row(children: [
            Expanded(
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Container(
                      margin: const EdgeInsets.only(top: Base.BASE_PADDING * 2),
                      padding: const EdgeInsets.all(Base.BASE_PADDING),
                      height: 60.0,
                      decoration: const BoxDecoration(
                          gradient: LinearGradient(
                              colors: [Color(0xff0f0f0f), Color(0xff0f0f0f)]),
                          borderRadius: BorderRadius.all(Radius.circular(20.0))),
                      child: Center(
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                    margin: const EdgeInsets.only(right: Base.BASE_PADDING),
                                    child: ClipRRect(
                                        borderRadius: BorderRadius.circular(5.0),
                                        child: Image.asset("assets/imgs/greenlight.png"))),
                                const Text('',
                                    style: TextStyle(color: Colors.white)),
                                Text('  (soon)',
                                    style: TextStyle(
                                        color: themeData.hintColor,
                                        fontFamily: "Montserrat",
                                        fontSize: 12))
                              ]))),
                )),
          ]));

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
          mainAxisSize: MainAxisSize.min,
          children: list,
        );
      },
      selector: (context, _provider) {
        return _provider.isConnected;
      },
    );

    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: mediaDataCache.size.width,
            height: mediaDataCache.size.height - mediaDataCache.padding.top,
            margin: EdgeInsets.only(top: mediaDataCache.padding.top),
            child: Container(
              color: cardColor,
              child: Center(
                child:
                    //main
                    Container(
                        width: mediaDataCache.size.width * 0.8, child: main),
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
