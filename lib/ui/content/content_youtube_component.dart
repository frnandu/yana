import 'package:flutter/material.dart';
import 'package:yana/utils/string_util.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import 'content_link_pre_component.dart';

class ContentYoutubeComponent extends StatelessWidget {
  String link;

  ContentYoutubeComponent({super.key,
    required this.link,
  });

  @override
  Widget build(BuildContext context) {
    var videoId = YoutubePlayer.convertUrlToId(link);
    if (StringUtil.isBlank(videoId)) {
      return ContentLinkPreComponent(
        link: link,
      );
    }

    return YoutubePlayer(
      controller: YoutubePlayerController(
          initialVideoId: videoId!,
          flags: const YoutubePlayerFlags(
            autoPlay: false,
          )),
    );
  }
}
