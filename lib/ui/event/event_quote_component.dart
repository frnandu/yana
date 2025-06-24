import 'package:ndk/domain_layer/entities/nip_01_event.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../i18n/i18n.dart';
import '../../provider/single_event_provider.dart';
import '../../utils/base.dart';
import '../../utils/router_path.dart';
import 'package:go_router/go_router.dart';
import '../cust_state.dart';
import 'event_main_component.dart';

class EventQuoteComponent extends StatefulWidget {
  Nip01Event? event;

  String? id;

  bool showVideo;

  bool showReactions;

  EventQuoteComponent({
    super.key,
    this.event,
    this.id,
    this.showReactions = false,
    this.showVideo = false,
  });

  @override
  State<StatefulWidget> createState() {
    return _EventQuoteComponent();
  }
}

class _EventQuoteComponent extends CustState<EventQuoteComponent> {
  // ScreenshotController screenshotController = ScreenshotController();

  @override
  Widget doBuild(BuildContext context) {
    var _singleEventProvider = Provider.of<SingleEventProvider>(context);

    var themeData = Theme.of(context);
    var cardColor = themeData.cardColor;
    var boxDecoration = BoxDecoration(
      borderRadius: BorderRadius.circular(10),
      color: themeData.focusColor,
      boxShadow: [
        BoxShadow(
          color: themeData.dividerColor.withOpacity(0.05),
          offset: const Offset(0, 0),
          blurRadius: 15,
          spreadRadius: 0,
        ),
      ],
    );

    if (widget.event != null) {
      return buildEventWidget(widget.event!, cardColor, boxDecoration);
    }

    return Selector<SingleEventProvider, Nip01Event?>(
      builder: (context, event, child) {
        if (event == null) {
          return buildBlankWidget(boxDecoration);
        }

        return buildEventWidget(event, cardColor, boxDecoration);
      },
      selector: (context, _provider) {
        return _provider.getEvent(widget.id!);
      },
    );
  }

  Widget buildEventWidget(
      Nip01Event event, Color cardColor, BoxDecoration boxDecoration) {
    return
        // Screenshot(
        // controller: screenshotController,
        // child:
        Container(
      // padding: const EdgeInsets.only(top: Base.BASE_PADDING),
      margin: const EdgeInsets.only(
          top: Base.BASE_PADDING, bottom: Base.BASE_PADDING),
      decoration: boxDecoration,
      child: GestureDetector(
        onTap: () {
          jumpToThread(event);
        },
        behavior: HitTestBehavior.translucent,
        child: EventMainComponent(
          // screenshotController: screenshotController,
          event: event,
          addDivider: false,
          showReactions: widget.showReactions,
          showReplying: false,
          textOnTap: () {
            jumpToThread(event);
          },
          showVideo: widget.showVideo,
          imageListMode: true,
        ),
      ),
      // ),
    );
  }

  Widget buildBlankWidget(BoxDecoration boxDecoration) {
    return Container(
      margin: const EdgeInsets.all(Base.BASE_PADDING),
      height: 60,
      decoration: boxDecoration,
      child: Center(child: Text(I18n.of(context).Note_loading)),
    );
  }

  void jumpToThread(Nip01Event event) {
    context.go(RouterPath.THREAD_DETAIL, extra: event);
  }

  @override
  Future<void> onReady(BuildContext context) async {}
}
