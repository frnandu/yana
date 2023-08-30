import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/metadata.dart';
import '../nostr/event.dart';
import '../nostr/filter.dart';
import '../models/event_mem_box.dart';
import '../main.dart';
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
    BotToast.showText(
        text: "Received notification " + receivedAction.payload.toString());
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

  void queryNew() {
    if (kDebugMode) {
      print('!!!!!!!!!!!!!!! New notifications queryNew: ${DateTime.now()}');
    }
    if (subscribeId != null) {
      try {
        nostr!.unsubscribe(subscribeId!);
      } catch (e) {}
    }

    _localSince =
        _localSince == null || notificationsProvider.lastTime() > _localSince!
            ? notificationsProvider.lastTime()
            : _localSince;

    subscribeId = StringUtil.rndNameStr(12);
    var filter = Filter(
      since: _localSince! + 1,
      kinds: notificationsProvider.queryEventKinds(),
      p: [nostr!.publicKey],
    );
    nostr!.query([filter.toJson()], (event) {
      later(event, handleEvents, null);
    }, id: subscribeId);
  }

  handleEvents(List<Event> events) {
    events =
        events.where((element) => element.pubKey != nostr?.publicKey).toList();
    eventMemBox.addList(events);
    _localSince = eventMemBox.newestEvent!.createdAt;
    if (appState != AppLifecycleState.resumed) {
      Metadata? metadata = metadataProvider.getMetadata(events.first.pubKey);
      AwesomeNotifications().createNotification(
        content: NotificationContent(
            id: events.first.id.hashCode,
            channelKey: 'basic',
            largeIcon: metadata?.picture,
            title: "${metadata != null ? metadata.getName() : "??"}: ${events
                .first.content}",
            payload: {"name": "FlutterCampus"},
            badge: eventMemBox.length() +
                dmProvider.howManyNewDMSessionsWithNewMessages(
                    dmProvider.followingList) +
                dmProvider
                    .howManyNewDMSessionsWithNewMessages(dmProvider.knownList) +
                dmProvider
                    .howManyNewDMSessionsWithNewMessages(
                    dmProvider.unknownList)),
      );
    }
    notifyListeners();
  }

  void clear() {
    eventMemBox.clear();

    notifyListeners();
  }
}
