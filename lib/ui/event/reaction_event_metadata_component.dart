import 'package:cached_network_image/cached_network_image.dart';
import 'package:ndk/entities.dart';
import 'package:flutter/material.dart';
import 'package:yana/utils/router_path.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../main.dart';
import '../../provider/metadata_provider.dart';
import '../../utils/string_util.dart';
import '../simple_name_component.dart';

class ReactionEventMetadataComponent extends StatefulWidget {
  String pubkey;

  ReactionEventMetadataComponent({
    super.key,
    required this.pubkey,
  });

  @override
  State<StatefulWidget> createState() {
    return _ReactionEventMetadataComponent();
  }
}

class _ReactionEventMetadataComponent
    extends State<ReactionEventMetadataComponent> {
  static const double IMAGE_WIDTH = 30;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Metadata?>(
        future: metadataProvider.getMetadata(widget.pubkey),
        builder: (context, snapshot) {
          var metadata = snapshot.data;
          List<Widget> list = [];

          var name = SimpleNameComponent.getSimpleName(widget.pubkey, metadata);

          Widget? imageWidget;
          if (metadata != null) {
            if (StringUtil.isNotBlank(metadata.picture)) {
              imageWidget = CachedNetworkImage(
                imageUrl: metadata.picture!,
                width: IMAGE_WIDTH,
                height: IMAGE_WIDTH,
                fit: BoxFit.cover,
                placeholder: (context, url) =>
                    const CircularProgressIndicator(),
                errorWidget: (context, url, error) => const Icon(Icons.error),
                cacheManager: localCacheManager,
              );
            }
          }

          list.add(Container(
            width: IMAGE_WIDTH,
            height: IMAGE_WIDTH,
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(IMAGE_WIDTH / 2),
              color: Colors.grey,
            ),
            child: imageWidget,
          ));

          list.add(Container(
            margin: EdgeInsets.only(left: 5),
            child: Text(
              name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ));

          return GestureDetector(
            onTap: () {
              context.push(RouterPath.USER, extra: widget.pubkey);
            },
            child: Container(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: list,
              ),
            ),
          );
        });
  }
}
