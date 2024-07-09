import 'dart:io';

import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:screenshot/screenshot.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utils/base.dart';
import '../i18n/i18n.dart';
import '../utils/platform_util.dart';
import '../utils/router_util.dart';

class LightningQrcodeDialog extends StatefulWidget {
  String invoice;

  LightningQrcodeDialog({super.key,
    required this.invoice,
  });

  static Future<bool?> show(BuildContext context, String text, {String? content}) async {
    return await showDialog<bool>(
      context: context,
      builder: (_context) {
        return LightningQrcodeDialog(invoice: text);
      },
    );
  }

  @override
  State<StatefulWidget> createState() {
    return _LightningQrcodeDialog();
  }
}

class _LightningQrcodeDialog extends State<LightningQrcodeDialog> {
  static const double IMAGE_WIDTH = 40;
  static const double QR_WIDTH = 200;
  ScreenshotController screenshotController = ScreenshotController();

  @override
  Widget build(BuildContext context) {
    var themeData = Theme.of(context);
    Color cardColor = themeData.hintColor;
    var hintColor = themeData.cardColor;

    List<Widget> list = [];
    list.add(Container(
      margin: const EdgeInsets.only(
        top: Base.BASE_PADDING,
        bottom: Base.BASE_PADDING,
        left: Base.BASE_PADDING_HALF,
        right: Base.BASE_PADDING_HALF,
      ),
      child: PrettyQrView.data(
          data: widget.invoice,
          decoration: const PrettyQrDecoration(
              shape: PrettyQrSmoothSymbol(roundFactor: 0),
              image: PrettyQrDecorationImage(

                image: AssetImage('assets/imgs/logo/logo-new.png'),
              ),
              )
      ),
      // child: PrettyQr(
      //   data: nip19Pubkey,
      //   size: QR_WIDTH,
      // ),
    ));
    list.add(GestureDetector(
      onTap: () {
        _doCopy(widget.invoice);
      },
      child: Container(
        // width: QR_WIDTH + Base.BASE_PADDING_HALF * 2,
        padding: EdgeInsets.all(Base.BASE_PADDING_HALF),
        decoration: BoxDecoration(
          color: hintColor.withOpacity(0.5),
          borderRadius: BorderRadius.circular(10),
        ),
        child: SelectableText(
          "Copy invoice",
          onTap: () {
            _doCopy(widget.invoice);
          },
        ),
      ),
    ));
    if (PlatformUtil.isPC() || PlatformUtil.isWeb() || true) {
      var link = 'lightning:${widget.invoice}';

      list.add(GestureDetector(
        onTap: () {
          _doPay(link);
        },
        child: Container(
          // width: QR_WIDTH + Base.BASE_PADDING_HALF * 2,
          padding: EdgeInsets.all(Base.BASE_PADDING_HALF),
          decoration: BoxDecoration(
            color: hintColor.withOpacity(0.5),
            borderRadius: BorderRadius.circular(10),
          ),
          child: SelectableText(
            "Open in app",
            onTap: () {
              _doPay(link);
            },
          ),
        ),
      ));
    }

    var main = Stack(
      children: [
        Screenshot(
          controller: screenshotController,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cardColor,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: list,
            ),
          ),
        ),
      ],
    );

    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.2),
      body: FocusScope(
        // autofocus: true,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            RouterUtil.back(context);
          },
          child: Container(
            width: double.infinity,
            height: double.infinity,
            padding: const EdgeInsets.only(
              left: Base.BASE_PADDING,
              right: Base.BASE_PADDING,
            ),
            child: GestureDetector(
              onTap: () {},
              child: main,
            ),
            alignment: Alignment.center,
          ),
        ),
      ),
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   var s = I18n.of(context);
  //   var themeData = Theme.of(context);
  //   Color cardColor = themeData.cardColor;
  //   var hintColor = themeData.hintColor;
  //
  //   List<Widget> list = [];
  //   list.add(Container(
  //     child: Text(s.Use_lightning_wallet_scan_and_send_sats),
  //   ));
  //   list.add(Container(
  //       margin: const EdgeInsets.only(
  //         top: Base.BASE_PADDING,
  //         bottom: Base.BASE_PADDING,
  //         left: Base.BASE_PADDING_HALF,
  //         right: Base.BASE_PADDING_HALF,
  //       ),
  //       child: PrettyQrView.data(
  //         data: widget.text,
  //         decoration: const PrettyQrDecoration(
  //             // image: PrettyQrDecorationImage(
  //             //   image: AssetImage('images/flutter.png'),
  //             // ),
  //             ),
  //       )
  //       // PrettyQr(
  //       //   data: widget.text,
  //       //   size: QR_WIDTH,
  //       // ),
  //       ));
  //   list.add(GestureDetector(
  //     onTap: () {
  //       _doCopy(widget.text);
  //     },
  //     child: Container(
  //       padding: const EdgeInsets.all(Base.BASE_PADDING_HALF),
  //       margin: const EdgeInsets.only(
  //         left: 20,
  //         right: 20,
  //         bottom: Base.BASE_PADDING_HALF,
  //       ),
  //       decoration: BoxDecoration(
  //         color: hintColor.withOpacity(0.5),
  //         borderRadius: BorderRadius.circular(10),
  //       ),
  //       child: SelectableText(
  //         widget.text,
  //         onTap: () {
  //           _doCopy(widget.text);
  //         },
  //       ),
  //     ),
  //   ));
  //
  //   var main = Container(
  //     width: QR_WIDTH + 200,
  //     padding: const EdgeInsets.only(
  //       top: 20,
  //       bottom: 20,
  //     ),
  //     decoration: BoxDecoration(
  //       color: cardColor,
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.center,
  //       mainAxisSize: MainAxisSize.min,
  //       children: list,
  //     ),
  //   );
  //
  //   return Scaffold(
  //     // backgroundColor: Colors.black.withOpacity(0.2),
  //     body: FocusScope(
  //       // autofocus: true,
  //       child: GestureDetector(
  //         behavior: HitTestBehavior.opaque,
  //         onTap: () {
  //           RouterUtil.back(context);
  //         },
  //         child: Container(
  //           width: double.infinity,
  //           height: double.infinity,
  //           padding: const EdgeInsets.only(
  //             left: Base.BASE_PADDING,
  //             right: Base.BASE_PADDING,
  //           ),
  //           child: PrettyQrView.data(
  //               data: widget.text,
  //               // decoration: const PrettyQrDecoration(
  //               //     // image: PrettyQrDecorationImage(
  //               //     //   image: AssetImage('images/flutter.png'),
  //               //     // ),
  //               //     )
  //           ),
  //
  //           // GestureDetector(
  //           //   onTap: () {},
  //           //   child: main,
  //           // ),
  //           alignment: Alignment.center,
  //         ),
  //       ),
  //     ),
  //   );
  // }

  void _doCopy(String text) {
    Clipboard.setData(ClipboardData(text: text)).then((_) {
      EasyLoading.show(status: I18n.of(context).Copy_success, dismissOnTap: true);
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
