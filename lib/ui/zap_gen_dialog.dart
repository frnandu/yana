import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter/material.dart';

import '../i18n/i18n.dart';
import '../nostr/nip47/nwc_notification.dart';
import '../nostr/nip57/zap_action.dart';
import '../utils/base.dart';
import '../utils/router_util.dart';

class ZapGenDialog extends StatefulWidget {
  String pubkey;

  String? eventId;

  BuildContext parentContext;

  Function(NwcNotification?) onZapped;

  ZapGenDialog(
      {super.key,
      required this.pubkey,
      this.eventId,
      required this.parentContext,
      required this.onZapped});

  static Future<void> show(BuildContext context, String pubkey,
      {String? eventId, required Function(NwcNotification?) onZapped}) async {
    return await showDialog<void>(
      context: context,
      builder: (_context) {
        return ZapGenDialog(
            pubkey: pubkey,
            eventId: eventId,
            parentContext: context,
            onZapped: onZapped);
      },
    );
  }

  @override
  State<StatefulWidget> createState() {
    return _ZapGenDialog();
  }
}

class _ZapGenDialog extends State<ZapGenDialog> {
  late TextEditingController controller;
  late TextEditingController commentController;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
    commentController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    var s = I18n.of(context);
    var themeData = Theme.of(context);
    Color cardColor = themeData.cardColor;
    var mainColor = themeData.primaryColor;
    var titleFontSize = themeData.textTheme.bodyLarge!.fontSize;

    List<Widget> list = [];

    list.add(Container(
      margin: const EdgeInsets.only(bottom: Base.BASE_PADDING),
      child: Text(
        s.Input_Sats_num,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: titleFontSize,
        ),
      ),
    ));

    list.add(Container(
      margin: EdgeInsets.only(bottom: Base.BASE_PADDING),
      child: TextField(
        controller: controller,
        minLines: 1,
        maxLines: 1,
        autofocus: true,
        decoration: InputDecoration(
          hintText: s.Input_Sats_num,
          border: OutlineInputBorder(borderSide: BorderSide(width: 1)),
        ),
      ),
    ));

    list.add(Container(
      child: TextField(
        controller: commentController,
        minLines: 1,
        maxLines: 1,
        autofocus: true,
        decoration: InputDecoration(
          hintText: "${s.Input_Comment} (${s.Optional})",
          border: OutlineInputBorder(borderSide: BorderSide(width: 1)),
        ),
      ),
    ));

    // list.add(Expanded(child: Container()));

    list.add(Container(
      margin: EdgeInsets.only(
        top: Base.BASE_PADDING,
        bottom: 6,
      ),
      child: Ink(
        decoration: BoxDecoration(color: mainColor),
        child: InkWell(
          onTap: () {
            _onConfirm();
          },
          highlightColor: mainColor.withOpacity(0.2),
          child: Container(
            color: mainColor,
            height: 40,
            alignment: Alignment.center,
            child: Text(
              I18n.of(context).Confirm,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    ));

    var main = Container(
      padding: EdgeInsets.all(Base.BASE_PADDING),
      decoration: BoxDecoration(
        color: cardColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: list,
      ),
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
            // height: double.infinity,
            padding: const EdgeInsets.only(
              left: Base.BASE_PADDING,
              right: Base.BASE_PADDING,
            ),
            alignment: Alignment.center,
            child: GestureDetector(
              onTap: () {},
              child: main,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _onConfirm() async {
    var text = controller.text;
    var num = int.tryParse(text);
    if (num == null) {
      EasyLoading.show(status: I18n.of(context).Number_parse_error);
      return;
    }

    var comment = commentController.text;
    RouterUtil.back(context);

    await ZapAction.handleZap(widget.parentContext, num, widget.pubkey,
        eventId: widget.eventId, comment: comment, onZapped: widget.onZapped);
  }
}
