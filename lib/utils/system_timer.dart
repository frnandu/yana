import 'dart:async';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:yana/main.dart';
import 'package:yana/provider/notifications_provider.dart';
import 'package:yana/provider/relay_provider.dart';
import 'package:yana/utils/string_util.dart';

import '../nostr/nostr.dart';
import '../provider/data_util.dart';
import '../provider/filter_provider.dart';
import '../provider/new_notifications_provider.dart';
import '../provider/setting_provider.dart';

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
      AwesomeNotifications().getAppLifeCycle().then((value) {
        if (value.toString() == "NotificationLifeCycle.Foreground") {
          if (kDebugMode) {
            print('!!!!!!!!!!!!!!! SystemTimer.runTask');
          }
          nostr!.checkAndReconnectRelays();
          newNotificationsProvider.queryNew();
          followNewEventProvider.queryNew();
          dmProvider.query(subscribe: false);
        }
      });
    }
    if (counter % 2 == 0 && nostr != null) {
      if (counter > 4) {
      }
    } else {
      if (counter > 4) {
      }
    }
  }

  static void stopTask() {
    if (timer != null) {
      timer!.cancel();
    }
  }

  static void notifications() async {
    if (kDebugMode) {
      print('!!!!!!!!!!!!!!! SystemTimer.notifications');
    }
    sharedPreferences = await DataUtil.getInstance();
    relayProvider = RelayProvider.getInstance();
    relayProvider!.load();

    settingProvider = await SettingProvider.getInstance();
    if (StringUtil.isNotBlank(settingProvider.privateKey)) {
      try {
        nostr = Nostr(privateKey: settingProvider.privateKey);
        // log("nostr init over");
        relayProvider.addRelays(nostr!).then((bla) {
          nostr!.checkAndReconnectRelays();
          filterProvider = FilterProvider.getInstance();
          notificationsProvider = NotificationsProvider();
          newNotificationsProvider = NewNotificationsProvider();
          newNotificationsProvider.queryNew();
        });
      } catch (e) {
        var index = settingProvider.privateKeyIndex;
        if (index != null) {
          settingProvider.removeKey(index);
        }
      }
    }
  }
}
