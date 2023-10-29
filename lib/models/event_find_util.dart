import 'package:dart_ndk/nips/nip01/event.dart';
import 'package:yana/main.dart';

import '../utils/find_event_interface.dart';
import 'event_mem_box.dart';

class EventFindUtil {
  static List<Nip01Event> findEvent(String str, {int? limit = 5}) {
    List<FindEventInterface> finders = [followEventProvider];
    finders.addAll(eventReactionsProvider.allReactions());

    var eventBox = EventMemBox(sortAfterAdd: false);
    for (var finder in finders) {
      var list = finder.findEvent(str, limit: limit);
      if (list.isNotEmpty) {
        eventBox.addList(list);

        if (limit != null && eventBox.length() >= limit) {
          break;
        }
      }
    }
    eventBox.sort();
    return eventBox.all();
  }
}
