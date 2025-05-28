import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../main.dart';
import '../../utils/base.dart';

class ContentVideoComponent extends StatefulWidget {
  final String url;

  const ContentVideoComponent({super.key, required this.url});

  @override
  State<StatefulWidget> createState() {
    return _ContentVideoComponent();
  }
}

class _ContentVideoComponent extends State<ContentVideoComponent> {
// Create a [Player] to control playback.
  late final player = Player();
  // Create a [VideoController] to handle video output from [Player].
  late final controller = VideoController(player);
  // late FlickManager _flickManager;
  // late VideoPlayerController _controller;

  bool disposed = false;
  bool visible = false;
  bool firstVisible = true;
  final Key _visibilityKey = UniqueKey();

  var userAgent = "Yana/${packageInfo.version}";

  @override
  void initState() {
    super.initState();

    player.open(Media(widget.url));
    player.setVolume(0);
    // if (widget.url.startsWith("http")) {
    //   _controller = VideoPlayerController.networkUrl(
    //     Uri.parse(widget.url), // networkUrl expects a Uri
    //     httpHeaders: {"user-agent": userAgent},
    //   );
    // } else {
    //   _controller = VideoPlayerController.file(File(widget.url));
    // }
    //
    // _flickManager = FlickManager(videoPlayerController: _controller, );
    // _flickManager.flickControlManager!.mute();

  }

  @override
  void dispose() {
    disposed = true;
    player.dispose();
    super.dispose();
  }

  void _handleVisibilityChanged(VisibilityInfo info) {
    // final visiblePercentage = info.visibleFraction * 100;
    //
    // if (disposed) return;
    //
    // if (visiblePercentage < 10) {
    //   visible = false;
    //   if (player.state.playing) {
    //     player.pause();
    //   }
    // } else {
    //   visible = true;
    //   if (firstVisible) {
    //     player.play();
    //     firstVisible = false;
    //   }
    // }
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: _visibilityKey,
      onVisibilityChanged: _handleVisibilityChanged,
      child: Container(
        margin: const EdgeInsets.only(
          top: Base.BASE_PADDING_HALF,
          bottom: Base.BASE_PADDING_HALF,
        ),
        child: Center(
          child:
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.width * 9.0 / 16.0,
            child: Video(controller: controller),
          )
        ),
      ),
    );
  }
}

// The rest of your code (ControlsOverlay class) remains unchanged
// class ControlsOverlay extends StatefulWidget {
//   final VideoPlayerController controller;
//
//   ControlsOverlay({super.key, required this.controller});
//
//   @override
//   State<StatefulWidget> createState() {
//     return _ControlsOverlay();
//   }
// }
//
// class _ControlsOverlay extends State<ControlsOverlay> {
//   late VideoPlayerController controller;
//
//   static const List<Duration> _exampleCaptionOffsets = <Duration>[
//     Duration(seconds: -10),
//     Duration(seconds: -3),
//     Duration(seconds: -1, milliseconds: -500),
//     Duration(milliseconds: -250),
//     Duration.zero,
//     Duration(milliseconds: 250),
//     Duration(seconds: 1, milliseconds: 500),
//     Duration(seconds: 3),
//     Duration(seconds: 10),
//   ];
//   static const List<double> _examplePlaybackRates = <double>[
//     0.25,
//     0.5,
//     1.0,
//     1.5,
//     2.0,
//     3.0,
//     5.0,
//     10.0,
//   ];
//
//   @override
//   void initState() {
//     super.initState();
//     controller = widget.controller;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       children: <Widget>[
//         AnimatedSwitcher(
//           duration: const Duration(milliseconds: 50),
//           reverseDuration: const Duration(milliseconds: 200),
//           child: controller.value.isPlaying
//               ? const SizedBox.shrink()
//               : Container(
//             color: Colors.black26,
//             child: const Center(
//               child: Icon(
//                 Icons.play_arrow,
//                 color: Colors.white,
//                 size: 100.0,
//                 semanticLabel: 'Play',
//               ),
//             ),
//           ),
//         ),
//         GestureDetector(
//           onTap: () {
//             controller.value.isPlaying ? controller.pause() : controller.play();
//             setState(() {});
//           },
//         ),
//         Align(
//           alignment: Alignment.topLeft,
//           child: PopupMenuButton<Duration>(
//             initialValue: controller.value.captionOffset,
//             tooltip: 'Caption Offset',
//             onSelected: (Duration delay) {
//               controller.setCaptionOffset(delay);
//             },
//             itemBuilder: (BuildContext context) {
//               return <PopupMenuItem<Duration>>[
//                 for (final Duration offsetDuration in _exampleCaptionOffsets)
//                   PopupMenuItem<Duration>(
//                     value: offsetDuration,
//                     child: Text('${offsetDuration.inMilliseconds}ms'),
//                   )
//               ];
//             },
//             child: Padding(
//               padding: const EdgeInsets.symmetric(
//                 vertical: 12,
//                 horizontal: 16,
//               ),
//               child: Text('${controller.value.captionOffset.inMilliseconds}ms'),
//             ),
//           ),
//         ),
//         Align(
//           alignment: Alignment.topRight,
//           child: PopupMenuButton<double>(
//             initialValue: controller.value.playbackSpeed,
//             tooltip: 'Playback speed',
//             onSelected: (double speed) {
//               controller.setPlaybackSpeed(speed);
//             },
//             itemBuilder: (BuildContext context) {
//               return <PopupMenuItem<double>>[
//                 for (final double speed in _examplePlaybackRates)
//                   PopupMenuItem<double>(
//                     value: speed,
//                     child: Text('${speed}x'),
//                   )
//               ];
//             },
//             child: Padding(
//               padding: const EdgeInsets.symmetric(
//                 vertical: 12,
//                 horizontal: 16,
//               ),
//               child: Text('${controller.value.playbackSpeed}x'),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }