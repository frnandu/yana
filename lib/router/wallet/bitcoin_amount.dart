import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../utils/base.dart';
import '../../utils/number_format_util.dart';

class BitcoinAmount extends StatelessWidget {
  String fiatUnit;

  BitcoinAmount({
    super.key,
    required this.fiatAmount, required this.balance, required this.fiatUnit
  });

  final double? fiatAmount;
  final int balance;

  @override
  Widget build(BuildContext context) {
    var themeData = Theme.of(context);

    return Container(
        margin: const EdgeInsets.only(
            top: Base.BASE_PADDING,
            bottom: Base.BASE_PADDING),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                  textBaseline: TextBaseline.ideographic,
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    RichText(
                        text: const TextSpan(
                            text: "₿",
                            style: TextStyle(
                                color: Color(0xFF7A7D81),
                                fontSize: 40,
                                fontFamily: 'Geist.Mono'))),

                    // const Text("₿",
                    //           style: TextStyle(
                    //               color: Color(0xFF7A7D81),
                    //               fontSize: 40,
                    //               fontFamily: 'Geist.Mono')),
                    const SizedBox(width: 4),
                    // const Text("000002112",
                    //     style: TextStyle(
                    //         color: Color(0xffD44E7D),
                    //         fontSize: 40,
                    //         fontFamily: 'Geist.Mono')),
                    NumberFormatUtil.formatBitcoinAmount(
                        balance / 100000000,
                        TextStyle(
                            color: themeData.focusColor,
                            fontSize: 40,
                            fontFamily: 'Geist.Mono'),
                        TextStyle(
                            color: themeData.primaryColor,
                            fontSize: 40,
                            fontFamily: 'Geist.Mono')),
                    Text(" sats",
                        style: TextStyle(
                            color: themeData.primaryColor,
                            fontSize: 24,
                            fontWeight: FontWeight.w100)),
                  ]),
              Container(
                  margin: const EdgeInsets.only(
                      top: Base.BASE_PADDING,
                      bottom: Base.BASE_PADDING),
                  child: Text(
                      fiatAmount == null
                          ? ""
                          : fiatAmount! < 0.01
                          ? "< 0.01 $fiatUnit"
                          : "${fiatAmount!.toStringAsFixed(2)} $fiatUnit",
                      style: const TextStyle(
                          color: Color(0xFF7A7D81),
                          fontSize: 20,
                          fontFamily: 'Geist.Mono')))
            ]));
  }
}
