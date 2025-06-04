import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:yana/main.dart';
import 'package:yana/provider/webview_provider.dart';
import 'package:yana/ui/webview_router.dart';
import 'package:yana/utils/platform_util.dart';

import '../i18n/i18n.dart';

class HomeComponent extends StatefulWidget {
  Widget child;

  Locale? locale;

  ThemeData? theme;

  HomeComponent({
    required this.child,
    this.locale,
    this.theme,
  });

  @override
  State<StatefulWidget> createState() {
    return _HomeComponent();
  }
}

class _HomeComponent extends State<HomeComponent> {
  @override
  Widget build(BuildContext context) {

    PlatformUtil.init(context);
    var _webviewProvider = Provider.of<WebViewProvider>(context);

    return MaterialApp(
      locale: widget.locale,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        I18n.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: I18n.delegate.supportedLocales,
      theme: widget.theme,
      home: widget.child
      // Stack(
      //   children: [
      //     Positioned.fill(child: widget.child),
      //     webViewProvider.url != null
      //         ? Positioned(
      //             child: Offstage(
      //             offstage: !_webviewProvider.showable,
      //             child: WebViewRouter(url: _webviewProvider.url!),
      //           ))
      //         : Container()
      //   ],
      // ),
    );
  }
}
