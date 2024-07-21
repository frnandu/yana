import 'package:dart_ndk/shared/nips/nip02/contact_list.dart';
import 'package:flutter/material.dart';

import '../../i18n/i18n.dart';
import '../../utils/router_util.dart';
import 'user_contact_list_component.dart';

class UserHistoryContactListRouter extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _UserHistoryContactListRouter();
  }
}

class _UserHistoryContactListRouter
    extends State<UserHistoryContactListRouter> {
  ContactList? contactList;

  @override
  Widget build(BuildContext context) {
    var s = I18n.of(context);

    if (contactList == null) {
      var arg = RouterUtil.routerArgs(context);
      if (arg != null) {
        contactList = arg as ContactList;
      }
    }
    if (contactList == null) {
      RouterUtil.back(context);
      return Container();
    }
    var themeData = Theme.of(context);
    var titleFontSize = themeData.textTheme.bodyLarge!.fontSize;
    var titleTextColor = themeData.appBarTheme.titleTextStyle!.color;

    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            RouterUtil.back(context);
          },
          child: Icon(
            Icons.arrow_back_ios,
            color: titleTextColor,
          ),
        ),
        title: Text(
          s.Following,
          style: TextStyle(
            fontSize: titleFontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Container(
            child: TextButton(
              child: Text(
                s.Recovery,
                style: TextStyle(
                  color: titleTextColor,
                  fontSize: 16,
                ),
              ),
              onPressed: doRecovery,
              style: ButtonStyle(),
            ),
          ),
        ],
      ),
      body: UserContactListComponent(contactList: contactList!),
    );
  }

  void doRecovery() {
    // contactListProvider.updateContacts(contactList!);
    RouterUtil.back(context);
  }
}
