import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:ndk/shared/nips/nip01/helpers.dart';
import 'dart:io';
import 'mem_file.dart';

class RemoveImageMetadata {
  static Future<MemFile> fileToMemFile(File file) async {
    try {
      // Read the image file
      Uint8List imageBytes = await file.readAsBytes();
      img.Image? image = img.decodeImage(imageBytes);

      if (image == null) {
        throw Exception('Failed to decode image');
      }

      // Create a new image without metadata
      img.Image cleanImage = img.Image.from(image);

      // Determine the original format and encode accordingly
      String extension = file.path.split('.').last.toLowerCase();
      String mimeType;
      Uint8List cleanImageBytes;

      switch (extension) {
        case 'png':
          cleanImageBytes = Uint8List.fromList(img.encodePng(cleanImage));
          mimeType = 'image/png';
          break;
        case 'jpg':
        case 'jpeg':
          cleanImageBytes =
              Uint8List.fromList(img.encodeJpg(cleanImage, quality: 100));
          mimeType = 'image/jpeg';
          break;

        case 'gif':
          cleanImageBytes = Uint8List.fromList(img.encodeGif(cleanImage));
          mimeType = 'image/gif';
          break;

        default:
          throw Exception('Unsupported image format: $extension');
      }

      final randomValues = Helpers.getSecureRandomString(10);

      return MemFile(
        bytes: cleanImageBytes,
        mimeType: mimeType,
        name: randomValues,
      );
    } catch (e) {
      print('Error in fileToMemFile: $e');
      rethrow;
    }
  }
}
