import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:ndk/shared/nips/nip01/helpers.dart';

import 'images_gallery.dart';

class ImagesTileView extends StatelessWidget {
  final List<String> images;
  final Widget? galleryBottomWidget;
  final String _tileViewId = Helpers.getRandomString(4);
  final double maxHeight;

  ImagesTileView({
    super.key,
    required this.images,
    this.galleryBottomWidget,
    this.maxHeight = 600,
  });

  @override
  Widget build(BuildContext context) {
    int imageCount = images.length;

    return LayoutBuilder(
      builder: (context, constraints) {
        double aspectRatio = 1;//imageCount > 1 ? 1 : 16 / 9;
        double widgetHeight = constraints.maxWidth / aspectRatio;

        widgetHeight = widgetHeight > maxHeight ? maxHeight : widgetHeight;

        return ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: SizedBox(
            height: maxHeight,
            child: _buildImageGrid(imageCount, constraints.maxWidth, context),
          ),
        );
      },
    );
  }

  Widget _buildImageGrid(
      int imageCount, double maxWidth, BuildContext context) {
    if (imageCount == 1) {
      return _buildImageTile(0, 0, context);
    }

    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              Expanded(child: _buildImageTile(0, 0, context)),
              if (imageCount > 1) SizedBox(width: 2),
              if (imageCount > 1)
                Expanded(child: _buildImageTile(1, 0, context)),
            ],
          ),
        ),
        if (imageCount > 2) SizedBox(height: 2),
        if (imageCount > 2)
          Expanded(
            child: Row(
              children: [
                Expanded(child: _buildImageTile(2, 0, context)),
                if (imageCount > 3) SizedBox(width: 2),
                if (imageCount > 3)
                  Expanded(child: _buildImageTile(3, imageCount - 4, context)),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildImageTile(
      int index, int additionalImages, BuildContext context) {
    return GestureDetector(
      onTap: () => _openGallery(context, index),
      child: Hero(
        tag: 'image-${images[index]}-$_tileViewId',
        child: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: images[index],
              fit: BoxFit.fitWidth,
              placeholder: (context, url) => _imageLoading(),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
            if (index == 3 && additionalImages > 0)
              _buildAdditionalImagesOverlay(additionalImages),
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalImagesOverlay(int additionalImages) {
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          colors: [
            Colors.black.withValues(alpha: 0.8),
            Colors.grey.withValues(alpha: 0.5),
          ],
          stops: const [0.0, 1.0],
        ),
      ),
      child: Center(
        child: Text(
          '+$additionalImages',
          style: const TextStyle(color: Colors.white, fontSize: 38),
        ),
      ),
    );
  }

  void _openGallery(BuildContext context, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImageGallery(
          imageUrls: images,
          defaultImageIndex: index,
          topBarTitle: 'close',
          bottomBarWidget: galleryBottomWidget,
          heroTag: _tileViewId,
        ),
      ),
    );
  }
}

Widget _imageLoading() {
  return Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(8),
      color: Colors.black,
    ),
    child: Center(
      child: CircularProgressIndicator(
        color: Colors.white,
      ),
    ),
  );
}
