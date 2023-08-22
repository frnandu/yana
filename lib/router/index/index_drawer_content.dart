import 'package:flutter/material.dart';
import 'package:yana/component/user/metadata_top_component.dart';
import 'package:yana/consts/base.dart';
import 'package:yana/consts/router_path.dart';
import 'package:yana/provider/index_provider.dart';
import 'package:yana/router/user/user_statistics_component.dart';
import 'package:yana/util/platform_util.dart';
import 'package:yana/util/router_util.dart';
import 'package:provider/provider.dart';

import '../../data/metadata.dart';
import '../../generated/l10n.dart';
import '../../main.dart';
import '../../provider/metadata_provider.dart';
import '../edit/editor_router.dart';
import 'account_manager_component.dart';

class IndexDrawerContnetComponnent extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _IndexDrawerContnetComponnent();
  }
}

class _IndexDrawerContnetComponnent
    extends State<IndexDrawerContnetComponnent> {
  ScrollController userStatisticscontroller = ScrollController();

  double profileEditBtnWidth = 40;

  @override
  Widget build(BuildContext context) {
    var _indexProvider = Provider.of<IndexProvider>(context);

    var s = S.of(context);
    var pubkey = nostr!.publicKey;
    var paddingTop = mediaDataCache.padding.top;
    var themeData = Theme.of(context);
    var mainColor = themeData.primaryColor;
    var cardColor = themeData.cardColor;
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
              isLocal: true,
              jumpable: true,
            );
          },
          selector: (context, _provider) {
            return _provider.getMetadata(pubkey);
          },
        ),
        Positioned(
          top: paddingTop + Base.BASE_PADDING_HALF,
          right: Base.BASE_PADDING,
          child: Container(
            height: profileEditBtnWidth,
            width: profileEditBtnWidth,
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(profileEditBtnWidth / 2),
            ),
            child: IconButton(
              icon: Icon(Icons.edit_square),
              onPressed: jumpToProfileEdit,
            ),
          ),
        ),
      ]),
    ));

    list.add(GestureDetector(
      behavior: HitTestBehavior.translucent,
      onHorizontalDragUpdate: (detail) {
        userStatisticscontroller
            .jumpTo(userStatisticscontroller.offset - detail.delta.dx);
      },
      child: SingleChildScrollView(
        controller: userStatisticscontroller,
        scrollDirection: Axis.horizontal,
        child: UserStatisticsComponent(pubkey: pubkey),
      ),
    ));

    if (PlatformUtil.isTableMode()) {
      list.add(IndexDrawerItem(
        iconData: Icons.home,
        name: s.Home,
        color: _indexProvider.currentTap == 0 ? mainColor : null,
        onTap: () {
          indexProvider.setCurrentTap(0);
        },
        onDoubleTap: () {
          indexProvider.followScrollToTop();
        },
      ));
      list.add(IndexDrawerItem(
        iconData: Icons.public,
        name: s.Globals,
        color: _indexProvider.currentTap == 1 ? mainColor : null,
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
        color: _indexProvider.currentTap == 2 ? mainColor : null,
        onTap: () {
          indexProvider.setCurrentTap(2);
        },
      ));
      list.add(IndexDrawerItem(
        iconData: Icons.mail,
        name: "DMs",
        color: _indexProvider.currentTap == 3 ? mainColor : null,
        onTap: () {
          indexProvider.setCurrentTap(3);
        },
      ));
    }

    list.add(IndexDrawerItem(
      iconData: Icons.key,
      name: s.Key_Backup,
      onTap: () {
        RouterUtil.router(context, RouterPath.KEY_BACKUP);
      },
    ));

    list.add(IndexDrawerItem(
      iconData: Icons.cloud,
      name: s.Relays,
      onTap: () {
        RouterUtil.router(context, RouterPath.RELAYS);
      },
    ));

    list.add(IndexDrawerItem(
      iconData: Icons.settings,
      name: s.Setting,
      onTap: () {
        RouterUtil.router(context, RouterPath.SETTING);
      },
    ));

    list.add(IndexDrawerItem(
      iconData: Icons.block,
      name: s.Filter,
      onTap: () {
        RouterUtil.router(context, RouterPath.FILTER);
      },
    ));


    list.add(Expanded(child: Container()));

    if (PlatformUtil.isTableMode()) {
      list.add(IndexDrawerItem(
        iconData: Icons.add,
        name: s.Add_a_Note,
        onTap: () {
          EditorRouter.open(context);
        },
      ));
    }

    list.add(IndexDrawerItem(
      iconData: Icons.account_box,
      name: s.Account_Manager,
      onTap: () {
        _showBasicModalBottomSheet(context);
      },
    ));
    // list.add(IndexDrawerItem(
    //   iconData: Icons.logout,
    //   name: "Sign out",
    //   onTap: signOut,
    // ));

    list.add(Container(
      margin: const EdgeInsets.only(top: Base.BASE_PADDING_HALF),
      padding: const EdgeInsets.only(
        left: Base.BASE_PADDING * 2,
        bottom: Base.BASE_PADDING,
        top: Base.BASE_PADDING,
      ),
      decoration: BoxDecoration(
          border: Border(
              top: BorderSide(
        width: 1,
        color: hintColor,
      ))),
      alignment: Alignment.centerLeft,
      child: Text("V " + packageInfo.version),
    ));

    return Container(
      child: Column(
        children: list,
      ),
    );
  }

  void jumpToProfileEdit() {
    var metadata = metadataProvider.getMetadata(nostr!.publicKey);
    RouterUtil.router(context, RouterPath.PROFILE_EDITOR, metadata);
  }

  void _showBasicModalBottomSheet(context) async {
    showModalBottomSheet(
      isScrollControlled: false, // true 为 全屏
      context: context,
      builder: (BuildContext context) {
        return AccountManagerComponent();
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

  // bool borderTop;

  // bool borderBottom;

  IndexDrawerItem({
    required this.iconData,
    required this.name,
    required this.onTap,
    this.color,
    this.onDoubleTap,
    // this.borderTop = true,
    // this.borderBottom = false,
  });

  @override
  Widget build(BuildContext context) {
    var themeData = Theme.of(context);
    var hintColor = themeData.hintColor;
    List<Widget> list = [];

    list.add(Container(
      margin: EdgeInsets.only(
        left: Base.BASE_PADDING * 2,
        right: Base.BASE_PADDING,
      ),
      child: Icon(
        iconData,
        color: color,
      ),
    ));

    list.add(Text(name, style: TextStyle(color: color)));

    var borderSide = BorderSide(width: 1, color: hintColor);

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
      child: Container(
        height: 34,
        // decoration: BoxDecoration(
        //   border: Border(
        //     top: borderTop ? borderSide : BorderSide.none,
        //     bottom: borderBottom ? borderSide : BorderSide.none,
        //   ),
        // ),
        child: Row(
          children: list,
        ),
      ),
    );
  }
}
