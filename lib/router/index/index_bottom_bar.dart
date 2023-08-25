import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yana/provider/index_provider.dart';

import '../../i18n/i18n.dart';
import '../../main.dart';

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
    var currentTap = _indexProvider.currentTap;

    List<Widget> list = [];

    List<NavigationDestination> destinations = [];

    int current = 0;
    var s = I18n.of(context);

    list.add(IndexBottomBarButton(
      iconData: Icons.home,
      index: current,
      selected: current == currentTap,
      onTap: (i) {
        if (i == currentTap) {
          indexProvider.followScrollToTop();
        } else {
          indexProvider.setCurrentTap(i);
        }
      },
      onDoubleTap: () {
        indexProvider.followScrollToTop();
      },
    ));
    destinations.add(NavigationDestination(
        icon: const Icon(Icons.home_outlined),
        label: s.Feed,
    ));
    current++;

    list.add(IndexBottomBarButton(
      iconData: Icons.search,
      index: current,
      selected: current == currentTap,
    ));
    destinations.add(NavigationDestination(
      icon: const Icon(Icons.search),
      label: s.Search,
    ));
    current++;

    list.add(IndexBottomBarButton(
      iconData: Icons.mail,
      index: current,
      selected: current == currentTap,
    ));
    destinations.add(NavigationDestination(
      icon: const Icon(Icons.mail_outline),
      label: s.Messages,
    ));
    current++;

    list.add(IndexBottomBarButton(
      iconData: Icons.notifications,
      index: current,
      selected: current == currentTap,
      onTap: (i) {
        if (i == currentTap) {
          // TODO
          //indexProvider.globalScrollToTop();
        } else {
          indexProvider.setCurrentTap(i);
        }
      },
      onDoubleTap: () {
        // TODO
        // indexProvider.globalScrollToTop();
      },
    ));
    destinations.add(NavigationDestination(
      icon: const Icon(Icons.notifications_none_outlined),
      label: s.Notifications,
    ));

    current++;

    // return NavigationBar(
    //   indicatorColor: themeData.primaryColor,
    //   selectedIndex: selectedPageIndex,
    //   onDestinationSelected: (int index) {
    //     setState(() {
    //       selectedPageIndex = index;
    //       // if (index == currentTap) {
    //       //   indexProvider.followScrollToTop();
    //       // } else {
    //       //   indexProvider.setCurrentTap(i);
    //       // }
    //
    //     });
    //   },
    //   destinations: destinations,
    // );
    return BottomAppBar(
      // shape: const CircularNotchedRectangle(),
      // notchMargin: 5,
      child: Container(
        color: Colors.transparent,
        width: double.infinity,
        child: Row(
          children: list,
        ),
      ),
    );
  }

  @override
  Future<void> onReady(BuildContext context) async {}
}

class IndexBottomBarButton extends StatelessWidget {
  final IconData iconData;
  final int index;
  final bool selected;
  final Function(int)? onTap;
  Function? onDoubleTap;

  IndexBottomBarButton({
    required this.iconData,
    required this.index,
    required this.selected,
    this.onTap,
    this.onDoubleTap,
  });

  @override
  Widget build(BuildContext context) {
    var themeData = Theme.of(context);
    var mainColor = themeData.primaryColor;
    // var settingProvider = Provider.of<SettingProvider>(context);
    // var bottomIconColor = settingProvider.bottomIconColor;

    Color? selectedColor = mainColor;

    return Expanded(
      child: InkWell(
        onTap: () {
          if (onTap != null) {
            onTap!(index);
          } else {
            indexProvider.setCurrentTap(index);
          }
        },
        onDoubleTap: () {
          if (onDoubleTap != null) {
            onDoubleTap!();
          }
        },
        child: SizedBox(
          height: IndexBottomBar.HEIGHT,
          child: Icon(
            iconData,
            size: IndexBottomBar.HEIGHT*0.5,
            color: selected ? selectedColor : null,
          ),
        ),
      ),
    );
  }
}
