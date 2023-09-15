import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yana/main.dart';
import 'package:yana/provider/nwc_provider.dart';
import 'package:yana/utils/base.dart';
import 'package:yana/utils/string_util.dart';

import '../../../i18n/i18n.dart';
import '../../../ui/appbar4stack.dart';
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
    nwcProvider.reload();
    // String? perms = sharedPreferences.getString(DataKey.NWC_PERMISSIONS);
    // if (StringUtil.isNotBlank(perms)) {
    //   permissions = perms!.split(",");
    // }
    //
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   readNwc();
    // });
  }

  // void readNwc() async {
  //   uri = await settingProvider.getNwc();
  //   if (StringUtil.isNotBlank(uri)) {
  //     await getBalance();
  //     setState(() {
  //       controller.text = uri!;
  //     });
  //   }
  //   controller.addListener(() async {
  //     if (uri == null || uri != controller.text) {
  //       uri = controller.text;
  //       await settingProvider.setNwc(uri!);
  //     }
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    var _nwcProvider = Provider.of<NwcProvider>(context);

    var s = I18n.of(context);
    var themeData = Theme.of(context);
    var cardColor = themeData.cardColor;
    var mainColor = themeData.primaryColor;

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
              // TODO format nicely BTC 0.0011000 sats
              return balance != null
                  ? Text("$balance sats",
                      style: const TextStyle(
                          fontSize: 40, fontWeight: FontWeight.bold))
                  : Container();
            },
            selector: (context, _provider) {
              return _provider.getBalance;
            },
          );
          list.add(balance);
          list.add(Container(margin: const EdgeInsets.all(200)));
          list.add(GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () async {
                controller.text = "";
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
                  child: Container(
                    alignment: Alignment.center,
                        margin: const EdgeInsets.all(Base.BASE_PADDING),
                        child: const Text("Disconnect wallet")),
                  )));

          // list.add(
          //   InkWell(
          //     onTap: () async {
          //       controller.text = "";
          //       await nwcProvider.disconnect();
          //     },
          //     child: Container(
          //       margin: const EdgeInsets.all(Base.BASE_PADDING),
          //       height: 36,
          //       color: mainColor,
          //       alignment: Alignment.center,
          //       child: const Text(
          //         "Disconnect wallet",
          //         style: TextStyle(
          //           fontFamily: "Montserrat",
          //           color: Colors.white,
          //           fontSize: 16,
          //           fontWeight: FontWeight.bold,
          //         ),
          //       ),
          //     ),
          //   ),
          // );
        } else {
          list.add(
            GestureDetector(
                onTap: () {
                  RouterUtil.router(context, RouterPath.NWC);
                },
                child: Expanded(
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
                            margin:
                                const EdgeInsets.only(right: Base.BASE_PADDING),
                            child: Image.asset("assets/imgs/nwc.png")),
                        const Text('Nostr Wallet Connect',
                            style: TextStyle(color: Colors.black))
                      ])),
                ))),
          );
          list.add(Row(children: [
            Expanded(
                child: Container(
              margin: const EdgeInsets.only(top: Base.BASE_PADDING * 2),
              padding: const EdgeInsets.all(Base.BASE_PADDING),
              height: 60.0,
              decoration: const BoxDecoration(
                  gradient: LinearGradient(
                      colors: [Color(0xff800000), Color(0xff550000)]),
                  borderRadius: BorderRadius.all(Radius.circular(20.0))),
              child: Center(
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                    Container(
                        margin: const EdgeInsets.only(right: Base.BASE_PADDING),
                        child: Image.asset("assets/imgs/mutiny.png")),
                    Text('Mutiny Wallet Connect',
                        style: TextStyle(color: Colors.white)),
                    Text('  (soon)',
                        style: TextStyle(
                            color: themeData.hintColor,
                            fontFamily: "Montserrat",
                            fontSize: 12))
                  ])),
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

          // list.add(Row(
          //   children: [
          //     Expanded(
          //         child: TextField(
          //       controller: controller,
          //       decoration:
          //           const InputDecoration(hintText: "nostr+walletconnect:"),
          //     )),
          //   ],
          // ));
          //
          // list.add(Container(
          //   margin: const EdgeInsets.all(Base.BASE_PADDING),
          //   child: InkWell(
          //     onTap: () async {
          //       await _nwcProvider.connect(controller.text);
          //     },
          //     child: Container(
          //       height: 36,
          //       color: mainColor,
          //       alignment: Alignment.center,
          //       child: const Text(
          //         "Connect",
          //         style: TextStyle(
          //           fontFamily: "Montserrat",
          //           color: Colors.white,
          //           fontSize: 16,
          //           fontWeight: FontWeight.bold,
          //         ),
          //       ),
          //     ),
          //   ),
          // ));
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

    // if (false) {
    // if (StringUtil.isNotBlank(uri) && permissions.isNotEmpty) {
    // permissions
    //     .where((element) => element != NWC_GET_BALANCE_PERMISSION)
    //     .forEach((permission) {
    //   list.add(Container(
    //       margin: const EdgeInsets.all(Base.BASE_PADDING),
    //       child: Text(permission)));
    // });
    // if (balance != null) {
    //   list.add(Container(
    //       margin: const EdgeInsets.all(Base.BASE_PADDING),
    //       child: Text("${balance!} sats", style: balanceTextStyle)));
    //   if (maxAmount != null && maxAmount! > 0) {
    //     list.add(Container(
    //         margin: const EdgeInsets.all(Base.BASE_PADDING),
    //         child: Text("Max amount: ${maxAmount!} sats")));
    //   }
    // } else if (permissions.contains(NWC_GET_BALANCE_PERMISSION)) {
    //   list.add(
    //     InkWell(
    //       onTap: _nwcProvider.requestBalance,
    //       child: Container(
    //         height: 36,
    //         color: mainColor,
    //         margin: const EdgeInsets.all(Base.BASE_PADDING),
    //         alignment: Alignment.center,
    //         child: const Text(
    //           "Get balance",
    //           style: TextStyle(
    //             fontFamily: "Montserrat",
    //             color: Colors.white,
    //             fontSize: 16,
    //             fontWeight: FontWeight.bold,
    //           ),
    //         ),
    //       ),
    //     ),
    //   );
    // }
    // if (permissions.contains(NWC_GET_BALANCE_PERMISSION)) {
    //   list.add(
    //     InkWell(
    //       onTap: _nwcProvider.payInvoice,
    //       child: Container(
    //         height: 36,
    //         color: mainColor,
    //         margin: const EdgeInsets.all(Base.BASE_PADDING),
    //         alignment: Alignment.center,
    //         child: const Text(
    //           "Pay invoice",
    //           style: TextStyle(
    //             fontFamily: "Montserrat",
    //             color: Colors.white,
    //             fontSize: 16,
    //             fontWeight: FontWeight.bold,
    //           ),
    //         ),
    //       ),
    //     ),
    //   );
    // }

    // list.add(
    //   InkWell(
    //     onTap: _nwcProvider.disconnect,
    //     child: Container(
    //       margin: const EdgeInsets.all(Base.BASE_PADDING),
    //       height: 36,
    //       color: mainColor,
    //       alignment: Alignment.center,
    //       child: const Text(
    //         "Disconnect",
    //         style: TextStyle(
    //           fontFamily: "Montserrat",
    //           color: Colors.white,
    //           fontSize: 16,
    //           fontWeight: FontWeight.bold,
    //         ),
    //       ),
    //     ),
    //   ),
    // );
    // } else {
    //   list.add(Row(children: [
    //     const Text("Wallet Connect URI (NWC)"),
    //     Container(
    //       margin: const EdgeInsets.only(left: Base.BASE_PADDING),
    //       child: Image.asset("assets/imgs/alby.png", width: 30, height: 30),
    //     ),
    //     Container(
    //         margin: const EdgeInsets.only(left: Base.BASE_PADDING),
    //         child: GestureDetector(
    //             behavior: HitTestBehavior.translucent,
    //             onTap: scanNWC,
    //             child: Icon(Icons.qr_code_scanner,
    //                 size: 25, color: themeData.iconTheme.color)))
    //   ]));
    //
    //   list.add(Row(
    //     children: [
    //       Expanded(
    //           child: TextField(
    //         controller: controller,
    //         decoration: const InputDecoration(hintText: "nostr+walletconnect:"),
    //       )),
    //     ],
    //   ));
    //
    //   list.add(Container(
    //     margin: const EdgeInsets.all(Base.BASE_PADDING),
    //     child: InkWell(
    //       onTap: () async {
    //         await _nwcProvider.connect(controller.text);
    //       },
    //       child: Container(
    //         height: 36,
    //         color: mainColor,
    //         alignment: Alignment.center,
    //         child: const Text(
    //           "Connect",
    //           style: TextStyle(
    //             fontFamily: "Montserrat",
    //             color: Colors.white,
    //             fontSize: 16,
    //             fontWeight: FontWeight.bold,
    //           ),
    //         ),
    //       ),
    //     ),
    //   ));
    // }

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
                child: Container(
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
