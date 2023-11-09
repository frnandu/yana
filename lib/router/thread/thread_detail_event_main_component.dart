import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:yana/main.dart';
import 'package:yana/router/thread/thread_detail_event.dart';
import 'package:yana/ui/event/event_main_component.dart';

import '../../utils/base.dart';

class ThreadDetailItemMainComponent extends StatefulWidget {
  static double BORDER_LEFT_WIDTH = 2;

  static double EVENT_MAIN_MIN_WIDTH = 200;

  ThreadDetailEvent item;

  double totalMaxWidth;

  String sourceEventId;

  GlobalKey sourceEventKey;

  ThreadDetailItemMainComponent({super.key,
    required this.item,
    required this.totalMaxWidth,
    required this.sourceEventId,
    required this.sourceEventKey,
  });

  @override
  State<StatefulWidget> createState() {
    return _ThreadDetailItemMainComponent();
  }
}

class _ThreadDetailItemMainComponent extends State<ThreadDetailItemMainComponent> {
  ScreenshotController screenshotController = ScreenshotController();


  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.sourceEventId == widget.item.event.id) {
        Scrollable.ensureVisible(context);
      }
    });
  }

  Widget getContainer(Widget w, int level, Color color) {
    if (level == 0) {
      return w;
    }
    return Container(
        margin: EdgeInsets.only(left: ThreadDetailItemMainComponent.BORDER_LEFT_WIDTH),
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              width: ThreadDetailItemMainComponent.BORDER_LEFT_WIDTH,
              color: color,
            ),
          ),
        ),
        child: getContainer(w, level - 1, color)
    );
  }

  @override
  Widget build(BuildContext context) {
    var themeData = Theme.of(context);
    var hintColor = themeData.hintColor;

    var currentMainEvent = EventMainComponent(
      screenshotController: screenshotController,
      event: widget.item.event,
      showReplying: false,
      highlight: widget.sourceEventId == widget.item.event.id,
      showVideo: true,
      imageListMode: false,
      showSubject: false,
    );
    return
      // Screenshot(
      // controller: screenshotController,
      // child:
      Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [getContainer(currentMainEvent, widget.item.currentLevel, widget.sourceEventId == widget.item.event.id ? themeData.primaryColor : hintColor)],
        ),
        // ),
      );
  }
}
