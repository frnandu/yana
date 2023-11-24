import 'dart:async';

import 'package:dart_ndk/nips/nip01/event.dart';
import 'package:dart_ndk/nips/nip01/filter.dart';
import 'package:dart_ndk/request.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:widget_size/widget_size.dart';
import 'package:yana/provider/event_reactions_provider.dart';
import 'package:yana/provider/single_event_provider.dart';

import '../../main.dart';
import '../../models/event_mem_box.dart';
import '../../nostr/event_kind.dart' as kind;
import '../../nostr/event_relation.dart';
import '../../ui/cust_state.dart';
import '../../ui/event/event_list_component.dart';
import '../../ui/event/event_load_list_component.dart';
import '../../ui/event_reply_callback.dart';
import '../../ui/simple_name_component.dart';
import '../../utils/base.dart';
import '../../utils/peddingevents_later_function.dart';
import '../../utils/platform_util.dart';
import '../../utils/router_util.dart';
import '../../utils/string_util.dart';
import '../../utils/when_stop_function.dart';
import 'thread_detail_event.dart';
import 'thread_detail_event_main_component.dart';
import 'thread_detail_item_component.dart';

class ThreadDetailRouter extends StatefulWidget {
  String? eventId;

  ThreadDetailRouter({super.key, this.eventId});

  @override
  State<StatefulWidget> createState() {
    return _ThreadDetailRouter(eventId);
  }

  static Widget detailAppBarTitle(Nip01Event event, ThemeData themeData) {
    var bodyLargeFontSize = themeData.textTheme.bodyLarge!.fontSize;

    List<Widget> appBarTitleList = [];
    var nameComponnet = SimpleNameComponent(
      pubkey: event.pubKey,
      textStyle: TextStyle(
        fontSize: bodyLargeFontSize,
        color: themeData.appBarTheme.titleTextStyle!.color,
      ),
    );
    appBarTitleList.add(nameComponnet);
    appBarTitleList.add(Text(" : "));
    appBarTitleList.add(Expanded(
        child: Text(
      event.content.replaceAll("\n", " ").replaceAll("\r", " "),
      style: TextStyle(
        overflow: TextOverflow.ellipsis,
        fontSize: bodyLargeFontSize,
      ),
    )));
    return Container(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: appBarTitleList,
      ),
    );
  }
}

class _ThreadDetailRouter extends CustState<ThreadDetailRouter> with PenddingEventsLaterFunction, WhenStopFunction {
  EventMemBox box = EventMemBox();

  String? eventId;
  Nip01Event? sourceEvent;
  Nip01Event? loadedEvent;
  int? sourceIdx;

  bool showTitle = false;

  final ScrollController _controller = ScrollController();

  double rootEventHeight = 120;

  _ThreadDetailRouter(this.eventId);

  @override
  void initState() {
    super.initState();
    // Future.delayed(const Duration(seconds: 3), () {
    //   if (sourceIdx!=null && sourceEvent!=null) {
    //     itemScrollController.jumpTo(
    //         index: sourceIdx!);
    //   }
    // });
    _controller.addListener(() {
      if (_controller.offset > rootEventHeight * 0.8 && !showTitle) {
        setState(() {
          showTitle = true;
        });
      } else if (_controller.offset < rootEventHeight * 0.8 && showTitle) {
        setState(() {
          showTitle = false;
        });
      }
    });
  }

  void loadEvent() async {
    if (eventId != null) {
      var filter = Filter(ids: [eventId!]);
      if (myInboxRelaySet != null) {
        NostrRequest request = await relayManager.requestRelays(myInboxRelaySet!.urls, filter, timeout: 2);
        request.stream.listen((event) {
          setState(() {
            loadedEvent = event;
          });
        });
      }
    }
  }

  List<ThreadDetailEvent>? rootSubList;

  GlobalKey sourceEventKey = GlobalKey();

  final ItemScrollController itemScrollController = ItemScrollController();
  final ScrollOffsetController scrollOffsetController = ScrollOffsetController();
  final ItemPositionsListener itemPositionsListener = ItemPositionsListener.create();
  final ScrollOffsetListener scrollOffsetListener = ScrollOffsetListener.create();

