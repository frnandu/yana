import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:mime/mime.dart';
// import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:yana/utils/platform_util.dart';
import 'package:yana/utils/string_util.dart';

import '../../utils/base64.dart';
import '../../utils/image_services.dart';
import 'nostr_build_uploader.dart';
import 'nostrimg_com_uploader.dart';

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

  static Future<String?> pick(BuildContext context) async {
    if (PlatformUtil.isPC() || PlatformUtil.isWeb()) {
      FilePickerResult? result = await FilePicker.platform.pickFiles();

      if (result != null) {
        if (PlatformUtil.isWeb() && result.files.single.bytes != null) {
          return BASE64.toBase64(result.files.single.bytes!);
        }

        return result.files.single.path;
      }

      return null;
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

    return null;
  }

  static Future<String?> upload(String localPath,
      {String? imageService}) async {
    // if (imageService == ImageServices.NOSTRIMG_COM) {
    //   return await NostrimgComUploader.upload(localPath);
    // } else if (imageService == ImageServices.NOSTR_BUILD) {
      return await NostrBuildUploader.upload(localPath);
    // }
    // return await NostrimgComUploader.upload(localPath);
  }
}
