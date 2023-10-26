import 'package:flutter/material.dart';
import 'package:yana/utils/string_util.dart';

class ContentStrLinkComponent extends StatelessWidget {
  bool showUnderline;

  String str;

  Function onTap;

  ContentStrLinkComponent(
      {required this.str, required this.onTap, this.showUnderline = true});

  @override
  Widget build(BuildContext context) {
    var themeData = Theme.of(context);
    var mainColor = themeData.primaryColor;
    return GestureDetector(
      onTap: () {
        this.onTap();
      },
      child: Transform.translate( offset: const Offset(0, 4), child: Container(
        margin: const EdgeInsets.only(bottom: 3, right:3, left:0),
        child: Text(
          StringUtil.breakWord(str),
          style: TextStyle(
            color: mainColor,
            fontSize: themeData.textTheme.bodyLarge!.fontSize! - 1
            // decoration:
            //     showUnderline ? TextDecoration.underline : TextDecoration.none,
          ),
        ),
      ),
    ));
  }
}
