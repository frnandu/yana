import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yana/utils/base.dart';

import '../utils/router_util.dart';

class Appbar4Stack extends StatefulWidget {
  Widget? title;

  Color? backgroundColor;

  Widget? action;

  Appbar4Stack({
    this.title,
    this.backgroundColor,
    this.action,
  });

  @override
  State<StatefulWidget> createState() {
    return _Appbar4Stack();
  }
}

class _Appbar4Stack extends State<Appbar4Stack> {
  double height = 46;

  @override
  Widget build(BuildContext context) {
    var themeData = Theme.of(context);
    var backgroundColor = widget.backgroundColor;
    if (backgroundColor == null) {
      backgroundColor = themeData.appBarTheme.backgroundColor;
    }

    List<Widget> list = [
      GestureDetector(
        child: Container(
          alignment: Alignment.center,
          width: height,
          child: const Icon(Icons.arrow_back_ios_new),
        ),
        onTap: () {
          context.pop();
        },
      )
    ];

    if (widget.title != null) {
      list.add(Expanded(child: widget.title!));
    } else {
      list.add(Expanded(child: Container()));
    }

    if (widget.action != null) {
      list.add(Container(
        child: widget.action,
      ));
    } else {
      list.add(Container(
        width: height,
      ));
    }

    return Container(
      margin: const EdgeInsets.only(top:Base.BASE_PADDING),
      height: height,
      color: backgroundColor,
      // color: Colors.red,
      child: Row(
        children: list,
      ),
    );
  }
}
