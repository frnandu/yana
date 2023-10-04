import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yana/main.dart';
import 'package:yana/models/relay_status.dart';
import 'package:yana/provider/relay_provider.dart';

import '../../i18n/i18n.dart';
import '../../nostr/relay_metadata.dart';
import '../../utils/base.dart';
import '../../utils/router_util.dart';

class UserRelayRouter extends StatefulWidget {
  const UserRelayRouter({super.key});

  @override
  State<StatefulWidget> createState() {
    return _UserRelayRouter();
  }
}

class _UserRelayRouter extends State<UserRelayRouter> {
  List<RelayMetadata>? relays;

  @override
  Widget build(BuildContext context) {
    var themeData = Theme.of(context);

    var s = I18n.of(context);
    if (relays == null) {
      relays = [];
      var arg = RouterUtil.routerArgs(context);
      if (arg != null && arg is List<RelayMetadata>) {
        relays = arg;
      }
    }

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
        title: Text(s.Relays),
      ),
      body: Container(
        margin: const EdgeInsets.only(
          top: Base.BASE_PADDING,
        ),
        child: ListView.builder(
          itemBuilder: (context, index) {
            var relayMetadata = relays![index];
            return Selector<RelayProvider, RelayStatus?>(
                builder: (context, relayStatus, child) {
              return RelayMetadataComponent(
                relayMetadata: relayMetadata,
                addAble: relayMetadata.count == null && relayStatus == null,
              );
            }, selector: (context, provider) {
              return provider.getRelayStatus(relayMetadata.addr);
            });
          },
          itemCount: relays!.length,
        ),
      ),
    );
  }
}

class RelayMetadataComponent extends StatelessWidget {
  RelayMetadata relayMetadata;

  bool addAble;

  RelayMetadataComponent(
      {super.key, required this.relayMetadata, this.addAble = true});

  @override
  Widget build(BuildContext context) {
    var s = I18n.of(context);
    var themeData = Theme.of(context);
    var cardColor = themeData.cardColor;
    var bodySmallFontSize = themeData.textTheme.bodySmall!.fontSize;

    Widget rightBtn = Container();
    if (addAble) {
      rightBtn = GestureDetector(
        onTap: () {
          relayProvider.addRelay(relayMetadata.addr);
        },
        child: const Icon(
          Icons.add,
        ),
      );
    } else {
      if (relayMetadata.count != null) {
        rightBtn = Row(children: [
          Text("${relayMetadata.count} ",
              style: TextStyle(
                  color: themeData.dividerColor,
                  fontSize: themeData.textTheme.labelLarge!.fontSize)),
          Text(
            "follows",
            style: TextStyle(
                color: themeData.disabledColor,
                fontSize: themeData.textTheme.labelSmall!.fontSize),
          )
        ]);
      }
    }

    return Container(
      margin: const EdgeInsets.only(
        bottom: Base.BASE_PADDING_HALF,
        left: Base.BASE_PADDING_HALF,
        right: Base.BASE_PADDING_HALF,
      ),
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Container(
        padding: const EdgeInsets.only(
          top: Base.BASE_PADDING,
          bottom: Base.BASE_PADDING,
          left: Base.BASE_PADDING,
          right: Base.BASE_PADDING,
        ),
        decoration: BoxDecoration(
          color: cardColor,
          // border: Border(
          //   left: BorderSide(
          //     width: 6,
          //     color: hintColor,
          //   ),
          // ),
          // borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: 2),
                    child: Text(relayMetadata.addr),
                  ),
                  Row(
                    children: [
                      relayMetadata.read != null && relayMetadata.read!
                          ? Container(
                              margin: const EdgeInsets.only(
                                  right: Base.BASE_PADDING),
                              child: Text(
                                s.Read,
                                style: TextStyle(
                                  fontSize: bodySmallFontSize,
                                  color: Colors.green,
                                ),
                              ),
                            )
                          : Container(),
                      relayMetadata.write != null && relayMetadata.write!
                          ? Container(
                              margin: const EdgeInsets.only(
                                  right: Base.BASE_PADDING),
                              child: Text(
                                s.Write,
                                style: TextStyle(
                                  fontSize: bodySmallFontSize,
                                  color: Colors.red,
                                ),
                              ),
                            )
                          : Container(),
                    ],
                  ),
                ],
              ),
            ),
            rightBtn,
          ],
        ),
      ),
    );
  }
}
