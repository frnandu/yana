import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yana/ui/keep_alive_cust_state.dart';
import 'package:yana/models/event_mem_box.dart';
import 'package:yana/main.dart';
import 'package:yana/provider/follow_event_provider.dart';
import 'package:yana/utils/platform_util.dart';

import '../../ui/event/event_list_component.dart';
import '../../ui/new_notes_updated_component.dart';
import '../../ui/placeholder/event_list_placeholder.dart';
import '../../utils/base.dart';
import '../../utils/base_consts.dart';
import '../../provider/follow_new_event_provider.dart';
import '../../provider/setting_provider.dart';
import '../../utils/load_more_event.dart';

class FollowPostsAndRepliesRouter extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _FollowPostsAndRepliesRouter();
  }
}

class _FollowPostsAndRepliesRouter
    extends KeepAliveCustState<FollowPostsAndRepliesRouter> with LoadMoreEvent {
  ScrollController _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    bindLoadMoreScroll(_controller);
  }

  @override
  Widget doBuild(BuildContext context) {
    var _settingProvider = Provider.of<SettingProvider>(context);
    var _followEventProvider = Provider.of<FollowEventProvider>(context);

    var eventBox = _followEventProvider.postsAndRepliesBox;
    var events = eventBox.all();
    if (events.isEmpty) {
      return EventListPlaceholder(
        onRefresh: () {
          followEventProvider.refreshReplies();
        },
      );
    }
    indexProvider.setFollowScrollController(_controller);
    preBuild();

    var main = ListView.builder(
      controller: _controller,
      itemBuilder: (BuildContext context, int index) {
        // var event = events[index];
        // return FrameSeparateWidget(
        //   index: index,
        //   child: EventListComponent(
        //     event: event,
        //   ),
        // );
        var event = events[index];
        return EventListComponent(
          event: event,
          showVideo: _settingProvider.videoPreviewInList == OpenStatus.OPEN,
        );
      },
      itemCount: events.length,
    );

    Widget ri = RefreshIndicator(
      onRefresh: () async {
        followEventProvider.refreshReplies();
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
      child: Selector<FollowNewEventProvider, EventMemBox>(
        builder: (context, eventMemBox, child) {
          if (eventMemBox.length() <= 0) {
            return Container();
          }

          return NewNotesUpdatedComponent(
            newEvents: eventMemBox.all(),
            onTap: () {
              followEventProvider.mergeNewPostAndReplyEvents();
              _controller.animateTo(0,
                  curve: Curves.ease, duration: const Duration(seconds: 1));
            },
          );
        },
        selector: (context, _provider) {
          return _provider.eventPostsAndRepliesMemBox;
        },
      ),
    ));
    return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          color: Colors.white,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: stackList,
        ));
  }

  @override
  void doQuery() {
    preQuery();
    followEventProvider.doQuery(until: until, forceUserLimit: forceUserLimit);
  }

  @override
  EventMemBox getEventBox() {
    return followEventProvider.postsAndRepliesBox;
  }

  @override
  Future<void> onReady(BuildContext context) async {}
}
