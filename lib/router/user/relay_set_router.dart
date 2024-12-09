import 'package:ndk/domain_layer/entities/nip_51_list.dart';
import 'package:ndk/domain_layer/entities/relay.dart';
import 'package:ndk/shared/helpers/relay_helper.dart';
import 'package:ndk/shared/nips/nip01/helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';
import 'package:yana/main.dart';
import 'package:yana/provider/relay_provider.dart';
import 'package:yana/router/user/search_relay_component.dart';

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
  Nip51Set? relaySet;
  late TabController tabController;
  TextEditingController controller = TextEditingController();
  List<String> searchResults = [];
  bool disposed = false;
  late String selectedList;
  List<Nip51Set>? list;

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

    // if (list==null) {
    //   return Container();
    // }

    var s = I18n.of(context);
    if (relaySet == null) {
      var arg = RouterUtil.routerArgs(context);
      if (arg != null && arg is Nip51Set) {
        relaySet = arg;
        selectedList = relaySet!.name;
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
          Text("${relaySet!.title} (${relaySet!.allRelays!.length})"),
      ),
      body: Container(
        margin: const EdgeInsets.only(
          top: Base.BASE_PADDING,
        ),
        child: RefreshIndicator(
          onRefresh: () async {
            Nip51Set? refreshedRelaySet = await ndk.lists.getSingleNip51RelaySet(relaySet!.name, loggedUserSigner!, forceRefresh: true);
            refreshedRelaySet ??= Nip51Set(kind: Nip51List.RELAY_SET, pubKey: relaySet!.pubKey, name: relaySet!.name, createdAt: Helpers.now, elements: []);
            setState(() {
              relaySet = refreshedRelaySet;
            });
          },
          child: ListView.builder(
            itemBuilder: (context, index) {
              int total = relaySet != null ? relaySet!.allRelays!.length : 0;
              if (index == total && loggedUserSigner!.canSign()) {
                return Column(children: [
                  TextField(
                    controller: controller,
                    onEditingComplete: onEditingComplete,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.lan),
                      hintText: "start typing relay name or URL",
                      suffixIcon: cleanRelayUrl(controller.text) != null
                          ? IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () async {
                                add(controller.text);
                              },
                            )
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
                                  onTap: (url) {
                                    add(url);
                                    //replaceMentionUser(metadata.pubKey);
                                  },
                                );
                              },
                              itemCount: searchResults.length))
                      : Container()
                ]);
              }
              return RelaySetItemComponent(
                url: relaySet!.allRelays![index],
                removable: loggedUserSigner!.canSign(),
                onRemove: (url) async {
                  bool? result = await ConfirmDialog.show(context, "Confirm add ${url} to list");
                  if (result != null && result) {
                    EasyLoading.show(status: 'Removing from list and broadcasting...', maskType: EasyLoadingMaskType.black, dismissOnTap: true);
                    relaySet = await ndk.lists.broadcastRemoveNip51SetRelay(url, relaySet!.name, myOutboxRelaySet!.urls,
                        defaultRelaysIfEmpty: relaySet!.allRelays);
                    relayProvider.notifyListeners();
                    EasyLoading.dismiss();
                    setState(() {});
                  }
                },
              );
            },
            itemCount: (relaySet != null ? relaySet!.allRelays!.length : 0) + (loggedUserSigner!.canSign() ? 1 : 0),
          ),
        ),
      ),
    );
  }

  void onEditingComplete() async {
    List<String> result = await relayProvider.findRelays(controller.text);
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

  Future<void> add(String url) async {
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
    if (relaySet!.allRelays!.contains(cleanUrl)) {
      EasyLoading.showError(
        "Relay already on list",
        dismissOnTap: true,
        duration: const Duration(seconds: 5),
        maskType: EasyLoadingMaskType.black,
      );
      return;
    }
    bool? result = await ConfirmDialog.show(context, "Confirm add ${url} to list");
    if (result != null && result) {
      EasyLoading.show(status: 'Broadcasting relay list...', maskType: EasyLoadingMaskType.black, dismissOnTap: true);
      relaySet = await ndk.lists.broadcastAddNip51SetRelay(url, relaySet!.name, myOutboxRelaySet!.urls, private: false);
      relayProvider.notifyListeners();
      EasyLoading.dismiss();
      setState(() {
        controller.text = "";
      });
    }
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
