import 'package:cached_network_image/cached_network_image.dart';
import 'package:ndk/entities.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../main.dart';
import '../provider/metadata_provider.dart';
import '../utils/string_util.dart';

class UserPicComponent extends StatefulWidget {
  String pubkey;

  double width;

  UserPicComponent({
    super.key,
    required this.pubkey,
    required this.width,
  });

  @override
  State<StatefulWidget> createState() {
    return _UserPicComponent();
  }
}

class _UserPicComponent extends State<UserPicComponent> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Metadata?>(
        future: metadataProvider.getMetadata(widget.pubkey),
        builder: (context, snapshot) {
          var metadata = snapshot.data;
          Widget? imageWidget;
          String? url = metadata != null && StringUtil.isNotBlank(metadata.picture) ? metadata.picture : StringUtil.robohash(widget.pubkey);

          if (url != null) {
            imageWidget = CachedNetworkImage(
              imageUrl: url,
              width: widget.width,
              height: widget.width,
              fit: BoxFit.cover,
              placeholder: (context, url) => CircularProgressIndicator(),
              errorWidget: (context, url, error) => Icon(Icons.error),
              cacheManager: localCacheManager,
            );
          }
          return Container(
            width: widget.width,
            height: widget.width,
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.width / 2),
              color: Colors.grey,
            ),
            child: imageWidget,
          );
        });
  }
}
