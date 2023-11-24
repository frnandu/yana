import 'package:dart_ndk/nips/nip01/event.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../main.dart';
import '../models/event_mem_box.dart';
import '../utils/peddingevents_later_function.dart';
import 'follow_event_provider.dart';

class FollowNewEventProvider extends ChangeNotifier
    with PenddingEventsLaterFunction {
  EventMemBox eventPostsMemBox = EventMemBox(sortAfterAdd: false);
  EventMemBox eventPostsAndRepliesMemBox = EventMemBox();

  void clear() {
    eventPostsMemBox.clear();
    eventPostsAndRepliesMemBox.clear();

    notifyListeners();
  }

  void clearReplies() {
    eventPostsAndRepliesMemBox.clear();
    notifyListeners();
  }

  void clearPosts() {
    eventPostsMemBox.clear();
    notifyListeners();
  }

  handleEvents(List<Nip01Event> events) {

    for (var event in events) {
      bool isPosts = FollowEventProvider.eventIsPost(event);
      if (isPosts) {
        if (!followEventProvider.postsBox.containsId(event.id)) {
          eventPostsMemBox.add(event);
        }
      } else {
        if (!followEventProvider.postsAndRepliesBox.containsId(event.id)) {
          eventPostsAndRepliesMemBox.add(event);
        }
      }
    }
    notifyListeners();
  }
}
