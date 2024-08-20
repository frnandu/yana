import 'package:ndk/domain_layer/entities/read_write_marker.dart';
import 'package:ndk/domain_layer/entities/relay.dart';
import 'package:ndk/domain_layer/entities/user_relay_list.dart';
import 'package:ndk/shared/helpers/relay_helper.dart';
import 'package:ndk/shared/nips/nip01/helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:yana/utils/when_stop_function.dart';

import '../../i18n/i18n.dart';
import '../../main.dart';
import '../../provider/relay_provider.dart';
import '../../ui/confirm_dialog.dart';
import '../../ui/cust_state.dart';
import '../../utils/base.dart';
import '../../utils/router_util.dart';
import '../user/search_relay_component.dart';
import 'relays_item_component.dart';

class RelaysRouter extends StatefulWidget {
  const RelaysRouter({super.key});

  @override
  State<StatefulWidget> createState() {
    return _RelaysRouter();
  }
}

class _RelaysRouter extends CustState<RelaysRouter> with WhenStopFunction {
  TextEditingController controller = TextEditingController();
  UserRelayList? userRelayList;
  List<String> searchResults = [];
  ItemScrollController itemScrollController = ItemScrollController();
  bool disposed=false;

  @override
  void initState() {
    controller.addListener(() {
      onEditingComplete();
    });
    loadRelayInfos();
  }

  loadRelayInfos() async {
    // Set<String> set = {};
    // set.addAll(myInboxRelaySet!.urls);
    // set.addAll(myOutboxRelaySet!.urls);

    userRelayList = cacheManager.loadUserRelayList(loggedUserSigner!.getPublicKey());
    userRelayList ??= await ndk.getSingleUserRelayList(loggedUserSigner!.getPublicKey(), forceRefresh: true);
    userRelayList ??= UserRelayList(
        pubKey: loggedUserSigner!.getPublicKey(),
        relays: {for (String url in relayManager.bootstrapRelays) url: ReadWriteMarker.readWrite},
        createdAt: Helpers.now,
        refreshedTimestamp: Helpers.now);
    await Future.wait(userRelayList!.urls.map((url) => relayManager.getRelayInfo(cleanRelayUrl(url)!)));

    /// TODO check if widget is not disposed already...

    if (!disposed) {
      setState(() {
        print("loaded relay infos");
      });
    }
  }

