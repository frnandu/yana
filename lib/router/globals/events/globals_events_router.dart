import 'package:dart_ndk/nips/nip01/event.dart';
import 'package:dart_ndk/nips/nip01/filter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:yana/ui/event_delete_callback.dart';
import 'package:yana/ui/keep_alive_cust_state.dart';

import '../../../main.dart';
import '../../../models/event_mem_box.dart';
import '../../../provider/setting_provider.dart';
import '../../../ui/event/event_list_component.dart';
import '../../../ui/placeholder/event_list_placeholder.dart';
import '../../../utils/base_consts.dart';
import '../../../utils/peddingevents_later_function.dart';
import '../../../utils/platform_util.dart';
import '../../../utils/string_util.dart';

class GlobalsEventsRouter extends StatefulWidget {

  GlobalsEventsRouter({super.key});

  EventMemBox eventBox = EventMemBox(sortAfterAdd: false);

  @override
  State<StatefulWidget> createState() {
    return _GlobalsEventsRouter();
  }
}

class _GlobalsEventsRouter extends KeepAliveCustState<GlobalsEventsRouter>
    with PenddingEventsLaterFunction {
  ScrollController scrollController = ScrollController();

  int? _initTime = DateTime.now().millisecondsSinceEpoch ~/ 1000 - 3600;


  @override
  Widget doBuild(BuildContext context) {
    var _settingProvider = Provider.of<SettingProvider>(context);

    if (widget.eventBox.isEmpty()) {
      return EventListPlaceholder(
        onRefresh: refresh,
      );
    }
    var list = widget.eventBox.all();

    var main = RefreshIndicator(
        onRefresh: () async {
          refresh();
        },
        child: EventDeleteCallback(
          onDeleteCallback: onDeleteCallback,
          child: ListView.builder(
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

  var subscribeId = StringUtil.rndNameStr(16);
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

  Future<void> refresh() async {
    if (StringUtil.isNotBlank(subscribeId)) {
      unsubscribe();
    }

    // var str = await DioUtil.getStr(Base.INDEXS_EVENTS);
    // // print(str);
    // if (StringUtil.isNotBlank(str)) {
    //   ids.clear();
    //   var itfs = jsonDecode(str!);
    //   for (var itf in itfs) {
    //     ids.add(itf as String);
    //   }
    // }
    //
    var filter = Filter(kinds: [Nip01Event.TEXT_NODE_KIND], since: _initTime);
    // TODO use dart_ndk
    // nostr!.subscribe([filter.toMap()], (event) {
    //   if (widget.eventBox.isEmpty()) {
    //     laterTimeMS = 200;
    //   } else {
    //     laterTimeMS = 1000;
    //   }
    //
    //   later(event, (list) {
    //     setState(() {
    //       widget.eventBox.addList(list);
    //       if (widget.eventBox.newestEvent != null) {
    //         _initTime = widget.eventBox.newestEvent!.createdAt;
    //       }
    //     });
    //   }, null);
    // }, id: subscribeId);
  }

  void unsubscribe() {
    try {
      /// TODO use dart_ndk
      // nostr!.unsubscribe(subscribeId);
    } catch (e) {}
  }

  @override
  void dispose() {
    super.dispose();

    unsubscribe();
    disposeLater();
  }

  onDeleteCallback(Nip01Event event) {
    widget.eventBox.delete(event.id);
    setState(() {});
  }
}
