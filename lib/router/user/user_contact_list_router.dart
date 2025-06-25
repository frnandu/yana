import 'package:ndk/domain_layer/entities/contact_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yana/main.dart';

import 'package:go_router/go_router.dart';

import '../../i18n/i18n.dart';
import '../../provider/contact_list_provider.dart';
import 'user_contact_list_component.dart';

class UserContactListRouter extends StatefulWidget {
  const UserContactListRouter({super.key});

  @override
  State<StatefulWidget> createState() {
    return _UserContactListRouter();
  }
}

class _UserContactListRouter extends State<UserContactListRouter> {
  String? pubKey;

  @override
  Widget build(BuildContext context) {
    var contactListProvider = Provider.of<ContactListProvider>(context);

    var s = I18n.of(context);

    if (pubKey == null) {
      var arg = GoRouterState.of(context).extra;
      if (arg != null) {
        pubKey = arg as String;
        contactListProvider?.loadContactList(pubKey!).then(
          (value) {
            setState(() {});
          },
        );
      }
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
            s.Following,
            style: TextStyle(
              fontSize: titleFontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: FutureBuilder<ContactList?>(
            future: contactListProvider.getContactList(pubKey!),
            builder: (context, snapshot) {
              var contactList = snapshot.data;
              if (contactList != null) {
                return UserContactListComponent(contactList: contactList);
              }
              return Container();
            }));
  }
}
