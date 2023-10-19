import 'dart:developer';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yana/nostr/event_kind.dart';
import 'package:yana/router/login/login_router.dart';
import 'package:yana/utils/when_stop_function.dart';

import '../../i18n/i18n.dart';
import '../../main.dart';
import '../../models/relay_status.dart';
import '../../nostr/event.dart';
import '../../nostr/filter.dart';
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
  List<String> urls = [];

  @override
  void initState() {
    loadRelayInfos();
  }

  loadRelayInfos() async {
    Set<String> set = {};
    set.addAll(myInboxRelays!.map.keys);
    set.addAll(myOutboxRelays!.map.keys);

    urls = List.of(set);
    await Future.wait(urls.map((url) => relayManager.getRelayInfo(url)));
    /// TODO check if widget is not disposed already...
    setState(() {
      print("loaded relay infos");
    });
  }

  @override
  Widget doBuild(BuildContext context) {
    var s = I18n.of(context);
    var _relayProvider = Provider.of<RelayProvider>(context);
    // var relayStatusMap = relayProvider.relayStatusMap;
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
                  await relayManager
                      .reconnectRelays(myOutboxRelays!.map.keys.toList());
                  await relayManager
                      .reconnectRelays(myInboxRelays!.map.keys.toList());
                  setState(() {});
                  // var filter = Filter(
                  //     authors: [nostr!.publicKey],
                  //     limit: 1,
                  //     kinds: [EventKind.RELAY_LIST_METADATA]);
                  //
                  // nostr!.query([filter.toJson()], (event) {
                  //   LoginRouter.handleRemoteRelays(event, nostr!.privateKey!);
                  //   nostr!.checkAndReconnectRelays();
                  // });
                  // nostr!.checkAndReconnectRelays();
                },
                child: ListView.builder(
                  itemBuilder: (context, index) {
                    var url = urls[index];

                    return RelaysItemComponent(
                      relay: relayManager.relays[url]!,
                      onRemove: () {
                        setState(() {
                          urls = _relayProvider.relayAddrs;
                        });
                      },
                    );
                  },
                  itemCount: urls.length,
                ),
              )),
        ),
        nostr!.privateKey != null
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
      BotToast.showText(text: I18n.of(context).Address_can_t_be_null);
      return;
    }

    await relayProvider.addRelay(addr);
    controller.clear();
    FocusScope.of(context).unfocus();
  }


  @override
  Future<void> onReady(BuildContext context) async {
  }
}
