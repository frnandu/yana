import 'dart:io';

import 'package:android_intent_plus/android_intent.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_timer_countdown/flutter_timer_countdown.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yana/main.dart';
import 'package:yana/nostr/nip47/nwc_notification.dart';
import 'package:yana/provider/nwc_provider.dart';
import 'package:yana/utils/base.dart';
import 'package:yana/utils/string_util.dart';

import '../../../ui/appbar4stack.dart';
import '../../i18n/i18n.dart';
import '../../ui/button.dart';
import '../../utils/platform_util.dart';
import '../../utils/router_util.dart';
import 'bitcoin_amount.dart';

class WalletReceiveRouter extends StatefulWidget {
  const WalletReceiveRouter({super.key});

  @override
  State<StatefulWidget> createState() {
    return _WalletReceiveRouter();
  }
}

class _WalletReceiveRouter extends State<WalletReceiveRouter> {
  TextEditingController amountInputcontroller = TextEditingController();
  TextEditingController descriptionInputcontroller = TextEditingController();
  late ConfettiController confettiController;
  String? payingInvoice;
  NwcNotification? paid;
  double? fiatAmount;

  static const int BTC_IN_SATS = 100000000;

  int? expiration;

  @override
  void initState() {
    // nwcProvider.reload();
    amountInputcontroller.addListener(() {
      setState(() {
        if (fiatCurrencyRate != null &&
            StringUtil.isNotBlank(amountInputcontroller.text.trim())) {
          double? btc =
              (int.parse(amountInputcontroller.text).toDouble() / BTC_IN_SATS);
          var fiatFactor = fiatCurrencyRate!["value"];
          fiatAmount = (btc * fiatFactor * 100).truncateToDouble() / 100;
          print(fiatAmount);
        }
      });
    });
    confettiController =
        ConfettiController(duration: const Duration(seconds: 2));
  }

