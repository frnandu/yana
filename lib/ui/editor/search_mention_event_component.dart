import 'package:go_router/go_router.dart';
import 'package:ndk/domain_layer/entities/nip_01_event.dart';
import 'package:flutter/material.dart';

import '../../utils/base.dart';
import '../../models/event_find_util.dart';
import '../../utils/router_util.dart';
import '../../utils/string_util.dart';
import '../../utils/when_stop_function.dart';
import '../event/event_list_component.dart';
import 'search_mention_component.dart';

class SearchMentionEventComponent extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SearchMentionEventComponent();
  }
}

class _SearchMentionEventComponent extends State<SearchMentionEventComponent>
    with WhenStopFunction {
  @override
  Widget build(BuildContext context) {
    return SearchMentionComponent(
      resultBuildFunc: resultBuild,
      handleSearchFunc: handleSearch,
    );
  }

  Widget resultBuild() {
    return Container(
      padding: const EdgeInsets.only(
        top: Base.BASE_PADDING_HALF,
        bottom: Base.BASE_PADDING_HALF,
      ),
      child: ListView.builder(
        itemBuilder: (context, index) {
          var event = events[index];
          return GestureDetector(
            onTap: () {
              context.pop(event.id);
            },
            child: EventListComponent(
              event: event,
              jumpable: false,
            ),
          );
        },
        itemCount: events.length,
      ),
    );
  }

  static const int searchMemLimit = 100;

  List<Nip01Event> events = [];

  void handleSearch(String? text) {
    events.clear();
    if (StringUtil.isNotBlank(text)) {
      var list = EventFindUtil.findEvent(text!, limit: searchMemLimit);
      setState(() {
        events = list;
      });
    }
  }
}
