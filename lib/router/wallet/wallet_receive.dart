import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:yana/main.dart';
import 'package:yana/nostr/nip47/nwc_notification.dart';
import 'package:yana/provider/nwc_provider.dart';
import 'package:yana/utils/base.dart';

import '../../../ui/appbar4stack.dart';
import '../../ui/lightning_qrcode_dialog.dart';

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
  NwcNotification? paid;

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

    Color? appbarBackgroundColor = Colors.transparent;

    var appBar = Appbar4Stack(
      title: Container(
        alignment: Alignment.center,
        child: const Text(
          "Receive",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: "Geist",
            fontSize: 20,
          ),
        ),
      ),
      backgroundColor: appbarBackgroundColor,
    );

    List<Widget> list = [];
    // list.add(Container(
    //     alignment: Alignment.centerLeft,
    //     child: Text("Amout")));
    if (paid==null) {
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

      list.add(GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () async {
            await _nwcProvider.makeInvoice(
                int.parse(amountInputcontroller.text) * 1000,
                descriptionInputcontroller.text,
                "",
                3600, (invoice) async {
              // await QrcodeDialog.show(context, invoice);
              await LightningQrcodeDialog.show(this.context, invoice);
            }, (notification) async {
              setState(() {
                paid = notification;
              });
              confettiController.play();
            });
          },
          child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Container(
                  margin: const EdgeInsets.all(Base.BASE_PADDING * 2),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(20.0)),
                    border: Border.all(
                      width: 1,
                      color: themeData.hintColor,
                    ),
                  ),
                  child: Row(children: [
                    Container(
                        margin: const EdgeInsets.all(Base.BASE_PADDING),
                        child: Icon(Icons.edit_note,
                            size: 25, color: themeData.iconTheme.color)),
                    const Text("Create Invoice"),
                  ])))));
    } else {
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
                '+${paid!.amount/1000} sats',
                style: TextStyle(
                  fontSize: 20.0,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
      );
    }
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
                    width: mediaDataCache.size.width * 0.8,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: list,
                    )),
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
}
