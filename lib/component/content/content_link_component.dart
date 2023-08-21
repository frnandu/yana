import 'package:flutter/material.dart';
import 'package:yana/component/content/content_str_link_component.dart';
import 'package:yana/component/webview_router.dart';

class ContentLinkComponent extends StatelessWidget {
  String link;

  String? title;

  ContentLinkComponent({
    required this.link,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    return ContentStrLinkComponent(
      str: title != null ? title! : link,
      onTap: () {
        WebViewRouter.open(context, link);
      },
    );
  }
}
