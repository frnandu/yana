import 'package:flutter/material.dart';

import 'events/globals_events_router.dart';

class GlobalsIndexRouter extends StatefulWidget {
  TabController tabController;

  GlobalsIndexRouter({required this.tabController});

  @override
  State<StatefulWidget> createState() {
    return _GlobalsIndexRouter();
  }
}

class _GlobalsIndexRouter extends State<GlobalsIndexRouter> {
  @override
  Widget build(BuildContext context) {
    return TabBarView(
      controller: widget.tabController,
      children: [
        GlobalsEventsRouter(),
      ],
    );
  }
}
