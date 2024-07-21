import 'package:dart_ndk/domain_layer/entities/nip_01_event.dart';

class ContentEventTagInfos {
  Map<String, String> emojiMap = {};

  ContentEventTagInfos.fromEvent(Nip01Event event) {
    for (var tag in event.tags) {
      if (tag is List<dynamic> && tag.length > 1) {
        var key = tag[0];
        if (key == "emoji" && tag.length > 2) {
          emojiMap[":${tag[1]}:"] = tag[2];
        }
      }
    }
  }
}
