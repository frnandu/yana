import 'package:dart_ndk/domain_layer/entities/nip_01_event.dart';
import 'package:flutter/material.dart';
import 'package:yana/nostr/event_relation.dart';

import '../../utils/base.dart';
import '../../utils/router_path.dart';
import '../../utils/router_util.dart';
import 'event_quote_component.dart';
import 'reaction_event_item_component.dart';

class ReactionEventListComponent extends StatefulWidget {
  Nip01Event event;

  bool jumpable;

  bool renderRootEvent;
  String text;

  ReactionEventListComponent({
    required this.event,
    this.renderRootEvent = false,
    this.jumpable = true,
    required this.text,
  });

  @override
  State<StatefulWidget> createState() => _ReactionEventListComponent();
}

class _ReactionEventListComponent extends State<ReactionEventListComponent> {
  @override
  Widget build(BuildContext context) {
    var themeData = Theme.of(context);
    var cardColor = themeData.cardColor;

    Widget main = Container(
      color: cardColor,
      margin: const EdgeInsets.only(bottom: Base.BASE_PADDING_HALF),
      padding: const EdgeInsets.only(
        top: Base.BASE_PADDING,
        bottom: Base.BASE_PADDING,
      ),
      child: ReactionEventItemComponent(
        pubkey: widget.event.pubKey,
        text: Text(" ${widget.text} "),
        createdAt: widget.event.createdAt,
      ),
    );

    EventRelation eventRelation = EventRelation.fromEvent(widget.event);

    if (eventRelation.replyId!=null || eventRelation.rootId!=null) {
      main = Column(children: [main, EventQuoteComponent(
        id: eventRelation.replyId ?? eventRelation.rootId,
        showReactions: false,
        showVideo: true,
      ),
      Container(color: themeData.disabledColor, margin: EdgeInsets.only(top:3), padding: EdgeInsets.only(bottom: 1),)
      ]);
    }

    if (widget.jumpable) {
      return GestureDetector(
        onTap: jumpToThread,
        child: main,
      );
    } else {
      return main;
    }
  }

  void jumpToThread() {
    RouterUtil.router(context, RouterPath.THREAD_DETAIL, widget.event);
  }
}
