import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:dart_ndk/nips/nip01/event.dart';
import 'package:dart_ndk/nips/nip01/metadata.dart';
import 'package:flutter/foundation.dart';
import 'package:yana/utils/index_taps.dart';

import '../main.dart';
import '../models/event_mem_box.dart';
import 'package:dart_ndk/nips/nip01/filter.dart';
import '../utils/peddingevents_later_function.dart';
import '../utils/string_util.dart';

class NewNotificationsProvider extends ChangeNotifier
    with PenddingEventsLaterFunction {
  EventMemBox eventMemBox = EventMemBox();

  int? _localSince;

  String? subscribeId;

  @pragma("vm:entry-point")
  static Future<void> onActionReceivedMethod(
      ReceivedAction receivedAction) async {
    if (kDebugMode) {
      BotToast.showText(
          text: "Received notification " + receivedAction.payload.toString());
    }
    newNotificationsProvider.queryNew();
    Future.delayed(Duration(seconds: 1), () {
      notificationsProvider.mergeNewEvent();
    });

    indexProvider.setCurrentTap(IndexTaps.NOTIFICATIONS);
    //
    // // Navigate into pages, avoiding to open the notification details page over another details page already opened
    // MyApp.navigatorKey.currentState?.pushNamedAndRemoveUntil('/notification-page',
    //         (route) => (route.settings.name != '/notification-page') || route.isFirst,
    //     arguments: receivedAction);
  }

  /// Use this method to detect when a new notification or a schedule is created
  @pragma("vm:entry-point")
  static Future<void> onNotificationCreatedMethod(
      ReceivedNotification receivedNotification) async {
    // Your code goes here
  }

  @pragma('vm:entry-point')
  void queryNew() {
    if (kDebugMode) {
      print('!!!!!!!!!!!!!!! New notifications queryNew');
    }
    /// TODO use dart_ndk
    // if (subscribeId != null) {
    //   try {
    //     nostr!.unsubscribe(subscribeId!);
    //   } catch (e) {}
    // }

    _localSince =
        _localSince == null || notificationsProvider.lastTime() > _localSince!
            ? notificationsProvider.lastTime()
            : _localSince;

    subscribeId = StringUtil.rndNameStr(12);
    var filter = Filter(
      since: _localSince!,
      kinds: notificationsProvider.queryEventKinds(),
      pTags: [loggedUserSigner!.getPublicKey()],
    );
    // TODO use dart_ndk
    // nostr!.query([filter.toMap()], (event) {
    //   later(event, handleEvents, null);
    // }, id: subscribeId);
  }

  handleEvents(List<Nip01Event> events) {
    int previousCount = eventMemBox.length();
    print("Received ${events.length} notification events");
    events =
        events.where((event) => event.pubKey != loggedUserSigner?.getPublicKey() && !notificationsProvider.eventBox.containsId(event.id)).toList();
    if (events.isEmpty) {
      return;
    }
    eventMemBox.addList(events);
    _localSince = eventMemBox.newestEvent!.createdAt;
    if (eventMemBox.length() > previousCount) {
      AwesomeNotifications().getAppLifeCycle().then((value) async {
        if (value.toString() != "NotificationLifeCycle.Foreground") {
          Metadata? metadata = await relayManager.getSingleMetadata(events.first.pubKey);
          if (metadata!=null) {
            AwesomeNotifications().createNotification(
              content: NotificationContent(
                  id: events.first.id.hashCode,
                  channelKey: 'yana',
                  largeIcon: metadata?.picture,
                  title: "${metadata != null
                      ? metadata.getName()
                      : "??"}: ${events
                      .first.content.replaceAll('+', '❤')}",
                  payload: {"name": "new notification"},
                  badge:
                  eventMemBox.length()
                // +
                //     dmProvider.howManyNewDMSessionsWithNewMessages(
                //         dmProvider.followingList) +
                //     dmProvider
                //         .howManyNewDMSessionsWithNewMessages(
                //         dmProvider.knownList) +
                //     dmProvider
                //         .howManyNewDMSessionsWithNewMessages(
                //         dmProvider.unknownList)
              ),
            );
          }
        }
      });
    }
    notifyListeners();
  }

  void clear() {
    eventMemBox.clear();

    notifyListeners();
  }
}
