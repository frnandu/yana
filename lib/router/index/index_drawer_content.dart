import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yana/provider/index_provider.dart';
import 'package:yana/ui/user/metadata_top_component.dart';
import 'package:yana/utils/base.dart';
import 'package:yana/utils/platform_util.dart';
import 'package:yana/utils/router_path.dart';
import 'package:yana/utils/router_util.dart';

import '../../i18n/i18n.dart';
import '../../main.dart';
import '../../models/metadata.dart';
import '../../provider/metadata_provider.dart';
import '../../provider/relay_provider.dart';
import '../../utils/index_taps.dart';
import 'account_manager_component.dart';

class IndexDrawerContnetComponnent extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _IndexDrawerContnetComponnent();
  }
}

class _IndexDrawerContnetComponnent
    extends State<IndexDrawerContnetComponnent> {
  // ScrollController userStatisticscontroller = ScrollController();

  double profileEditBtnWidth = 40;

  @override
  Widget build(BuildContext context) {
    var _indexProvider = Provider.of<IndexProvider>(context);

    var s = I18n.of(context);
    var pubkey = nostr!.publicKey;
    var themeData = Theme.of(context);
    var mainColor = themeData.primaryColor;
    var hintColor = themeData.hintColor;
    List<Widget> list = [];

    list.add(Container(
      // margin: EdgeInsets.only(bottom: Base.BASE_PADDING),
      child: Stack(children: [
        Selector<MetadataProvider, Metadata?>(
          builder: (context, metadata, child) {
            return MetadataTopComponent(
              pubkey: pubkey,
              metadata: metadata,
              condensedIcons: true,
              jumpable: true,
            );
          },
          selector: (context, _provider) {
            return _provider.getMetadata(pubkey);
          },
        ),
      ]),
    ));

    list.add(Container(
        margin: const EdgeInsets.only(top: Base.BASE_PADDING_HALF),
        padding: const EdgeInsets.only(
          left: Base.BASE_PADDING * 2,
          bottom: Base.BASE_PADDING / 2,
          top: Base.BASE_PADDING / 2,
        ),
        decoration: BoxDecoration(
            border: Border(
                top: BorderSide(
          width: 1,
          color: hintColor,
        )))));
    // list.add(GestureDetector(
    //   behavior: HitTestBehavior.translucent,
    //   onHorizontalDragUpdate: (detail) {
    //     userStatisticscontroller
    //         .jumpTo(userStatisticscontroller.offset - detail.delta.dx);
    //   },
    //   child: SingleChildScrollView(
    //     controller: userStatisticscontroller,
    //     scrollDirection: Axis.horizontal,
    //     child: UserStatisticsComponent(pubkey: pubkey),
    //   ),
    // ));

    if (PlatformUtil.isTableMode()) {
      list.add(IndexDrawerItem(
        iconData: Icons.home,
        name: s.Home,
        color: _indexProvider.currentTap == IndexTaps.FOLLOW ? mainColor : null,
        onTap: () {
          indexProvider.setCurrentTap(0);
        },
        onDoubleTap: () {
          indexProvider.followScrollToTop();
        },
      ));
      list.add(IndexDrawerItem(
        iconData: Icons.notifications,
        name: s.Globals,
        color: _indexProvider.currentTap == IndexTaps.NOTIFICATIONS
            ? mainColor
            : null,
        onTap: () {
          indexProvider.setCurrentTap(1);
        },
        onDoubleTap: () {
          // TODO
          // indexProvider.globalScrollToTop();
        },
      ));
      list.add(IndexDrawerItem(
        iconData: Icons.search,
        name: s.Search,
        color: _indexProvider.currentTap == IndexTaps.SEARCH ? mainColor : null,
        onTap: () {
          indexProvider.setCurrentTap(2);
        },
      ));
      list.add(IndexDrawerItem(
        iconData: Icons.mail,
        name: "DMs",
        color: _indexProvider.currentTap == IndexTaps.DM ? mainColor : null,
        onTap: () {
          indexProvider.setCurrentTap(3);
        },
      ));
    }

    list.add(IndexDrawerItem(
      iconData: Icons.person,
      name: s.Profile,
      onTap: () {
        RouterUtil.router(context, RouterPath.USER, pubkey);
      },
    ));

    list.add(IndexDrawerItem(
      iconData: Icons.key,
      name: s.Key_Backup,
      onTap: () {
        RouterUtil.router(context, RouterPath.KEY_BACKUP);
      },
    ));

    list.add(
      IndexDrawerItem(
        iconData: Icons.lan_outlined,
        name: s.Relays,
        onTap: () {
          RouterUtil.router(context, RouterPath.RELAYS);
        },
        rightWidget: Selector<RelayProvider, String>(
            builder: (context, relayNum, child) {
              return Text(
                relayNum,
                style: TextStyle(color: themeData.disabledColor),
              );
            }, selector: (context, _provider) {
          return _provider.relayNumStr();
        })
      ),
    );

    list.add(IndexDrawerItem(
      iconData: Icons.security,
      name: s.Filters,
      onTap: () {
        RouterUtil.router(context, RouterPath.FILTER);
      },
    ));

    list.add(IndexDrawerItem(
      iconData: Icons.settings,
      name: s.Setting,
      onTap: () {
        RouterUtil.router(context, RouterPath.SETTING);
      },
    ));

    list.add(Expanded(child: Container()));

    list.add(IndexDrawerItem(
      iconData: Icons.supervisor_account,
      name: s.Accounts,
      onTap: () {
        _showBasicModalBottomSheet(context);
      },
    ));

    list.add(Container(
      margin: const EdgeInsets.only(top: Base.BASE_PADDING_HALF),
      padding: const EdgeInsets.only(
        left: Base.BASE_PADDING * 2,
        bottom: Base.BASE_PADDING / 2,
        top: Base.BASE_PADDING / 2,
      ),
      decoration: BoxDecoration(
          border: Border(
              top: BorderSide(
        width: 1,
        color: hintColor,
      ))),
      alignment: Alignment.centerLeft,
      child: Text("v" + packageInfo.version),
    ));

    return Column(
      children: list,
    );
  }

  void _showBasicModalBottomSheet(context) async {
    showModalBottomSheet(
      isScrollControlled: false, // true 为 全屏
      context: context,
      builder: (BuildContext context) {
        return AccountsComponent();
      },
    );
  }
}

