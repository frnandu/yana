import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../nostr/event.dart';
import '../../nostr/nip02/cust_contact_list.dart';
import '../../ui/event/zap_event_list_component.dart';
import '../../ui/user/metadata_component.dart';
import '../../utils/base.dart';
import '../../utils/router_path.dart';
import '../../models/metadata.dart';
import '../../i18n/i18n.dart';
import '../../provider/metadata_provider.dart';
import '../../utils/router_util.dart';

class UserZapListRouter extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _UserZapListRouter();
  }
}

class _UserZapListRouter extends State<UserZapListRouter> {
  List<Event>? zapList;

  @override
  Widget build(BuildContext context) {
    var s = I18n.of(context);

    if (zapList == null) {
      var arg = RouterUtil.routerArgs(context);
      if (arg != null) {
        zapList = arg as List<Event>;
      }
    }
    if (zapList == null) {
      RouterUtil.back(context);
      return Container();
    }

    var themeData = Theme.of(context);
    var titleFontSize = themeData.textTheme.bodyLarge!.fontSize;

    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            RouterUtil.back(context);
          },
          child: Icon(
            Icons.arrow_back_ios,
            color: themeData.appBarTheme.titleTextStyle!.color,
          ),
        ),
        title: Text(
          "⚡Zaps⚡",
          style: TextStyle(
            fontSize: titleFontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView.builder(
        itemBuilder: (context, index) {
          var zapEvent = zapList![index];
          return ZapEventListComponent(event: zapEvent);
        },
        itemCount: zapList!.length,
      ),
    );
  }
}
