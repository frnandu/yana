import 'package:flutter/material.dart';
import 'package:yana/ui/tag_info_component.dart';
import 'package:yana/utils/base.dart';

import '../../nostr/nip02/cust_contact_list.dart';
import '../../i18n/i18n.dart';
import '../../utils/router_util.dart';

class FollowedTagsListRouter extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _FollowedTagsListRouter();
  }
}

class _FollowedTagsListRouter extends State<FollowedTagsListRouter> {
  CustContactList? contactList;

  @override
  Widget build(BuildContext context) {
    if (contactList == null) {
      var arg = RouterUtil.routerArgs(context);
      if (arg != null) {
        contactList = arg as CustContactList;
      }
    }
    if (contactList == null) {
      RouterUtil.back(context);
      return Container();
    }

    var s = I18n.of(context);
    var themeData = Theme.of(context);
    var titleFontSize = themeData.textTheme.bodyLarge!.fontSize;

    var tagList = contactList!.tagList().toList();

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
          s.Followed_Tags,
          style: TextStyle(
            fontSize: titleFontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 3,
          crossAxisSpacing: Base.BASE_PADDING_HALF,
        ),
        itemBuilder: (context, index) {
          var tag = tagList[index];

          return TagInfoComponent(
            tag: tag,
            jumpable: true,
          );
        },
        itemCount: tagList.length,
      ),
    );
  }
}
