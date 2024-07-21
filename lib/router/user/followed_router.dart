import 'package:dart_ndk/shared/nips/nip01/metadata.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../i18n/i18n.dart';
import '../../provider/metadata_provider.dart';
import '../../ui/editor/search_mention_user_component.dart';
import '../../utils/base.dart';
import '../../utils/platform_util.dart';
import '../../utils/router_path.dart';
import '../../utils/router_util.dart';
import '../../utils/string_util.dart';

class FollowedRouter extends StatefulWidget {

  List<String>? pubkeys;
  String? title;

  FollowedRouter({super.key});

  FollowedRouter.withTitle(this.pubkeys, this.title, {super.key});

  @override
  State<StatefulWidget> createState() {
    return _FollowedRouter();
  }
}

class _FollowedRouter extends State<FollowedRouter> {
  ScrollController scrollController = ScrollController();


  @override
  Widget build(BuildContext context) {
    var s = I18n.of(context);

    if (widget.pubkeys == null) {
      var arg = RouterUtil.routerArgs(context);
      if (arg != null) {
        widget.pubkeys = arg as List<String>;
      }
    }
    if (widget.pubkeys == null) {
      RouterUtil.back(context);
      return Container();
    }
    var themeData = Theme.of(context);
    var titleFontSize = themeData.textTheme.bodyLarge!.fontSize;

    var listView = ListView.builder(
      controller: scrollController,
      itemBuilder: (context, index) {
        var pubkey = widget.pubkeys![index];
        if (StringUtil.isBlank(pubkey)) {
          return Container();
        }

        return Container(
          margin: const EdgeInsets.only(bottom: Base.BASE_PADDING_HALF),
          child: Selector<MetadataProvider, Metadata?>(
            builder: (context, metadata, child) {
              return  metadata != null
                      ? SearchMentionUserItemComponent(
                          metadata: metadata!,
                          onTap: (metadata) {
                            RouterUtil.router(context, RouterPath.USER, pubkey);
                          },
                          width: 400)
                      : Container();
                  // MetadataComponent(
                  //   pubKey: pubkey,
                  //   metadata: metadata,
                  //   jumpable: true,
                  // ),
            },
            selector: (context, _provider) {
              return _provider.getMetadata(pubkey);
            },
          ),
        );
      },
      itemCount: widget.pubkeys!.length,
    );

    var main = Scaffold(
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
          widget.title??s.Followers,
          style: TextStyle(
            fontSize: titleFontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: listView,
    );

    if (PlatformUtil.isTableMode()) {
      return GestureDetector(
        onVerticalDragUpdate: (detail) {
          scrollController.jumpTo(scrollController.offset - detail.delta.dy);
        },
        behavior: HitTestBehavior.translucent,
        child: main,
      );
    }

    return main;
  }
}
