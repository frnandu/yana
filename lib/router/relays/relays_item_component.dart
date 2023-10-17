import 'package:bot_toast/bot_toast.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dart_ndk/relay.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yana/main.dart';
import 'package:yana/nostr/nip19/nip19_tlv.dart';
import 'package:yana/utils/router_path.dart';
import 'package:yana/utils/router_util.dart';

import '../../i18n/i18n.dart';
import '../../nostr/client_utils/keys.dart';
import '../../utils/base.dart';
import '../../utils/string_util.dart';

class RelaysItemComponent extends StatelessWidget {
  Relay relay;

  Function onRemove;

  RelaysItemComponent({required this.relay, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    var themeData = Theme.of(context);
    var cardColor = themeData.cardColor;
    Color borderLeftColor = Colors.red;
    if (relayManager.isRelayConnected(relay.url)) {
      borderLeftColor = Colors.green;
    } else if (relay.connecting) {
      borderLeftColor = Colors.yellow;
    }

    Widget imageWidget;

    String? url;

    if (relay.url.startsWith("wss://relay.damus.io")) {
      url = "https://damus.io/img/logo.png";
    } else if (relay.url.startsWith("wss://relay.snort.social")) {
      url = "https://snort.social/favicon.ico";
    } else {
      url = relay != null &&
          relay.info != null &&
          StringUtil.isNotBlank(relay.info!.icon)
          ? relay.info!.icon
          : StringUtil.robohash(getRandomHexString());
    }

    imageWidget = Container(
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          // color: themeData.cardColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: CachedNetworkImage(
          imageUrl: url,
          width: 40,
          height: 40,
          fit: BoxFit.cover,
          placeholder: (context, url) => const CircularProgressIndicator(),
          errorWidget: (context, url, error) => CachedNetworkImage(
              imageUrl: StringUtil.robohash(relay!.info!.name)),
          cacheManager: localCacheManager,
        ));

    return GestureDetector(
        onTap: () {
          if (relay != null && relay.info != null) {
            RouterUtil.router(context, RouterPath.RELAY_INFO, relay);
          }
        },
        child: Container(
          margin: const EdgeInsets.only(
            bottom: Base.BASE_PADDING_HALF,
            left: Base.BASE_PADDING_HALF,
            right: Base.BASE_PADDING_HALF,
          ),
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.only(
                  left: Base.BASE_PADDING_HALF / 2,
                  right: Base.BASE_PADDING_HALF / 2,
                ),
                color: borderLeftColor,
                height: 50,
                child: const Icon(
                  Icons.lan,
                ),
              ),
              Expanded(
                  child: Row(
                children: [
                  Container(
                      padding: const EdgeInsets.only(
                        left: Base.BASE_PADDING,
                        top: Base.BASE_PADDING_HALF,
                        bottom: Base.BASE_PADDING_HALF,
                        right: Base.BASE_PADDING_HALF,
                      ),
                      child: imageWidget),
                  Container(
                      padding: const EdgeInsets.only(
                        left: Base.BASE_PADDING_HALF,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(bottom: 2),
                            child: Text(relay.url),
                          ),
                          Row(
                            children: [
                              Container(
                                margin: const EdgeInsets.only(
                                    right: Base.BASE_PADDING),
                                child: RelaysItemNumComponent(
                                  iconData: Icons.mail,
                                  num: 0 // todo relay.relayStatus.noteReceived,
                                ),
                              ),
                              // relay.relayStatus.error > 0
                              //     ? RelaysItemNumComponent(
                              //         iconColor: Colors.red,
                              //         iconData: Icons.error_outline,
                              //         num: relay.relayStatus.error,
                              //       )
                              //     : Container(),
                            ],
                          ),
                        ],
                      ))
                ],
              )),
              GestureDetector(
                onTap: () {
                  var text = NIP19Tlv.encodeNrelay(Nrelay(relay.url));
                  Clipboard.setData(ClipboardData(text: text)).then((_) {
                    BotToast.showText(text: I18n.of(context).Copy_success);
                  });
                },
                child: Container(
                  margin: const EdgeInsets.only(right: Base.BASE_PADDING),
                  child: const Icon(
                    Icons.copy,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () async {
                  if (nostr!.privateKey!=null) {
                    await removeRelay(relay.url);
                  }
                },
                child: nostr!.privateKey!=null ? Container(
                  padding: const EdgeInsets.only(
                    right: Base.BASE_PADDING,
                  ),
                  child: const Icon(
                    Icons.delete,
                  ),
                ) : Container(),
              ),
            ],
          ),
        ));
  }

  Future<void> removeRelay(String addr) async {
    await relayProvider.removeRelay(addr);
    onRemove();
  }
}

class RelaysItemNumComponent extends StatelessWidget {
  Color? iconColor;

  IconData iconData;

  int num;

  RelaysItemNumComponent({
    super.key,
    this.iconColor,
    required this.iconData,
    required this.num,
  });

  @override
  Widget build(BuildContext context) {
    var themeData = Theme.of(context);
    var smallFontSize = themeData.textTheme.bodySmall!.fontSize;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          margin: const EdgeInsets.only(right: Base.BASE_PADDING_HALF),
          child: Icon(
            iconData,
            color: iconColor,
            size: smallFontSize,
          ),
        ),
        Text(
          num.toString(),
          style: TextStyle(
            fontSize: smallFontSize,
          ),
        ),
      ],
    );
  }
}
