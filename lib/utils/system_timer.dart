import 'dart:async';

import 'package:yana/main.dart';

class SystemTimer {
  static int counter = 0;

  static Timer? timer;

  static void run() {
    if (timer != null) {
      timer!.cancel();
    }
    timer = Timer.periodic(Duration(seconds: 15), (timer) {
      try {
        runTask();
        counter++;
      } catch (e) {
        print(e);
      }
    });
  }

  static void runTask() {
    // log("SystemTimer runTask");
    if (nostr!=null) {
      nostr!.checkAndReconnectRelays();
    }
    if (counter % 2 == 0 && nostr != null) {
      if (counter > 4) {
        newNotificationsProvider.queryNew();
        dmProvider.query(subscribe: false);
      }
    } else {
      if (counter > 4) {
        followNewEventProvider.queryNew();
      }
    }
  }

  static void stopTask() {
    if (timer != null) {
      timer!.cancel();
    }
  }
}
