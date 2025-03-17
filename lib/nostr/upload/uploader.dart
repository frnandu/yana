import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:yana/nostr/upload/remove_image_metadata.dart';
import 'package:yana/utils/platform_util.dart';
import 'package:yana/utils/string_util.dart';

import '../../utils/base64.dart';

class Uploader {
  // static Future<String?> pickAndUpload(BuildContext context) async {
  //   var assets = await AssetPicker.pickAssets(
  //     context,
  //     pickerConfig: const AssetPickerConfig(maxAssets: 1),
  //   );

  //   if (assets != null && assets.isNotEmpty) {
  //     for (var asset in assets) {
  //       var file = await asset.file;
  //       return await NostrBuildUploader.upload(file!.path);
  //     }
  //   }

  //   return null;
  // }

  static String getFileType(String filePath) {
    var fileType = lookupMimeType(filePath);
    if (StringUtil.isBlank(fileType)) {
      fileType = "image/jpeg";
    }

    return fileType!;
  }

  static Future<List<String?>> pick(BuildContext context) async {
    if (PlatformUtil.isPC() || PlatformUtil.isWeb()) {
      FilePickerResult? result = await FilePicker.platform.pickFiles();

      if (result != null) {
        if (PlatformUtil.isWeb() && result.files.single.bytes != null) {
          return [BASE64.toBase64(result.files.single.bytes!)];
        }

        return [result.files.single.path];
      }

      return [];
    }
    final ImagePicker picker = ImagePicker();
    final result = await picker.pickMultiImage();

    try {
      for (final image in result) {
        await RemoveImageMetadata.fileToMemFile(File(image.path));
      }
      return result.map((a) => a.path).toList();
    } catch (e) {
      // TODO
    }
    // var assets = await AssetPicker.pickAssets(
    //   context,
    //   pickerConfig: const AssetPickerConfig(maxAssets: 1),
    // );
    //
    // if (assets != null && assets.isNotEmpty) {
    //   var file = await assets[0].file;
    //   return file!.path;
    // }

    return [];
  }
}
