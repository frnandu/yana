import 'package:flutter/material.dart';

import 'package:yana/utils/router_path.dart';
import 'package:yana/utils/router_util.dart';

import 'content_str_link_component.dart';

class ContentTagComponent extends StatelessWidget {
  String tag;

  ContentTagComponent({super.key, required this.tag});

  @override
  Widget build(BuildContext context) {
    // return SelectableText.rich(TextSpan(text: "$tag "));
    return ContentStrLinkComponent(
      str: tag,
      onTap: () {
        var plainTag = tag.replaceFirst("#", "");
        RouterUtil.router(context, RouterPath.TAG_DETAIL, plainTag);
      },
    );
  }
}
