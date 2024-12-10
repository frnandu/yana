import 'dart:io';

import 'package:android_intent_plus/android_intent.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_timer_countdown/flutter_timer_countdown.dart';
import 'package:lottie/lottie.dart';
import 'package:ndk/domain_layer/entities/metadata.dart';
import 'package:ndk/domain_layer/usecases/nwc/nwc_notification.dart';
import 'package:ndk/domain_layer/usecases/nwc/responses/make_invoice_response.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yana/main.dart';
import 'package:yana/provider/nwc_provider.dart';
import 'package:yana/utils/base.dart';
import 'package:yana/utils/string_util.dart';

import '../../ui/button.dart';
import '../../utils/platform_util.dart';
import '../../utils/router_util.dart';
import 'bitcoin_amount.dart';

class WalletReceiveInvoiceRouter extends StatefulWidget {
  const WalletReceiveInvoiceRouter({super.key});

  @override
  State<StatefulWidget> createState() {
    return _WalletReceiveRouter();
  }
}

class _WalletReceiveRouter extends State<WalletReceiveInvoiceRouter> {
  TextEditingController amountInputcontroller = TextEditingController();
  TextEditingController descriptionInputcontroller = TextEditingController();
  late ConfettiController confettiController;
  String? payingInvoice;
  NwcNotification? paid;
  int sats = 0;
  double fiat = 0;

  int? expiration;
  Metadata? metadata;
  bool satsInput = true;

  @override
  void initState() {

    amountInputcontroller.addListener(() {
      setState(() {
        if (fiatCurrencyRate != null) {
          updateOtherCurrency();
        }
      });
    });
    confettiController = ConfettiController(duration: const Duration(seconds: 2));
  }

