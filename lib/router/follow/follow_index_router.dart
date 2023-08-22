import 'package:flutter/material.dart';

import '../globals/events/globals_events_router.dart';
import 'follow_posts_and_replies_router.dart';
import 'follow_posts_router.dart';

class FollowIndexRouter extends StatefulWidget {
  TabController tabController;

  FollowIndexRouter({required this.tabController});

  @override
  State<StatefulWidget> createState() {
    return _FollowIndexRouter();
  }
}

class _FollowIndexRouter extends State<FollowIndexRouter> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: TabBarView(
        children: [
          FollowPostsRouter(),
          FollowPostsAndRepliesRouter(),
          GlobalsEventsRouter(),
        ],
        controller: widget.tabController,
      ),
    );
  }
}
