import 'package:flutter/material.dart';

import '../../nostr/event_kind.dart' as kind;
import '../../nostr/nip57/zap_num_util.dart';
import '../../ui/event/event_bitcoin_icon_component.dart';
import '../../utils/base.dart';
import '../../utils/number_format_util.dart';
import 'thread_detail_event.dart';
import 'thread_detail_event_main_component.dart';

class ThreadDetailItemComponent extends StatefulWidget {
  double totalMaxWidth;

  ThreadDetailEvent item;

  String sourceEventId;

  GlobalKey sourceEventKey;

  ThreadDetailItemComponent({super.key,
    required this.item,
    required this.totalMaxWidth,
    required this.sourceEventId,
    required this.sourceEventKey,
  });

  @override
  State<StatefulWidget> createState() {
    return _ThreadDetailItemComponent();
  }
}

class _ThreadDetailItemComponent extends State<ThreadDetailItemComponent> {
  @override
  Widget build(BuildContext context) {
    var themeData = Theme.of(context);
    var cardColor = themeData.cardColor;
    var hintColor = themeData.hintColor;

    Widget main = ThreadDetailItemMainComponent(
      item: widget.item,
      totalMaxWidth: widget.totalMaxWidth,
      sourceEventId: widget.sourceEventId,
      sourceEventKey: widget.sourceEventKey,
    );

    if (widget.item.event.kind == kind.EventKind.ZAP) {
      var zapNum = ZapNumUtil.getNumFromZapEvent(widget.item.event);
      String zapNumStr = NumberFormatUtil.format(zapNum);

      main = Column(
        children: [
          Stack(
            children: [
              main,
              Positioned(
                bottom: -5,
                right: 50,
                child:
                Container(
                    margin: const EdgeInsets.only(bottom: Base.BASE_PADDING),
                    child: RichText(
                      text: TextSpan(
                        style:
                        DefaultTextStyle
                            .of(context)
                            .style, // default text style
                        children: <TextSpan>[
                          TextSpan(
                              text: ' zapped ',
                              style: DefaultTextStyle
                                  .of(context)
                                  .style),
                          TextSpan(
                            text: zapNumStr.toString(),
                            style: const TextStyle(
                              color: Colors.orange, // set the color here
                              fontWeight:
                              FontWeight.bold, // you can also apply other styles
                            ),
                          ),
                          TextSpan(
                              text: ' sats   ',
                              style: DefaultTextStyle
                                  .of(context)
                                  .style),
                        ],
                      ),
                    )),
              ),
              const Positioned(
                top: -35,
                right: -10,
                child: EventBitcoinIconComponent(),
              ),
            ],
          ),
        ],
      );
    }

    return Container(
      color: cardColor,
      margin: const EdgeInsets.only(bottom: Base.BASE_PADDING_HALF),
      child: main,
    );
  }
}
