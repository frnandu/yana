import 'package:flutter/material.dart';

class MediaDataCache {
  late Size size;
  bool init=false;
  late EdgeInsets padding;

  void update(BuildContext context) {
    if (init) {
      return; // No need to update if already set
    }
    var mediaData = MediaQuery.of(context);
    size = mediaData.size;
    padding = mediaData.padding;
    init = true;
  }
}
