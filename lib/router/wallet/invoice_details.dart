import 'dart:convert';
import 'dart:io';

import 'package:android_intent_plus/android_intent.dart';
import 'package:bech32/bech32.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ndk/domain_layer/entities/metadata.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yana/main.dart';
import 'package:yana/nostr/nip47/nwc_notification.dart';
import 'package:yana/provider/nwc_provider.dart';
import 'package:yana/utils/router_path.dart';
import 'package:yana/utils/string_util.dart';

import '../../nostr/nip19/nip19.dart';
import '../../ui/button.dart';
import '../../ui/user_pic_component.dart';
import '../../utils/router_util.dart';

class WalletReceiveRouter extends StatefulWidget {
  const WalletReceiveRouter({super.key});

  @override
  State<StatefulWidget> createState() {
    return _WalletReceiveRouter();
  }
}

class _WalletReceiveRouter extends State<WalletReceiveRouter> {
  late ConfettiController confettiController;
  String? payingInvoice;
  NwcNotification? paid;
  static Bech32Codec bech32Codec = const Bech32Codec();

  Metadata? metadata;

  @override
  void initState() {
    super.initState();
    metadata = metadataProvider.getMetadata(loggedUserSigner!.getPublicKey());
    confettiController =
        ConfettiController(duration: const Duration(seconds: 2));
    nwcProvider.paymentReceivedCallback = (nwcNotification) {
      setState(() {
        paid = nwcNotification;
      });
      confettiController.play();
    };
  }

  @override
  void dispose() {
    nwcProvider.paymentReceivedCallback = null;
    confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var _nwcProvider = Provider.of<NwcProvider>(context);

    var themeData = Theme.of(context);
    var cardColor = themeData.cardColor;
    var hintColor = themeData.cardColor;

    var appBarNew = AppBar(
      toolbarHeight: 70,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      backgroundColor: themeData.appBarTheme.foregroundColor,
      leading: GestureDetector(
          onTap: () {
            RouterUtil.back(context);
          },
          child: Container(
            margin: const EdgeInsets.only(left: 10),
            child: Icon(
              Icons.arrow_back_ios,
              color: themeData.hintColor,
            ),
          )),
      title: const Text("Receive",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: "Geist.Mono",
            fontSize: 20,
          )),
      actions: [barOptions()],
    );

