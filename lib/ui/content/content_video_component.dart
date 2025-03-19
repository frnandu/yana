import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../utils/base.dart';

class ContentVideoComponent extends StatefulWidget {
  String url;

  ContentVideoComponent({required this.url});

  @override
  State<StatefulWidget> createState() {
    return _ContentVideoComponent();
  }
}

class _ContentVideoComponent extends State<ContentVideoComponent> {
  late VideoPlayerController _controller;
  late ChewieController chewieController;
  bool disposed = false;
  bool visible = false;
  bool firstVisible = true;
  // Generate a unique key for the visibility detector
  final Key _visibilityKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    if (widget.url.indexOf("http") == 0) {
      _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url));
        // ..initialize().then((_) {
        //   if (!disposed) {
        //     setState(() {});
        //   }
        // });
    } else {
      _controller = VideoPlayerController.file(File(widget.url));
        // ..initialize().then((_) {
        //   if (!disposed) {
        //     setState(() {});
        //   }
        // });
    }
    chewieController = ChewieController(
      videoPlayerController: _controller,
      autoInitialize: true,
      autoPlay: false,
      looping: false,
    );
    // _controller.initialize().then((_) async {
    //   if (!disposed) {
    //     await _controller.setVolume(100);
    //     _controller.play();
    //   }
    // });
    if (!disposed) {
      _controller.setVolume(0);
    }
    // Future.delayed(Duration(seconds:2), () {
    //   if (visible) {
    //     _controller.play();
    //   }
    // });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
    chewieController.dispose();
    disposed = true;
  }

  // Handle visibility changes
  void _handleVisibilityChanged(VisibilityInfo info) {
    // The visibility percentage (0 means fully invisible, 100 means fully visible)
    final visiblePercentage = info.visibleFraction * 100;

    // You can adjust this threshold based on your requirements
    if (visiblePercentage < 10) {
      visible = false;
      // When widget is less than 10% visible, pause the video
      if (_controller.value.isPlaying && !chewieController.isFullScreen) {
        _controller.pause();
      }
    } else {
      visible = true;
      if (firstVisible) {
        _controller.play();
        firstVisible = false;
      }
      // Optionally: auto-resume when visible again
      // Comment this out if you don't want auto-resume behavior
      // if (chewieController.autoPlay && !_controller.value.isPlaying) {
      //   _controller.play();
      // }
    }
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: _visibilityKey,
      onVisibilityChanged: _handleVisibilityChanged,
      child: Container(
        width: double.maxFinite,
        height: 600,
        margin: const EdgeInsets.only(
          top: Base.BASE_PADDING_HALF,
          bottom: Base.BASE_PADDING_HALF,
        ),
        child: Center(
          child: _controller.value.isInitialized
              ? AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: Chewie(
              controller: chewieController,
            ),
          )
              : Container(),
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