import 'package:flutter/material.dart';

import '../../utils/base.dart';

class SettingGroupTitleComponent extends StatelessWidget {
  IconData iconData;

  String title;

  SettingGroupTitleComponent({super.key,
    required this.iconData,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    var themeData = Theme.of(context);
    var hintColor = themeData.hintColor;
    var fontSize = themeData.textTheme.bodyMedium!.fontSize;

    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.only(
          top: 30,
        ),
        child: Row(
          children: [
            Container(
              margin: const EdgeInsets.only(right: Base.BASE_PADDING_HALF),
              child: Icon(
                iconData,
                color: hintColor,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                color: hintColor,
                fontWeight: FontWeight.bold,
                fontSize: fontSize,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
