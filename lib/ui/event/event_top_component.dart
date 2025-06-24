import 'dart:convert';

import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:ndk/domain_layer/entities/relay.dart';
import 'package:ndk/domain_layer/entities/relay_connectivity.dart';
import 'package:ndk/entities.dart';
import 'package:flutter/material.dart';
import 'package:get_time_ago/get_time_ago.dart';
import 'package:ndk/shared/helpers/relay_helper.dart';
import 'package:provider/provider.dart';
import 'package:yana/nostr/event_kind.dart';
import 'package:yana/ui/name_component.dart';
import 'package:yana/utils/router_path.dart';
import 'package:go_router/go_router.dart';
import 'package:yana/utils/string_util.dart';

import '../../main.dart';
import '../../provider/metadata_provider.dart';
import '../../utils/base.dart';
import '../../utils/base_consts.dart';
import '../../utils/hash_util.dart';
import '../enum_selector_component.dart';
import '../user_pic_component.dart';

class EventTopComponent extends StatefulWidget {
  Nip01Event event;

  String? pagePubkey;
  Color? color;

  EventTopComponent({
    super.key,
    required this.event,
    this.pagePubkey,
    this.color,
  });

  @override
  State<StatefulWidget> createState() {
    return _EventTopComponent();
  }
}

class _EventTopComponent extends State<EventTopComponent> {
  static const double IMAGE_WIDTH = 50;

  @override
  void initState() {
    // loadRelayInfos();
  }

  @override
  Widget build(BuildContext context) {
    var themeData = Theme.of(context);
    var smallTextSize = themeData.textTheme.bodySmall!.fontSize;

    var pubkey = widget.event.pubKey;
    // if this is the zap event, change the pubkey from the zap tag info
    if (widget.event.kind == EventKind.ZAP_RECEIPT) {
      for (var tag in widget.event.tags) {
        if (tag[0] == "description" && widget.event.tags.length > 1) {
          var description = tag[1];
          var jsonMap = jsonDecode(description);
          var sourceEvent = Nip01Event.fromJson(jsonMap);
          if (StringUtil.isNotBlank(sourceEvent.pubKey)) {
            pubkey = sourceEvent.pubKey;
          }
        }
      }
    }
    List<GestureDetector> relayIcons = [];
    widget.event.sources.forEach((source) {
      RelayConnectivity? relayConnectivity =
          ndk.relays.globalState.relays[source];
      relayConnectivity ??=
          ndk.relays.globalState.relays[cleanRelayUrl(source)];
      Container? relayIcon = relayConnectivity != null
          ? getRelayIcon(relayConnectivity, 13)
          : null;
      if (relayIcon != null) {
        relayIcons.add(GestureDetector(
            onTap: () async {
              await showRelaysPopup();
            },
            child: relayIcon));
      }
    });

    int maxAvatars = 10;
    double maxWidth = 50;
    double width = 13;
    int count = relayIcons.length > maxAvatars ? maxAvatars : relayIcons.length;
    double distance = (maxWidth - count * width) / count;

    if (distance > 3) {
      distance = 3;
    }

    return FutureBuilder<Metadata?>(
        future: metadataProvider.getMetadata(pubkey),
        builder: (context, snapshot) {
          var metadata = snapshot.data;
          var themeData = Theme.of(context);

          Widget? imageWidget = UserPicComponent(
            pubkey: widget.event.pubKey,
            width: IMAGE_WIDTH,
          );
          return Container(
            color: widget.color,
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
                  child: imageWidget,
                )),
                Expanded(
                  child: Container(
                    padding:
                        const EdgeInsets.only(left: Base.BASE_PADDING_HALF),
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
                        Row(
                          children: [
                            Text(
                              (GetTimeAgo.parse(
                                      DateTime.fromMillisecondsSinceEpoch(
                                          widget.event.createdAt * 1000)) +
                                  " in "),
                              style: TextStyle(
                                fontSize: smallTextSize,
                                color: themeData.hintColor,
                              ),
                            ),
                          ]..add(GestureDetector(
                              onTap: () async {
                                await showRelaysPopup();
                              },
                              child: RowSuper(
                                  innerDistance: distance, //,
                                  outerDistance: 5.0,
                                  children: relayIcons))),

                          // ..add(GestureDetector(onTap: () { showRelaysPopup();}, child: Text(
                          //       "${widget.event.sources.length}",
                          //       style: TextStyle(
                          //         fontSize: smallTextSize,
                          //         color: themeData.hintColor,
                          //       )),
                          //     ))
                          //       ..add(GestureDetector(onTap: () { showRelaysPopup();}, child: Icon(Icons.lan_outlined, color: themeData.hintColor, size: 15,)))
                          //   //..addAll(relayIcons)
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }

  Widget jumpWrap(Widget c) {
    return GestureDetector(
      onTap: () {
        if (widget.event.pubKey != 'unset') {
          // disable jump when in same user page.
          if (widget.pagePubkey == widget.event.pubKey) {
            return;
          }

          context.push(RouterPath.USER, extra: widget.event.pubKey);
        }
      },
      child: c,
    );
  }

  Container? getRelayIcon(RelayConnectivity relayConnectivity, double size) {
    if (relayConnectivity != null) {
      String? iconUrl;
      if (relayConnectivity.url.startsWith("wss://relay.damus.io")) {
        iconUrl = "https://damus.io/img/logo.png";
      } else if (relayConnectivity.url.startsWith("wss://relay.snort.social")) {
        iconUrl = "https://snort.social/favicon.ico";
      } else {
        iconUrl = relayConnectivity.relayInfo != null &&
                StringUtil.isNotBlank(relayConnectivity.relayInfo!.icon)
            ? relayConnectivity.relayInfo!.icon
            : StringUtil.robohash(HashUtil.md5(relayConnectivity.url));
      }
      try {
        return Container(
            // padding: const EdgeInsets.all(5),
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
            ),
            child: CachedNetworkImage(
              imageUrl: iconUrl,
              width: size,
              height: size,
              fit: BoxFit.cover,
              placeholder: (context, url) => const CircularProgressIndicator(),
              errorWidget: (context, url, error) => CachedNetworkImage(
                  imageUrl: StringUtil.robohash(
                      HashUtil.md5(relayConnectivity!.url))),
              cacheManager: localCacheManager,
            ));
      } catch (e) {
        print(e);
      }
    }
    return null;
  }

  loadRelayInfos() async {
    await Future.wait(widget.event.sources
        .map((url) => ndk.relays.getRelayInfo(cleanRelayUrl(url)!)));
    // setState(() {});
  }

  Future<void> showRelaysPopup() async {
    if (widget.event.sources.isNotEmpty) {
      await loadRelayInfos();

      List<EnumObj>? relays = widget.event.sources.map((source) {
        RelayConnectivity? relayConnectivity =
            ndk.relays.globalState.relays[source];
        relayConnectivity ??=
            ndk.relays.globalState.relays[cleanRelayUrl(source)];
        return EnumObj(
          source,
          null,
          widget: Row(children: [
            relayConnectivity != null
                ? getRelayIcon(relayConnectivity, 25)!
                : Container(),
            const SizedBox(
              width: 10,
            ),
            Text(source.replaceAll("wss://", ""))
          ]),
        );
      }).toList();
      EnumObj? resultEnumObj =
          await EnumSelectorComponent.show(context, relays!);
      if (resultEnumObj != null) {
        context.go(RouterPath.RELAY_INFO,
            extra: ndk.relays.globalState.relays[resultEnumObj.value]!.relay);
      }
    }
  }
}
