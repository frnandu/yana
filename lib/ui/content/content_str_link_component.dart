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
      child: Container(
        margin: const EdgeInsets.only(top: 3, right:3),
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
    );
  }
}
