import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';
import 'package:yana/provider/dm_provider.dart';
import 'package:yana/provider/index_provider.dart';

import '../../i18n/i18n.dart';
import '../../main.dart';
import '../../models/event_mem_box.dart';
import '../../provider/follow_new_event_provider.dart';
import '../../provider/new_notifications_provider.dart';

class IndexBottomBar extends StatefulWidget {
  static const double HEIGHT = 60;

  IndexBottomBar({super.key});

  @override
  State<StatefulWidget> createState() {
    return _IndexBottomBar();
  }
}

class _IndexBottomBar extends State<IndexBottomBar> {
  int selectedPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    var themeData = Theme.of(context);
    var _indexProvider = Provider.of<IndexProvider>(context);
    var _followEventProvider = Provider.of<FollowNewEventProvider>(context);
    var _mentionMeProvider = Provider.of<NewNotificationsProvider>(context);

    List<Widget> destinations = [];

    var s = I18n.of(context);

    destinations.add(NavigationDestination(
      icon: Selector<FollowNewEventProvider, Tuple2<EventMemBox, EventMemBox>>(
        builder: (context, tuple, child) {
          Icon icon = selectedPageIndex == 0 ? Icon(
              Icons.home, size: 30, color: themeData.dividerColor) : Icon(
              Icons.home_outlined, size: 30, color: themeData.disabledColor);
          if (tuple.item1.length() <= 0 && tuple.item2.length() <= 0) {
            return icon;
          }
          int total = tuple.item1.length() + tuple.item2.length();
          return Badge(
              offset: const Offset(8, 0),
              label: Text(total.toString(),
                  style: const TextStyle(color: Colors.white)),
              backgroundColor: const Color(0xFF6A1B9A),
              child: icon);
        },
        selector: (context, _provider) {
          return Tuple2(
              _provider.eventPostsMemBox, _provider.eventPostsAndRepliesMemBox);
        },
      ),
      label: s.Feed,
    ));

    destinations.add(NavigationDestination(
      selectedIcon: Icon(Icons.search, size: 30, color: themeData.dividerColor),
      icon: Icon(Icons.search, size: 30, color: themeData.disabledColor),
      label: s.Search,
    ));

    destinations.add(NavigationDestination(
      icon: Selector<DMProvider, int>(
        builder: (context, count, child) {
          Icon icon = selectedPageIndex == 2 ? Icon(
              Icons.mail, size: 30, color: themeData.dividerColor) : Icon(
              Icons.mail_outline, size: 30, color: themeData.disabledColor);
          // FlutterAppBadger.updateBadgeCount(count);
          if (count <= 0) {
            return icon;
          }
          return Badge(
              offset: const Offset(8, 0),
              label: Text(count.toString(),
                  style: const TextStyle(color: Colors.white)),
              backgroundColor: const Color(0xFF6A1B9A),
              child: icon);
        },
        selector: (context, _provider) {
          return
            _provider.howManyNewDMSessionsWithNewMessages(
                _provider.followingList) +
                _provider.howManyNewDMSessionsWithNewMessages(
                    _provider.knownList) +
                _provider.howManyNewDMSessionsWithNewMessages(
                    _provider.unknownList)
          ;
        },
      ),
      label: s.Messages,
    ));


    destinations.add(NavigationDestination(
      icon: Selector<NewNotificationsProvider, EventMemBox>(
        builder: (context, eventMemBox, child) {
          Icon icon = selectedPageIndex == 3
              ? Icon(
              Icons.notifications, size: 30, color: themeData.dividerColor)
              : Icon(Icons.notifications_none_outlined, size: 30,
              color: themeData.disabledColor);
          if (eventMemBox.length() <= 0) {
            return icon;
          }
          return Badge(
              offset: const Offset(8, 0),
              label: Text(eventMemBox.length().toString(),
                style: const TextStyle(color: Colors.white),),
              backgroundColor: const Color(0xFF6A1B9A),
              child: icon);
        },
        selector: (context, _provider) {
          return _provider.eventMemBox;
        },
      ),
      label: s.Notifications,
    ));

    return NavigationBar(
      labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
      indicatorColor: themeData.cardColor,
      selectedIndex: selectedPageIndex,
      onDestinationSelected: (int index) {
        if (selectedPageIndex == index) {
          if (index == 0) indexProvider.followScrollToTop();
        } else {
          indexProvider.setCurrentTap(index);
        }

        setState(() {
          selectedPageIndex = index;
        });
      },
      destinations: destinations,
    );
  }

  @override
  Future<void> onReady(BuildContext context) async {}
}
