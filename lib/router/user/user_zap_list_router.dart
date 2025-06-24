import 'package:ndk/domain_layer/entities/nip_01_event.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../ui/event/zap_event_list_component.dart';

class UserZapListRouter extends StatefulWidget {
  const UserZapListRouter({super.key});

  @override
  State<StatefulWidget> createState() {
    return _UserZapListRouter();
  }
}

class _UserZapListRouter extends State<UserZapListRouter> {
  List<Nip01Event>? zapList;

  @override
  Widget build(BuildContext context) {
    if (zapList == null) {
      var arg = GoRouterState.of(context).extra;
      if (arg != null) {
        zapList = arg as List<Nip01Event>;
      }
    }
    if (zapList == null) {
      context.pop();
      return Container();
    }

    var themeData = Theme.of(context);
    var titleFontSize = themeData.textTheme.bodyLarge!.fontSize;

    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            context.pop();
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
