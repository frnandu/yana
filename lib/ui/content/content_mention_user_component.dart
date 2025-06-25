import 'package:ndk/entities.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../main.dart';
import '../../provider/metadata_provider.dart';
import '../../utils/router_path.dart';
import 'package:go_router/go_router.dart';
import '../simple_name_component.dart';
import 'content_str_link_component.dart';

class ContentMentionUserComponent extends StatefulWidget {
  String _pubkey;

  ContentMentionUserComponent({super.key, required String pubkey})
      : _pubkey = pubkey;

  @override
  State<StatefulWidget> createState() {
    return _ContentMentionUserComponent();
  }
}

class _ContentMentionUserComponent extends State<ContentMentionUserComponent> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Metadata?>(
        future: metadataProvider.getMetadata(widget._pubkey),
        builder: (context, snapshot) {
          var metadata = snapshot.data;
          String name =
              SimpleNameComponent.getSimpleName(widget._pubkey, metadata);

          return ContentStrLinkComponent(
            str: "$name",
            showUnderline: false,
            onTap: () {
              context.push(RouterPath.USER, extra: widget._pubkey);
            },
          );
        });
  }
}
