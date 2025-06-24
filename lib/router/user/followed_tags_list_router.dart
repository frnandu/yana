import 'package:ndk/domain_layer/entities/contact_list.dart';
import 'package:flutter/material.dart';
import 'package:yana/ui/tag_info_component.dart';
import 'package:yana/utils/base.dart';

import 'package:go_router/go_router.dart';

import '../../i18n/i18n.dart';

class FollowedTagsListRouter extends StatefulWidget {
  const FollowedTagsListRouter({super.key});

  @override
  State<StatefulWidget> createState() {
    return _FollowedTagsListRouter();
  }
}

class _FollowedTagsListRouter extends State<FollowedTagsListRouter> {
  ContactList? contactList;

  @override
  Widget build(BuildContext context) {
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

    var s = I18n.of(context);
    var themeData = Theme.of(context);
    var titleFontSize = themeData.textTheme.bodyLarge!.fontSize;

    var tagList = contactList!.followedTags;

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
