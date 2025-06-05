import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:yana/utils/base64.dart';

import '../../main.dart';

class PicEmbedBuilder extends EmbedBuilder {
  @override
  Widget build(BuildContext context, EmbedContext embedContext) {
    var imageUrl = embedContext.node.value.data as String;
    if (imageUrl.indexOf("http") == 0 || imageUrl.indexOf(BASE64.PREFIX) == 0) {
      // netword image
      return CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => CircularProgressIndicator(),
        errorWidget: (context, url, error) => Icon(Icons.error),
        cacheManager: localCacheManager,
      );
    } else {
      // local image
      return Image.file(
        File(imageUrl),
        fit: BoxFit.cover,
      );
    }
  }

  @override
  String get key => BlockEmbed.imageType;
}