  void updateOtherCurrency() {
    if (satsInput) {
      sats = StringUtil.isNotBlank(amountInputcontroller.text) ? int.parse(amountInputcontroller.text) : 0;
      double? btc = StringUtil.isNotBlank(amountInputcontroller.text) ? double.parse(amountInputcontroller.text) / NwcProvider.BTC_IN_SATS : 0;
      var fiatFactor = fiatCurrencyRate!["value"];
      fiat = btc * fiatFactor;
    } else {
      String a1 = fiat.toStringAsFixed(fiat < 10 ? 2 : 0);
      String a2 = amountInputcontroller.text;
      if (a1 != a2) {
        double a3 = StringUtil.isNotBlank(amountInputcontroller.text) ? double.parse(amountInputcontroller.text) : 0;
        sats = a3 != 0.0 ? (a3 / fiatCurrencyRate!["value"] * NwcProvider.BTC_IN_SATS).round() : 0;
      } else {
        sats = (fiat / fiatCurrencyRate!["value"] * NwcProvider.BTC_IN_SATS).round();
        print(fiat);
      }
    }
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
          child: Container(
            margin: const EdgeInsets.only(left: 10),
            child: Icon(
              Icons.arrow_back_ios,
              color: themeData.hintColor,
            ),
          )),
      title: Text(payingInvoice != null ? "Pay Invoice" : "Create Invoice",
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
                    decoration: PrettyQrDecoration(
                      shape: const PrettyQrSmoothSymbol(roundFactor: 1),
                      image: PrettyQrDecorationImage(
                        image: metadata != null && StringUtil.isNotBlank(metadata!.picture)
                            ? CachedNetworkImageProvider(metadata!.picture!)
                            : const AssetImage('assets/imgs/logo/logo-new.png'),
                      ),
                    )))
            // LightningQrcodeDialog(invoice: payingInvoice!)
            );
        String? link;
        if (PlatformUtil.isPC() || PlatformUtil.isWeb() || true) {
          link = 'lightning:${payingInvoice!}';
        }
        list.add(BitcoinAmount(fiatAmount: fiat, fiatUnit: fiatCurrencyRate?["unit"], balance: sats));
        if (StringUtil.isNotBlank(descriptionInputcontroller.text)) {
          list.add(Container(
              margin: const EdgeInsets.only(bottom: Base.BASE_PADDING * 2),
              child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [Text(descriptionInputcontroller.text, style: const TextStyle(fontSize: 20, fontFamily: 'Geist.Mono'))])));
        }
        list.add(const SizedBox(height: 10));
        const TextStyle timeTextStyle = TextStyle(color: Color(0xFF7A7D81), fontSize: 18, fontFamily: 'Geist.Mono');
        list.add(Container(
            margin: const EdgeInsets.only(bottom: Base.BASE_PADDING),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(width: 10),
                SizedBox(width: 20, height: 20, child: Lottie.asset("assets/animations/spinner.json")
                    // CircularProgressIndicator(
                    //     color: themeData.primaryColor,
                    //     strokeWidth: 2.0,
                    //   )
                    ),
                const SizedBox(width: 10),
                const Expanded(child: Text("Waiting for settlement", style: timeTextStyle)),
                const SizedBox(width: 10),
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
              ],
            )));
        list.add(const SizedBox(height: 20));

        if (link != null) {
          list.add(Row(children: [
            Expanded(
                child: Button(
                    before: const Icon(Icons.copy, color: Colors.white),
                    text: "Copy ",
                    onTap: () async {
                      _doCopy(payingInvoice!);
                    }))
          ]));
          list.add(const SizedBox(height: 10));
          list.add(Row(
            children: [
              Expanded(
                  child: Button(
                      before: Icon(Icons.ios_share, color: themeData.textTheme.labelSmall!.color),
                      fill: false,
                      border: true,
                      text: "Share",
                      onTap: () async {
                        _doPay(link!);
                      }))
            ],
          ));
          list.add(const SizedBox(height: 10));
          list.add(Button(
              before: Icon(Icons.edit_outlined, color: themeData.disabledColor),
              border: false,
              fill: false,
              fontColor: themeData.disabledColor,
              text: "Edit Invoice",
              onTap: () async {
                setState(() {
                  payingInvoice = null;
                });
              }));
        }
      } else {
        // =====================================
        // Form ==============================
        // ===================================
        list.add(Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
                child: TextField(
              autofocus: true,
              textAlign: TextAlign.center,
              cursorColor: themeData.primaryColor,
              style: const TextStyle(fontSize: 80, fontFamily: 'Geist.Mono'),
              // textDirection: TextDirection.ltr,
              controller: amountInputcontroller,
              keyboardType: TextInputType.numberWithOptions(decimal: !satsInput),
              inputFormatters: <TextInputFormatter>[satsInput ? FilteringTextInputFormatter.digitsOnly : FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: "  0",
                hintTextDirection: TextDirection.ltr,
                hintStyle: TextStyle(fontSize: 80, color: themeData.disabledColor, fontFamily: 'Geist.Mono'),
                contentPadding: const EdgeInsets.only(right: 20),
              ),
            )),
          ],
        ));
        list.add(const SizedBox(
          height: 5,
        ));
        list.add(GestureDetector(
            onTap: () {
              setState(() {
                satsInput = !satsInput;
                if (satsInput) {
                  amountInputcontroller.text = "$sats";
                } else {
                  amountInputcontroller.text = fiat.toStringAsFixed(fiat < 10 ? 2 : 0);
                }
              });
            },
            child: Row(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: [
              Text(
                  textAlign: TextAlign.center,
                  satsInput ? "sats" : fiatCurrencyRate?["unit"],
                  style: const TextStyle(color: Color(0xFF7A7D81), fontSize: 32, fontFamily: 'Geist.Mono')),
              Image.asset('assets/imgs/arrows.png'),
            ])));
        list.add(const SizedBox(
          height: 10,
        ));
        print("sats:$sats fiat: $fiat");
        String fiatString = (fiat == 0.0 ? "0.00" : fiat.toStringAsFixed(fiat < 10 ? 2 : 0));
        print("fiatString: $fiatString");
        list.add(Row(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: [
          Expanded(
              child: Text(
                  textAlign: TextAlign.center,
                  "${!satsInput ? sats : fiatString} "
                  "${satsInput ? "${fiatCurrencyRate?['unit']}" : 'sats'}",
                  style: const TextStyle(color: Color(0xFF7A7D81), fontSize: 30, fontFamily: 'Geist.Mono')))
        ]));
        list.add(const SizedBox(
          height: 20,
        ));

        list.add(Row(
          children: [
            Expanded(
                child: TextField(
              controller: descriptionInputcontroller,
              decoration: InputDecoration(hintText: "Add description (optional)", hintStyle: TextStyle(color: themeData.disabledColor)),
            )),
          ],
        ));
        list.add(const SizedBox(
          height: 20,
        ));
        list.add(Row(children: [
          Expanded(
              child: Button(
                  text: "Create Invoice",
                  fill: false,
                  border: true,
                  onTap: () async {
                    expiration = 3600;
                    sats = satsInput ? int.parse(amountInputcontroller.text) : fiat.round();

                    MakeInvoiceResponse? response = await _nwcProvider.makeInvoice(sats, descriptionInputcontroller.text, "", expiration!);
                    if (response != null) {
                      nwcProvider.connection!.paymentsReceivedStream.listen((notification) {
                        if (payingInvoice != null && notification.preimage != '' && notification.invoice == payingInvoice) {
                          setState(() {
                            paid = notification;
                          });
                          confettiController.play();
                        }
                      });
                      setState(() {
                        payingInvoice = response.invoice;
                      });
                    }
                  }))
        ]));
      }
    } else {
      double? fiatAmount = fiatCurrencyRate != null ? ((paid!.amount / 100000000000) * fiatCurrencyRate!["value"]) : null;
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
                fiatAmount! < 0.01 ? "< ${fiatCurrencyRate?["unit"]}0.01" : "~${fiatCurrencyRate?["unit"]}${fiatAmount.toStringAsFixed(2)}",
                style: const TextStyle(
                  fontSize: 22.0,
                ),
              ),
              StringUtil.isNotBlank(paid!.description) ? const SizedBox(height: 10.0) : Container(),
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
      list.add(const SizedBox(height: 20.0));

      list.add(Button(
        text: "Close",
        onTap: () {
          RouterUtil.back(context);
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
