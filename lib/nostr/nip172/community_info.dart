import 'package:yana/nostr/event.dart';
import 'package:yana/utils/string_util.dart';
import '../../nostr/event_kind.dart' as kind;

import 'community_id.dart';

class CommunityInfo {
  int createdAt;

  CommunityId communityId;

  String? description;

  String? image;

  CommunityInfo({
    required this.createdAt,
    required this.communityId,
    this.description,
    this.image,
  });

  static CommunityInfo? fromEvent(Event event) {
    if (event.kind == kind.EventKind.COMMUNITY_DEFINITION) {
      String title = "";
      String description = "";
      String image = "";
      for (var tag in event.tags) {
        if (tag.length > 1) {
          var tagKey = tag[0];
          var tagValue = tag[1];

          if (tagKey == "d") {
            title = tagValue;
          } else if (tagKey == "description") {
            description = tagValue;
          } else if (tagKey == "image") {
            image = tagValue;
          }
        }
      }

      if (StringUtil.isNotBlank(title)) {
        var id = CommunityId(pubkey: event.pubKey, title: title);
        return CommunityInfo(
          createdAt: event.createdAt,
          communityId: id,
          description: description,
          image: image,
        );
      }
    }

    return null;
  }
}
