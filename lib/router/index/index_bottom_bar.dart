import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';
import 'package:yana/provider/dm_provider.dart';
import 'package:yana/provider/index_provider.dart';

import '../../config/app_features.dart';
import '../../i18n/i18n.dart';
import '../../main.dart';
import '../../models/event_mem_box.dart';
import '../../provider/follow_new_event_provider.dart';
import '../../provider/new_notifications_provider.dart';
import '../../utils/index_taps.dart';

class IndexBottomBar extends StatefulWidget {
  static const double HEIGHT = 60;

  IndexBottomBar({super.key});

  @override
  State<StatefulWidget> createState() {
    return _IndexBottomBar();
  }
}

class _IndexBottomBar extends State<IndexBottomBar> {
  var badgeTextStyle =
      const TextStyle(color: Colors.white, fontFamily: "Roboto");

  final badgeSize = 6.0;

  @override
  Widget build(BuildContext context) {
    var themeData = Theme.of(context);
    var _indexProvider = Provider.of<IndexProvider>(context);
    // var _followEventProvider = Provider.of<FollowNewEventProvider>(context);

    List<Widget> destinations = [];

    var s = I18n.of(context);

    if (AppFeatures.isWalletOnly) {
      destinations.add(NavigationDestination(
        selectedIcon: Icon(Symbols.account_balance_wallet,
            size: 35, fill: 1, weight: 1, color: themeData.dividerColor),
        icon: Icon(Symbols.account_balance_wallet,
            size: 35, weight: 1, color: themeData.disabledColor),
        label: s.Wallet,
      ));
    }

    if (AppFeatures.enableSocial) {
      destinations.add(NavigationDestination(
        icon:
            Selector<FollowNewEventProvider, Tuple2<EventMemBox, EventMemBox>>(
          builder: (context, tuple, child) {
            Icon icon = _indexProvider.currentTap == IndexTaps.FOLLOW
                ? Icon(Symbols.home_filled,
                    fill: 1, size: 35, weight: 1, color: themeData.dividerColor)
                : Icon(Symbols.home,
                    size: 35, weight: 1, color: themeData.disabledColor);
            if (tuple.item1.length() <= 0 && tuple.item2.length() <= 0) {
              return icon;
            }
            // int total = tuple.item1.length() + tuple.item2.length();
            return _badge(icon, themeData);
            return Badge(
                offset: const Offset(10, 0),
                // label: Text(total.toString(), style: badgeTextStyle),
                backgroundColor: themeData.primaryColor,
                child: icon);
          },
          selector: (context, _provider) {
            return Tuple2(_provider.eventPostsMemBox,
                _provider.eventPostsAndRepliesMemBox);
          },
        ),
        label: s.Feed,
      ));
    }

    if (AppFeatures.enableSearch) {
      destinations.add(NavigationDestination(
        selectedIcon: Icon(Symbols.search,
            size: 35, fill: 1, weight: 1, color: themeData.dividerColor),
        icon: Icon(Symbols.search,
            size: 35, weight: 1, color: themeData.disabledColor),
        label: s.Search,
      ));
    }

    if (AppFeatures.enableDm) {
      destinations.add(NavigationDestination(
        icon: Selector<DMProvider, int>(
          builder: (context, count, child) {
            Icon icon = _indexProvider.currentTap == IndexTaps.DM
                ? Icon(Symbols.mail,
                    fill: 1, size: 35, weight: 1, color: themeData.dividerColor)
                : Icon(Symbols.mail,
                    size: 35, weight: 1, color: themeData.disabledColor);
            // FlutterAppBadger.updateBadgeCount(count);
            if (count <= 0) {
              return icon;
            }
            return _badge(icon, themeData);
            // return Badge(
            //     offset: const Offset(10, 0),
            //     // label: Text(count.toString(),style: badgeTextStyle),
            //     backgroundColor: themeData.primaryColor,
            //     child: icon);
          },
          selector: (context, _provider) {
            return _provider.howManyNewDMSessionsWithNewMessages(
                    _provider.followingList) +
                _provider
                    .howManyNewDMSessionsWithNewMessages(_provider.knownList) +
                _provider
                    .howManyNewDMSessionsWithNewMessages(_provider.unknownList);
          },
        ),
        label: s.Messages,
      ));
    }

    if (AppFeatures.enableNotifications) {
      destinations.add(NavigationDestination(
        icon: Selector<NewNotificationsProvider, EventMemBox>(
          builder: (context, eventMemBox, child) {
            Icon icon = _indexProvider.currentTap == IndexTaps.NOTIFICATIONS
                ? Icon(Symbols.notifications,
                    fill: 1, size: 35, weight: 1, color: themeData.dividerColor)
                : Icon(Symbols.notifications,
                    size: 35, weight: 1, color: themeData.disabledColor);
            if (eventMemBox.length() <= 0) {
              return icon;
            }
            return _badge(icon, themeData);
            // return Badge(
            //     offset: const Offset(8, 0),
            //     // label: Text(eventMemBox.length().toString(),style: badgeTextStyle),
            //     backgroundColor: themeData.primaryColor,
            //     child: icon);
          },
          selector: (context, _provider) {
            return _provider.eventMemBox;
          },
        ),
        label: s.Notifications,
      ));
    }

    return destinations.length >= 2 && !AppFeatures.isWalletOnly
        ? NavigationBar(
            labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
            indicatorColor: themeData.cardColor,
            selectedIndex: _indexProvider.currentTap,
            onDestinationSelected: (int index) {
              setState(() {
                if (_indexProvider.currentTap == index) {
                  if (index == IndexTaps.FOLLOW)
                    indexProvider.followScrollToTop();
                } else {
                  indexProvider.setCurrentTap(index);
                }
              });
            },
            destinations: destinations,
          )
        : Container();
  }

  @override
  Future<void> onReady(BuildContext context) async {}

  Widget _badge(Widget child, ThemeData themeData) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned(
          top: 3,
          right: -badgeSize / 1.2,
          child: Container(
            width: badgeSize,
            height: badgeSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: themeData.primaryColor,
            ),
          ),
        ),
      ],
    );
  }
}
