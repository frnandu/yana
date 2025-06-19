import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ndk/ndk.dart';
import 'package:provider/provider.dart';
import 'package:yana/main.dart';
import 'package:yana/ui/event_delete_callback.dart';

import '../../models/event_mem_box.dart';
import '../../nostr/event_kind.dart' as kind;
import '../../provider/setting_provider.dart';
import '../../ui/cust_state.dart';
import '../../ui/event/event_list_component.dart';
import '../../ui/tag_info_component.dart';
import '../../utils/base_consts.dart';
import '../../utils/peddingevents_later_function.dart';
import '../../utils/platform_util.dart';
import '../../utils/router_util.dart';
import '../../utils/string_util.dart';

class TagDetailRouter extends StatefulWidget {
  const TagDetailRouter({super.key});

  @override
  State<StatefulWidget> createState() {
    return _TagDetailRouter();
  }
}

class _TagDetailRouter extends CustState<TagDetailRouter>
    with PenddingEventsLaterFunction {
  EventMemBox box = EventMemBox();

  ScrollController _controller = ScrollController();

  NdkResponse? subscription;

  bool showTitle = false;

  double tagHeight = 80;

  String? tag;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      if (_controller.offset > tagHeight * 0.8 && !showTitle) {
        setState(() {
          showTitle = true;
        });
      } else if (_controller.offset < tagHeight * 0.8 && showTitle) {
        setState(() {
          showTitle = false;
        });
      }
    });
  }

  @override
  Widget doBuild(BuildContext context) {
    var _settingProvider = Provider.of<SettingProvider>(context);
    if (StringUtil.isBlank(tag)) {
      var arg = GoRouterState.of(context).extra;
      if (arg != null && arg is String) {
        tag = arg;
      }
    } else {
      var arg = GoRouterState.of(context).extra;
      if (arg != null && arg is String && tag != arg) {
        // arg changed! reset
        tag = arg;

        box = EventMemBox();
        doQuery();
      }
    }
    if (StringUtil.isBlank(tag)) {
      context.pop();
      return Container();
    }

    var themeData = Theme.of(context);
    var bodyLargeFontSize = themeData.textTheme.bodyLarge!.fontSize;

    Widget? appBarTitle;
    if (showTitle) {
      appBarTitle = Text(
        tag!,
        style: TextStyle(
          fontSize: bodyLargeFontSize,
          overflow: TextOverflow.ellipsis,
        ),
      );
    }

    Widget main = EventDeleteCallback(
      onDeleteCallback: onDeleteCallback,
      child: ListView.builder(
        controller: _controller,
        itemBuilder: (context, index) {
          if (index == 0) {
            return TagInfoComponent(
              tag: tag!,
              height: tagHeight,
            );
          }

          var event = box.get(index - 1);
          if (event == null) {
            return null;
          }

          return EventListComponent(
            event: event,
            showVideo: _settingProvider.videoPreview == OpenStatus.OPEN,
          );
        },
        itemCount: box.length() + 1,
      ),
    );

    if (PlatformUtil.isTableMode()) {
      main = GestureDetector(
        onVerticalDragUpdate: (detail) {
          _controller.jumpTo(_controller.offset - detail.delta.dy);
        },
        behavior: HitTestBehavior.translucent,
        child: main,
      );
    }

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
        actions: [],
        title: appBarTitle,
      ),
      body: main,
    );
  }

  @override
  Future<void> onReady(BuildContext context) async {
    doQuery();
  }

  void doQuery() async {
    if (subscription != null) {
      ndk.requests.closeSubscription(subscription!.requestId);
    }
    var plainTag = tag!.replaceFirst("#", "");
    var filter = Filter(kinds: [
      Nip01Event.kTextNodeKind,
      kind.EventKind.LONG_FORM,
      kind.EventKind.FILE_HEADER,
      kind.EventKind.POLL,
    ], tTags: [
      plainTag
    ], limit: 100);
    // this place set #t not #r ???
    // var list = TopicMap.getList(plainTag);
    // if (list != null) {
    //   queryArg["#t"] = list;
    // } else {
    //   queryArg["#t"] = [plainTag];
    // }
    subscription = ndk.requests
        .subscription(filters: [filter], relaySet: myInboxRelaySet!);
    subscription!.stream.listen((event) {
      onEvent(event);
    });
  }

  void onEvent(Nip01Event event) {
    later(event, (list) {
      box.addList(list);
      setState(() {});
    }, null);
  }

  @override
  void dispose() {
    super.dispose();
    disposeLater();

    try {
      ndk.requests.closeSubscription(subscription!.requestId);
    } catch (e) {
      print(e);
    }
  }

  onDeleteCallback(Nip01Event event) {
    box.delete(event.id);
    setState(() {});
  }
}
