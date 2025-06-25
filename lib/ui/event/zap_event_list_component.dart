import 'package:ndk/domain_layer/entities/nip_01_event.dart';
import 'package:flutter/material.dart';

import '../../utils/base.dart';
import '../../utils/router_path.dart';
import 'package:go_router/go_router.dart';
import 'zap_event_main_component.dart';

class ZapEventListComponent extends StatefulWidget {
  Nip01Event event;

  bool jumpable;

  ZapEventListComponent({
    required this.event,
    this.jumpable = true,
  });

  @override
  State<StatefulWidget> createState() {
    return _ZapEventListComponent();
  }
}

class _ZapEventListComponent extends State<ZapEventListComponent> {
  @override
  Widget build(BuildContext context) {
    var themeData = Theme.of(context);
    var cardColor = themeData.cardColor;

    var main = Container(
      color: cardColor,
      margin: const EdgeInsets.only(bottom: Base.BASE_PADDING_HALF),
      padding: const EdgeInsets.only(
        top: Base.BASE_PADDING,
        bottom: Base.BASE_PADDING,
      ),
      child: ZapEventMainComponent(
        event: widget.event,
      ),
    );

    if (widget.jumpable) {
      return GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: jumpToThread,
        child: main,
      );
    } else {
      return main;
    }
  }

  void jumpToThread() {
    context.push(RouterPath.THREAD_DETAIL, extra: widget.event);
  }
}
