import 'package:flutter_list_view/flutter_list_view.dart';
import 'package:go_router/go_router.dart';
import 'package:ndk/domain_layer/entities/nip_01_event.dart';
import 'package:ndk/shared/nips/nip25/reactions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:widget_size/widget_size.dart';

import '../../i18n/i18n.dart';
import '../../models/event_reactions.dart';
import '../../nostr/event_kind.dart' as kind;
import '../../provider/event_reactions_provider.dart';
import '../../provider/single_event_provider.dart';
import '../../ui/event/event_list_component.dart';
import '../../ui/event/event_load_list_component.dart';
import '../../ui/event/reaction_event_list_component.dart';
import '../../ui/event/zap_event_list_component.dart';
import '../../utils/platform_util.dart';
import '../../utils/router_util.dart';
import '../thread/thread_detail_router.dart';

class EventDetailRouter extends StatefulWidget {
  const EventDetailRouter({super.key});

  @override
  State<StatefulWidget> createState() {
    return _EventDetailRouter();
  }
}

class _EventDetailRouter extends State<EventDetailRouter> {
  String? eventId;

  Nip01Event? event;

  bool showTitle = false;

  final FlutterListViewController _controller = FlutterListViewController();

  double rootEventHeight = 120;

  @override
  void initState() {
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    var i18n = I18n.of(context);

    var arg = GoRouterState.of(context).extra;
    if (arg != null) {
      if (arg is Nip01Event) {
        event = arg;
        eventId = event!.id;
      } else if (arg is String) {
        event = null;
        eventId = arg;
      }
    }
    if (event == null && eventId == null) {
      context.pop();
      return Container();
    }
    var themeData = Theme.of(context);

    Widget? appBarTitle;
    if (showTitle && event != null) {
      appBarTitle = ThreadDetailRouter.detailAppBarTitle(event!, themeData);
    }

    Widget? mainEventWidget;
    if (event != null) {
      mainEventWidget = EventListComponent(
        event: event!,
        showVideo: true,
        showDetailBtn: false,
      );
    } else if (eventId != null) {
      mainEventWidget = Selector<SingleEventProvider, Nip01Event?>(
        builder: (context, _event, child) {
          if (_event == null) {
            return EventLoadListComponent();
          } else {
            event = _event;
            return EventListComponent(
              event: _event,
              showVideo: true,
              showDetailBtn: false,
            );
          }
        },
        selector: (context, _provider) {
          return _provider.getEvent(eventId!);
        },
      );
    }

    var mainWidget = Selector<EventReactionsProvider, EventReactions?>(
      builder: (context, eventReactions, child) {
        if (eventReactions == null) {
          return mainEventWidget!;
        }

        List<Nip01Event> allEvent = [];
        allEvent.addAll(eventReactions.replies);
        allEvent.addAll(eventReactions.reposts);
        allEvent.addAll(eventReactions.likes);
        allEvent.addAll(eventReactions.zaps);
        allEvent.sort((event1, event2) {
          return event2.createdAt - event1.createdAt;
        });

        Widget main = FlutterListView(
            controller: _controller,
            delegate: FlutterListViewDelegate(
              (BuildContext context, int index) {
                if (index == 0) {
                  return WidgetSize(
                    child: mainEventWidget!,
                    onChange: (size) {
                      rootEventHeight = size.height;
                    },
                  );
                }

                var event = allEvent[index - 1];
                if (event.kind == kind.EventKind.ZAP_RECEIPT) {
                  return ZapEventListComponent(event: event);
                } else if (event.kind == Nip01Event.kTextNodeKind) {
                  return ReactionEventListComponent(
                      event: event, text: i18n.replied);
                } else if (event.kind == kind.EventKind.REPOST ||
                    event.kind == kind.EventKind.GENERIC_REPOST) {
                  return ReactionEventListComponent(
                      event: event, text: i18n.boosted);
                } else if (event.kind == Reaction.kKind) {
                  return ReactionEventListComponent(
                      event: event, text: i18n.liked);
                }

                return Container();
              },
              childCount: allEvent.length + 1,
            ));

        if (PlatformUtil.isTableMode()) {
          main = GestureDetector(
            onVerticalDragUpdate: (detail) {
              _controller.jumpTo(_controller.offset - detail.delta.dy);
            },
            behavior: HitTestBehavior.translucent,
            child: main,
          );
        }

        return main;
      },
      selector: (context, _provider) {
        return event != null
            ? _provider.get(event!.id, pubKey: event!.pubKey)
            : null;
      },
      shouldRebuild: (previous, next) {
        if ((previous == null && next != null) ||
            (previous != null &&
                next != null &&
                (previous.replies.length != next.replies.length ||
                    previous.repostNum != next.repostNum ||
                    previous.likeNum != next.likeNum ||
                    previous.zapNum != next.zapNum))) {
          return true;
        }

        return false;
      },
    );

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
        title: appBarTitle,
      ),
      body: mainWidget,
    );
  }
}
