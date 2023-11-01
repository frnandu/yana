import 'package:bot_toast/bot_toast.dart';
import 'package:dart_ndk/models/user_relay_list.dart';
import 'package:dart_ndk/nips/nip01/helpers.dart';
import 'package:dart_ndk/nips/nip65/read_write_marker.dart';
import 'package:dart_ndk/relay.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';
import 'package:yana/utils/when_stop_function.dart';

import '../../i18n/i18n.dart';
import '../../main.dart';
import '../../provider/relay_provider.dart';
import '../../ui/cust_state.dart';
import '../../utils/base.dart';
import '../../utils/router_util.dart';
import '../../utils/string_util.dart';
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

  @override
  void initState() {
    loadRelayInfos();
  }

  loadRelayInfos() async {
    // Set<String> set = {};
    // set.addAll(myInboxRelaySet!.urls);
    // set.addAll(myOutboxRelaySet!.urls);

    userRelayList =
        cacheManager.loadUserRelayList(loggedUserSigner!.getPublicKey());
    userRelayList ??= await relayManager.getSingleUserRelayList(
        loggedUserSigner!.getPublicKey(),
        forceRefresh: true);
    userRelayList ??= UserRelayList(pubKey: loggedUserSigner!.getPublicKey(), relays: { for (String url in relayManager.bootstrapRelays) url : ReadWriteMarker.readWrite}, createdAt: Helpers.now, refreshedTimestamp: Helpers.now);
    await Future.wait(userRelayList!.urls
        .map((url) => relayManager.getRelayInfo(Relay.clean(url)!)));

    /// TODO check if widget is not disposed already...
    setState(() {
      print("loaded relay infos");
    });
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
                    UserRelayList? oldRelayList = cacheManager
                        .loadUserRelayList(loggedUserSigner!.getPublicKey());
                    UserRelayList? userRelayList =
                        await relayManager.getSingleUserRelayList(
                            loggedUserSigner!.getPublicKey(),
                            forceRefresh: true);
                    if (userRelayList != null &&
                        (oldRelayList == null ||
                            oldRelayList.createdAt < userRelayList.createdAt)) {
                      createMyRelaySets(userRelayList);
                    }
                    await loadRelayInfos();
                    await relayManager.connect(urls: userRelayList!.urls);

                    // await relayManager.reconnectRelays(userRelayList!.urls);
                    setState(() {});
                  },
                  child: Selector<RelayProvider, UserRelayList?>(
                    selector: (BuildContext, RelayProvider) {
                      return relayProvider
                          .getUserRelayList(loggedUserSigner!.getPublicKey());
                    },
                    builder: (BuildContext context, UserRelayList? userRelayList,
                        Widget? child) {
                      userRelayList ??= UserRelayList(pubKey: loggedUserSigner!.getPublicKey(), relays: { for (String url in relayManager.bootstrapRelays) url : ReadWriteMarker.readWrite}, createdAt: Helpers.now, refreshedTimestamp: Helpers.now);

                      return userRelayList==null? Container(): ListView.builder(
                        itemBuilder: (context, index) {
                          var url = userRelayList!.urls.toList()[index];
                          ReadWriteMarker? marker = userRelayList!.relays[url]!;
                          return RelaysItemComponent(
                            url: url,
                            relay: relayManager.getRelay(url)!,
                            marker: marker,
                            onRemove: () async {
                              await loadRelayInfos();
                            },
                          );
                        },
                        itemCount: userRelayList != null
                            ? userRelayList!.relays.length
                            : 0,
                      );
                    },
                  ))),
        ),
        loggedUserSigner!.canSign()
            ? TextField(
                controller: controller,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.lan),
                  hintText: s.Input_relay_address,
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: addRelay,
                  ),
                ),
              )
            : Container(),
      ]),
    );
  }

  Future<void> addRelay() async {
    var addr = controller.text;
    addr = addr.trim();
    if (StringUtil.isBlank(addr)) {
      EasyLoading.showError(I18n.of(context).Address_can_t_be_null, dismissOnTap: true);
      return;
    }

    bool finished = false;
    Future.delayed(const Duration(seconds: 1),() {
      if (!finished) {
        EasyLoading.show(status: "Refreshing relay list before adding...", maskType: EasyLoadingMaskType.black);
      }
    });
    await relayProvider.addRelay(addr);
    await loadRelayInfos();
    finished = true;
    EasyLoading.dismiss();
    controller.clear();
    FocusScope.of(context).unfocus();
  }

  @override
  Future<void> onReady(BuildContext context) async {}
}
