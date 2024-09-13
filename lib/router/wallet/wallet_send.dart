import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ndk/entities.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:yana/main.dart';
import 'package:yana/nostr/nip47/nwc_notification.dart';
import 'package:yana/provider/nwc_provider.dart';
import 'package:yana/utils/string_util.dart';

import '../../nostr/nip57/zap.dart';
import '../../nostr/nip57/zap_num_util.dart';
import '../../ui/button.dart';
import '../../ui/editor/search_mention_user_component.dart';
import '../../utils/base.dart';
import '../../utils/dio_util.dart';
import '../../utils/router_path.dart';
import '../../utils/router_util.dart';

class WalletSendRouter extends StatefulWidget {
  const WalletSendRouter({super.key});

  @override
  State<StatefulWidget> createState() {
    return _WalletSendRouter();
  }
}

class _WalletSendRouter extends State<WalletSendRouter> {
  TextEditingController recipientInputcontroller = TextEditingController();
  TextEditingController amountInputcontroller = TextEditingController();
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? qrController;

  String? recipientAddress;
  String? invoice;
  int? amount;
  String? description;

  NwcNotification? paid;
  List<Metadata> mentionResults = [];

  bool scanning = false;

  void _onQRViewCreated(QRViewController controller) {
    qrController = controller;
    controller.scannedDataStream.listen((scanData) async {
      if (invoice == null) {
        if (scanData.code != null &&
            scanData.code!.startsWith(NwcProvider.BOLT11_PREFIX)) {
          // nwcProvider.connect(scanData.code!);
          setState(() {
            invoice = scanData.code;
            if (invoice != null) {
              RouterUtil.router(
                  context, RouterPath.WALLET_SEND_CONFIRM, invoice);
            }

            scanning = false;
            qrController!.pauseCamera();
          });
        }
      }
    });
  }

  @override
  void initState() {
    recipientInputcontroller.addListener(() {
      String t = recipientInputcontroller.text.trim().toLowerCase();
      if (t.startsWith("lightning:")) {
        t = t.replaceAll("lightning:", "");
      }
      if (t.startsWith("lnbc")) {
        int num = ZapNumUtil.getNumFromStr(t);
        if (num > 0) {
          setState(() {
            amountInputcontroller.text = "$num";
            recipientAddress = t;
          });
          RouterUtil.router(context, RouterPath.WALLET_SEND_CONFIRM, t);
        }
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
    if (qrController != null) {
      qrController!.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var _nwcProvider = Provider.of<NwcProvider>(context);

    var themeData = Theme.of(context);
    var cardColor = themeData.cardColor;
    String? sendTo = RouterUtil.routerArgs(context) as String?;
    if (StringUtil.isNotBlank(sendTo)) {
      setState(() {
        recipientInputcontroller!.text = sendTo!;
        recipientAddress = sendTo;
        // TODO move along the process
      });
    }

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
      title: Text(!scanning ? "Send" : "Scan QR",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: "Geist.Mono",
            fontSize: 20,
          )),
    );

    List<Widget> list = [];
    if (!scanning) {
      list.addAll(inputWidgets());
    }
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 150.0
        : 350.0;

    return Scaffold(
        backgroundColor: cardColor,
        appBar: appBarNew,
        body: scanning
            ? Stack(children: [
                QRView(
                  key: qrKey,
                  overlay: QrScannerOverlayShape(
                      cutOutBottomOffset: 50,
                      borderColor: themeData.primaryColor,
                      borderRadius: 10,
                      borderLength: 30,
                      borderWidth: 10,
                      cutOutSize: scanArea),
                  onQRViewCreated: _onQRViewCreated,
                )
              ])
            : Container(
                margin: const EdgeInsets.all(Base.BASE_PADDING*2),
                decoration: BoxDecoration(
                  // color: themeData.cardColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  // mainAxisSize: MainAxisSize.min,
                  children: list,
                ))
        // Stack(
        //         children: [
        //           SizedBox(
        //             width: mediaDataCache.size.width,
        //             height:
        //                 mediaDataCache.size.height - mediaDataCache.padding.top,
        //             child: Container(
        //               color: cardColor,
        //               child: Center(
        //                 child: SizedBox(
        //                     width: mediaDataCache.size.width * 0.8,
        //                     child: Column(
        //                       mainAxisSize: MainAxisSize.min,
        //                       children: list,
        //                     )),
        //               ),
        //             ),
        //           ),
        //         ],
        //       ),
        );
  }

  Iterable<Widget> inputWidgets() {
    List<Widget> list = [];
    list.add(Row(
      children: [
        Expanded(
            child: TextField(
          controller: recipientInputcontroller,
          decoration:
              const InputDecoration(hintText: "Contact, address, invoice..."),
        )),
        IconButton(
            onPressed: () {
              Clipboard.getData(Clipboard.kTextPlain).then((clipboardData) {
                if (clipboardData != null &&
                    StringUtil.isNotBlank(clipboardData.text)) {
                  setState(() {
                    recipientInputcontroller.text = clipboardData.text!;
                  });
                  String t = recipientInputcontroller.text.trim().toLowerCase();
                  if (t.startsWith("lnbc")) {
                    int num = ZapNumUtil.getNumFromStr(t);
                    if (num > 0) {
                      setState(() {
                        amountInputcontroller.text = "$num";
                        recipientAddress = t;
                      });
                      RouterUtil.router(
                          context, RouterPath.WALLET_SEND_CONFIRM, t);
                    }
                  }
                }
              });
            },
            icon: Icon(
              size: 32,
              Icons.paste,
              color: Colors.grey[700],
            )),
        const SizedBox(
          width: 10,
        ),
        GestureDetector(
            onTap: () {
              if (qrController != null) {
                qrController!.resumeCamera();
              }
              setState(() {
                invoice = null;
                scanning = true;
              });
            },
            child: Image.asset("assets/imgs/scan.png", width: 32, height: 32)),
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
    if (recipientAddress != null || invoice != null) {
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
      list.add(const SizedBox(
        height: 20,
      ));
      list.add(Button(
        text: "Continue",
        onTap: () async {
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
            amount = int.parse(amountInputcontroller.text);
            var amountMsats = amount! * 1000;

            callback += "amount=$amountMsats";
            var responseMap = await DioUtil.get(callback);
            if (responseMap != null &&
                StringUtil.isNotBlank(responseMap["pr"])) {
              invoice = responseMap["pr"];
              RouterUtil.router(
                  context, RouterPath.WALLET_SEND_CONFIRM, invoice);
            }
          }
        },
      ));
    }
    return list;
  }
}
