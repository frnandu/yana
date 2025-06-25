import 'package:flutter_list_view/flutter_list_view.dart';
import 'package:ndk/domain_layer/entities/metadata.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../i18n/i18n.dart';
import '../../main.dart';
import '../../provider/metadata_provider.dart';
import 'package:go_router/go_router.dart';
import '../../ui/editor/search_mention_user_component.dart';
import '../../utils/base.dart';
import '../../utils/platform_util.dart';
import '../../utils/router_path.dart';
import '../../utils/string_util.dart';

class FollowedRouterArgs {
  List<String> pubkeys;
  String title;

  FollowedRouterArgs({required this.pubkeys, required this.title});
}

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
  final scrollController = FlutterListViewController();

  @override
  Widget build(BuildContext context) {
    var s = I18n.of(context);

    if (widget.pubkeys == null) {
      var arg = GoRouterState.of(context).extra;
      if (arg != null && arg is FollowedRouterArgs) {
        widget.pubkeys = arg.pubkeys;
        widget.title = arg.title;
      } else if (arg != null) {
        widget.pubkeys = arg as List<String>;
      }
    }
    if (widget.pubkeys == null) {
      context.pop();
      return Container();
    }
    var themeData = Theme.of(context);
    var titleFontSize = themeData.textTheme.bodyLarge!.fontSize;

    var listView = FlutterListView(
        controller: scrollController,
        delegate: FlutterListViewDelegate(
          (BuildContext context, int index) {
            var pubkey = widget.pubkeys![index];
            if (StringUtil.isBlank(pubkey)) {
              return Container();
            }

            return Container(
                margin: const EdgeInsets.only(bottom: Base.BASE_PADDING_HALF),
                child: FutureBuilder<Metadata?>(
                    future: metadataProvider.getMetadata(pubkey),
                    builder: (context, snapshot) {
                      return snapshot.hasData
                          ? SearchMentionUserItemComponent(
                              metadata: snapshot.data!,
                              onTap: (metadata) {
                                context.push(RouterPath.USER, extra: pubkey);
                              },
                              width: 400)
                          : Container();
                    }));
          },
          childCount: widget.pubkeys!.length,
        ));

    var main = Scaffold(
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
          widget.title ?? s.Followers,
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
