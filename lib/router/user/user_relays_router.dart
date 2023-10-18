import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yana/main.dart';
import 'package:yana/models/relay_status.dart';
import 'package:yana/provider/relay_provider.dart';

import '../../i18n/i18n.dart';
import '../../nostr/relay.dart';
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

class _UserRelayRouter extends State<UserRelayRouter>
    with SingleTickerProviderStateMixin {
  List<RelayMetadata>? relays;
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    var themeData = Theme.of(context);
    var _relayProvider = Provider.of<RelayProvider>(context);

    var s = I18n.of(context);
    if (relays == null) {
      relays = [];
      var arg = RouterUtil.routerArgs(context);
      if (arg != null && arg is List<RelayMetadata>) {
        relays = arg;
      }
    }
    if (followsNostr!=null && relays!.any((element) => element.count!=null)) {
      relays!.sort(
              (r1, r2) => compareRelays(r1, r2));
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
        child: RefreshIndicator(
            onRefresh: () async {
              if (relays != null &&
                  relays!.isNotEmpty &&
                  relays![0].count != null &&
                  followsNostr != null) {
                await followsNostr!.checkAndReconnectRelays();
                relayProvider.notifyListeners();
                setState(() {
                  if (kDebugMode) {
                    print("refreshed");
                  }
                });
              }
            },
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
                  return provider.getRelayStatus(relayMetadata.url!);
                });
              },
              itemCount: relays!.length,
            )),
      ),
    );
  }

  int compareRelays(RelayMetadata r1, RelayMetadata r2) {
    Relay? relay1 = followsNostr!.getRelay(r1.url!);
    Relay? relay2 = followsNostr!.getRelay(r2.url!);
    if (relay1 == null) {
      return 1;
    }
    if (relay2 == null) {
      return -1;
    }
    bool a1 = relay1!.isActive();
    bool a2 = relay2!.isActive();
    if (a1) {
      return a2 ? (r2.count!=null?r2.count!.compareTo(r1.count!):0) : -1;
    }
    return a2 ? 1 : (r2.count!=null?r2.count!.compareTo(r1.count!):0);
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
    var bodySmallFontSize = themeData.textTheme.labelSmall!.fontSize;

    Widget leftBtn = Container();

    Widget rightBtn = Container();
    if (addAble) {
      rightBtn = GestureDetector(
        onTap: () async {
          await relayProvider.addRelay(relayMetadata.url!);
        },
        child: const Icon(
          Icons.add,
        ),
      );
    } else {
      if (relayMetadata.count != null) {
        leftBtn = Selector<RelayProvider, int?>(builder: (context, state, client) {
          Color borderLeftColor = Colors.red;
          if (state != null && state == WebSocket.open) {
            borderLeftColor = Colors.green;
          } else if (state != null && state == WebSocket.connecting) {
            borderLeftColor = Colors.yellow;
          }
          return Container(
            padding: const EdgeInsets.only(
              left: Base.BASE_PADDING_HALF / 2,
              right: Base.BASE_PADDING_HALF,
            ),
            height: 30,
            child: Icon(
              Icons.lan,
              color: borderLeftColor,
            ),
          );
          main;
        }, selector: (context, _provider) {
          return _provider.getFeedRelayState(relayMetadata.url!);
        });
        rightBtn = Row(children: [
          Text("${relayMetadata.count} ",
              style: TextStyle(
                  color: themeData.dividerColor,
                  fontSize: themeData.textTheme.labelLarge!.fontSize)),
          Text(
            "contact"+((relayMetadata.count!>1)?"s":""),
            style: TextStyle(
                color: themeData.disabledColor,
                fontSize: themeData.textTheme.labelSmall!.fontSize),
          )
        ]);
      }
    }

    // body: TabBarView(
    //   controller: tabController,
    //   children: [
    //     BlockedWordsComponent(),
    //     BlockedProfilesComponent(),
    //   ],
    // ),
    //

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
            leftBtn,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: 2),
                    child: Text(relayMetadata.url!),
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
                                  color: themeData.disabledColor,
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
                                  color: themeData.disabledColor,
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
