import 'package:ndk/domain_layer/entities/contact_list.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../i18n/i18n.dart';
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
      var arg = GoRouterState.of(context).extra;
      if (arg != null) {
        contactList = arg as ContactList;
      }
    }
    if (contactList == null) {
      context.pop();
      return Container();
    }
    var themeData = Theme.of(context);
    var titleFontSize = themeData.textTheme.bodyLarge!.fontSize;
    var titleTextColor = themeData.appBarTheme.titleTextStyle!.color;

    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            context.pop();
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
    context.pop();
  }
}