  void initFromArgs({bool force=false}) {
    // do some init oper
    var eventRelation = EventRelation.fromEvent(sourceEvent!);
    rootId = eventRelation.rootId;
    if (rootId == null) {
      // source event is root event
      rootId = sourceEvent!.id;
      rootEvent = sourceEvent!;
    }
    eventReactionsProvider.getThreadReplies(rootId!, force: force).then(
      (replies) {
        box.addList(replies.where((event) {
          if (event.content.startsWith("nostr:nevent1") && !event.content.contains(" ")) {
            return false;
          }
          var eventRelation = EventRelation.fromEvent(event);
          if (eventRelation.replyId != null || eventRelation.rootId != null) {
            return true;
          }
          return false;
        }).toList());
        setState(() {
          rootSubList = listToTree();
        });
        if (sourceIdx == null && replies.length > 5) {
          Future.delayed(const Duration(milliseconds: 500), () {
            if (sourceIdx != null) {
              itemScrollController.jumpTo(index: sourceIdx!);
            }
          });
        }
      },
    );

    // load sourceEvent replies and avoid blank page
    // var eventReactions = eventReactionsProvider.get(rootId!);
    // eventReactionsProvider.subscription(sourceEvent!.id, sourceEvent!.pubKey, null).then((sub) {
    //   if (sub!=null) {
    //     sub.onData((data) {
    //       setState(() {
    //         listToTree(refresh: true);
    //       });
    //     });
    //   }
    // },);

    // if (eventReactions != null && eventReactions.replies.isNotEmpty) {
    //   box.addList(eventReactions.replies);
    // } else if (rootEvent == null) {
    //   box.add(sourceEvent!);
    // }
    // listToTree(refresh: true);
  }

