import 'package:flutter/material.dart';
import 'package:flutter_list_view/flutter_list_view.dart';
import 'package:provider/provider.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:yana/main.dart';
import 'package:yana/models/event_mem_box.dart';
import 'package:yana/provider/follow_event_provider.dart';
import 'package:yana/ui/keep_alive_cust_state.dart';
import 'package:yana/utils/platform_util.dart';

import '../../i18n/i18n.dart';
import '../../provider/follow_new_event_provider.dart';
import '../../provider/setting_provider.dart';
import '../../ui/event/event_list_component.dart';
import '../../ui/new_notes_updated_component.dart';
import '../../ui/placeholder/event_list_placeholder.dart';
import '../../utils/base.dart';
import '../../utils/base_consts.dart';
import '../../utils/load_more_event.dart';

class FollowPostsAndRepliesRouter extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _FollowPostsAndRepliesRouter();
  }
}

class _FollowPostsAndRepliesRouter
    extends KeepAliveCustState<FollowPostsAndRepliesRouter> with LoadMoreEvent {
  FlutterListViewController _controller = FlutterListViewController();

  @override
  void initState() {
    super.initState();
    bindLoadMoreScroll(_controller);
    _controller.addListener(() {
      followEventProvider.setRepliesTimestampToNewestAndSave();
    });

  }

  @override
  void deactivate() {
    super.deactivate();
    followEventProvider.setRepliesTimestampToNewestAndSave();
  }

  @override
  void dispose() {
    super.dispose();
    followEventProvider.setRepliesTimestampToNewestAndSave();
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

    var main = VisibilityDetector(
        key: const Key('feed-replies'),
        onVisibilityChanged: (visibilityInfo) {
          if (visibilityInfo.visibleFraction == 0.0) {
            followEventProvider.setRepliesTimestampToNewestAndSave;
          }
        },
        child:
        FlutterListView(
            controller: _controller,
            delegate:
            FlutterListViewDelegate((BuildContext context, int index) {
            var event = events[index];
            return EventListComponent(
              event: event,
              showVideo: _settingProvider.videoPreview == OpenStatus.OPEN,
            );
          },
          childCount: events.length,
        )));

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
            text: I18n.of(context).replied,
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
        // decoration: BoxDecoration(
        //   borderRadius: BorderRadius.circular(50),
        //   color: Colors.white,
        // ),
        child: Stack(
      alignment: Alignment.center,
      children: stackList,
    ));
  }

  @override
  void doQuery() {
    preQuery();
    if (until != null) {
      followEventProvider.queryOlder(until: until!);
    }
  }

  @override
  EventMemBox getEventBox() {
    return followEventProvider.postsAndRepliesBox;
  }

  @override
  Future<void> onReady(BuildContext context) async {}
}
