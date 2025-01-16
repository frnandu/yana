import 'dart:convert';

import 'package:ndk/domain_layer/entities/nip_01_event.dart';
import 'package:ndk/shared/nips/nip25/reactions.dart';

import '../main.dart';
import '../nostr/event_kind.dart' as kind;
import '../nostr/nip57/zap_num_util.dart';
import '../utils/find_event_interface.dart';

/// TODO cache in DB
class EventReactions implements FindEventInterface {
  String id;

  int replyNum = 0;

  List<Nip01Event> replies = [];

  int repostNum = 0;

  List<Nip01Event> reposts = [];

  int likeNum = 0;

  List<Nip01Event> likes = [];

  String? get reaction {
    String? reaction = null;
    if (likes.isNotEmpty) {
      for (var reactionEvent in likes) {
        if (reaction != null && reaction != reactionEvent.content) {
          return null;
        }
        reaction = reactionEvent.content;
      }
    }
    return reaction;
  }

  List<Nip01Event>? myLikeEvents;

  bool hasMyReply = false;
  bool hasMyRepost = false;
  bool hasMyZap = false;

  int zapNum = 0;

  List<Nip01Event> zaps = [];

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
  List<Nip01Event> findEvent(String str, {int? limit = 5}) {
    List<Nip01Event> list = [];
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

  bool onEvent(Nip01Event event) {
    dataTime = DateTime.now();

    var id = event.id;
    if (eventIdMap[id] == null) {
      eventIdMap[id] = 1;

      if (event.kind == Nip01Event.kTextNodeKind) {
        if (event.pubKey == loggedUserSigner!.getPublicKey()) {
          hasMyReply = true;
        }
        replyNum++;
        replies.add(event);
      } else if (event.kind == kind.EventKind.REPOST ||
          event.kind == kind.EventKind.GENERIC_REPOST) {
        if (event.pubKey == loggedUserSigner!.getPublicKey()) {
          hasMyRepost = true;
        }
        repostNum++;
        reposts.add(event);
      } else if (event.kind == Reaction.kKind) {
        if (event.content == "-") {
          likeNum--;
        } else {
          likeNum++;
          likes.add(event);
          if (loggedUserSigner!=null && event.pubKey == loggedUserSigner!.getPublicKey()) {
            myLikeEvents ??= [];
            myLikeEvents!.add(event);
          }
        }
      } else if (event.kind == kind.EventKind.ZAP_RECEIPT) {
        zapNum += ZapNumUtil.getNumFromZapEvent(event);
        zaps.add(event);

        // if (StringUtil.isNotBlank(event.content)) {
          if (loggedUserSigner!=null && event.pubKey == loggedUserSigner!.getPublicKey()) {
            hasMyZap = true;
          } else {
            var tagLength = event.tags.length;
            for (var i = 0; i < tagLength; i++) {
              var tag = event.tags[i];
              if (tag is List && tag.length > 1) {
                var key = tag[0];
                var value = tag[1];
                if (key == "description") {
                  var description = json.decode(value);
                  if (description['pubkey'] == loggedUserSigner!.getPublicKey()) {
                    hasMyZap = true;
                    break;
                  }
                }
              }
            }
          }
          // replyNum++;
          // replies.add(event);
        // }
      }

      return true;
    }

    return false;
  }
}
