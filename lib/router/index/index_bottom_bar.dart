import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';
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
  int feedBadgeCount = 0;
  int messagesBadgeCount = 0;
  int notificaationsBadgeCount = 0;

  @override
  Widget build(BuildContext context) {
    var themeData = Theme.of(context);
    var _indexProvider = Provider.of<IndexProvider>(context);
    var _followEventProvider = Provider.of<FollowNewEventProvider>(context);
    var _mentionMeProvider = Provider.of<NewNotificationsProvider>(context);


    List<Widget> destinations = [];

    var s = I18n.of(context);

    destinations.add(NavigationDestination(
      icon: Selector<FollowNewEventProvider, Tuple2<EventMemBox,EventMemBox>>(
        builder: (context, tuple, child) {
          if (tuple.item1.length() <= 0 && tuple.item2.length() <=0 || selectedPageIndex==0) {
            return const Icon(Icons.home_outlined);
          }
          int total = tuple.item1.length() + tuple.item2.length();
          return Badge(
              label: Text(total.toString()),
              backgroundColor: themeData.primaryColor,
              child: const Icon(Icons.home_outlined));
        },
        selector: (context, _provider) {
          return Tuple2(_provider.eventPostsMemBox, _provider.eventPostsAndRepliesMemBox);
        },
      ),
      label: s.Feed,
    ));

    destinations.add(NavigationDestination(
      icon: const Icon(Icons.search),
      label: s.Search,
    ));

    destinations.add(NavigationDestination(
      icon: const Icon(Icons.mail_outline),
      label: s.Messages,
    ));

    destinations.add(NavigationDestination(
      icon: Selector<NewNotificationsProvider,EventMemBox>(
        builder: (context, eventMemBox, child) {
          if (eventMemBox.length() <= 0 || selectedPageIndex==3) {
            return const Icon(Icons.notifications_none_outlined);
          }
          return Badge(
              label: Text(eventMemBox.length().toString()),
              backgroundColor: themeData.primaryColor,
              child: const Icon(Icons.notifications_none_outlined));
        },
        selector: (context, _provider) {
          return _provider.eventMemBox;
        },
      ),
      label: s.Notifications,
    ));

    return NavigationBar(
      labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
      indicatorColor: themeData.primaryColor,
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
