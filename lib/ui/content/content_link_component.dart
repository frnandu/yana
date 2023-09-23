import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yana/ui/webview_router.dart';

import 'content_str_link_component.dart';

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
        launchUrl(Uri.parse(link), mode: LaunchMode.externalApplication);
//        WebViewRouter.open(context, link);
      },
    );
  }
}
