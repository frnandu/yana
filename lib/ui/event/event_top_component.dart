import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:crypto/crypto.dart';
import 'package:dart_ndk/nips/nip01/event.dart';
import 'package:dart_ndk/relay.dart';
import 'package:flutter/material.dart';
import 'package:get_time_ago/get_time_ago.dart';
import 'package:provider/provider.dart';
import 'package:yana/nostr/client_utils/keys.dart';
import 'package:yana/nostr/event_kind.dart';
import 'package:yana/ui/name_component.dart';
import 'package:yana/utils/router_path.dart';
import 'package:yana/utils/router_util.dart';
import 'package:yana/utils/string_util.dart';

import '../../main.dart';
import '../../models/metadata.dart';
import '../../nostr/event.dart';
import '../../provider/metadata_provider.dart';
import '../../utils/base.dart';
import '../../utils/hash_util.dart';
import '../user_pic_component.dart';

class EventTopComponent extends StatefulWidget {
  Nip01Event event;
  String? pagePubkey;

  EventTopComponent({
    required this.event,
    this.pagePubkey,
  });

  @override
  State<StatefulWidget> createState() {
    return _EventTopComponent();
  }
}

class _EventTopComponent extends State<EventTopComponent> {
  static const double IMAGE_WIDTH = 34;

  static const double HALF_IMAGE_WIDTH = 17;

  @override
  Widget build(BuildContext context) {
    var themeData = Theme.of(context);
    var smallTextSize = themeData.textTheme.bodySmall!.fontSize;

    var pubkey = widget.event.pubKey;
    // if this is the zap event, change the pubkey from the zap tag info
    if (widget.event.kind == EventKind.ZAP) {
      for (var tag in widget.event.tags) {
        if (tag[0] == "description" && widget.event.tags.length > 1) {
          var description = tag[1];
          var jsonMap = jsonDecode(description);
          var sourceEvent = Event.fromJson(jsonMap);
          if (StringUtil.isNotBlank(sourceEvent.pubKey)) {
            pubkey = sourceEvent.pubKey;
          }
        }
      }
    }
    List<GestureDetector> relayIcons = [];
    widget.event.sources.forEach((source) {
      Relay? relay = relayManager.relays[Relay.clean(source)];
      if (relay != null) {
        String? iconUrl;
        if (relay.url.startsWith("wss://relay.damus.io")) {
          iconUrl = "https://damus.io/img/logo.png";
        } else if (relay.url.startsWith("wss://relay.snort.social")) {
          iconUrl = "https://snort.social/favicon.ico";
        } else {
          iconUrl = relay != null &&
              relay.info != null &&
              StringUtil.isNotBlank(relay.info!.icon)
              ? relay.info!.icon
              : StringUtil.robohash(HashUtil.md5(relay!.url));
        }

        GestureDetector icon = GestureDetector(
            onTap: () {
              if (relay != null && relay.info != null) {
                RouterUtil.router(context, RouterPath.RELAY_INFO, relay);
              }
            },
            child: Container(
                padding: const EdgeInsets.all(3),
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  // color: themeData.cardColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: CachedNetworkImage(

                  imageUrl: iconUrl,
                  width: 15,
                  height: 15,
                  fit: BoxFit.cover,
                  placeholder: (context, url) =>
                  const CircularProgressIndicator(),
                  errorWidget: (context, url, error) => CachedNetworkImage(
                      imageUrl: StringUtil.robohash(HashUtil.md5(relay!.url))),
                  cacheManager: localCacheManager,
                )));

        relayIcons.add(icon);
      }
    });

    return Selector<MetadataProvider, Metadata?>(
      shouldRebuild: (previous, next) {
        return previous != next;
      },
      selector: (context, _metadataProvider) {
        return _metadataProvider.getMetadata(pubkey);
      },
      builder: (context, metadata, child) {
        var themeData = Theme.of(context);

        Widget? imageWidget = UserPicComponent(
          pubkey: widget.event.pubKey,
          width: IMAGE_WIDTH,
        );
        return Container(
          padding: const EdgeInsets.only(
            left: Base.BASE_PADDING,
            right: Base.BASE_PADDING,
            bottom: Base.BASE_PADDING_HALF,
          ),
          child: Row(
            children: [
              jumpWrap(Container(
                width: IMAGE_WIDTH,
                height: IMAGE_WIDTH,
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(HALF_IMAGE_WIDTH),
                  color: Colors.grey,
                ),
                child: imageWidget,
              )),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.only(left: Base.BASE_PADDING_HALF),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(bottom: 2),
                        child: jumpWrap(
                          NameComponent(
                            pubkey: widget.event.pubKey,
                            metadata: metadata,
                          ),
                        ),
                      ),
                      Row(children: [
                        Text(
                          (GetTimeAgo.parse(DateTime.fromMillisecondsSinceEpoch(
                              widget.event.createdAt * 1000)) + " in "),
                          style: TextStyle(
                            fontSize: smallTextSize,
                            color: themeData.hintColor,
                          ),
                        ),

                      ]..addAll(relayIcons))
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget jumpWrap(Widget c) {
    return GestureDetector(
      onTap: () {
        // disable jump when in same user page.
        if (widget.pagePubkey == widget.event.pubKey) {
          return;
        }

        RouterUtil.router(context, RouterPath.USER, widget.event.pubKey);
      },
      child: c,
    );
  }
}
