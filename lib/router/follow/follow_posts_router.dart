import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
  ScrollController _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    bindLoadMoreScroll(_controller);
    doQuery();
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

    var main = SingleChildScrollView(
        controller: _controller,
        child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
          Flexible(
              child: ListView.builder(
            addAutomaticKeepAlives: true,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            // controller: _controller,
            itemBuilder: (BuildContext context, int index) {
              var event = events[index];
              return EventListComponent(
                event: event,
                showVideo:
                    _settingProvider.videoPreviewInList == OpenStatus.OPEN,
              );
            },
            itemCount: events.length,
          ))
        ]));

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
            text: I18n.of(context).posted,
            newEvents: eventMemBox.all(),
            onTap: () {
              setState(() {
                followEventProvider.mergeNewPostEvents();
                _controller.animateTo(0,curve: Curves.ease, duration: const Duration(seconds: 1));
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
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(60 / 2),
          color: Colors.grey,
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
    return followEventProvider.postsBox;
  }

  @override
  Future<void> onReady(BuildContext context) async {}
}
