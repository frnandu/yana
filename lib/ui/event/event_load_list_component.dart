import 'package:flutter/material.dart';

import '../../utils/base.dart';
import '../../i18n/i18n.dart';

class EventLoadListComponent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var themeData = Theme.of(context);
    var cardColor = themeData.cardColor;

    var s = I18n.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: Base.BASE_PADDING_HALF),
      color: cardColor,
      height: 60,
      child: Center(child: Text(s.Note_loading)),
    );
  }
}