class IndexDrawerItem extends StatelessWidget {
  IconData iconData;

  String name;

  Function onTap;

  Function? onDoubleTap;

  Color? color;

  Widget? rightWidget;

  // bool borderTop;

  // bool borderBottom;

  IndexDrawerItem({super.key,
    required this.iconData,
    required this.name,
    required this.onTap,
    this.color,
    this.onDoubleTap,
    this.rightWidget
    // this.borderTop = true,
    // this.borderBottom = false,
  });

  @override
  Widget build(BuildContext context) {
    var themeData = Theme.of(context);
    var hintColor = themeData.hintColor;
    List<Widget> list = [];

    list.add(MouseRegion(
        cursor: SystemMouseCursors.click,
        child:Container(
      margin: const EdgeInsets.only(
        left: Base.BASE_PADDING * 2,
        right: Base.BASE_PADDING,
      ),
      child: Icon(
        iconData,
        color: color,
      ),
    )));

    list.add(MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Text(name,
        style: TextStyle(color: color, fontSize: Base.BASE_FONT_SIZE + 4))));

    if (rightWidget!=null) {
      list.add(MouseRegion(
          cursor: SystemMouseCursors.click,
          child:Container(
          margin: const EdgeInsets.only(
            left: Base.BASE_PADDING,
          ),
          child: rightWidget!)
      ));
    }

    return GestureDetector(
      onTap: () {
        onTap();
      },
      onDoubleTap: () {
        if (onDoubleTap != null) {
          onDoubleTap!();
        }
      },
      behavior: HitTestBehavior.translucent,
      child: SizedBox(
        height: 50,
        child: Row(
          children: list,
        ),
      ),
    );
  }
}
