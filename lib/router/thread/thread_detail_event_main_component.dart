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

    List<Widget> list = [];
    // var currentWidth = mediaDataCache.size.width;
    // var leftWidth = (widget.item.currentLevel - 1) *
    //     (Base.BASE_PADDING_HALF + ThreadDetailItemMainComponent.BORDER_LEFT_WIDTH);
    // currentWidth = mediaDataCache.size.width - leftWidth;
    // if (currentWidth < ThreadDetailItemMainComponent.EVENT_MAIN_MIN_WIDTH) {
    //   currentWidth = ThreadDetailItemMainComponent.EVENT_MAIN_MIN_WIDTH;
    // }
    Key? currentEventKey = ValueKey<String>(widget.item.event.id);
    // if (widget.item.event.id == widget.sourceEventId) {
    //   currentEventKey = widget.sourceEventKey;
    // }

    List<Widget> aaa = [];
    // for (var i = 0; i < widget.item.currentLevel; i++) {
    //   aaa.add(
    //     Container(
    //         margin: const EdgeInsets.only(top: Base.BASE_PADDING),
    //         child: Divider(height: 200, thickness: ThreadDetailItemMainComponent.BORDER_LEFT_WIDTH*widget.item.currentLevel),
    //       decoration: BoxDecoration(
    //         border: Border(
    //           left: BorderSide(
    //             width: ThreadDetailItemMainComponent.BORDER_LEFT_WIDTH*widget.item.currentLevel*2,
    //             color: widget.sourceEventId == widget.item.event.id ? themeData.primaryColor : hintColor,
    //           ),
    //         ),
    //       )
    //     )
    //   );
    // }
    aaa.add(Expanded(
      key: currentEventKey,
      //alignment: Alignment.centerLeft,
      child: getContainer(currentMainEvent, widget.item.currentLevel, widget.sourceEventId == widget.item.event.id ? themeData.primaryColor : hintColor)
      // Container(
      //     decoration: BoxDecoration(
      //       border: Border(
      //         left: BorderSide(
      //           width: ThreadDetailItemMainComponent.BORDER_LEFT_WIDTH * widget.item.currentLevel * 2,
      //           color: ,
      //         ),
      //       ),
      //     ),
      //     child: currentMainEvent),

    ));
    list.add(Row(children: aaa,));
    // list.add(Container(
    //     decoration: BoxDecoration(
    //         border: Border(
    //           left: BorderSide(
    //             width: ThreadDetailItemMainComponent.BORDER_LEFT_WIDTH*widget.item.currentLevel,
    //             color: widget.sourceEventId == widget.item.event.id ? themeData.primaryColor : hintColor,
    //           ),
    //         ),
    //     ),
    //     child: currentMainEvent
    // ));

    // if (widget.item.subItems != null && widget.item.subItems.isNotEmpty) {
    //   List<Widget> subWidgets = [];
    //   for (var subItem in widget.item.subItems) {
    //     Key? currentEventKey;
    //     if (subItem.event.id == widget.sourceEventId) {
    //       currentEventKey = widget.sourceEventKey;
    //     }
    //     Key? subCurrentEventKey = ValueKey<String>(subItem.event.id);
    //     // if (widget.item.event.id == widget.sourceEventId) {
    //     //   subCurrentEventKey = widget.sourceEventKey;
    //     // }
    //     // subWidgets.add(Text("${widget.sourceEventKey} == ${subCurrentEventKey}"));
    //
    //     subWidgets.add(
    //       ThreadDetailItemMainComponent(
    //         key: subCurrentEventKey,
    //         item: subItem,
    //         totalMaxWidth: widget.totalMaxWidth,
    //         sourceEventId: widget.sourceEventId,
    //         sourceEventKey: widget.sourceEventKey,
    //       ),
    //     );
    //   }
    //   list.add(Container(
    //     alignment: Alignment.centerLeft,
    //     margin: const EdgeInsets.only(
    //       bottom: Base.BASE_PADDING,
    //       left: Base.BASE_PADDING_HALF / 2,
    //     ),
    //     decoration: BoxDecoration(
    //       border: Border(
    //         left: BorderSide(
    //           width: ThreadDetailItemMainComponent.BORDER_LEFT_WIDTH,
    //           color: hintColor,
    //         ),
    //       ),
    //     ),
    //     child: Column(
    //       crossAxisAlignment: CrossAxisAlignment.start,
    //       children: subWidgets,
    //     ),
    //   ));
    // }

    return
      // Screenshot(
      // controller: screenshotController,
      // child:
      Container(
        // alignment: Alignment.centerLeft,
        // margin: widget.item.currentLevel==1 ? const EdgeInsets.only(
        //   // bottom: Base.BASE_PADDING,
        //   left: Base.BASE_PADDING_HALF / 2,
        // ) : null,
        // decoration: BoxDecoration(
        //   color: themeData.cardColor,
        //   // color: widget.sourceEventId == widget.item.event.id? Colors.grey[600] : null,
        //   border: widget.item.currentLevel==1 ? Border(
        //     left: BorderSide(
        //       width: ThreadDetailItemMainComponent.BORDER_LEFT_WIDTH,
        //       color: hintColor,
        //     ),
        //   ) : null,
        // ),
        //
        // padding: const EdgeInsets.only(
        //   top: Base.BASE_PADDING,
        // ),
        // // // color: cardColor,
        // margin: const EdgeInsets.only(top: Base.BASE_PADDING),
        child: Column(
          // mainAxisSize: MainAxisSize.min,
          // crossAxisAlignment: CrossAxisAlignment.start,
          children: [getContainer(currentMainEvent, widget.item.currentLevel, widget.sourceEventId == widget.item.event.id ? themeData.primaryColor : hintColor)],
        ),
        // ),
      );
  }
}
