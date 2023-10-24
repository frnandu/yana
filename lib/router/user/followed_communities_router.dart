import 'package:dart_ndk/nips/nip02/contact_list.dart';
import 'package:flutter/material.dart';
import 'package:yana/nostr/nip172/community_id.dart';
import 'package:yana/utils/router_path.dart';
import 'package:yana/provider/contact_list_provider.dart';
import 'package:provider/provider.dart';

import '../../utils/base.dart';
import '../../i18n/i18n.dart';
import '../../main.dart';
import '../../utils/router_util.dart';

class FollowedCommunitiesRouter extends StatefulWidget {
  const FollowedCommunitiesRouter({super.key});

  @override
  State<StatefulWidget> createState() {
    return _FollowedCommunitiesRouter();
  }
}

class _FollowedCommunitiesRouter extends State<FollowedCommunitiesRouter> {
  Nip02ContactList? contactList;

  @override
  Widget build(BuildContext context) {
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

    var s = I18n.of(context);
    var themeData = Theme.of(context);
    var titleFontSize = themeData.textTheme.bodyLarge!.fontSize;
    var hintColor = themeData.hintColor;

    var communitiesList = contactList!.followedCommunities;

    var main = ListView.builder(
      itemBuilder: (context, index) {
        var id = CommunityId.fromString(communitiesList[index]);
        if (id == null) {
          return Container();
        }

        var item = Container(
          padding: const EdgeInsets.only(
            left: Base.BASE_PADDING,
            right: Base.BASE_PADDING,
          ),
          child: Container(
              padding: const EdgeInsets.only(
                left: Base.BASE_PADDING,
                right: Base.BASE_PADDING,
                top: Base.BASE_PADDING,
                bottom: Base.BASE_PADDING,
              ),
              decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(
                color: hintColor,
              ))),
              child: Row(children: [
                Text(id.title),
                Expanded(child: Container()),
                Selector<ContactListProvider, bool>(
                    builder: (context, exist, child) {
                  IconData iconData = Icons.star_border;
                  Color? color;
                  if (exist) {
                    iconData = Icons.star;
                    color = Colors.yellow;
                  }
                  return GestureDetector(
                    onTap: () {
                      if (exist) {
                        contactListProvider.removeCommunity(id.toAString());
                      } else {
                        contactListProvider.addCommunity(id.toAString());
                      }
                    },
                    child: Container(
                      margin:
                          const EdgeInsets.only(left: Base.BASE_PADDING_HALF),
                      child: Icon(
                        iconData,
                        color: color,
                      ),
                    ),
                  );
                }, selector: (context, _provider) {
                  return _provider.containCommunity(id.toAString());
                })
              ])),
        );

        return GestureDetector(
          onTap: () {
            RouterUtil.router(context, RouterPath.COMMUNITY_DETAIL, id);
          },
          child: item,
        );
      },
      itemCount: communitiesList.length,
    );

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
          s.Followed_Communities,
          style: TextStyle(
            fontSize: titleFontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Container(
        child: main,
      ),
    );
  }
}