    List<Widget> list = [];
    if (paid == null) {
      if (metadata != null && StringUtil.isNotBlank(metadata!.lud16)) {
        list.add(Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.black,
            ),
            child: PrettyQrView.data(
                data: metadata!.lud16!,
                decoration: const PrettyQrDecoration(
                  background: Colors.black,
                  shape:
                      PrettyQrSmoothSymbol(color: Colors.white, roundFactor: 1),
                  image: PrettyQrDecorationImage(
                    scale: 0.3,
                    image: AssetImage('assets/imgs/logo/logo-new.png'),
                  ),
                ))));
        list.add(const SizedBox(height: 10));
        list.add(UserPicComponent(
          pubkey: loggedUserSigner!.getPublicKey(),
          width: 64,
        ));
        list.add(Text(metadata!.getName(),
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontFamily: "Geist.Mono",
              fontSize: 20,
            )));
        List<String> lnAddressSplit = metadata!.lud16!.split("@");
        list.add(Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: lnAddressSplit.first,
                style: const TextStyle(
                  fontSize: 14,
                  fontFamily: 'Geist.Mono',
                  fontWeight: FontWeight.w400,
                ),
              ),
              TextSpan(
                text: "@${lnAddressSplit.last}",
                style: TextStyle(
                  color: themeData.disabledColor,
                  fontSize: 14,
                  fontFamily: 'Geist.Mono',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ));
        list.add(const SizedBox(height: 10));
        list.add(
          Row(children: [
            Expanded(
                child: Button(
                    height: 50,
                    before: const Icon(Icons.copy, color: Colors.white),
                    text: "Copy Address",
                    onTap: () async {
                      _doCopy(metadata!.lud16!);
                    }))
          ]),
        );
        list.add(const SizedBox(height: 15));
        list.add(Row(children: [
          Expanded(
              child: Button(
                  before: const Icon(Icons.ios_share),
                  height: 50,
                  text: "Share",
                  fill: false,
                  onTap: () async {
                    final lnurl = bech32Codec.encode(Bech32(
                        'LNURL1',
                        Nip19.convertBits(
                            utf8.encode(
                                "https://${lnAddressSplit.last}/.well-known/lnurlp/${lnAddressSplit.first}"),
                            8,
                            5,
                            true)));
                    _doPay("lightning:$lnurl");
                  }))
        ]));
        list.add(const SizedBox(height: 15));
        list.add(Button(
            before: Icon(Icons.receipt_long_outlined,
                color: themeData.disabledColor),
            border: false,
            fill: false,
            fontColor: themeData.disabledColor,
            text: "Payment Invoice",
            onTap: () async {
              RouterUtil.router(context, RouterPath.WALLET_RECEIVE_INVOICE);
            }));
      }
      // TODO
      // no lud16 set, go directly to create invoice
    } else {
      double? fiatAmount = fiatCurrencyRate != null
          ? ((paid!.amount / 100000000000) * fiatCurrencyRate!["value"])
          : null;
      // int feesPaid = (paid!.feesPaid / 1000).round();
      int amount = (paid!.amount / 1000).round();

      list.add(
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle,
                color: Color(0xff47A66D),
                size: 100.0,
              ),
              const SizedBox(height: 20.0),
              const Text(
                'Payment Received',
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10.0),
              RichText(
                text: TextSpan(
                  children: <TextSpan>[
                    TextSpan(
                      text: "+$amount",
                      style: const TextStyle(
                          fontSize: 28.0, color: Color(0xff47A66D)),
                    ),
                    TextSpan(
                      text: ' sats',
                      style: TextStyle(fontSize: 24.0, color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
              // Row(
              //   children: [
              //     Text(
              //       '+$amount',
              //       style: const TextStyle(
              //           fontSize: 28.0, color: Color(0xff47A66D)),
              //     ),
              //     const SizedBox(
              //       width: 5,
              //     ),
              //     Text(
              //       'sats',
              //       style: TextStyle(fontSize: 24.0, color: Colors.grey[700]),
              //     ),
              //   ],
              // ),
              const SizedBox(height: 10.0),
              Text(
                fiatAmount! < 0.01
                    ? "< ${fiatCurrencyRate?["unit"]}0.01"
                    : "~${fiatCurrencyRate?["unit"]}${fiatAmount.toStringAsFixed(2)}",
                style: const TextStyle(
                  fontSize: 22.0,
                ),
              ),
              StringUtil.isNotBlank(paid!.description)
                  ? const SizedBox(height: 10.0)
                  : Container(),
              StringUtil.isNotBlank(paid!.description)
                  ? Text(
                      '${paid!.description}',
                      style: TextStyle(
                        fontSize: 20.0,
                        color: Colors.grey[700],
                      ),
                    )
                  : Container(),
            ],
          ),
        ),
      );
      list.add(const SizedBox(height: 60,));
      list.add(Button(
        text: "Close",
        fill: false,
        border: true,
        width: 300,
        onTap: () {
          RouterUtil.back(context);
        },
      ));
      list.add(const SizedBox(height: 20,));
      list.add(Button(
        text: "View Details",
        fill: false,
        fontColor: themeData.disabledColor,
        border: false,
        width: 300,
        onTap: () {
        },
      ));
    }
    return Scaffold(
      backgroundColor: themeData.cardColor,
      appBar: appBarNew,
      body: Stack(
        children: [
          SizedBox(
            width: mediaDataCache.size.width,
            height: mediaDataCache.size.height - mediaDataCache.padding.top,
            // margin: EdgeInsets.only(top: mediaDataCache.padding.top),
            child: Container(
              color: cardColor,
              child: Center(
                child: SizedBox(
                    width: mediaDataCache.size.width * 0.85,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: list,
                    )),
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: confettiController,
              emissionFrequency: 0.1,
              numberOfParticles: 5,
              maxBlastForce: 20,
              minBlastForce: 1,
              gravity: 0.8,
              particleDrag: 0.05,
              blastDirectionality: BlastDirectionality.explosive,
              colors: const [Colors.yellow, Colors.orange, Colors.purple],
            ),
          ),
        ],
      ),
    );
  }

  void _doCopy(String text) {
    Clipboard.setData(ClipboardData(text: text)).then((_) {});
  }

  void _doPay(String link) async {
    if (Platform.isAndroid) {
      AndroidIntent intent = AndroidIntent(
        action: 'action_view',
        data: link,
      );
      await intent.launch();
    } else {
      var url = Uri.parse(link);
      launchUrl(url);
    }
  }

  Widget barOptions() {
    return Container();
    // TODO LNURL-withdraw
    // return Container(
    //     margin: const EdgeInsets.all(10),
    //     child: PopupMenuButton<String>(
    //         icon: Image.asset("assets/imgs/scan.png", width: 24, height: 24),
    //         // icon: const Icon(Icons.qr_code_scanner_outlined, color: Colors.grey,size: 30),
    //         tooltip: "Scan Invoice",
    //         itemBuilder: (context) {
    //           List<PopupMenuEntry<String>> list = [
    //             //const PopupMenuItem(value: "settings", child: Text("Settings")),
    //           ];
    //           return list;
    //         },
    //         onSelected: (value) async {
    //           // TODO open qr invoice
    //         }));
  }
}
