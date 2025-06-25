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

import 'package:go_router/go_router.dart';

import '../../i18n/i18n.dart';
import '../../nostr/relay_metadata.dart';
import '../../ui/confirm_dialog.dart';
import '../../utils/base.dart';

class MediaServersRouter extends StatefulWidget {
  const MediaServersRouter({super.key});

  @override
  State<StatefulWidget> createState() {
    return _MediaServersRouter();
  }
}

class _MediaServersRouter extends State<MediaServersRouter>
    with SingleTickerProviderStateMixin {
  List<String> mediaServers = [];
  late TabController tabController;
  TextEditingController controller = TextEditingController();
  bool disposed = false;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
    controller.addListener(() {
      onEditingComplete();
    });
    ndk.blossomUserServerList.getUserServerList(pubkeys: [loggedUserSigner!.getPublicKey()]).then((value) {
      setState(() {
        if (value != null) {
          mediaServers = value;
        } else {
          mediaServers = [];
        }
      });
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

    var s = I18n.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            context.pop();
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

            Text(
                "Blossom Media servers (${mediaServers!.length})"),
      ),
      body: Container(
        margin: const EdgeInsets.only(
          top: Base.BASE_PADDING,
        ),
        child: RefreshIndicator(
          onRefresh: () async {
            await ndk.blossomUserServerList.getUserServerList(pubkeys: [loggedUserSigner!.getPublicKey()]).then((value) {
              setState(() {
                if (value != null) {
                  mediaServers = value;
                } else {
                  mediaServers = [];
                }
              });
            });
          },
          child: ListView.builder(
            itemBuilder: (context, index) {
              int total = mediaServers.length;
              if (index == total && loggedUserSigner!.canSign()) {
                return Column(children: [
                  TextField(
                    controller: controller,
                    onEditingComplete: onEditingComplete,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.lan),
                      hintText: "Blossom Media Server URL",
                      suffixIcon: cleanRelayUrl(controller.text) != null
                          ? IconButton(onPressed: () { add(controller.text, true); }, icon: Icon(Icons.add), ):
                      IconButton(onPressed: () { add(controller.text, true); }, icon: Icon(Icons.add), )
                    )
                  ),
                ]);
              }
              return RelayListElementComponent(
                private: true,
                url: mediaServers![index],
                removable: loggedUserSigner!.canSign(),
                onRemove: (url) async {
                  bool? result = await ConfirmDialog.show(
                      context, "Confirm remove $url from list");
                  if (result != null && result) {
                    EasyLoading.show(
                        status: 'Removing from list and broadcasting...',
                        maskType: EasyLoadingMaskType.black,
                        dismissOnTap: true);
                    mediaServers.remove(url);
                    ndk.blossomUserServerList.publishUserServerList(
                      serverUrlsOrdered: mediaServers,
                    );
                    relayProvider.notifyListeners();
                    EasyLoading.dismiss();
                    setState(() {});
                  }
                },
              );
            },
            itemCount: mediaServers.length +
                (loggedUserSigner!.canSign() ? 1 : 0),
          ),
        ),
      ),
    );
  }

  void onEditingComplete() async {
    // List<String> result = await relayProvider.findRelays(controller.text,
    //     nip: mediaServers!.kind == Nip51List.kSearchRelays ? Nip50.kNip : null);
    // result.forEach((url) {
    //   if (ndk.relays.getRelayConnectivity(url) == null ||
    //       ndk.relays.getRelayConnectivity(url)!.relayInfo == null) {
    //     ndk.relays.getRelayInfo(url).then((value) {
    //       if (!disposed) {
    //         setState(() {});
    //       }
    //     });
    //   }
    // });

    // setState(() {
    //   searchResults = result;
    // });
  }

  int compareRelays(RelayMetadata r1, RelayMetadata r2) {
    Relay? relay1 = ndk.relays.getRelayConnectivity(r1.url!)!.relay;
    Relay? relay2 = ndk.relays.getRelayConnectivity(r2.url!)!.relay;
    if (relay1 == null) {
      return 1;
    }
    if (relay2 == null) {
      return -1;
    }
    bool a1 = ndk.relays.isRelayConnected(r1.url!);
    bool a2 = ndk.relays.isRelayConnected(r2.url!);
    if (a1) {
      return a2 ? (r2.count != null ? r2.count!.compareTo(r1.count!) : 0) : -1;
    }
    return a2 ? 1 : (r2.count != null ? r2.count!.compareTo(r1.count!) : 0);
  }

  Future<void> add(String url, bool private) async {
    if (mediaServers!.contains(url)) {
      EasyLoading.showError(
        "Relay already on list",
        dismissOnTap: true,
        duration: const Duration(seconds: 5),
        maskType: EasyLoadingMaskType.black,
      );
      return;
    }
    bool? result = await ConfirmDialog.show(context,
        "Confirm add ${url} to list");
    if (result != null && result) {
      EasyLoading.show(
          status: 'Broadcasting relay list...',
          maskType: EasyLoadingMaskType.black,
          dismissOnTap: true);
      mediaServers.add(url);
      ndk.blossomUserServerList.publishUserServerList(
        serverUrlsOrdered: mediaServers,
      );
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

  RelayListElementComponent(
      {super.key,
      required this.url,
      required this.private,
      this.removable = true,
      this.onRemove});

  @override
  Widget build(BuildContext context) {
    var s = I18n.of(context);
    var themeData = Theme.of(context);
    var cardColor = themeData.cardColor;
    var bodySmallFontSize = themeData.textTheme.labelSmall!.fontSize;

    Widget leftBtn = GestureDetector(
        onTap: () async {
          EasyLoading.showInfo(private ? "Private" : "Public",
              dismissOnTap: true, duration: const Duration(seconds: 3));
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
                if (ndk.relays.getRelayConnectivity(url) == null ||
                    ndk.relays.getRelayConnectivity(url)!.relayInfo == null) {
                  EasyLoading.show(status: "Loading relay info...");
                  ndk.relays.getRelayInfo(url).then((info) {
                    EasyLoading.dismiss();
                    if (info != null) {
                      context.go(RouterPath.RELAY_INFO,
                          extra: ndk.relays.getRelayConnectivity(url));
                    }
                  });
                } else {
                  context.go(RouterPath.RELAY_INFO,
                      extra: ndk.relays.getRelayConnectivity(url));
                }
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                      margin: const EdgeInsets.only(bottom: 2, left: 5),
                      child: Text(url
                          .replaceAll("wss://", "")
                          .replaceAll("ws://", ""))),
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
