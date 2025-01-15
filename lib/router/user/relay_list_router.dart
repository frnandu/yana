import 'package:ndk/domain_layer/entities/nip_51_list.dart';
import 'package:ndk/domain_layer/entities/relay.dart';
import 'package:ndk/shared/helpers/relay_helper.dart';
import 'package:ndk/shared/nips/nip01/helpers.dart';
import 'package:ndk/shared/nips/nip50/nip50.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';
import 'package:yana/main.dart';
import 'package:yana/provider/relay_provider.dart';
import 'package:yana/router/user/search_relay_component.dart';
import 'package:yana/utils/router_path.dart';

import '../../i18n/i18n.dart';
import '../../nostr/relay_metadata.dart';
import '../../ui/confirm_dialog.dart';
import '../../utils/base.dart';
import '../../utils/router_util.dart';

class RelayListRouter extends StatefulWidget {
  const RelayListRouter({super.key});

  @override
  State<StatefulWidget> createState() {
    return _RelayListRouter();
  }
}

class _RelayListRouter extends State<RelayListRouter> with SingleTickerProviderStateMixin {
  Nip51List? relayList;
  late TabController tabController;
  TextEditingController controller = TextEditingController();
  List<String> searchResults = [];
  bool disposed = false;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
    controller.addListener(() {
      onEditingComplete();
    });
    //ndk.relays.getNip51RelaySets(loggedUserSigner!).then((value) {
    //   setState(() {
    //     list = value;
    //   });
    // });
  }

  @override
  void dispose() {
    super.dispose();
    disposed = true;
  }

  @override
  Widget build(BuildContext context) {
    var themeData = Theme.of(context);
    var _relayProvider = Provider.of<RelayProvider>(context);

    var s = I18n.of(context);
    if (relayList == null) {
      var arg = RouterUtil.routerArgs(context);
      if (arg != null && arg is Nip51List) {
        relayList = arg;
      }
    }
    popupItemBuilder(context) {
      List<PopupMenuEntry<String>> list = [
        const PopupMenuItem(
          value: "public",
          child: Text("Add public"),
        ),
        const PopupMenuItem(value: "private", child: Text("Add private"))
      ];
      return list;
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
        title:
            // DropdownButton<String>(
            //   value: selectedList,
            //   items: list!.map((relaySet) =>DropdownMenuItem(child: Text("${relaySet.title??relaySet.name}" ),value: relaySet.name)).toList(),
            //   onChanged: (value) {
            //     print("!!!!!!!!!!!!!! $value");
            //     setState(() {
            //       relaySet =ndk.relays.getCachedNip51RelaySet(value!, loggedUserSigner!);
            //       selectedList = value!;
            //     });
            //   },
            // )

            Text("${relayList!.displayTitle} (${relayList!.allRelays!.length})"),
      ),
      body: Container(
        margin: const EdgeInsets.only(
          top: Base.BASE_PADDING,
        ),
        child: RefreshIndicator(
          onRefresh: () async {
            Nip51List? refreshedList = await ndk.lists.getSingleNip51List(relayList!.kind, loggedUserSigner!, forceRefresh: true);
            refreshedList ??= Nip51List(pubKey: relayList!.pubKey, kind: relayList!.kind, elements: [], createdAt: Helpers.now);
            setState(() {
              relayList = refreshedList;
            });
          },
          child: ListView.builder(
            itemBuilder: (context, index) {
              int total = relayList != null ? relayList!.allRelays!.length : 0;
              if (index == total && loggedUserSigner!.canSign()) {
                return Column(children: [
                  TextField(
                    controller: controller,
                    onEditingComplete: onEditingComplete,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.lan),
                      hintText: "start typing relay name or URL",
                      suffixIcon: cleanRelayUrl(controller.text) != null
                          ? PopupMenuButton<String>(
                              icon: const Icon(Icons.add),
                              tooltip: "more",
                              itemBuilder: popupItemBuilder,
                              onSelected: (value) async {
                                add(controller.text, value == "private" ? true : false);
                              })
                          : null,
                    ),
                  ),
                  searchResults.isNotEmpty
                      ? SizedBox(
                          height: 300,
                          child: ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                return SearchRelayItemComponent(
                                    url: searchResults[index],
                                    width: 400,
                                    popupMenuButton: PopupMenuButton<String>(
                                        icon: const Icon(Icons.add),
                                        tooltip: "more",
                                        itemBuilder: popupItemBuilder,
                                        onSelected: (value) async {
                                          add(searchResults[index], value == "private" ? true : false);
                                        }));
                              },
                              itemCount: searchResults.length))
                      : Container()
                ]);
              }
              return RelayListElementComponent(
                private: relayList!.elements[index]!.private,
                url: relayList!.elements[index]!.value,
                removable: loggedUserSigner!.canSign(),
                onRemove: (url) async {
                  bool? result = await ConfirmDialog.show(context, "Confirm remove ${url} from list");
                  if (result != null && result) {
                    EasyLoading.show(status: 'Removing from list and broadcasting...', maskType: EasyLoadingMaskType.black, dismissOnTap: true);
                    relayList = await ndk.lists.broadcastRemoveNip51Relay(relayList!.kind, url, myOutboxRelaySet!.urls, defaultRelaysIfEmpty: relayList!.allRelays);
                    if (relayList!.kind == Nip51List.kSearchRelays) {
                      searchRelays = relayList!.allRelays;
                    } else if (relayList!.kind == Nip51List.kBlockedRelays) {
                     ndk.relays.globalState.blockedRelays = relayList!.allRelays.toSet();
                    }
                    relayProvider.notifyListeners();
                    EasyLoading.dismiss();
                    setState(() {});
                  }
                },
              );
            },
            itemCount: (relayList != null ? relayList!.allRelays!.length : 0) + (loggedUserSigner!.canSign() ? 1 : 0),
          ),
        ),
      ),
    );
  }

  void onEditingComplete() async {
    List<String> result = await relayProvider.findRelays(controller.text, nip: relayList!.kind == Nip51List.kSearchRelays ? Nip50.kNip : null);
    result.forEach((url) {
      if (ndk.relays.getRelayConnectivity(url) == null ||ndk.relays.getRelayConnectivity(url)!.relayInfo == null) {
       ndk.relays.getRelayInfo(url).then((value) {
          if (!disposed) {
            setState(() {});
          }
        });
      }
    });

    setState(() {
      searchResults = result;
    });
  }

  int compareRelays(RelayMetadata r1, RelayMetadata r2) {
    Relay? relay1 =ndk.relays.getRelayConnectivity(r1.url!)!.relay;
    Relay? relay2 = ndk.relays.getRelayConnectivity(r2.url!)!.relay;
    if (relay1 == null) {
      return 1;
    }
    if (relay2 == null) {
      return -1;
    }
    bool a1 =ndk.relays.isRelayConnected(r1.url!);
    bool a2 =ndk.relays.isRelayConnected(r2.url!);
    if (a1) {
      return a2 ? (r2.count != null ? r2.count!.compareTo(r1.count!) : 0) : -1;
    }
    return a2 ? 1 : (r2.count != null ? r2.count!.compareTo(r1.count!) : 0);
  }

  Future<void> add(String url, bool private) async {
    String? cleanUrl = cleanRelayUrl(url);
    if (cleanUrl == null) {
      EasyLoading.showError(
        "Invalid address wss://<host>:<port> or ws://<host>:<port>",
        dismissOnTap: true,
        duration: const Duration(seconds: 5),
        maskType: EasyLoadingMaskType.black,
      );
      return;
    }
    if (relayList!.allRelays!.contains(cleanUrl)) {
      EasyLoading.showError(
        "Relay already on list",
        dismissOnTap: true,
        duration: const Duration(seconds: 5),
        maskType: EasyLoadingMaskType.black,
      );
      return;
    }
    bool? result = await ConfirmDialog.show(context, "Confirm add ${private ? "private" : "public"} ${url} to list");
    if (result != null && result) {
      EasyLoading.show(status: 'Broadcasting relay list...', maskType: EasyLoadingMaskType.black, dismissOnTap: true);
      relayList = await ndk.lists.broadcastAddNip51ListRelay(relayList!.kind, url, myOutboxRelaySet!.urls, private: private);
      if (relayList!.kind == Nip51List.kSearchRelays) {
        searchRelays = relayList!.allRelays!;
        await ndk.relays.reconnectRelays(searchRelays);
      } else if (relayList!.kind == Nip51List.kBlockedRelays) {
       ndk.relays.globalState.blockedRelays = relayList!.allRelays.toSet();
      }
      relayProvider.notifyListeners();
      EasyLoading.dismiss();
      setState(() {
        controller.text = "";
      });
    }
  }
}

