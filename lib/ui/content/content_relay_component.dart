import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yana/main.dart';
import 'package:yana/provider/relay_provider.dart';

import '../../i18n/i18n.dart';
import '../../utils/base.dart';
import '../confirm_dialog.dart';

class ContentRelayComponent extends StatelessWidget {
  String addr;

  ContentRelayComponent(this.addr, {super.key});

  @override
  Widget build(BuildContext context) {
    var themeData = Theme.of(context);
    Color? cardColor = themeData.cardColor;
    if (cardColor == Colors.white) {
      cardColor = Colors.grey[300];
    }
    var fontSize = themeData.textTheme.bodyMedium!.fontSize;

    return Selector<RelayProvider, bool>(
        builder: (context, addable, client) {
      List<Widget> list = [
        Icon(
          Icons.lan,
          size: fontSize,
        ),
        Container(
          margin: const EdgeInsets.only(
            left: 6,
            right: 4,
          ),
          child: Text(addr),
        )
      ];
      if (addable) {
        list.add(Icon(
          Icons.add,
          size: fontSize,
        ));
      }

      Widget main = Container(
        padding: const EdgeInsets.only(
          left: Base.BASE_PADDING_HALF,
          right: Base.BASE_PADDING_HALF,
          top: 2,
          bottom: 2,
        ),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: list,
        ),
      );

      if (addable) {
        main = GestureDetector(
          onTap: () async {
            var result = await ConfirmDialog.show(
                context, I18n.of(context).Add_this_relay_to_local);
            if (result == true) {
              await relayProvider.addRelay(addr);
            }
          },
          child: main,
        );
      }

      return main;
    }, selector: (context, _provider) {
      return !myInboxRelaySet!.urls.contains(addr) && myOutboxRelaySet!.urls.contains(addr);
    });
  }
}
