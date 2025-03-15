import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:flutter/services.dart';

/// A widget for displaying an image gallery with swipeable fullscreen images.
class ImageGallery extends StatefulWidget {
  final List<String> imageUrls;
  /// Index of the image to show by default when the gallery opens.
  final int defaultImageIndex;

  /// Title displayed on the top bar of the gallery.
  final String topBarTitle;

  /// Optional hero animation tag for image transitions.
  final String? heroTag;

  /// Optional widget to display in the bottom bar.
  final Widget? bottomBarWidget;

  const ImageGallery({
    super.key,
    required this.imageUrls,
    required this.defaultImageIndex,
    required this.topBarTitle,
    this.bottomBarWidget,
    this.heroTag,
  });

  @override
  _ImageGalleryState createState() => _ImageGalleryState();
}

/// State class for [ImageGallery].
/// Manages the behavior of the gallery, including swiping between images
/// and showing/hiding the status bar.
class _ImageGalleryState extends State<ImageGallery> {
  late PageController _pageController; 
  bool _hideStatusBarWhileViewing = false; // Tracks if the status bar is hidden.
  late int _currentPageIndex; // Tracks the currently displayed image index.

  /// Shows or hides the status bar based on the [show] parameter.
  void _showHideStatusBar(bool show) {
    if (show) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);
    }
  }

  /// Resets the status bar visibility to default when the widget is disposed.
  void _resetStatusBar() {
    if (!_hideStatusBarWhileViewing) return;
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
  }

  @override
  void initState() {
    super.initState();
    _showHideStatusBar(true); // Ensure status bar is visible initially.
    _currentPageIndex = widget.defaultImageIndex;
    _pageController = PageController(initialPage: widget.defaultImageIndex);

    // Update the current page index whenever the page changes.
    _pageController.addListener(() {
      setState(() {
        _currentPageIndex = _pageController.page!.round();
      });
    });
  }

  @override
  void dispose() {
    _resetStatusBar(); // Reset the status bar when the widget is disposed.
    _pageController.dispose(); // Dispose of the PageController.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // Allow the body to extend behind the app bar.
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      body: GestureDetector(
        // Toggle the visibility of the status bar when the screen is tapped.
        onTap: () {
          setState(() {
            _showHideStatusBar(_hideStatusBarWhileViewing);
            _hideStatusBarWhileViewing = !_hideStatusBarWhileViewing;
          });
        },
        child: Stack(
          children: [
            _imageGallery(), // The main image gallery.
            SafeArea(
              child: AnimatedOpacity(
                opacity: _hideStatusBarWhileViewing ? 0 : 1, // Hide UI if status bar is hidden.
                duration: const Duration(milliseconds: 100),
                curve: Curves.easeInOut,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _topBar(context), // Top bar with navigation and title.
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        child: widget.bottomBarWidget, // Optional bottom bar widget.
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the top bar with a close button, title and image count.
  Container _topBar(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      color: Colors.black.withOpacity(0.25), // Transparent background color.
      child: Row(
        children: [
          // Close button to exit the gallery.
          IconButton(
            icon: const Icon(Icons.close, size: 30),
            color: Colors.white,
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          // Title of the gallery.
          Text(
            widget.topBarTitle,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          // Current image index out of total images.
          if (widget.imageUrls.length > 1)
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Text(
                '${_currentPageIndex + 1}/${widget.imageUrls.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Builds the image gallery as a swipeable PageView.
  PageView _imageGallery() {
    return PageView.builder(
      controller: _pageController,
      itemCount: widget.imageUrls.length, // Total number of images.
      itemBuilder: (context, index) {
        return PhotoView(
          imageProvider: NetworkImage(widget.imageUrls[index]), // Display image from network.
          heroAttributes: widget.heroTag != null
              ? PhotoViewHeroAttributes(
                  tag:
                      'image-${widget.imageUrls[widget.defaultImageIndex]}-${widget.heroTag}')
              : null, // Optional hero animation.
          minScale: PhotoViewComputedScale.contained * 1, // Minimum zoom scale.
          maxScale: PhotoViewComputedScale.covered * 2, // Maximum zoom scale.
          filterQuality: FilterQuality.high, // High quality image rendering.
        );
      },
    );
  }
}
