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
import '../../ui/confirm_dialog.dart';
import '../../utils/base.dart';
import '../../utils/hash_util.dart';
import '../../utils/store_util.dart';
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
          : StringUtil.robohash(HashUtil.md5(relay!.url));
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
              imageUrl: StringUtil.robohash(HashUtil.md5(relay!.url))),
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
                            child: Text(relay.url.replaceAll("wss://",""), style: themeData.textTheme.titleLarge,),
                          ),
                          Row(
                            children: [
                              Container(
                                margin: const EdgeInsets.only(
                                    right: Base.BASE_PADDING),
                                child: RelaysItemNumComponent(
                                    iconData: Icons.mail,
                                    textColor: themeData.disabledColor,
                                    iconColor: themeData.disabledColor,
                                    num: "${relay.stats.getTotalEventsRead()}"),
                              ),
                              Container(
                                  margin: const EdgeInsets.only(
                                      right: Base.BASE_PADDING),
                                  child: RelaysItemNumComponent(
                                    iconColor: Colors.lightGreen,
                                    textColor: Colors.lightGreen,
                                    iconData: Icons.lan_outlined,
                                    num: "${relay.stats.connections}",
                                  )),
                              Container(
                                  margin: const EdgeInsets.only(
                                      right: Base.BASE_PADDING),
                                  child: RelaysItemNumComponent(
                                    iconColor: relay.stats.connectionErrors >0 ? Colors.red : themeData.disabledColor,
                                    textColor: relay.stats.connectionErrors >0 ? Colors.red : themeData.disabledColor,
                                    iconData: Icons.error_outline,
                                    num: "${relay.stats.connectionErrors}",
                                  )),
                              Container(
                                  margin: const EdgeInsets.only(
                                      right: Base.BASE_PADDING),
                                  child: RelaysItemNumComponent(
                                    iconColor: themeData.disabledColor,
                                    textColor: themeData.disabledColor,
                                    iconData: Icons.network_check,
                                    num: StoreUtil.bytesToShowStr(
                                        relay.stats.getTotalBytesRead()),
                                  ))
                            ],
                          ),
                        ],
                      ))
                ],
              )),
              // GestureDetector(
              //   onTap: () {
              //     var text = NIP19Tlv.encodeNrelay(Nrelay(relay.url));
              //     Clipboard.setData(ClipboardData(text: text)).then((_) {
              //       BotToast.showText(text: I18n.of(context).Copy_success);
              //     });
              //   },
              //   child: Container(
              //     margin: const EdgeInsets.only(right: Base.BASE_PADDING),
              //     child: const Icon(
              //       Icons.copy,
              //     ),
              //   ),
              // ),
              GestureDetector(
                onTap: () async {
                  bool? result = await ConfirmDialog.show(
                      context, I18n.of(context).Confirm);

                  if (result!=null && result && loggedUserSigner!.canSign()) {
                    await removeRelay(relay.url);
                  }
                },
                child: loggedUserSigner!.canSign()
                    ? Container(
                        padding: const EdgeInsets.only(
                          right: Base.BASE_PADDING,
                        ),
                        child: const Icon(
                          Icons.delete,
                        ),
                      )
                    : Container(),
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
  Color? textColor;

  IconData iconData;

  String num;

  RelaysItemNumComponent({
    super.key,
    this.iconColor,
    this.textColor,
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
          num,
          style: TextStyle(fontSize: smallFontSize, color: textColor),
        ),
      ],
    );
  }
}
