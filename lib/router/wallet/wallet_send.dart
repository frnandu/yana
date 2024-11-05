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
  bool makingInvoice = false;
  String? makeInvoiceError;

  void _onQRViewCreated(QRViewController controller) {
    qrController = controller;
    controller.scannedDataStream.listen((scanData) async {
      // TODO handle lightning: + ln address
      if (invoice == null && scanData.code!=null) {
        String qr = scanData.code!;
        if (qr.startsWith("lightning:")) {
          qr = qr.replaceAll("lightning:", "");
        }
        if (qr.startsWith(NwcProvider.BOLT11_PREFIX)) {
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
        } else if (qr.contains("@")) {
          setState(() {
            recipientAddress = qr;
            recipientInputcontroller.text = qr;
            scanning = false;
            qrController!.pauseCamera();
          });
        }
      }
    });
  }

  @override
  void initState() {
    amountInputcontroller.addListener(() {
      setState(() {
        makeInvoiceError = null;
      });
    });
    recipientInputcontroller.addListener(() async {
      setState(() {
        makeInvoiceError = null;
      });
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
        List<Metadata> list = (await cacheManager.searchMetadatas(t, 100)).toList();
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
                margin: const EdgeInsets.all(Base.BASE_PADDING),
                decoration: BoxDecoration(
                  // color: themeData.cardColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  // mainAxisSize: MainAxisSize.min,
                  children: list,
                )));
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
      list.add(const SizedBox(
        height: 10,
      ));
      list.add(const Text(
        "Contacts",
        style: TextStyle(
          fontSize: 20.0,
          fontWeight: FontWeight.bold,
        ),
      ));
      list.add(const SizedBox(
        height: 10,
      ));
      list.add(Expanded(
          child: ListView.builder(
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
              itemCount: mentionResults.length)));
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
      list.add(const SizedBox(
        height: 20,
      ));
      if (makeInvoiceError != null) {
        list.add(Text(
          "Error: $makeInvoiceError",
          style: TextStyle(
            fontSize: 20.0,
            color: Colors.grey[700],
          ),
        ));
        list.add(const SizedBox(
          height: 20,
        ));
      }
      if (amountInputcontroller.text.trim().length > 0 &&
          recipientAddress != null) {
        list.add(Button(
          text: makingInvoice ? "Making Invoice..." : "Make Invoice",
          after: makingInvoice
              ? Row(children: [
                  const SizedBox(width: 30),
                  Visibility(
                    visible: makingInvoice,
                    child: const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.0,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  )
                ])
              : Container(),
          onTap: () async {
            if (recipientInputcontroller.text
                .trim()
                .toLowerCase()
                .contains("@")) {
              setState(() {
                makeInvoiceError = null;
                makingInvoice = true;
              });
              String? lnurl =
                  Zap.getLud16LinkFromLud16(recipientInputcontroller.text);
              var lnurlResponse =
                  lnurl != null ? await Zap.getLnurlResponse(lnurl!) : null;
              if (lnurlResponse == null) {
                setState(() {
                  makeInvoiceError =
                  "could not generate invoice from $lnurl";
                  makingInvoice = false;
                });
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
              } else {
                if (responseMap != null &&
                    responseMap["status"] == "ERROR" &&
                    responseMap["reason"] != null) {
                  setState(() {
                    makeInvoiceError = responseMap["reason"];
                  });
                } else {
                  setState(() {
                    makeInvoiceError =
                        "could not generate invoice, unknown error";
                  });
                }
              }
              setState(() {
                makingInvoice = false;
              });
            }
          },
        ));
      }
    }
    return list;
  }
}
