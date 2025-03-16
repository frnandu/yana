import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_list_view/flutter_list_view.dart';
import 'package:provider/provider.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:yana/main.dart';
import 'package:yana/models/event_mem_box.dart';
import 'package:yana/provider/follow_event_provider.dart';
import 'package:yana/provider/follow_new_event_provider.dart';
import 'package:yana/ui/keep_alive_cust_state.dart';
import 'package:yana/ui/new_notes_updated_component.dart';
import 'package:yana/utils/base.dart';
import 'package:yana/utils/base_consts.dart';

import '../../i18n/i18n.dart';
import '../../provider/setting_provider.dart';
import '../../ui/event/event_list_component.dart';
import '../../ui/placeholder/event_list_placeholder.dart';
import '../../utils/load_more_event.dart';
import '../../utils/platform_util.dart';

class FollowPostsRouter extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _FollowPostsRouter();
  }
}

class _FollowPostsRouter extends KeepAliveCustState<FollowPostsRouter>
    with LoadMoreEvent {
  // ScrollController _controller = ScrollController();
  FlutterListViewController _controller = FlutterListViewController();

  //int _initTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;

  @override
  void initState() {
    super.initState();
    bindLoadMoreScroll(_controller);
    _controller.addListener(() {
      followEventProvider.setPostsTimestampToNewestAndSave();
    });
  }

  @override
  void deactivate() {
    super.deactivate();
    followEventProvider.setPostsTimestampToNewestAndSave();
  }

  @override
  void dispose() {
    super.dispose();
    followEventProvider.setPostsTimestampToNewestAndSave();
  }

  @override
  Widget doBuild(BuildContext context) {
    var _settingProvider = Provider.of<SettingProvider>(context);
    var _followEventProvider = Provider.of<FollowEventProvider>(context);

    var eventBox = _followEventProvider.postsBox;
    var events = eventBox.all();
    if (events.isEmpty) {
      return EventListPlaceholder(
        onRefresh: () {
          followEventProvider.refreshPosts();
        },
      );
    }
    indexProvider.setFollowPostsScrollController(_controller);
    preBuild();

    var main = VisibilityDetector(
        key: const Key('feed-posts'),
        onVisibilityChanged: (visibilityInfo) {
          if (visibilityInfo.visibleFraction == 0.0) {
            followEventProvider.setPostsTimestampToNewestAndSave();
          }
        },
        child: FlutterListView(
          controller: _controller,
            delegate:
                FlutterListViewDelegate((BuildContext context, int index) {
          var event = events[index];
          // Map<String, dynamic> map = event.toJson();
          // map['content']=event.content+event.sources.toString();
          // var e = Nip01Event.fromJson(map);
          // e.sources = event.sources;
          return EventListComponent(
            event: event,
            showVideo: _settingProvider.videoPreview == OpenStatus.OPEN,
          );
        }, childCount: events.length))
        );

    // var main = SingleChildScrollView(
    //     controller: _controller,
    //     child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
    //       Flexible(
    //           child: ListView.builder(
    //         addAutomaticKeepAlives: true,
    //         shrinkWrap: true,
    //         physics: const NeverScrollableScrollPhysics(),
    //         // controller: _controller,
    //         itemBuilder: (BuildContext context, int index) {
    //           var event = events[index];
    //           return EventListComponent(
    //             event: event,
    //             showVideo:
    //                 _settingProvider.videoPreview == OpenStatus.OPEN,
    //           );
    //         },
    //         itemCount: events.length,
    //       ))
    //     ]));

    Widget ri = RefreshIndicator(
      onRefresh: () async {
        followEventProvider.refreshPosts();
        // followEventProvider.refreshReplies();
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
            text: I18n.of(context).posted,
            newEvents: eventMemBox.all(),
            onTap: () {
              setState(() {
                followEventProvider.mergeNewPostEvents();
                _controller.animateTo(0,
                    curve: Curves.ease, duration: const Duration(seconds: 1));
              });
            },
          );
        },
        selector: (context, _provider) {
          return _provider.eventPostsMemBox;
        },
      ),
    ));
    return Container(
        // clipBehavior: Clip.hardEdge,
        // decoration: BoxDecoration(
        //   borderRadius: BorderRadius.circular(60 / 2),
        //   color: Colors.grey,
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
    return followEventProvider.postsBox;
  }

  @override
  Future<void> onReady(BuildContext context) async {}
}
