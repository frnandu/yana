import 'dart:convert';

import 'package:dart_ndk/nips/nip01/event.dart';
import 'package:dart_ndk/nips/nip01/filter.dart';
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
import '../../nostr/nip19/nip19.dart';
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
  List<Nip51ListElement> searchResults = [];
  bool disposed = false;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
    controller.addListener(() {
      onEditingComplete();
    });
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
        const PopupMenuItem(value: "public", child: Text("Add public")),
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
                                //add(controller.text, value == "private" ? true : false);
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
                                if (searchResults[index].tag == Nip51List.PUB_KEY) {
                                  Metadata? metadata = metadataProvider.getMetadata(searchResults[index].value);
                                  if (metadata != null) {
                                    return SearchMentionUserItemComponent(
                                      metadata: metadata,
                                      width: 400,
                                      onTap: (metadata) {
                                      },
                                      popupMenuButton:
                                        PopupMenuButton<String>(
                                            icon: const Icon(Icons.add),
                                            tooltip: "more",
                                            itemBuilder: popupItemBuilder,
                                            onSelected: (value) async {
                                              add(searchResults[index], value == "private" ? true : false);
                                            })
                                    );
                                  }
                                }
                                return Nip51ListElementSearchComponent(
                                  element: searchResults[index],
                                  width: 400,
                                  onTap: (element) {},
                                  popupMenuButton: PopupMenuButton<String>(
                                      icon: const Icon(Icons.add),
                                      tooltip: "more",
                                      itemBuilder: popupItemBuilder,
                                      onSelected: (value) async {
                                        add(searchResults[index], value == "private" ? true : false);
                                      }),
                                );
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
                    muteList = await relayManager.broadcastRemoveNip51ListElement(
                        muteList!.kind, element.tag, element.value, myOutboxRelaySet!.urls, loggedUserSigner!);
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
    searchResults = [];
    String search = controller.text.trim();
    if (search.isNotEmpty) {
      if (search.indexOf("npub") == 0) {
        try {
          var result = Nip19.decode(search);
          searchResults.add(Nip51ListElement(tag: Nip51List.PUB_KEY, value: result, private: true));
        } catch (e) {}
      } else if (search.startsWith("#")) {
        String hashtag = search.replaceAll("#", "").trim();
        if (hashtag.isNotEmpty) {
          searchResults.add(Nip51ListElement(tag: Nip51List.HASHTAG, value: hashtag, private: true));
        }
      } else {
        searchResults.add(Nip51ListElement(tag: Nip51List.WORD, value: search, private: true));
        Iterable<Metadata> searchMetadatas = cacheManager.searchMetadatas(search, 10);
        searchResults.addAll(searchMetadatas.map((metadata) => Nip51ListElement(tag: Nip51List.PUB_KEY, value: metadata.pubKey, private: true)));
        if (searchResults.length < 3) {
          Map<String, dynamic>? filterMap;
          filterMap = Filter(kinds: [Metadata.KIND], limit: 10).toMap();
          filterMap!["search"] = search;
          List<String> relaysWithNip50 = searchRelays.isNotEmpty ? searchRelays : ["wss://relay.nostr.band", "wss://relay.noshere.com"];
          relayManager.requestRelays(relaysWithNip50, Filter.fromMap(filterMap!), timeout: 10).then((request) {
            request.stream.listen((event) {
              onQueryEvent(search, event);
            });
          });
          // });
        }
      }
    }
    setState(() {});
  }

  void onQueryEvent(String searched, Nip01Event event) {
    if (event.kind == Metadata.KIND && controller.text.trim() == searched && !disposed && !contactListProvider.contacts().contains(event.pubKey)) {
      var jsonObj = jsonDecode(event.content);
      Metadata metadata = Metadata.fromJson(jsonObj);
      metadata.pubKey = event.pubKey;
      metadataProvider.getMetadata(event.pubKey);
      searchResults.add(Nip51ListElement(tag: Nip51List.PUB_KEY, value: event.pubKey, private: true));
      setState(() {

      });
    }
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

  Future<void> add(Nip51ListElement element, bool private) async {
    if (muteList!.elements!.any((e) => element.tag == e.tag && element.value == e.value,)) {
      EasyLoading.showError(
        "Position already on list",
        dismissOnTap: true,
        duration: const Duration(seconds: 5),
        maskType: EasyLoadingMaskType.black,
      );
      return;
    }
    bool? result = await ConfirmDialog.show(context, "Confirm add ${private ? "private" : "public"} ${element.tag} ${element.value} to list");
    if (result != null && result) {
      EasyLoading.show(status: 'Broadcasting mute list...', maskType: EasyLoadingMaskType.black, dismissOnTap: true);

      muteList = await relayManager.broadcastAddNip51ListElement(muteList!.kind, element.tag, element.value, myOutboxRelaySet!.urls, loggedUserSigner!, private: private);
      filterProvider.muteList = muteList;
      filterProvider.notifyListeners();
      EasyLoading.dismiss();
      setState(() {
        controller.text = "";
      });
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
          EasyLoading.showInfo(element.private ? "Private" : "Public", dismissOnTap: true, duration: const Duration(seconds: 3));
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
          top: Base.BASE_PADDING_HALF,
          bottom: Base.BASE_PADDING_HALF,
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
                    margin: const EdgeInsets.only(bottom: 2, left: 5),
                    child: element.tag == Nip51List.PUB_KEY
                        ? Selector<MetadataProvider, Metadata?>(
                            builder: (context, metadata, child) {
                              return SearchMentionUserItemComponent(
                                  metadata: metadata ?? Metadata(pubKey: element.value),
                                  onTap: (metadata) {
                                    RouterUtil.router(context, RouterPath.USER, element.value);
                                  },
                                  width: 400);
                            },
                            selector: (context, _provider) {
                              return _provider.getMetadata(element.value);
                            },
                          )
                        : Nip51ListElementSearchComponent(element: element, width: 400, onTap: (element) {},)
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

class Nip51ListElementSearchComponent extends StatelessWidget {
  static const double IMAGE_WIDTH = 50;

  final Nip51ListElement element;

  final double width;

  Function(Nip51ListElement) onTap;

  PopupMenuButton? popupMenuButton;

  Nip51ListElementSearchComponent({super.key, required this.element, required this.width, required this.onTap, this.popupMenuButton});

  @override
  Widget build(BuildContext context) {
    var themeData = Theme.of(context);
    var mainColor = themeData.primaryColor;
    var cardColor = themeData.cardColor;
    Color hintColor = themeData.hintColor;

    var main = Container(
      width: width,
      color: cardColor,
      padding: const EdgeInsets.all(Base.BASE_PADDING_HALF),
      child:  GestureDetector(
        onTap: () async {
          if (element.tag == Nip51List.HASHTAG) {
            var plainTag = element.value.replaceFirst("#", "");
            RouterUtil.router(context, RouterPath.TAG_DETAIL, plainTag);
          }
        },
        child: Row(
        children: [
          Icon(
            element.tag == Nip51List.HASHTAG?
            Icons.tag : Icons.format_color_text,
            color: themeData.appBarTheme.titleTextStyle!.color,
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.only(left: Base.BASE_PADDING_HALF),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                      padding: const EdgeInsets.all(Base.BASE_PADDING_HALF),
                      child: Text(
                        element.value,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      )),
                ],
              ),
            ),
          ),
          popupMenuButton!=null? popupMenuButton! : Container()
        ],
      )),
    );

    return GestureDetector(
      onTap: () {
        onTap(element);
        // RouterUtil.back(context, metadata.pubKey);
      },
      child: main,
    );
  }
}
