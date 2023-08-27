import 'package:bot_toast/bot_toast.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yana/main.dart';
import 'package:yana/nostr/nip19/nip19_tlv.dart';
import 'package:yana/utils/router_path.dart';
import 'package:yana/utils/router_util.dart';

import '../../i18n/i18n.dart';
import '../../models/relay_status.dart';
import '../../nostr/client_utils/keys.dart';
import '../../utils/base.dart';
import '../../utils/client_connected.dart';
import '../../utils/string_util.dart';

class RelaysItemComponent extends StatelessWidget {
  String addr;

  RelayStatus relayStatus;

  RelaysItemComponent({required this.addr, required this.relayStatus});

  @override
  Widget build(BuildContext context) {
    var themeData = Theme.of(context);
    var cardColor = themeData.cardColor;
    Color borderLeftColor = Colors.green;
    if (relayStatus.connected != ClientConneccted.CONNECTED) {
      borderLeftColor = Colors.red;
    }
    var relay = nostr!.getRelay(addr);

    Widget imageWidget;
    String? url = relay != null &&
            relay.info != null &&
            StringUtil.isNotBlank(relay.info!.icon)
        ? relay.info!.icon
        : StringUtil.robohash(getRandomHexString());

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
      errorWidget: (context, url, error) => CachedNetworkImage(imageUrl: StringUtil.robohash(relay!.info!.name)),
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
          child: Container(
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
                              child: Text(addr),
                            ),
                            Row(
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(
                                      right: Base.BASE_PADDING),
                                  child: RelaysItemNumComponent(
                                    iconData: Icons.mail,
                                    num: relayStatus.noteReceived,
                                  ),
                                ),
                                relayStatus.error > 0 ?
                                RelaysItemNumComponent(
                                  iconColor: Colors.red,
                                  iconData: Icons.error_outline,
                                  num: relayStatus.error,
                                ): Container(),
                              ],
                            ),
                          ],
                        ))
                  ],
                )),
                GestureDetector(
                  onTap: () {
                    var text = NIP19Tlv.encodeNrelay(Nrelay(addr));
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
                  onTap: () {
                    removeRelay(addr);
                  },
                  child: Container(
                    padding: const EdgeInsets.only(
                      right: Base.BASE_PADDING,
                    ),
                    child: const Icon(
                      Icons.delete,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  void removeRelay(String addr) {
    relayProvider.removeRelay(addr);
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
