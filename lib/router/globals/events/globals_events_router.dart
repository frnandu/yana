import 'dart:async';

import 'package:ndk/ndk.dart';
import 'package:ndk/shared/nips/nip01/helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:yana/ui/event_delete_callback.dart';
import 'package:yana/ui/keep_alive_cust_state.dart';

import '../../../main.dart';
import '../../../models/event_mem_box.dart';
import '../../../nostr/event_kind.dart';
import '../../../provider/setting_provider.dart';
import '../../../ui/event/event_list_component.dart';
import '../../../ui/placeholder/event_list_placeholder.dart';
import '../../../utils/base_consts.dart';
import '../../../utils/load_more_event.dart';
import '../../../utils/peddingevents_later_function.dart';
import '../../../utils/platform_util.dart';

class GlobalsEventsRouter extends StatefulWidget {
  GlobalsEventsRouter({super.key});

  @override
  State<StatefulWidget> createState() {
    return _GlobalsEventsRouter();
  }
}

class _GlobalsEventsRouter extends KeepAliveCustState<GlobalsEventsRouter>
    with PenddingEventsLaterFunction, LoadMoreEvent {
  ScrollController scrollController = ScrollController();
  EventMemBox eventBox = EventMemBox();

  NdkResponse? subscription;

  int? _initTime = DateTime.now().millisecondsSinceEpoch ~/ 1000 - 3600;

  @override
  void initState() {
    super.initState();
    bindLoadMoreScroll(scrollController);
  }

  @override
  Widget doBuild(BuildContext context) {
    var _settingProvider = Provider.of<SettingProvider>(context);
    preBuild();

    if (eventBox.isEmpty()) {
      return EventListPlaceholder(
        onRefresh: () async {
          until = null;
          await refresh();
        },
      );
    }
    var list = eventBox.all();

    var main = RefreshIndicator(
        onRefresh: () async {
          until = null;
          refresh();
        },
        child: EventDeleteCallback(
          onDeleteCallback: onDeleteCallback,
          child: ListView.builder(
            // physics: const PositionRetainedScrollPhysics(),
            controller: scrollController,
            itemBuilder: (context, index) {
              var event = list[index];
              return EventListComponent(
                event: event,
                showVideo: _settingProvider.videoPreview == OpenStatus.OPEN,
              );
            },
            itemCount: list.length,
          ),
        ));

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

  bool _scrollingDown = false;

  @override
  Future<void> onReady(BuildContext context) async {
    indexProvider.setEventScrollController(scrollController);
    scrollController.addListener(() {
      if (scrollController.position.userScrollDirection ==
              ScrollDirection.reverse &&
          !_scrollingDown) {
        setState(() {
          _scrollingDown = true;
        });
      }
      if (scrollController.position.userScrollDirection ==
              ScrollDirection.forward &&
          _scrollingDown) {
        setState(() {
          _scrollingDown = false;
        });
      }
    });

    refresh();
  }

  List<int> queryEventKinds() {
    return [
      Nip01Event.TEXT_NODE_KIND,
      EventKind.REPOST,
      EventKind.GENERIC_REPOST,
      EventKind.LONG_FORM,
      EventKind.FILE_HEADER,
      EventKind.POLL,
    ];
  }

  int howManySecondsToLoadBack = 600;

  Future<void> refresh() async {
    var filter = Filter(
        kinds: queryEventKinds(),
        until: until,
        since:
            (until != null ? until! : Helpers.now) - howManySecondsToLoadBack,
        limit: 100);
    if (subscription != null) {
      ndk.requests.closeSubscription(subscription!.requestId);
    }

    await ndk.relays.reconnectRelays(myInboxRelaySet!.urls);

    subscription = ndk.requests.query(name: "global", filters: [filter], relaySet: myInboxRelaySet!);
    subscription!.stream.listen((event) {
      if (eventBox.isEmpty()) {
        laterTimeMS = 200;
      } else {
        laterTimeMS = 1000;
      }

      later(event, (list) {
        print("Received GLOBAL ${list.length} events");
        setState(() {
          eventBox.addList(list);
          if (eventBox.newestEvent != null) {
            _initTime = eventBox.newestEvent!.createdAt;
          }
        });
      }, null);
    });
  }

  void unsubscribe() async {
    try {
      if (subscription != null) {
        ndk.requests.closeSubscription(subscription!.requestId);
      }
    } catch (e) {}
  }

  @override
  void dispose() {
    super.dispose();

    unsubscribe();
    disposeLater();
  }

  onDeleteCallback(Nip01Event event) {
    // widget.eventBox.delete(event.id);
    setState(() {});
  }

  @override
  void doQuery() {
    preQuery();
    refresh();
  }

  @override
  EventMemBox getEventBox() {
    return eventBox;
  }
}
