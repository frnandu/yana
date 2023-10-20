import 'package:cached_network_image/cached_network_image.dart';
import 'package:dart_ndk/nips/nip01/metadata.dart';
import 'package:dart_ndk/relay.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yana/main.dart';
import 'package:yana/provider/metadata_provider.dart';
import 'package:yana/ui/name_component.dart';
import 'package:yana/utils/base.dart';
import 'package:yana/utils/router_path.dart';

import '../../ui/webview_router.dart';
import '../../utils/hash_util.dart';
import '../../utils/router_util.dart';
import '../../utils/string_util.dart';

class RelayInfoRouter extends StatefulWidget {
  const RelayInfoRouter({super.key});

  @override
  State<StatefulWidget> createState() {
    return _RelayInfoRouter();
  }
}

class _RelayInfoRouter extends State<RelayInfoRouter> {
  double IMAGE_WIDTH = 45;

  @override
  Widget build(BuildContext context) {
    var themeData = Theme.of(context);
    var titleFontSize = themeData.textTheme.bodyLarge!.fontSize;

    var relayItf = RouterUtil.routerArgs(context);
    if (relayItf == null || !(relayItf is Relay)) {
      RouterUtil.back(context);
      return Container();
    }

    var relay = relayItf as Relay;
    var relayInfo = relay.info!;

    List<Widget> list = [];
    Widget imageWidget;
    String? icon;
    if (relay.url.startsWith("wss://relay.damus.io")) {
      icon = "https://damus.io/img/logo.png";
    } else if (relay.url.startsWith("wss://relay.snort.social")) {
      icon = "https://snort.social/favicon.ico";
    } else {
      icon = relay != null &&
          relay.info != null &&
          StringUtil.isNotBlank(relay.info!.icon)
          ? relay.info!.icon
          : StringUtil.robohash(HashUtil.md5(relay!.url));
    }
    imageWidget = CachedNetworkImage(
      imageUrl: icon,
      width: 50,
      height: 50,
      fit: BoxFit.cover,
      placeholder: (context, url) => const CircularProgressIndicator(),
      errorWidget: (context, url, error) =>
          CachedNetworkImage(imageUrl: StringUtil.robohash(HashUtil.md5(relay!.url))),
      cacheManager: localCacheManager,
    );

    Row iconAndNameRow = Row(children: [
      Container(
          margin: const EdgeInsets.only(
            top: Base.BASE_PADDING * 2,
            bottom: Base.BASE_PADDING * 2,
            left: Base.BASE_PADDING * 2,
            right: Base.BASE_PADDING,
          ),
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            // color: themeData.cardColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: imageWidget),
      Column(children: [
        Container(
          margin: const EdgeInsets.only(
              top: Base.BASE_PADDING,
              bottom: Base.BASE_PADDING,
              left: Base.BASE_PADDING),
          child: Text(
            relayInfo.name,
            style: TextStyle(
              fontSize: titleFontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ])
    ]);

    list.add(iconAndNameRow);

    list.add(Container(
      margin: const EdgeInsets.only(
          bottom: Base.BASE_PADDING, top: Base.BASE_PADDING),
      child: Text(
        relayInfo.description,
        maxLines: 3,
      ),
    ));

    list.add(RelayInfoItemComponent(
      title: "Url",
      child: SelectableText(relay.url),
    ));

    list.add(RelayInfoItemComponent(
      title: "Owner",
      child: Selector<MetadataProvider, Metadata?>(
        builder: (context, metadata, child) {
          List<Widget> list = [];

          Widget? imageWidget;
          if (metadata != null) {
            imageWidget = CachedNetworkImage(
              imageUrl: metadata.picture!,
              width: IMAGE_WIDTH,
              height: IMAGE_WIDTH,
              fit: BoxFit.cover,
              placeholder: (context, url) => const CircularProgressIndicator(),
              errorWidget: (context, url, error) => const Icon(Icons.error),
              cacheManager: localCacheManager,
            );
          }
          list.add(Container(
            height: IMAGE_WIDTH,
            width: IMAGE_WIDTH,
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(IMAGE_WIDTH),
              color: Colors.grey,
            ),
            child: imageWidget,
          ));

          list.add(Container(
            margin: const EdgeInsets.only(left: Base.BASE_PADDING),
            child: NameComponent(
              pubkey: relayInfo.pubKey,
              metadata: metadata,
            ),
          ));

          return GestureDetector(
            onTap: () {
              RouterUtil.router(context, RouterPath.USER, relayInfo.pubKey);
            },
            child: Row(
              children: list,
            ),
          );
        },
        selector: (context, _provider) {
          return _provider.getMetadata(relayInfo.pubKey);
        },
      ),
    ));

    list.add(RelayInfoItemComponent(
      title: "Contact",
      child: SelectableText(relayInfo.contact),
    ));

    list.add(RelayInfoItemComponent(
      title: "Soft",
      child: SelectableText(relayInfo.software),
    ));

    list.add(RelayInfoItemComponent(
      title: "Version",
      child: SelectableText(relayInfo.version),
    ));

    List<Widget> nipWidgets = [];
    for (var nip in relayInfo.nips) {
      nipWidgets.add(NipComponent(nip: nip));
    }
    list.add(RelayInfoItemComponent(
      title: "NIPs",
      child: Wrap(
        children: nipWidgets,
        spacing: Base.BASE_PADDING,
        runSpacing: Base.BASE_PADDING,
      ),
    ));

    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            RouterUtil.back(context);
          },
          child: Icon(
            Icons.arrow_back_ios,
            color: themeData.appBarTheme.titleTextStyle!.color,
          ),
        ),
        title: Text(
          "Relay Info",
          style: TextStyle(
            fontSize: titleFontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          width: double.maxFinite,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: list,
          ),
        ),
      ),
    );
  }
}

class RelayInfoItemComponent extends StatelessWidget {
  String title;

  Widget child;

  RelayInfoItemComponent({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    List<Widget> list = [];

    list.add(Container(
      child: Text(
        "$title :",
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
    ));

    list.add(Container(
      padding: EdgeInsets.only(
        left: Base.BASE_PADDING,
        right: Base.BASE_PADDING,
      ),
      child: child,
    ));

    return Container(
      padding: EdgeInsets.only(
        left: Base.BASE_PADDING,
        right: Base.BASE_PADDING,
      ),
      margin: EdgeInsets.only(
        bottom: Base.BASE_PADDING,
      ),
      width: double.maxFinite,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: list,
      ),
    );
  }
}

class NipComponent extends StatelessWidget {
  dynamic nip;

  NipComponent({required this.nip});

  @override
  Widget build(BuildContext context) {
    var themeData = Theme.of(context);
    var mainColor = themeData.primaryColor;

    var nipStr = nip.toString();
    if (nipStr == "1") {
      nipStr = "01";
    } else if (nipStr == "2") {
      nipStr = "02";
    } else if (nipStr == "3") {
      nipStr = "03";
    } else if (nipStr == "4") {
      nipStr = "04";
    } else if (nipStr == "5") {
      nipStr = "05";
    } else if (nipStr == "6") {
      nipStr = "06";
    } else if (nipStr == "7") {
      nipStr = "07";
    } else if (nipStr == "8") {
      nipStr = "08";
    } else if (nipStr == "9") {
      nipStr = "09";
    }

    return GestureDetector(
      onTap: () {
        var url =
            "https://github.com/nostr-protocol/nips/blob/master/$nipStr.md";
        WebViewRouter.open(context, url);
      },
      child: Text(
        nipStr,
        style: TextStyle(
          color: mainColor,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }
}
