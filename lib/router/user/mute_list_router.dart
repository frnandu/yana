import 'package:dart_ndk/nips/nip01/helpers.dart';
import 'package:dart_ndk/nips/nip01/metadata.dart';
import 'package:dart_ndk/nips/nip50/nip50.dart';
import 'package:dart_ndk/nips/nip51/nip51.dart';
import 'package:dart_ndk/relay.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';
import 'package:yana/main.dart';
import 'package:yana/provider/filter_provider.dart';
import 'package:yana/provider/relay_provider.dart';
import 'package:yana/router/user/search_relay_component.dart';
import 'package:yana/utils/router_path.dart';

import '../../i18n/i18n.dart';
import '../../nostr/relay_metadata.dart';
import '../../provider/metadata_provider.dart';
import '../../ui/confirm_dialog.dart';
import '../../ui/editor/search_mention_user_component.dart';
import '../../utils/base.dart';
import '../../utils/router_util.dart';

class MuteListRouter extends StatefulWidget {
  const MuteListRouter({super.key});

  @override
  State<StatefulWidget> createState() {
    return _MuteListRouter();
  }
}

class _MuteListRouter extends State<MuteListRouter> with SingleTickerProviderStateMixin {
  Nip51List? muteList;
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
    // relayManager.getNip51RelaySets(loggedUserSigner!).then((value) {
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
    var _filterProvider = Provider.of<FilterProvider>(context);


    var s = I18n.of(context);
    if (muteList == null) {
      var arg = RouterUtil.routerArgs(context);
      if (arg != null && arg is Nip51List) {
        muteList = arg;
      }
    }
    popupItemBuilder(context) {
      List<PopupMenuEntry<String>> list = [
        const PopupMenuItem(value: "public",child: Text("Add public")),
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
            //       relaySet = relayManager.getCachedNip51RelaySet(value!, loggedUserSigner!);
            //       selectedList = value!;
            //     });
            //   },
            // )

            Text("${muteList!.displayTitle} (${muteList!.elements!.length})"),
      ),
      body: Container(
        margin: const EdgeInsets.only(
          top: Base.BASE_PADDING,
        ),
        child: RefreshIndicator(
          onRefresh: () async {
            Nip51List? refreshedList = await relayManager.getSingleNip51List(muteList!.kind, loggedUserSigner!, forceRefresh: true);
            refreshedList ??= Nip51List(pubKey: muteList!.pubKey, kind: muteList!.kind, elements: [], createdAt: Helpers.now);
            filterProvider.muteList = refreshedList;
            filterProvider.notifyListeners();
            setState(() {
              muteList = refreshedList;
            });
          },
          child: ListView.builder(
            itemBuilder: (context, index) {
              int total = muteList != null ? muteList!.elements!.length : 0;
              if (index == total && loggedUserSigner!.canSign()) {
                return Column(children: [
                  TextField(
                    controller: controller,
                    onEditingComplete: onEditingComplete,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.lan),
                      hintText: "profile name, pubkey, hashtag or word",
                      suffixIcon: Relay.clean(controller.text) != null
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
              return MuteListElementComponent(
                element: muteList!.elements![index],
                removable: loggedUserSigner!.canSign(),
                onRemove: (element) async {
                  bool? result = await ConfirmDialog.show(context, "Confirm remove ${element.value} from list");
                  if (result != null && result) {
                    EasyLoading.show(status: 'Removing from list and broadcasting...', maskType: EasyLoadingMaskType.black, dismissOnTap: true);
                    muteList = await relayManager.broadcastRemoveNip51ListElement(muteList!.kind, element.tag, element.value, myOutboxRelaySet!.urls, loggedUserSigner!);
                    filterProvider.muteList = muteList;
                    filterProvider.notifyListeners();
                    EasyLoading.dismiss();
                    setState(() {});
                  }
                },
              );
            },
            itemCount: (muteList != null ? muteList!.elements!.length : 0) + (loggedUserSigner!.canSign() ? 1 : 0),
          ),
        ),
      ),
    );
  }

  void onEditingComplete() async {
    List<String> result = await relayProvider.findRelays(controller.text, nip: muteList!.kind == Nip51List.SEARCH_RELAYS ? Nip50.NIP : null);
    result.forEach((url) {
      if (relayManager.getRelay(url) == null || relayManager.getRelay(url)!.info == null) {
        relayManager.relays[url] = Relay(url);
        relayManager.getRelayInfo(url).then((value) {
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

  Future<void> add(String url, bool private) async {
    String? cleanUrl = Relay.clean(url);
    if (cleanUrl == null) {
      EasyLoading.showError(
        "Invalid address wss://<host>:<port> or ws://<host>:<port>",
        dismissOnTap: true,
        duration: const Duration(seconds: 5),
        maskType: EasyLoadingMaskType.black,
      );
      return;
    }
    if (muteList!.privateRelays!.contains(cleanUrl) || muteList!.publicRelays!.contains(cleanUrl)) {
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
      /// TODO
      // muteList = await relayManager.broadcastAddNip51ListElement(muteList!.kind, "Tag", "Value", myOutboxRelaySet!.urls, loggedUserSigner!, private: private);
      // filterProvider.muteList = muteList;
      // filterProvider.notifyListeners();
      // EasyLoading.dismiss();
      // setState(() {
      //   controller.text = "";
      // });
    }
  }
}

class MuteListElementComponent extends StatelessWidget {
  Nip51ListElement element;
  Function(Nip51ListElement)? onRemove;

  bool removable;

  MuteListElementComponent({super.key, required this.element, this.removable = true, this.onRemove});

  @override
  Widget build(BuildContext context) {
    var s = I18n.of(context);
    var themeData = Theme.of(context);
    var cardColor = themeData.cardColor;
    var bodySmallFontSize = themeData.textTheme.labelSmall!.fontSize;

    Widget leftBtn = GestureDetector(
        onTap: () async {
          // EasyLoading.showInfo(private ? "Private" : "Public", dismissOnTap: true, duration: const Duration(seconds: 3));
        },
        child: Icon(
          element.private ? Icons.perm_identity_sharp : Icons.public,
          color: themeData.disabledColor,
        ));

    Widget rightBtn = Container();
    if (removable && onRemove != null) {
      rightBtn = GestureDetector(
        onTap: () async {
          onRemove!(element);
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
                  // if (relayManager.getRelay(element) == null || relayManager.getRelay(element)!.info == null) {
                  //   relayManager.relays[element] = Relay(element);
                  //   EasyLoading.show(status: "Loading relay info...");
                  //   relayManager.getRelayInfo(element).then((info) {
                  //     EasyLoading.dismiss();
                  //     if (info != null) {
                  //       RouterUtil.router(context, RouterPath.RELAY_INFO, relayManager.relays[element]);
                  //     }
                  //   });
                  // } else {
                  //   RouterUtil.router(context, RouterPath.RELAY_INFO, relayManager.relays[element]);
                  // }
                },
                child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: 2, left: 5),
                    child: element.tag == Nip51List.PUB_KEY ?  Selector<MetadataProvider, Metadata?>(
                      builder: (context, metadata, child) {
                        return
                            SearchMentionUserItemComponent(
                            metadata: metadata??Metadata(pubKey: element.value),
                            onTap: (metadata) {
                              RouterUtil.router(context, RouterPath.USER, element.value);
                            },
                            width: 400)
                            ;
                        // MetadataComponent(
                        //   pubKey: pubkey,
                        //   metadata: metadata,
                        //   jumpable: true,
                        // ),
                      },
                      selector: (context, _provider) {
                        return _provider.getMetadata(element.value);
                      },
                    ) : Text(element.value),
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
