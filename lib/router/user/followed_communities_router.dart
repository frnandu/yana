import 'package:ndk/domain_layer/entities/contact_list.dart';
import 'package:flutter/material.dart';
import 'package:yana/nostr/nip172/community_id.dart';
import 'package:yana/utils/router_path.dart';
import 'package:yana/provider/contact_list_provider.dart';
import 'package:provider/provider.dart';

import 'package:go_router/go_router.dart';

import '../../utils/base.dart';
import '../../i18n/i18n.dart';
import '../../main.dart';

class FollowedCommunitiesRouter extends StatefulWidget {
  const FollowedCommunitiesRouter({super.key});

  @override
  State<StatefulWidget> createState() {
    return _FollowedCommunitiesRouter();
  }
}

class _FollowedCommunitiesRouter extends State<FollowedCommunitiesRouter> {
  ContactList? contactList;

  bool? follows;

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
                FutureBuilder<bool?>(
                    future:
                        contactListProvider.followsCommunity(id.toAString()),
                    builder: (context, snapshot) {
                      bool exist = snapshot.hasData && snapshot.data!;
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
                          margin: const EdgeInsets.only(
                              left: Base.BASE_PADDING_HALF),
                          child: Icon(
                            iconData,
                            color: color,
                          ),
                        ),
                      );
                    })
              ])),
        );

        return GestureDetector(
          onTap: () {
            context.go(RouterPath.COMMUNITY_DETAIL, extra: id);
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
            context.pop();
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
