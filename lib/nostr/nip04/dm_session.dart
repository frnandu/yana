import 'package:dart_ndk/nips/nip01/event.dart';

import '../../models/event_mem_box.dart';

class DMSession {
  final String pubkey;

  EventMemBox _box = EventMemBox();

  DMSession({required this.pubkey});

  DMSession clone() {
    return DMSession(pubkey: this.pubkey).._box = this._box;
  }

  bool addEvent(Nip01Event event) {
    return _box.add(event, returnTrueOnNewSources: false);
  }

  void addEvents(List<Nip01Event> events) {
    _box.addList(events);
  }

  Nip01Event? get newestEvent {
    return _box.newestEvent;
  }

  int length() {
    return _box.length();
  }

  Nip01Event? get(int index) {
    if (_box.length() <= index) {
      return null;
    }

    return _box.get(index);
  }

  int lastTime() {
    return _box.newestEvent!.createdAt!;
  }
}