  @override
  Widget doBuild(BuildContext context) {
    var _singleEventProvider = Provider.of<SingleEventProvider>(context);
    var _eventReactionsProvider = Provider.of<EventReactionsProvider>(context);
    if (sourceEvent == null) {
      if (loadedEvent != null) {
        sourceEvent = loadedEvent;
      } else {
        var obj = RouterUtil.routerArgs(context);
        if (obj != null && obj is Nip01Event) {
          sourceEvent = obj;
          if (sourceEvent == null) {
            RouterUtil.back(context);
            return Container();
          }
        } else if (obj != null && obj is String) {
          eventId = obj;
          Future.delayed(const Duration(seconds: 2), () async {
            loadEvent();
          });
        } else {
          Future.delayed(const Duration(seconds: 2), () async {
            loadEvent();
          });
        }
      }
      if (sourceEvent == null) {
        return Container();
      }
//      initFromArgs();
    } else {
      var obj = RouterUtil.routerArgs(context);
      if (obj != null && obj is Nip01Event) {
        if (obj.id != sourceEvent!.id) {
          // arg change! reset.
          sourceEvent = null;
          rootId = null;
          rootSubList = null;
          rootEvent = null;
          sourceIdx = null;
          box = EventMemBox();

          sourceEvent = obj;
//          initFromArgs();
        }
      }
    }
    if (rootSubList == null) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (rootSubList == null) {
          EasyLoading.show(status: "Loading thread...", dismissOnTap: true);
        }
      });
    } else {
      EasyLoading.dismiss();
    }

    var themeData = Theme.of(context);
    var bodyLargeFontSize = themeData.textTheme.bodyLarge!.fontSize;
    var titleTextColor = themeData.appBarTheme.titleTextStyle!.color;
    var cardColor = themeData.cardColor;

    Widget? appBarTitle;
    if (showTitle && rootEvent != null) {
      appBarTitle = ThreadDetailRouter.detailAppBarTitle(rootEvent!, themeData);
    }

    Widget? rootEventWidget;
    if (rootEvent == null) {
      rootEventWidget = rootId != null
          ? Selector<SingleEventProvider, Nip01Event?>(builder: (context, event, child) {
              if (event == null) {
                return EventLoadListComponent();
              }

              return EventListComponent(
                event: event,
                jumpable: false,
                showVideo: true,
                imageListMode: false,
                showLongContent: true,
              );
            }, selector: (context, provider) {
              return provider.getEvent(rootId!);
            })
          : null;
    } else {
      rootEventWidget = EventListComponent(
        event: rootEvent!,
        jumpable: false,
        showVideo: true,
        imageListMode: false,
        showLongContent: true,
      );
    }

    // Widget main = Selector<EventReactionsProvider, EventReactions?>(
    //     builder: (context, reactions, child) {
    //       if (reactions != null && reactions.replies.isNotEmpty) {
    //         box.addList(reactions.replies.where((event) {
    //           var eventRelation = EventRelation.fromEvent(event);
    //           if (eventRelation.replyId!=null || eventRelation.rootId!=null) {
    //             return true;
    //           }
    //           return false;
    //         }).toList());
    //       } else if (rootEvent == null) {
    //         box.add(sourceEvent!);
    //       }
    //
    //       List<ThreadDetailEvent>? rootSubList = listToTree();

    List<Widget> mainList = [];

    if (rootEventWidget != null) {
      mainList.add(WidgetSize(
        child: rootEventWidget!,
        onChange: (size) {
          rootEventHeight = size.height;
        },
      ));
    }
    if (rootSubList != null) {
      for (var item in rootSubList!) {
        addThreadItem(item, mainList);
      }
    }
    Widget main = ScrollablePositionedList.builder(
      initialScrollIndex: sourceIdx ?? 0,
      itemCount: mainList.length,
      itemBuilder: (context, index) => mainList[index],
      itemScrollController: itemScrollController,
      scrollOffsetController: scrollOffsetController,
      itemPositionsListener: itemPositionsListener,
      scrollOffsetListener: scrollOffsetListener,
    );
    // return ListView(
    //
    //   controller: _controller,
    //   children: mainList,
    // );
    // },
    //     selector:  (context, provider) {
    //       return provider.get(rootId!);
    //     },
    // );

    if (PlatformUtil.isTableMode()) {
      main = GestureDetector(
        onVerticalDragUpdate: (detail) {
          _controller.jumpTo(_controller.offset - detail.delta.dy);
        },
        behavior: HitTestBehavior.translucent,
        child: main,
      );
    }

    return  RefreshIndicator(
        onRefresh: () async {
          initFromArgs(force: true);
        },
        child: Scaffold(
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
          // actions: [
          //   IconButton(
          //     onPressed: () {},
          //     icon: Icon(Icons.more_horiz),
          //   ),
          // ],
          title: appBarTitle,
        ),
        body: EventReplyCallback(
            onReplyCallback: onReplyCallback,
            child: main,
          ),
        ));
  }

  @override
  Future<void> onReady(BuildContext context) async {
    initFromArgs();
  }

  String? rootId;

  Nip01Event? rootEvent;

  // List<ThreadDetailEvent>? rootSubList = [];
  //
  // void onRootEvent(Event event) {
  //   setState(() {
  //     rootEvent = event;
  //   });
  // }

  void onEvent(Nip01Event event) {
    if (event.kind == kind.EventKind.ZAP_RECEIPT && StringUtil.isBlank(event.content)) {
      return;
    }

    later(event, (list) {
      box.addList(list);
      //listToTree();
      eventReactionsProvider.onEvents(list);
    }, null);
  }

  @override
  void dispose() {
    super.dispose();
    disposeLater();
    if (sourceEvent != null) {
      eventReactionsProvider.removePendding(sourceEvent!.id);
    }
    sourceEvent = null;
  }

  List<ThreadDetailEvent> listToTree() {
    List<ThreadDetailEvent> rootSubList = [];

    // event in box had been sorted. The last one is the oldest.
    var all = box.all();
    var length = all.length;
    List<ThreadDetailEvent> _rootSubList = [];
    // key - id, value - item
    Map<String, ThreadDetailEvent> itemMap = {};
    for (var i = length - 1; i > -1; i--) {
      var event = all[i];
      var item = ThreadDetailEvent(event: event);
      itemMap[event.id] = item;
    }

    for (var i = length - 1; i > -1; i--) {
      var event = all[i];
      var relation = EventRelation.fromEvent(event);
      var item = itemMap[event.id]!;

      if (relation.replyId == null) {
        _rootSubList.add(item);
      } else {
        var replyItem = itemMap[relation.replyId];
        if (replyItem == null) {
          _rootSubList.add(item);
        } else {
          replyItem.subItems.add(item);
        }
      }
    }

    rootSubList = _rootSubList;
    for (var rootSub in rootSubList!) {
      rootSub.handleTotalLevelNum(0);
    }

    return _rootSubList;
  }

  onReplyCallback(Nip01Event event) {
    onEvent(event);
  }

  void addThreadItem(ThreadDetailEvent item, List<Widget> mainList) {
    var totalLevelNum = item.totalLevelNum;
    var needWidth =
        (totalLevelNum - 1) * (Base.BASE_PADDING + ThreadDetailItemMainComponent.BORDER_LEFT_WIDTH) + ThreadDetailItemMainComponent.EVENT_MAIN_MIN_WIDTH;
    if (item.event.id == sourceEvent!.id) {
      sourceIdx = mainList.length;
    }
    if (needWidth > mediaDataCache.size.width) {
      mainList.add(SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: needWidth,
          child: ThreadDetailItemComponent(
            // key: sourceEvent!=null && item.event.id == sourceEvent!.id? sourceEventKey : null,
            item: item,
            totalMaxWidth: needWidth,
            sourceEventId: sourceEvent!.id,
            sourceEventKey: sourceEventKey,
          ),
        ),
      ));
    } else {
      mainList.add(ThreadDetailItemComponent(
        // key: sourceEvent!=null && item.event.id == sourceEvent!.id? sourceEventKey : null,
        item: item,
        totalMaxWidth: needWidth,
        sourceEventId: sourceEvent!.id,
        sourceEventKey: sourceEventKey,
      ));
    }
    if (item.subItems != null && item.subItems.isNotEmpty) {
      for (var subItem in item.subItems!) {
        addThreadItem(subItem, mainList);
      }
    }
  }
}
