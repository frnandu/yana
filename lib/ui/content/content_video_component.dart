import 'dart:io';

import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:yana/models/video_autoplay_preference.dart';
import 'package:yana/provider/setting_provider.dart';
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
  FlickManager? _flickManager;
  late VideoPlayerController _controller;

  bool disposed = false;
  bool visible = false;
  List<ConnectivityResult>? cachedConnectivityResults;
  int lastConnectivityCheck = 0;
  bool firstVisible = true;
  final Key _visibilityKey = UniqueKey();

  var userAgent = "Yana/${packageInfo.version}";

  @override
  void initState() {
    super.initState();

    if (widget.url.startsWith("http")) {
      _controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.url), // networkUrl expects a Uri
        httpHeaders: {"user-agent": userAgent},
      );
    } else {
      _controller = VideoPlayerController.file(File(widget.url));
    }
    _controller.addListener(() {
      setState(() {

      });
    });
    shouldAutoPlay().then((shouldPlay) {
      if (disposed) return;
      setState(() {
        _flickManager = FlickManager(
          autoPlay: shouldPlay,
          videoPlayerController: _controller,
        );
        _flickManager!.flickControlManager!.mute();
      });
    });
  }

  @override
  void dispose() {
    disposed = true;
    _flickManager?.dispose();
    super.dispose();
  }

  void _handleVisibilityChanged(VisibilityInfo info) async {
    final visiblePercentage = info.visibleFraction * 100;
    final settingProvider =
        Provider.of<SettingProvider>(context, listen: false);

    if (disposed || _flickManager==null || !_controller.value.isInitialized) return;

    if (visiblePercentage < 10) {
      visible = false;
      if (_flickManager!.flickVideoManager!.isPlaying) {
        _flickManager!.flickControlManager!.pause();
      }
    } else {
      visible = true;
      if (firstVisible) {
        bool shouldPlay = false;

        shouldPlay = await shouldAutoPlay();
        // If !hasAnyConnection, shouldPlay also remains false

        if (shouldPlay) {
          if (_controller.value.isInitialized) {
            _flickManager!.flickControlManager!.play();
          }
        }
        firstVisible = false;
      }
    }
  }

  Future<bool> shouldAutoPlay() async {
    if (cachedConnectivityResults==null || lastConnectivityCheck < DateTime.now().millisecondsSinceEpoch - 10000) {
      lastConnectivityCheck = DateTime.now().millisecondsSinceEpoch;
      cachedConnectivityResults =
        await (Connectivity().checkConnectivity());
    }

    bool hasAnyConnection =
        !cachedConnectivityResults!.contains(ConnectivityResult.none);

    if (hasAnyConnection) {
      // Only proceed if there's some form of internet
      VideoAutoplayPreference preference =
          settingProvider.videoAutoplayPreference;
      if (preference == VideoAutoplayPreference.always) {
        return true;
      } else if (preference == VideoAutoplayPreference.wifiOnly) {
        bool isOnWifi = cachedConnectivityResults!.contains(ConnectivityResult.wifi);
        if (isOnWifi) {
          return true;
        }
      }
      // If preference is VideoAutoplayPreference.never, shouldPlay remains false by default
    }
    // If !hasAnyConnection, shouldPlay also remains false
    return false;
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
            child: _flickManager!=null ? FlickVideoPlayer(
                flickManager: _flickManager!,
                flickVideoWithControls: const FlickVideoWithControls(
                  controls: FlickPortraitControls(
                    iconSize: 32,
                    fontSize: 14,
                  ),
                ))
            : const CircularProgressIndicator(), // Show a loader while initializing
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
