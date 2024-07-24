import 'package:dart_ndk/domain_layer/entities/contact_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yana/main.dart';

import '../../i18n/i18n.dart';
import '../../provider/contact_list_provider.dart';
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
  String? pubKey;

  @override
  Widget build(BuildContext context) {
    var _contactListProvider = Provider.of<ContactListProvider>(context);

    var s = I18n.of(context);

    if (pubKey == null) {
      var arg = RouterUtil.routerArgs(context);
      if (arg != null) {
        pubKey = arg as String;
        contactListProvider.loadContactList(pubKey!).then((value) {
          setState(() {
          });
        },);
      }
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
        body:  Selector<ContactListProvider, ContactList?>(
            builder: (context, contactList, child) {
              if (contactList!=null) {
                return UserContactListComponent(contactList: contactList);
              }
              return Container();
            },
            selector: (context, _provider) {
              return contactListProvider.getContactList(pubKey!);
            }
        )
    );
  }
}
