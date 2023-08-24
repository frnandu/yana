import 'package:flutter/material.dart';
import 'package:yana/ui/cust_state.dart';
import 'package:yana/ui/event/zap_event_main_component.dart';
import 'package:yana/ui/keep_alive_cust_state.dart';
import 'package:yana/models/event_mem_box.dart';
import 'package:yana/main.dart';
import 'package:yana/provider/mention_me_new_provider.dart';
import 'package:yana/provider/mention_me_provider.dart';
import 'package:yana/utils/load_more_event.dart';
import 'package:yana/utils/string_util.dart';
import 'package:provider/provider.dart';

import '../../nostr/event_kind.dart' as kind;
import '../../nostr/filter.dart';
import '../../ui/event/event_list_component.dart';
import '../../ui/event/zap_event_list_component.dart';
import '../../ui/new_notes_updated_component.dart';
import '../../ui/placeholder/event_list_placeholder.dart';
import '../../ui/placeholder/event_placeholder.dart';
import '../../utils/base.dart';
import '../../utils/base_consts.dart';
import '../../utils/router_path.dart';
import '../../provider/setting_provider.dart';
import '../../utils/platform_util.dart';
import '../../utils/router_util.dart';

class NotificationsRouter extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _NotificationsRouter();
  }
}

class _NotificationsRouter extends KeepAliveCustState<NotificationsRouter>
    with LoadMoreEvent {
  ScrollController _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    bindLoadMoreScroll(_controller);
  }

  @override
  Widget doBuild(BuildContext context) {
    var _settingProvider = Provider.of<SettingProvider>(context);
    var _mentionMeProvider = Provider.of<MentionMeProvider>(context);
    var eventBox = _mentionMeProvider.eventBox;
    var events = eventBox.all();
    if (events.isEmpty) {
      return EventListPlaceholder(
        onRefresh: () {
          mentionMeProvider.refresh();
        },
      );
    }
    indexProvider.setMentionedScrollController(_controller);
    preBuild();

    var main = ListView.builder(
      controller: _controller,
      itemBuilder: (BuildContext context, int index) {
        var event = events[index];
        if (event.kind == kind.EventKind.ZAP &&
            StringUtil.isBlank(event.content)) {
          return ZapEventListComponent(event: event);
        } else {
          return EventListComponent(
            event: event,
            showVideo: _settingProvider.videoPreviewInList == OpenStatus.OPEN,
          );
        }
      },
      itemCount: events.length,
    );

    Widget ri = RefreshIndicator(
      onRefresh: () async {
        mentionMeProvider.refresh();
      },
      child: main,
    );

    if (PlatformUtil.isTableMode()) {
      ri = GestureDetector(
        onVerticalDragUpdate: (detail) {
          _controller.jumpTo(_controller.offset - detail.delta.dy);
        },
        behavior: HitTestBehavior.translucent,
        child: ri,
      );
    }

    List<Widget> stackList = [ri];
    stackList.add(Positioned(
      top: Base.BASE_PADDING,
      child: Selector<MentionMeNewProvider, EventMemBox>(
        builder: (context, eventMemBox, child) {
          if (eventMemBox.length() <= 0) {
            return Container();
          }

          return NewNotesUpdatedComponent(
            newEvents: eventMemBox.all(),
            onTap: () {
              mentionMeProvider.mergeNewEvent();
              _controller.animateTo(0,curve: Curves.ease, duration: const Duration(seconds: 1));
            },
          );
        },
        selector: (context, _provider) {
          return _provider.eventMemBox;
        },
      ),
    ));
    return Stack(
      alignment: Alignment.center,
      children: stackList,
    );
  }

  @override
  void doQuery() {
    preQuery();
    mentionMeProvider.doQuery(until: until);
  }

  @override
  EventMemBox getEventBox() {
    return mentionMeProvider.eventBox;
  }

  @override
  Future<void> onReady(BuildContext context) async {}
}
