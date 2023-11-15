import 'package:dart_ndk/nips/nip01/helpers.dart';
import 'package:dart_ndk/nips/nip51/nip51.dart';
import 'package:dart_ndk/relay.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';
import 'package:yana/main.dart';
import 'package:yana/provider/relay_provider.dart';

import '../../i18n/i18n.dart';
import '../../nostr/relay_metadata.dart';
import '../../ui/confirm_dialog.dart';
import '../../utils/base.dart';
import '../../utils/router_util.dart';

class RelaySetRouter extends StatefulWidget {
  const RelaySetRouter({super.key});

  @override
  State<StatefulWidget> createState() {
    return _RelaySetRouter();
  }
}

class _RelaySetRouter extends State<RelaySetRouter> with SingleTickerProviderStateMixin {
  Nip51RelaySet? relaySet;
  late TabController tabController;
  TextEditingController controller = TextEditingController();

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
    if (relaySet == null) {
      var arg = RouterUtil.routerArgs(context);
      if (arg != null && arg is Nip51RelaySet) {
        relaySet = arg;
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
        title: Text("${relaySet!.name} (${relaySet!.relays.length})"),
      ),
      body: Container(
        margin: const EdgeInsets.only(
          top: Base.BASE_PADDING,
        ),
        child: RefreshIndicator(
          onRefresh: () async {
            Nip51RelaySet? refreshedRelaySet = await relayManager.getSingleNip51RelaySet(relaySet!.pubKey, relaySet!.name, forceRefresh: true);
            if (refreshedRelaySet == null) {
              refreshedRelaySet = Nip51RelaySet(pubKey: relaySet!.pubKey, name: relaySet!.name, relays: [], createdAt: Helpers.now);
              setState(() {
                relaySet = refreshedRelaySet;
              });
            }
          },
          child: ListView.builder(
            itemBuilder: (context, index) {
              int total = relaySet != null ? relaySet!.relays.length : 0;
              if (index == total && loggedUserSigner!.canSign()) {
                return TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.lan),
                    hintText: "start typing relay name or URL",
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () async {
                        String url = controller.text;
                        bool? result = await ConfirmDialog.show(context, "Confirm add ${url} to list");
                        if (result != null && result) {
                          EasyLoading.show(status: 'Broadcasting relay list...', maskType: EasyLoadingMaskType.black, dismissOnTap: true);
                          relaySet = await relayManager.broadcastAddNip51Relay(url, relaySet!.name, myOutboxRelaySet!.urls, loggedUserSigner!);
                          if (relaySet!.name == "search") {
                            searchRelays = relaySet!.relays;
                          } else if (relaySet!.name == "blocked") {
                            relayManager.blockedRelays = relaySet!.relays;
                          }
                          relayProvider.notifyListeners();
                          EasyLoading.dismiss();
                          setState(() {

                          });
                        }
                      },
                    ),
                  ),
                );
              }
              return RelaySetItemComponent(
                url: relaySet!.relays[index],
                removable: loggedUserSigner!.canSign(),
                onRemove: (url) async {
                  bool? result = await ConfirmDialog.show(context, "Confirm add ${url} to list");
                  if (result != null && result) {
                    EasyLoading.show(status: 'Removing from list and broadcasting...', maskType: EasyLoadingMaskType.black, dismissOnTap: true);
                    relaySet = await relayManager.broadcastRemoveNip51Relay(url, relaySet!.name, myOutboxRelaySet!.urls, loggedUserSigner!,
                        defaultRelaysIfEmpty: relaySet!.relays);
                    if (relaySet!.name == "search") {
                      searchRelays = relaySet!.relays;
                    } else if (relaySet!.name == "blocked") {
                      relayManager.blockedRelays = relaySet!.relays;
                    }
                    relayProvider.notifyListeners();
                    EasyLoading.dismiss();
                    setState(() {});
                  }
                },
              );
            },
            itemCount: (relaySet != null ? relaySet!.relays!.length : 0) + (loggedUserSigner!.canSign() ? 1 : 0),
          ),
        ),
      ),
    );
  }

  int compareRelays(RelayMetadata r1, RelayMetadata r2) {
    Relay? relay1 = relayManager.getRelay(r1.url!);
    Relay? relay2 = relayManager!.getRelay(r2.url!);
    if (relay1 == null) {
      return 1;
    }
    if (relay2 == null) {
      return -1;
    }
    bool a1 = relayManager.isRelayConnected(r1.url!);
    bool a2 = relayManager.isRelayConnected(r2.url!);
    if (a1) {
      return a2 ? (r2.count != null ? r2.count!.compareTo(r1.count!) : 0) : -1;
    }
    return a2 ? 1 : (r2.count != null ? r2.count!.compareTo(r1.count!) : 0);
  }
}

class RelaySetItemComponent extends StatelessWidget {
  String url;
  Function(String)? onRemove;

  bool removable;

  RelaySetItemComponent({super.key, required this.url, this.removable = true, this.onRemove});

  @override
  Widget build(BuildContext context) {
    var s = I18n.of(context);
    var themeData = Theme.of(context);
    var cardColor = themeData.cardColor;
    var bodySmallFontSize = themeData.textTheme.labelSmall!.fontSize;

    Widget leftBtn = Container();

    Widget rightBtn = Container();
    if (removable && onRemove != null) {
      rightBtn = GestureDetector(
        onTap: () async {
          onRemove!(url);
        },
        child: Icon(
          Icons.close,
          color: themeData.disabledColor,
        ),
      );
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
                    child: Text(url),
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
