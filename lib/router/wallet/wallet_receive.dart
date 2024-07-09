import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:eeffects/eEffect/effects/colorShift.dart';
import 'package:eeffects/eEffect/effects/effect.dart';
import 'package:eeffects/eEffect/effects/lightning/lightning.dart';
import 'package:eeffects/eEffect/math/relative.dart';
import 'package:eeffects/eEffect/math/relativePair.dart';
import 'package:eeffects/eEffect/math/relativePos.dart';
import 'package:eeffects/eEffect/scene/scene.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:yana/main.dart';
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
  bool paid = false;
  EScene? scene = EScene(
    width: 400,
    height: 600,
    effects: [
      ELightning(
          ERelativePos(0.5, 0),
          0.02,
          ERelative(1, ERelative.absolute),
          ERelative(20, ERelative.absolute),
          ERelative(600, ERelative.absolute),
          50,
          5,
          EColorShift([Color.fromARGB(255, 80, 0, 255)], 0),
          true,
          8,
          1,
          name: "Example Lightning"),
    ],
    darkness: EColorShift([Color.fromARGB(255, 0, 0, 0)], 0),
    afterUpdate: () {},
    beforeUpdate: () {},
  );

  @override
  void initState() {
    // nwcProvider.reload();
    confettiController =  ConfettiController(duration: const Duration(seconds: 2));
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
    if (!paid) {
      list.add(Row(
        children: [
          Expanded(
              child: TextField(
                controller: amountInputcontroller,
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
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
            await _nwcProvider.makeInvoice(int.parse(amountInputcontroller.text) * 1000, descriptionInputcontroller.text, "", 3600, (invoice) async {
              // await QrcodeDialog.show(context, invoice);
              await LightningQrcodeDialog.show(this.context, invoice);
              setState(() {
                paid = true;
              });
              //confettiController.play();
              EEffect effect = scene!.getEffect("Example Lightning")!;
              if (effect is ELightning) {
                ELightning ourLightning = effect;
                ourLightning.buildLightningOnNextTickATTarget(ERelativePair(
                    ERelative(100, ERelative.absolute),
                    ERelative(200, ERelative.absolute)));

                ourLightning.fireLightningIn(3);
              }
            },);
          },
          child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Container(
                  margin: EdgeInsets.all(Base.BASE_PADDING * 2),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(20.0)),
                    border: Border.all(
                      width: 1,
                      color: themeData.hintColor,
                    ),
                  ),
                  child: Row(children: [
                    Container(margin: const EdgeInsets.all(Base.BASE_PADDING), child: Icon(Icons.edit_note, size: 25, color: themeData.iconTheme.color)),
                    const Text("Create Invoice"),
                  ])))));
    } else {
      list.add(Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 100.0,
            ),
            SizedBox(height: 20.0),
            Text(
              'Payment Sent',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10.0),
            Text(
              '?? sats',
              style: TextStyle(
                fontSize: 20.0,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),);
    }
    return Scaffold(
      body: Stack(
        children: [
          Align(
              alignment: Alignment.center,
              child: scene
            // ConfettiWidget(
            //   confettiController: confettiController,
            //   // blastDirection: -pi / 2,
            //   // emissionFrequency: 0.01,
            //   // numberOfParticles: 20,
            //   // maxBlastForce: 100,
            //   // minBlastForce: 80,
            //   // displayTarget: true,
            //   gravity: 0.8,
            //   blastDirectionality: BlastDirectionality.explosive, // don't specify a direction, blast randomly
            //   shouldLoop: false, // start again as soon as the animation is finished
            //   colors: const [
            //     Colors.yellow,
            //     Colors.orange,
            //     // Colors.red
            //   ], // manually specify the colors to be used
            //   // createParticlePath: drawStar, // define a custom shape/path.
            // ),
          ),
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
        ],
      ),
    );
  }
}
