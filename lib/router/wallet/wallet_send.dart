import 'package:confetti/confetti.dart';
import 'package:dart_ndk/nips/nip01/metadata.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:yana/main.dart';
import 'package:yana/nostr/nip47/nwc_notification.dart';
import 'package:yana/provider/nwc_provider.dart';
import 'package:yana/utils/base.dart';
import 'package:yana/utils/string_util.dart';

import '../../../ui/appbar4stack.dart';
import '../../nostr/nip57/zap.dart';
import '../../nostr/nip57/zap_num_util.dart';
import '../../ui/editor/search_mention_user_component.dart';
import '../../utils/dio_util.dart';

class WalletSendRouter extends StatefulWidget {
  const WalletSendRouter({super.key});

  @override
  State<StatefulWidget> createState() {
    return _WalletReceiveRouter();
  }
}

class _WalletReceiveRouter extends State<WalletSendRouter> {
  TextEditingController recipientInputcontroller = TextEditingController();
  TextEditingController amountInputcontroller = TextEditingController();
  late ConfettiController confettiController;
  String? recipientAddress;
  NwcNotification? paid;
  bool sending = false;
  List<Metadata> mentionResults = [];

  @override
  void initState() {
    // nwcProvider.reload();
    confettiController =
        ConfettiController(duration: const Duration(seconds: 2));
    recipientInputcontroller.addListener(() {
      String t = recipientInputcontroller.text.trim().toLowerCase();
      if (t.startsWith("lnbc")) {
        int num = ZapNumUtil.getNumFromStr(t);
        setState(() {
          amountInputcontroller.text = "$num";
          recipientAddress = t;
        });
      } else if (t.contains("@")) {
        setState(() {
          recipientAddress = t;
        });
      } else if (t.isNotEmpty) {
        List<Metadata> list = cacheManager.searchMetadatas(t, 4).toList();
        if (list.length != mentionResults.length) {
          setState(() {
            mentionResults = list;
            recipientAddress = null;
          });
        }
      } else {
        setState(() {
          mentionResults = [];
          recipientAddress = null;
        });
      }
    });
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
          "Send",
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
    if (paid == null) {
      list.add(Row(
        children: [
          Expanded(
              child: TextField(
            controller: recipientInputcontroller,
            decoration:
                const InputDecoration(hintText: "Contact, address, invoice..."),
          )),
        ],
      ));
      if (mentionResults != null && mentionResults.isNotEmpty) {
        list.add(ListView.builder(
            physics: const BouncingScrollPhysics(),
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return SearchMentionUserItemComponent(
                metadata: mentionResults[index],
                width: 400,
                showNip05: false,
                showLnAddress: true,
                onTap: (metadata) {
                  recipientInputcontroller.text = metadata.lud16!;
                  setState(() {
                    mentionResults = [];
                    recipientAddress = metadata.lud16!;
                  });
                },
              );
            },
            itemCount: mentionResults.length));
      }
      if (recipientAddress != null) {
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
        list.add(GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () async {
              String? invoice;
              var amount = int.parse(amountInputcontroller.text) * 1000;
              if (recipientInputcontroller.text
                  .trim()
                  .toLowerCase()
                  .contains("@")) {
                String? lnurl =
                    Zap.getLud16LinkFromLud16(recipientInputcontroller.text);
                var lnurlResponse =
                    lnurl != null ? await Zap.getLnurlResponse(lnurl!) : null;
                if (lnurlResponse == null) {
                  return;
                }

                var callback = lnurlResponse.callback!;
                if (callback.contains("?")) {
                  callback += "&";
                } else {
                  callback += "?";
                }

                callback += "amount=$amount";
                var responseMap = await DioUtil.get(callback);
                if (responseMap != null &&
                    StringUtil.isNotBlank(responseMap["pr"])) {
                  invoice = responseMap["pr"];
                }
              }
              if (recipientInputcontroller.text.startsWith("lnbc")) {
                invoice = recipientInputcontroller.text;
              }
              if (invoice != null) {
                FocusManager.instance.primaryFocus?.unfocus();
                setState(() {
                  sending = true;
                });
                await _nwcProvider.payInvoice(invoice, null,
                    (nwcNotification) async {
                  setState(() {
                    paid = nwcNotification;
                    nwcNotification!.amount = amount; // * 1000;
                  });
                  confettiController.play();
                });
              }
            },
            child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Container(
                    margin: const EdgeInsets.all(Base.BASE_PADDING * 2),
                    decoration: BoxDecoration(
                      borderRadius:
                          const BorderRadius.all(Radius.circular(20.0)),
                      border: Border.all(
                        width: 1,
                        color: themeData.hintColor,
                      ),
                    ),
                    child: Row(children: [
                      Container(
                          margin: const EdgeInsets.all(Base.BASE_PADDING),
                          child: const Icon(Icons.bolt,
                              size: 25, color: Colors.amberAccent)),
                      Text("Pay ${amountInputcontroller.text} sats"),
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
                      ),
                    ])))));
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
                'Payment Sent',
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10.0),
              Text(
                '-$amount sat${amount > 1 ? 's' : ''}',
                style: const TextStyle(
                  fontSize: 28.0,
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
                fiatAmount! < 0.01
                    ? "< ${fiatCurrencyRate?["unit"]}0.01"
                    : "~${fiatCurrencyRate?["unit"]}${fiatAmount.toStringAsFixed(2)}",
                // "~${fiatCurrencyRate?["unit"]}${fiatAmount?.toStringAsFixed(2)}",
                style: const TextStyle(
                  fontSize: 22.0,
                  // color: Colors.grey[700],
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
                child: SizedBox(
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
            child: SizedBox(
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