class RelayListElementComponent extends StatelessWidget {
  String url;
  Function(String)? onRemove;
  bool private;

  bool removable;

  RelayListElementComponent({super.key, required this.url, required this.private, this.removable = true, this.onRemove});

  @override
  Widget build(BuildContext context) {
    var s = I18n.of(context);
    var themeData = Theme.of(context);
    var cardColor = themeData.cardColor;
    var bodySmallFontSize = themeData.textTheme.labelSmall!.fontSize;

    Widget leftBtn = GestureDetector(
        onTap: () async {
          EasyLoading.showInfo(private ? "Private" : "Public", dismissOnTap: true, duration: const Duration(seconds: 3));
        },
        child: Icon(
          private ? Icons.perm_identity_sharp : Icons.public,
          color: themeData.disabledColor,
        ));

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
              child: GestureDetector(
                onTap: () async {
                  if (ndk.relays.getRelayConnectivity(url) == null ||ndk.relays.getRelayConnectivity(url)!.relayInfo == null) {
                    EasyLoading.show(status: "Loading relay info...");
                   ndk.relays.getRelayInfo(url).then((info) {
                      EasyLoading.dismiss();
                      if (info != null) {
                        RouterUtil.router(context, RouterPath.RELAY_INFO,ndk.relays.getRelayConnectivity(url));
                      }
                    });
                  } else {
                    RouterUtil.router(context, RouterPath.RELAY_INFO,ndk.relays.getRelayConnectivity(url));
                  }
                },
                child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: 2, left: 5),
                    child: Text(url.replaceAll("wss://", "").replaceAll("ws://", ""))
                  ),
                ],
              ),
            )),
            rightBtn,
          ],
        ),
      ),
    );
  }
}
