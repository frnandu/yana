import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:yana/component/cust_state.dart';
import 'package:yana/component/pc_router_fake.dart';
import 'package:yana/consts/base_consts.dart';
import 'package:yana/provider/pc_router_fake_provider.dart';
import 'package:yana/router/follow/mention_me_router.dart';
import 'package:yana/util/platform_util.dart';
import 'package:yana/util/string_util.dart';
import 'package:provider/provider.dart';

import '../../generated/l10n.dart';
import '../../main.dart';
import '../../provider/index_provider.dart';
import '../../provider/setting_provider.dart';
import '../../util/auth_util.dart';
import '../dm/dm_router.dart';
import '../edit/editor_router.dart';
import '../follow/follow_index_router.dart';
import '../globals/globals_index_router.dart';
import '../login/login_router.dart';
import '../search/search_router.dart';
import 'index_app_bar.dart';
import 'index_bottom_bar.dart';
import 'index_drawer_content.dart';

class IndexRouter extends StatefulWidget {
  Function reload;

  IndexRouter({required this.reload});

  @override
  State<StatefulWidget> createState() {
    return _IndexRouter();
  }
}

class _IndexRouter extends CustState<IndexRouter>
    with TickerProviderStateMixin {
  static double PC_MAX_COLUMN_0 = 200;

  static double PC_MAX_COLUMN_1 = 550;

  late TabController followTabController;

  late TabController dmTabController;

  bool _scrollingDown = false;

  @override
  void initState() {
    super.initState();
    int followInitTab = 0;
    int globalsInitTab = 0;

    if (settingProvider.defaultTab != null) {
      if (settingProvider.defaultIndex == 1) {
        globalsInitTab = settingProvider.defaultTab!;
      } else {
        followInitTab = settingProvider.defaultTab!;
      }
    }

    followTabController =
        TabController(initialIndex: followInitTab, length: 3, vsync: this);
    dmTabController = TabController(length: 2, vsync: this);
  }

  @override
  Future<void> onReady(BuildContext context) async {
    if (settingProvider.lockOpen == OpenStatus.OPEN && !unlock) {
      doAuth();
    } else {
      setState(() {
        unlock = true;
      });
    }
  }

  bool unlock = false;

  @override
  Widget doBuild(BuildContext context) {
    mediaDataCache.update(context);
    var s = S.of(context);

    var _settingProvider = Provider.of<SettingProvider>(context);
    if (nostr == null) {
      return LoginRouter();
    }

    if (!unlock) {
      return Scaffold();
    }

    var _indexProvider = Provider.of<IndexProvider>(context);
    _indexProvider.setFollowTabController(followTabController);

    _indexProvider.addScrollListener((direction) {
      if (direction == ScrollDirection.reverse && !_scrollingDown) {
        setState(() {
          _scrollingDown = true;
        });
      }
      if (direction == ScrollDirection.forward && _scrollingDown) {
        setState(() {
          _scrollingDown = false;
        });
      }
    });

    var themeData = Theme.of(context);
    var titleTextColor = themeData.appBarTheme.titleTextStyle!.color;
    var titleTextStyle = TextStyle(
      fontWeight: FontWeight.bold,
      color: titleTextColor,
    );
    Color? indicatorColor = titleTextColor;
    if (PlatformUtil.isPC()) {
      indicatorColor = themeData.primaryColor;
    }

    Widget? appBarCenter;
    if (_indexProvider.currentTap == 0) {
      appBarCenter = TabBar(
        indicatorColor: indicatorColor,
        indicatorWeight: 3,
        tabs: [
          Container(
            height: IndexAppBar.height,
            alignment: Alignment.center,
            child: Text(
              s.Following,
              style: titleTextStyle,
            ),
          ),
          Container(
            height: IndexAppBar.height,
            alignment: Alignment.center,
            child: Text(
              s.Following_replies,
              textAlign: TextAlign.center,
              style: titleTextStyle,
            ),
          ),
          Container(
            height: IndexAppBar.height,
            alignment: Alignment.center,
            child: Text(
              s.Global,
              style: titleTextStyle,
            ),
          ),
        ],
        controller: followTabController,
      );
    } else if (_indexProvider.currentTap == 1) {
      appBarCenter = Center(
        child: Text(
          s.Notifications,
          style: titleTextStyle,
        ),
      );
    } else if (_indexProvider.currentTap == 2) {
      appBarCenter = Center(
        child: Text(
          s.Search,
          style: titleTextStyle,
        ),
      );
    } else if (_indexProvider.currentTap == 3) {
      appBarCenter = TabBar(
        indicatorColor: indicatorColor,
        indicatorWeight: 3,
        tabs: [
          Container(
            height: IndexAppBar.height,
            alignment: Alignment.center,
            child: Text(
              "DMs",
              style: themeData.appBarTheme.titleTextStyle,
            ),
          ),
          Container(
            height: IndexAppBar.height,
            alignment: Alignment.center,
            child: Text(
              s.Request,
              style: themeData.appBarTheme.titleTextStyle,
            ),
          ),
        ],
        controller: dmTabController,
      );
    }

    var addBtn = FloatingActionButton(
      backgroundColor: themeData.primaryColor,
      child: Icon(Icons.add),
      onPressed: () {
        EditorRouter.open(context);
      },
    );

    var mainCenterWidget = MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: Expanded(
          child: IndexedStack(
        index: _indexProvider.currentTap,
        children: [
          FollowIndexRouter(
            tabController: followTabController,
          ),
          MentionMeRouter(),
          SearchRouter(),
          DMRouter(
            tabController: dmTabController,
          ),
          // NoticeRouter(),
        ],
      )),
    );

    var mainIndex = Column(
      children: [
        // AnimatedContainer(
        //     duration: const Duration(milliseconds: 300),
        //     curve: Curves.ease,
        //     height: _scrollingDown ? 0.0 : 80,
        //     child:
        IndexAppBar(
          center: appBarCenter,
          // )
        ),
        mainCenterWidget,
      ],
    );

    if (PlatformUtil.isTableMode()) {
      var maxWidth = mediaDataCache.size.width;
      double column0Width = maxWidth * 1 / 5;
      double column1Width = maxWidth * 2 / 5;
      if (column0Width > PC_MAX_COLUMN_0) {
        column0Width = PC_MAX_COLUMN_0;
      }
      if (column1Width > PC_MAX_COLUMN_1) {
        column1Width = PC_MAX_COLUMN_1;
      }

      return Scaffold(
        extendBody: true,
        // floatingActionButton: addBtn,
        // floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        body: Row(children: [
          Container(
            width: column0Width,
            child: IndexDrawerContnetComponnent(),
          ),
          Container(
            width: column1Width,
            margin: EdgeInsets.only(
              // left: 1,
              right: 1,
            ),
            child: mainIndex,
          ),
          Expanded(
            child: Container(
              child: Selector<PcRouterFakeProvider, List<RouterFakeInfo>>(
                builder: (context, infos, child) {
                  if (infos.isEmpty) {
                    return Container(
                      child: Center(
                        child: Text(s.There_should_be_a_universe_here),
                      ),
                    );
                  }

                  List<Widget> pages = [];
                  for (var info in infos) {
                    if (StringUtil.isNotBlank(info.routerPath) &&
                        routes[info.routerPath] != null) {
                      var builder = routes[info.routerPath];
                      if (builder != null) {
                        pages.add(PcRouterFake(
                          info: info,
                          child: builder(context),
                        ));
                      }
                    } else if (info.buildContent != null) {
                      pages.add(PcRouterFake(
                        info: info,
                        child: info.buildContent!(context),
                      ));
                    }
                  }

                  return IndexedStack(
                    index: pages.length - 1,
                    children: pages,
                  );
                },
                selector: (context, _provider) {
                  return _provider.routerFakeInfos;
                },
                shouldRebuild: (previous, next) {
                  if (previous != next) {
                    return true;
                  }
                  return false;
                },
              ),
            ),
          )
        ]),
      );
    } else {
      return Scaffold(
          body: mainIndex,
          extendBody: true,
          floatingActionButton: AnimatedContainer(
              curve: Curves.ease,
              duration: const Duration(milliseconds: 200),
              height: _scrollingDown ? 0.0 : 50,
              child: addBtn),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          drawer: Drawer(
            child: IndexDrawerContnetComponnent(),
          ),
          bottomNavigationBar: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.ease,
              height: _scrollingDown ? 0.0 : 50,
              child: IndexBottomBar()));
    }
  }

  void doAuth() {
    AuthUtil.authenticate(context, S.of(context).Please_authenticate_to_use_app)
        .then((didAuthenticate) {
      if (didAuthenticate) {
        setState(() {
          unlock = true;
        });
      } else {
        doAuth();
      }
    });
  }
}
