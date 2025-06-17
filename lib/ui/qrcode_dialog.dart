import 'package:ndk/entities.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:provider/provider.dart';
import 'package:yana/nostr/nip19/nip19.dart';

import '../main.dart';
import '../utils/base.dart';
import '../i18n/i18n.dart';
import '../provider/metadata_provider.dart';
import 'package:go_router/go_router.dart';

class QrcodeDialog extends StatefulWidget {
  String pubkey;

  QrcodeDialog({required this.pubkey});

  static Future<String?> show(BuildContext context, String pubkey) async {
    return await showDialog<String>(
        context: context,
        builder: (_context) {
          return QrcodeDialog(
            pubkey: pubkey,
          );
        });
  }

  @override
  State<StatefulWidget> createState() {
    return _QrcodeDialog();
  }
}

class _QrcodeDialog extends State<QrcodeDialog> {
  static const double IMAGE_WIDTH = 40;
  static const double QR_WIDTH = 255;

  // ScreenshotController screenshotController = ScreenshotController();

  @override
  Widget build(BuildContext context) {
    var themeData = Theme.of(context);
    Color cardColor = themeData.hintColor;
    var hintColor = themeData.cardColor;

    List<Widget> list = [];
    var nip19Pubkey = Nip19.encodePubKey(widget.pubkey);
    Widget topWidget = FutureBuilder<Metadata?>(
        future: metadataProvider.getMetadata(widget.pubkey),
        builder: (context, snapshot) {
          return Container(
            width: QR_WIDTH,
            margin: const EdgeInsets.only(
              left: Base.BASE_PADDING_HALF,
              right: Base.BASE_PADDING_HALF,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: EdgeInsets.only(left: Base.BASE_PADDING_HALF),
                  child: Container(
                    width: QR_WIDTH - IMAGE_WIDTH - Base.BASE_PADDING_HALF,
                  ),
                ),
              ],
            ),
          );
        });
    list.add(topWidget);
    list.add(Container(
      margin: const EdgeInsets.only(
        top: Base.BASE_PADDING,
        bottom: Base.BASE_PADDING,
        left: Base.BASE_PADDING_HALF,
        right: Base.BASE_PADDING_HALF,
      ),
      child: PrettyQr(
        data: nip19Pubkey,
        size: QR_WIDTH,
      ),
    ));
    list.add(GestureDetector(
      onTap: () {
        _doCopy(nip19Pubkey);
      },
      child: Container(
        width: QR_WIDTH + Base.BASE_PADDING_HALF * 2,
        padding: const EdgeInsets.all(Base.BASE_PADDING_HALF),
        decoration: BoxDecoration(
          color: hintColor.withOpacity(0.5),
          borderRadius: BorderRadius.circular(10),
        ),
        child: SelectableText(
          nip19Pubkey,
          onTap: () {
            _doCopy(nip19Pubkey);
          },
        ),
      ),
    ));

    var main = Stack(
      children: [
        // Screenshot(
        //   controller: screenshotController,
        //   child:
        Container(
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
        // ),
      ],
    );

    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.2),
      body: FocusScope(
        // autofocus: true,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            context.pop();
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

  void _doCopy(String text) {
    Clipboard.setData(ClipboardData(text: text)).then((_) {
      EasyLoading.show(status: I18n.of(context).key_has_been_copied);
    });
  }
}