  @override
  void dispose() {
    confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var _nwcProvider = Provider.of<NwcProvider>(context);

    var themeData = Theme.of(context);
    var cardColor = themeData.cardColor;

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
        child: Icon(
          Icons.arrow_back_ios,
          color: themeData.appBarTheme.titleTextStyle!.color,
        ),
      ),
      title: const Text("Receive",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: "Geist.Mono",
            fontSize: 20,
          )),
    );

    List<Widget> list = [];
    if (paid == null) {
      if (payingInvoice != null) {
        list.add(Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                ),
                child: PrettyQrView.data(
                    data: payingInvoice!,
                    decoration: const PrettyQrDecoration(
                      shape: PrettyQrSmoothSymbol(roundFactor: 0),
                      image: PrettyQrDecorationImage(
                        image: AssetImage('assets/imgs/logo/logo-new.png'),
                      ),
                    )))
            // LightningQrcodeDialog(invoice: payingInvoice!)
            );
        Color cardColor = themeData.hintColor;
        var hintColor = themeData.cardColor;
        String? link;
        if (PlatformUtil.isPC() || PlatformUtil.isWeb() || true) {
          link = 'lightning:${payingInvoice!}';
        }
        list.add(BitcoinAmount(
            fiatAmount: fiatAmount,
            fiatUnit: fiatCurrencyRate?["unit"],
            balance: int.parse(amountInputcontroller.text)));
        list.add(Container(
            margin: const EdgeInsets.only(bottom: Base.BASE_PADDING * 2),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: themeData.primaryColor,
                      strokeWidth: 2.0,
                    )),
                const SizedBox(width: 10),
                const Text("Waiting for settlement",
                    style: TextStyle(
                        color: Color(0xFF7A7D81),
                        fontSize: 20,
                        fontFamily: 'Geist.Mono'))
              ],
            )));
        const TextStyle timeTextStyle = TextStyle(
            color: Color(0xFF7A7D81), fontSize: 16, fontFamily: 'Geist.Mono');
        list.add(
          Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Expanded(
                    child: Text("Expiration time:", style: timeTextStyle)),
                const SizedBox(
                  width: 40,
                ),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                      TimerCountdown(
                        enableDescriptions: false,
                        spacerWidth: 1,
                        colonsTextStyle: timeTextStyle,
                        timeTextStyle: timeTextStyle,
                        format: CountDownTimerFormat.hoursMinutesSeconds,
                        endTime: DateTime.now().add(
                          Duration(seconds: expiration!),
                        ),
                        onEnd: () {
                          RouterUtil.back(context);
                        },
                      )
                    ]))
              ]),
        );
        list.add(const SizedBox(height: 20));
        list.add(Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
                child: Button(
                    before: const Icon(Icons.copy),
                    text: "Copy ",
                    onTap: () async {
                      _doCopy(payingInvoice!);
                    })),
            if (link != null) const SizedBox(width: 24),
            if (link != null)
              Expanded(
                  child: Button(
                      before: const Icon(Icons.ios_share),
                      text: "Share",
                      onTap: () async {
                        _doPay(link!);
                      }))
            else
              Container()
          ],
        ));
      } else {
        list.add(Row(
          children: [
            Expanded(
                child: TextField(
              controller: amountInputcontroller,
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly
              ],
              decoration: const InputDecoration(hintText: "Amount in sats"),
            )),
          ],
        ));

        list.add(Row(children: [
          Container(
              margin: const EdgeInsets.only(
                  top: Base.BASE_PADDING * 2, bottom: Base.BASE_PADDING * 2),
              child: Text(
                  fiatAmount == null
                      ? ""
                      : fiatAmount! < 0.01
                          ? "< 0.01 ${fiatCurrencyRate?["unit"]}"
                          : "${fiatAmount!.toStringAsFixed(fiatAmount! < 10 ? 2 : 0)} ${fiatCurrencyRate?["unit"]}",
                  style: const TextStyle(
                      color: Color(0xFF7A7D81),
                      fontSize: 20,
                      fontFamily: 'Geist.Mono')))
        ]));
        // list.add(const Divider());
        // list.add(Container(
        //     alignment: Alignment.centerLeft,
        //     child: Text("Description")));

        list.add(Row(
          children: [
            Expanded(
                child: TextField(
              controller: descriptionInputcontroller,
              decoration: const InputDecoration(hintText: "Description"),
            )),
          ],
        ));
        list.add(const SizedBox(
          height: 20,
        ));
        list.add(Button(
            text: "Create Invoice",
            onTap: () async {
              expiration = 3600;
              await _nwcProvider.makeInvoice(
                  int.parse(amountInputcontroller.text) * 1000,
                  descriptionInputcontroller.text,
                  "",
                  expiration!, (invoice) async {
                // await QrcodeDialog.show(context, invoice);
                payingInvoice = invoice;
              }, (notification) async {
                setState(() {
                  paid = notification;
                });
                confettiController.play();
              });
            }));
      }
    } else {
      double? fiatAmount = fiatCurrencyRate != null
          ? ((paid!.amount / 100000000000) * fiatCurrencyRate!["value"])
          : null;
      int feesPaid = (paid!.feesPaid / 1000).round();
      int amount = (paid!.amount / 1000).round();

      list.add(
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle,
                color: Colors.green,
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
              Text(
                '+$amount sats',
                style: const TextStyle(
                  fontSize: 28.0,
                  // color: Colors.grey[700],
                ),
              ),
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
      list.add(Button(text:"Close", onTap: () {
        RouterUtil.back(context);
      },));
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
          // Positioned(
          //   top: mediaDataCache.padding.top,
          //   child: SizedBox(
          //     width: mediaDataCache.size.width,
          //     child: appBarNew,
          //   ),
          // ),
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
    Clipboard.setData(ClipboardData(text: text)).then((_) {
      // EasyLoading.showSuccess(I18n.of(context).Copy_success,
      //     dismissOnTap: true, duration: const Duration(seconds: 2));
    });
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
}
