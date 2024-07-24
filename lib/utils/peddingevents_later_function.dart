import 'package:dart_ndk/domain_layer/entities/nip_01_event.dart';

import '../main.dart';

mixin PenddingEventsLaterFunction {
  int laterTimeMS = 200;

  bool latering = false;

  List<Nip01Event> penddingEvents = [];

  bool _running = true;

  void later(Nip01Event event, Function(List<Nip01Event>) func, Function? completeFunc) {
    penddingEvents.add(event);
    if (latering) {
      return;
    }

    latering = true;
    Future.delayed(Duration(milliseconds: laterTimeMS), () {
      latering = false;
      if (!_running || loggedUserSigner==null) {
        return;
      }

      func(penddingEvents);
      penddingEvents.clear();
      if (completeFunc != null) {
        completeFunc();
      }
    });
  }

  void disposeLater() {
    _running = false;
  }
}
