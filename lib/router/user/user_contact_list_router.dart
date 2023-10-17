import 'package:dart_ndk/nips/nip02/contact_list.dart';
import 'package:flutter/material.dart';

import '../../nostr/nip02/contact_list.dart';
import '../../i18n/i18n.dart';
import '../../utils/router_util.dart';
import 'user_contact_list_component.dart';

class UserContactListRouter extends StatefulWidget {
  const UserContactListRouter({super.key});

  @override
  State<StatefulWidget> createState() {
    return _UserContactListRouter();
  }
}

class _UserContactListRouter extends State<UserContactListRouter> {
  Nip02ContactList? contactList;

  @override
  Widget build(BuildContext context) {
    var s = I18n.of(context);

    if (contactList == null) {
      var arg = RouterUtil.routerArgs(context);
      if (arg != null) {
        contactList = arg as Nip02ContactList;
      }
    }
    if (contactList == null) {
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
          s.Following,
          style: TextStyle(
            fontSize: titleFontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: UserContactListComponent(contactList: contactList!),
    );
  }
}
