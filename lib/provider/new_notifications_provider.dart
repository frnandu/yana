import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:ndk/domain_layer/entities/filter.dart';
import 'package:ndk/domain_layer/entities/metadata.dart';
import 'package:ndk/domain_layer/entities/nip_01_event.dart';
import 'package:ndk/shared/nips/nip25/reactions.dart';
import 'package:flutter/foundation.dart';
import 'package:yana/nostr/event_kind.dart';
import 'package:yana/nostr/event_relation.dart';
import 'package:yana/utils/index_taps.dart';

import '../main.dart';
import '../models/event_mem_box.dart';
import '../nostr/nip57/zap_num_util.dart';
import '../utils/peddingevents_later_function.dart';

class NewNotificationsProvider extends ChangeNotifier
    with PenddingEventsLaterFunction {
  EventMemBox eventMemBox = EventMemBox();

  int? _localSince;

  @pragma("vm:entry-point")
  static Future<void> onActionReceivedMethod(
      ReceivedAction receivedAction) async {
    if (newNotificationsProvider != null) {
      newNotificationsProvider!.queryNew();
      Future.delayed(const Duration(seconds: 1), () {
        if (notificationsProvider != null) {
          notificationsProvider!.mergeNewEvent();
        }
      });
      indexProvider.setCurrentTap(IndexTaps.NOTIFICATIONS);
    }
  }

  /// Use this method to detect when a new notification or a schedule is created
  @pragma("vm:entry-point")
  static Future<void> onNotificationCreatedMethod(
      ReceivedNotification receivedNotification) async {
    // Your code goes here
  }

  @pragma('vm:entry-point')
  Future<void> queryNew() async {
    if (kDebugMode) {
      print('!!!!!!!!!!!!!!! New notifications queryNew');
    }

    _localSince = _localSince == null ||
            (notificationsProvider?.lastTime() ?? 0) > _localSince!
        ? (notificationsProvider?.lastTime() ?? 0)
        : _localSince;

    var filter = Filter(
      since: _localSince!,
      kinds: notificationsProvider?.queryEventKinds() ?? [],
      pTags: [loggedUserSigner!.getPublicKey()],
    );
    await for (final event in ndk.requests
        .query(
            name: "new-notifications",
            filters: [filter],
            relaySet: myInboxRelaySet!)
        .stream) {
      // TODO fix this since it was screwing over received events to handle (metadata mixed)
      handleEvent(event, await ndk.metadata.loadMetadata(event.pubKey));
    }
  }

  handleEvent(Nip01Event event, Metadata? metadata) {
    int previousCount = eventMemBox.length();
    if (event.pubKey != loggedUserSigner?.getPublicKey() &&
        (notificationsProvider?.eventBox.containsId(event.id) == false)) {
      if (eventMemBox.add(event, returnTrueOnNewSources: false)) {
        _localSince = eventMemBox.newestEvent!.createdAt;
        if (eventMemBox.length() > previousCount) {
          print("Received 1 notification event");
          AwesomeNotifications().getAppLifeCycle().then((value) async {
            if (value.toString() != "NotificationLifeCycle.Foreground") {
              String title = "";
              String? body;
              EventRelation eventRelation = EventRelation.fromEvent(event);
              Nip01Event? otherEvent;
              print("event.tags: ${event.tags}");
              if (eventRelation.replyId != null) {
                await for (final event in ndk.requests.query(filters: [
                  Filter(ids: [eventRelation.replyId!])
                ], relaySet: myInboxRelaySet!).stream) {
                  otherEvent = event;
                }
              } else if (eventRelation.tagEList.isNotEmpty) {
                await for (final event in ndk.requests.query(filters: [
                  Filter(ids: [eventRelation.tagEList.first!])
                ], relaySet: myInboxRelaySet!).stream) {
                  otherEvent = event;
                }
              }
              String name =
                  metadata != null ? metadata.getName() : event.pubKey;
              if (event.kind == Reaction.kKind) {
                title = "$name reacted ${event.content.replaceAll('+', '❤')}";
                if (otherEvent != null) {
                  body = otherEvent.content;
                }
              } else if (event.kind == EventKind.ZAP_RECEIPT) {
                var zapNum = ZapNumUtil.getNumFromZapEvent(event);
                title = "$name zapped $zapNum sats";
                if (otherEvent != null) {
                  body = otherEvent.content;
                }
              } else {
                title = "$name replied ";
                body = event.content;
              }
              print("title: $title body: $body metadata:${metadata}");
              AwesomeNotifications().createNotification(
                content: NotificationContent(
                    id: event.id.hashCode,
                    channelKey: 'yana',
                    largeIcon: metadata?.picture,
                    title: title,
                    body: body,
                    payload: {"name": "new notification"},
                    badge: eventMemBox.length()
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
          });
        }
        notifyListeners();
      }
    }
  }

  void clear() {
    eventMemBox.clear();

    notifyListeners();
  }

  int? get lastTimeSafe => notificationsProvider?.lastTime();

  List<int> get queryEventKindsSafe =>
      notificationsProvider?.queryEventKinds() ?? [];

  EventMemBox? get eventBoxSafe => notificationsProvider?.eventBox;
}
