import 'package:flutter/material.dart';
import 'package:yana/main.dart';
import 'package:yana/utils/string_util.dart';

import '../utils/base.dart';
import '../i18n/i18n.dart';
import 'package:go_router/go_router.dart';

class NIP07Dialog extends StatefulWidget {
  String method;

  String? content;

  NIP07Dialog({
    required this.method,
    this.content,
  });

  static Future<bool?> show(BuildContext context, String method,
      {String? content}) async {
    return await showDialog<bool>(
      context: context,
      builder: (_context) {
        return NIP07Dialog(
          method: method,
          content: content,
        );
      },
    );
  }

  @override
  State<StatefulWidget> createState() {
    return _NIP07Dialog();
  }
}

class _NIP07Dialog extends State<NIP07Dialog> {
  @override
  Widget build(BuildContext context) {
    var themeData = Theme.of(context);
    var mainColor = themeData.primaryColor;
    var titleFontSize = themeData.textTheme.bodyLarge!.fontSize;
    Color cardColor = themeData.cardColor;
    var hintColor = themeData.hintColor;

    var s = I18n.of(context);

    List<Widget> list = [];
    list.add(Container(
      child: Text(
        "NIP-07 ${s.Confirm}",
        style: TextStyle(
          fontSize: titleFontSize! + 4,
          fontWeight: FontWeight.bold,
        ),
      ),
    ));

    list.add(Divider());

    list.add(Container(
      margin: EdgeInsets.only(bottom: Base.BASE_PADDING_HALF),
      child: Row(
        children: [
          Text("${s.Method}:  "),
          Text(widget.method),
        ],
      ),
    ));

    if (StringUtil.isNotBlank(widget.content)) {
      list.add(Container(
        child: Text("${s.Content}:"),
      ));
      list.add(Container(
        width: double.maxFinite,
        padding: const EdgeInsets.all(Base.BASE_PADDING_HALF),
        decoration: BoxDecoration(
          color: hintColor.withOpacity(0.3),
          borderRadius: BorderRadius.circular(6),
        ),
        margin: const EdgeInsets.only(
          bottom: Base.BASE_PADDING_HALF,
          top: Base.BASE_PADDING_HALF,
        ),
        child: SelectableText(widget.content!),
      ));
    }

    list.add(Container(
      margin: EdgeInsets.only(top: Base.BASE_PADDING_HALF),
      child: Row(children: [
        Expanded(
            child: InkWell(
          onTap: () {
            context.pop(false);
          },
          child: Container(
            height: 36,
            color: hintColor.withOpacity(0.3),
            alignment: Alignment.center,
            child: Text(
              s.Cancel,
              style: TextStyle(
                fontSize: titleFontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        )),
        Container(
          width: Base.BASE_PADDING,
        ),
        Expanded(
            child: InkWell(
          onTap: () {
            context.pop(true);
          },
          child: Container(
            height: 36,
            color: hintColor.withOpacity(0.3),
            alignment: Alignment.center,
            child: Text(
              s.Confirm,
              style: TextStyle(
                fontSize: titleFontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        )),
      ]),
    ));

    var main = Container(
      padding: const EdgeInsets.all(20),
      constraints: BoxConstraints(maxHeight: mediaDataCache.size.height * 0.85),
      decoration: BoxDecoration(
        color: cardColor,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: list,
        ),
      ),
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
}
