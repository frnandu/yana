import 'package:bolt11_decoder/bolt11_decoder.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:ndk/domain_layer/usecases/nwc/nwc_notification.dart';
import 'package:ndk/domain_layer/usecases/nwc/responses/pay_invoice_response.dart';
import 'package:provider/provider.dart';
import 'package:yana/main.dart';
import 'package:yana/provider/nwc_provider.dart';
import 'package:yana/utils/router_path.dart';
import 'package:yana/utils/string_util.dart';

import 'package:go_router/go_router.dart';
import '../../ui/button.dart';
import 'bitcoin_amount.dart';

class WalletSendConfirmRouter extends StatefulWidget {
  const WalletSendConfirmRouter({super.key});

  @override
  State<StatefulWidget> createState() {
    return _WalletSendConfirmRouter();
  }
}

class _WalletSendConfirmRouter extends State<WalletSendConfirmRouter> {
  late ConfettiController confettiController;
  String? invoice;
  int? amount;
  String? description;

  PayInvoiceResponse? paid;

  bool sending = false;

  @override
  void initState() {
    // nwcProvider.reload();
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
    invoice = GoRouterState.of(context).extra as String?;

    List<Widget> list = [];
    if (StringUtil.isNotBlank(invoice)) {
      Bolt11PaymentRequest req = Bolt11PaymentRequest(invoice!);

      double btc = req.amount.toDouble();
      amount = (btc * NwcProvider.BTC_IN_SATS).round();

      if (req.tags.any((el) {
        return el.type == "description";
      })) {
        description = req.tags.firstWhere((el) {
          return el.type == "description";
        }).data;
      }
      // TODO
      // req.tags.forEach((TaggedField t) {
      //   print("${t.type}: ${t.data}");
      // });
      if (paid != null) {
        // PAID
        double? fiatAmount = fiatCurrencyRate != null
            ? ((amount! / 100000000000) * fiatCurrencyRate!["value"])
            : null;
        int feesPaid = (paid!.feesPaid / 1000).round();

        list.add(Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle_outline,
                color: Color(0xFF47A66D),
                size: 100.0,
              ),
              const SizedBox(height: 20.0),
              const Text(
                'Payment Sent',
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
                      text: "-$amount",
                      style: const TextStyle(
                          fontSize: 28.0, color: Color(0xFFE26842)),
                    ),
                    TextSpan(
                      text: ' sat${amount! > 1 ? 's' : ''}',
                      style: TextStyle(fontSize: 24.0, color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
              feesPaid > 0 ? const SizedBox(height: 10.0) : Container(),
              feesPaid > 0
                  ? Text(
                      'Fee $feesPaid sat${feesPaid > 1 ? 's' : ''}',
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.grey[700],
                      ),
                    )
                  : Container(),
              const SizedBox(height: 10.0),
              Text(
                fiatAmount == null || fiatAmount < 0.01
                    ? "< ${fiatCurrencyRate?["unit"]}0.01"
                    : "~${fiatCurrencyRate?["unit"]}${fiatAmount.toStringAsFixed(2)}",
                // "~${fiatCurrencyRate?["unit"]}${fiatAmount?.toStringAsFixed(2)}",
                style: const TextStyle(
                  fontSize: 22.0,
                  // color: Colors.grey[700],
                ),
              ),
              StringUtil.isNotBlank(description)
                  ? const SizedBox(height: 10.0)
                  : Container(),
              StringUtil.isNotBlank(description)
                  ? Text(
                      '$description',
                      style: TextStyle(
                        fontSize: 20.0,
                        color: Colors.grey[700],
                      ),
                    )
                  : Container(),
            ],
          ),
        ));
        list.add(const SizedBox(
          height: 20,
        ));
        list.add(Button(
          text: "Close",
          fill: false,
          border: true,
          width: 300,
          onTap: () {
            context.go(RouterPath.WALLET);
          },
        ));
        list.add(const SizedBox(
          height: 20,
        ));
      } else {
        // CONFIRM
        var fiatFactor = fiatCurrencyRate!["value"];
        double fiat = btc * fiatFactor;

        list.add(BitcoinAmount(
            fiatAmount: fiat,
            fiatUnit: fiatCurrencyRate?["unit"],
            balance: amount!));
        if (StringUtil.isNotBlank(description)) {
          list.add(Text(
            '$description',
            style: TextStyle(
              fontSize: 20.0,
              color: Colors.grey[700],
            ),
          ));
          list.add(const SizedBox(
            height: 20,
          ));
        }
        list.add(const SizedBox(
          height: 20,
        ));

        list.add(Row(children: [
          Expanded(
              child: Button(
                  text: sending ? "Paying..." : "Pay $amount sats",
                  onTap: () {
                    setState(() {
                      sending = true;
                    });
                    doPay();
                  },
                  after: Row(children: [
                    const SizedBox(width: 30),
                    Visibility(
                      visible: sending,
                      child: const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.0,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                    )
                  ])))
        ]));
      }
    } else {
      list.add(const Text("invalid invoice"));
    }

    var appBarNew = AppBar(
      toolbarHeight: 70,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      backgroundColor: themeData.appBarTheme.foregroundColor,
      leading: GestureDetector(
          onTap: () {
            context.go(RouterPath.WALLET);
          },
          child: Container(
            margin: const EdgeInsets.only(left: 10),
            child: Icon(
              Icons.arrow_back_ios,
              color: themeData.hintColor,
            ),
          )),
      title: const Text("Confirm Payment",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: "Geist.Mono",
            fontSize: 20,
          )),
    );

    return Scaffold(
      backgroundColor: cardColor,
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
                    width: mediaDataCache.size.width * 0.8,
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

  void doPay() async {
    PayInvoiceResponse? response = await nwcProvider?.payInvoice(invoice!);
    if (response != null && response.preimage != '') {
      setState(() {
        paid = response;
      });
      confettiController.play();
    }
    ;
  }
}