  @override
  Widget doBuild(BuildContext context) {
    var s = I18n.of(context);
    var _relayProvider = Provider.of<RelayProvider>(context);
    var themeData = Theme.of(context);
    var titleFontSize = themeData.textTheme.bodyLarge!.fontSize;

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
        title: Text(
          s.Relays,
          style: TextStyle(
            fontSize: titleFontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(children: [
        Expanded(
          child: Container(
              margin: const EdgeInsets.only(
                top: Base.BASE_PADDING,
              ),
              child: RefreshIndicator(
                  onRefresh: () async {
                    UserRelayList? oldRelayList = cacheManager.loadUserRelayList(loggedUserSigner!.getPublicKey());
                    UserRelayList? userRelayList = await ndk.getSingleUserRelayList(loggedUserSigner!.getPublicKey(), forceRefresh: true);
                    if (userRelayList != null && (oldRelayList == null || oldRelayList.createdAt < userRelayList.createdAt)) {
                      createMyRelaySets(userRelayList);
                    }
                    await loadRelayInfos();
                    // try {
                    //   await Future.wait(userRelayList!.urls.map((url) => relayManager.webSockets[url]!,).map((webSocket) => webSocket.disconnect("reconnect")).toList());
                    // } catch (e) {
                    //   print(e);
                    // }

                    await relayManager.reconnectRelays(userRelayList!.urls);

                    // await relayManager.reconnectRelays(userRelayList!.urls);
                    setState(() {});
                  },
                  child: Selector<RelayProvider, UserRelayList?>(
                    selector: (BuildContext, RelayProvider) {
                      return relayProvider.getUserRelayList(loggedUserSigner!.getPublicKey());
                    },
                    builder: (BuildContext context, UserRelayList? userRelayList, Widget? child) {
                      userRelayList ??= UserRelayList(
                          pubKey: loggedUserSigner!.getPublicKey(),
                          relays: {for (String url in relayManager.bootstrapRelays) url: ReadWriteMarker.readWrite},
                          createdAt: Helpers.now,
                          refreshedTimestamp: Helpers.now);
                      return userRelayList == null
                          ? Container()
                          : ListView.builder(
                              itemBuilder: (context, index) {
                                int total = userRelayList!.relays.length;
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
                                            addRelay(controller.text);
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
                                              addRelay(url);
                                              //replaceMentionUser(metadata.pubKey);
                                            },
                                          );
                                        },
                                        itemCount: searchResults.length))
                                        :Container()
                                  ]);
                                }

                                var url = userRelayList!.urls.toList()[index];
                                ReadWriteMarker? marker = userRelayList!.relays[url]!;
                                return RelaysItemComponent(
                                  url: url,
                                  relay: relayManager.getRelay(url)!,
                                  marker: marker,
                                  showConnection: true,
                                  showStats: true,
                                  onRemove: () async {
                                    await loadRelayInfos();
                                  },
                                );
                              },
                              itemCount: (userRelayList != null ? userRelayList!.relays.length : 0) + (loggedUserSigner!.canSign() ? 1 : 0),
                            );
                    },
                  ))),
        ),
        // loggedUserSigner!.canSign()
        //     ? TextField(
        //         controller: controller,
        //         decoration: InputDecoration(
        //           prefixIcon: const Icon(Icons.lan),
        //           hintText: s.Input_relay_address,
        //           suffixIcon: IconButton(
        //             icon: const Icon(Icons.add),
        //             onPressed: () {
        //               addRelay(controller.text);
        //             }
        //           ),
        //         ),
        //       )
        //     : Container(),
      ]),
    );
  }
  void onEditingComplete() async {
    // itemScrollController.jumpTo(index: userRelayList!.relays.length-1);
    List<String> result = await relayProvider.findRelays(controller.text);
    for (var url in result) {
      if (relayManager.getRelay(url)==null || relayManager.getRelay(url)!.info==null) {
        relayManager.relays[url] = Relay(url);
        relayManager.getRelayInfo(url).then((value) {
          if (!disposed) {
            setState(() {});
          }
        });
      }
    }

    setState(() {
      searchResults = result ;
    });
  }


  @override
  void dispose() {
    super.dispose();
    disposed = true;
  }
  // Future<void> add(String url) async {
  //   String? cleanUrl = cleanRelayUrl(url);
  //   if (cleanUrl==null) {
  //     EasyLoading.showError("Invalid address wss://<host>:<port> or ws://<host>:<port>", dismissOnTap: true, duration: const Duration(seconds: 5));
  //     return;
  //   }
  //   if (relaySet!.relays.contains(cleanUrl)) {
  //     EasyLoading.showError("Relay already on list", dismissOnTap: true, duration: const Duration(seconds: 5));
  //     return;
  //   }
  //   bool? result = await ConfirmDialog.show(context, "Confirm add ${url} to list");
  //   if (result != null && result) {
  //     EasyLoading.show(status: 'Broadcasting relay list...', maskType: EasyLoadingMaskType.black, dismissOnTap: true);
  //     relaySet = await relayManager.broadcastAddNip51Relay(url, relaySet!.name, myOutboxRelaySet!.urls, loggedUserSigner!);
  //     if (relaySet!.name == "search") {
  //       searchRelays = relaySet!.relays;
  //     } else if (relaySet!.name == "blocked") {
  //       relayManager.blockedRelays = relaySet!.relays;
  //     }
  //     relayProvider.notifyListeners();
  //     EasyLoading.dismiss();
  //     setState(() {
  //       controller.text="";
  //     });
  //   }
  // }

  Future<void> addRelay(String url) async {
    String? cleanUrl = cleanRelayUrl(url);
    if (cleanUrl==null) {
      EasyLoading.showError("Invalid address wss://<host>:<port> or ws://<host>:<port>", dismissOnTap: true, duration: const Duration(seconds: 5), maskType: EasyLoadingMaskType.black,);
      return;
    }
    if (userRelayList!.relays.keys!.any((element) => cleanRelayUrl(element) == cleanUrl)) {
      EasyLoading.showError("Relay already on list", maskType: EasyLoadingMaskType.black, dismissOnTap: true, duration: const Duration(seconds: 5));
      return;
    }
    url = cleanUrl;
    // if (StringUtil.isBlank(url)) {
    //   EasyLoading.showError(I18n.of(context).Address_can_t_be_null, dismissOnTap: true);
    //   return;
    // }
    bool? result = await ConfirmDialog.show(context, "Confirm add ${url} to list");
    if (result != null && result) {
      bool finished = false;
      Future.delayed(const Duration(seconds: 1), () {
        if (!finished) {
          EasyLoading.showInfo("Refreshing relay list before adding...",
              maskType: EasyLoadingMaskType.black, dismissOnTap: true, duration: const Duration(seconds: 5));
        }
      });
      await relayProvider.addRelay(url);
      await loadRelayInfos();
      finished = true;
      EasyLoading.dismiss();
      controller.clear();
      FocusScope.of(context).unfocus();
      setState(() {

      });
    }
  }

  @override
  Future<void> onReady(BuildContext context) async {}
}
