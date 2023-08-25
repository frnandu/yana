import '../main.dart';
import '../nostr/event.dart';
import '../nostr/event_kind.dart' as kind;
import '../nostr/nip57/zap_num_util.dart';
import '../utils/find_event_interface.dart';

class EventReactions implements FindEventInterface {
  String id;

  int replyNum = 0;

  List<Event> replies = [];

  int repostNum = 0;

  List<Event> reposts = [];

  int likeNum = 0;

  List<Event> likes = [];

  List<Event>? myLikeEvents;

  bool hasMyReply = false;
  bool hasMyRepost = false;
  bool hasMyZap = false;

  int zapNum = 0;

  List<Event> zaps = [];

  Map<String, int> eventIdMap = {};

  EventReactions(this.id);

  DateTime accessTime = DateTime.now();

  DateTime dataTime = DateTime.now();

  EventReactions clone() {
    return EventReactions(id)
      ..replyNum = replyNum
      ..replies = replies
      ..repostNum = repostNum
      ..reposts = reposts
      ..likeNum = likeNum
      ..likes = likes
      ..hasMyReply = hasMyReply
      ..hasMyRepost = hasMyRepost
      ..myLikeEvents = myLikeEvents
      ..hasMyZap = hasMyZap
      ..zaps = zaps
      ..zapNum = zapNum
      ..eventIdMap = eventIdMap
      ..accessTime = accessTime
      ..dataTime = dataTime;
  }

  @override
  List<Event> findEvent(String str, {int? limit = 5}) {
    List<Event> list = [];
    for (var event in replies) {
      if (event.content.contains(str)) {
        list.add(event);

        if (limit != null && list.length >= limit) {
          break;
        }
      }
    }
    return list;
  }

  void access(DateTime t) {
    accessTime = t;
  }

  bool onEvent(Event event) {
    dataTime = DateTime.now();

    var id = event.id;
    if (eventIdMap[id] == null) {
      eventIdMap[id] = 1;

      if (event.kind == kind.EventKind.TEXT_NOTE) {
        if (event.pubKey == nostr!.publicKey) {
          hasMyReply = true;
        }
        replyNum++;
        replies.add(event);
      } else if (event.kind == kind.EventKind.REPOST ||
          event.kind == kind.EventKind.GENERIC_REPOST) {
        if (event.pubKey == nostr!.publicKey) {
          hasMyRepost = true;
        }
        repostNum++;
        reposts.add(event);
      } else if (event.kind == kind.EventKind.REACTION) {
        if (event.content == "-") {
          likeNum--;
        } else {
          likeNum++;
          likes.add(event);
          if (event.pubKey == nostr!.publicKey) {
            myLikeEvents ??= [];
            myLikeEvents!.add(event);
          }
        }
      } else if (event.kind == kind.EventKind.ZAP) {
        zapNum += ZapNumUtil.getNumFromZapEvent(event);
        zaps.add(event);

        // if (StringUtil.isNotBlank(event.content)) {
          if (event.pubKey == nostr!.publicKey) {
            hasMyZap = true;
          }
          replyNum++;
          replies.add(event);
        // }
      }

      return true;
    }

    return false;
  }
}
