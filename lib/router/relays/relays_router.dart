import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:yana/ui/confirm_dialog.dart';
import 'package:yana/utils/when_stop_function.dart';
import 'package:provider/provider.dart';

import '../../nostr/event.dart';
import '../../nostr/event_kind.dart' as kind;
import '../../nostr/filter.dart';
import '../../ui/cust_state.dart';
import '../../utils/base.dart';
import '../../models/relay_status.dart';
import '../../i18n/i18n.dart';
import '../../main.dart';
import '../../provider/relay_provider.dart';
import '../../utils/router_util.dart';
import '../../utils/string_util.dart';
import 'relays_item_component.dart';

class RelaysRouter extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _RelaysRouter();
  }
}

class _RelaysRouter extends CustState<RelaysRouter> with WhenStopFunction {
  TextEditingController controller = TextEditingController();
  @override
  Widget doBuild(BuildContext context) {
    var s = I18n.of(context);
    var _relayProvider = Provider.of<RelayProvider>(context);
    var relayAddrs = _relayProvider.relayAddrs;
    var relayStatusMap = relayProvider.relayStatusMap;
    var themeData = Theme.of(context);
    var color = themeData.textTheme.bodyLarge!.color;
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
            child: ListView.builder(
              itemBuilder: (context, index) {
                var addr = relayAddrs[index];
                var relayStatus = relayStatusMap[addr];
                relayStatus ??= RelayStatus(addr);

                return RelaysItemComponent(
                  addr: addr,
                  relayStatus: relayStatus,
                );
              },
              itemCount: relayAddrs.length,
            ),
          ),
        ),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.lan),
            hintText: s.Input_relay_address,
            suffixIcon: IconButton(
              icon: const Icon(Icons.add),
              onPressed: addRelay,
            ),
          ),
        ),
      ]),
    );
  }

  void addRelay() {
    var addr = controller.text;
    addr = addr.trim();
    if (StringUtil.isBlank(addr)) {
      BotToast.showText(text: I18n.of(context).Address_can_t_be_null);
      return;
    }

    relayProvider.addRelay(addr);
    controller.clear();
    FocusScope.of(context).unfocus();
  }

  Event? remoteRelayEvent;

  @override
  Future<void> onReady(BuildContext context) async {
    var filter = Filter(
        authors: [nostr!.publicKey],
        limit: 1,
        kinds: [kind.EventKind.RELAY_LIST_METADATA]);
    nostr!.query([filter.toJson()], (event) {
      if ((remoteRelayEvent != null &&
              event.createdAt > remoteRelayEvent!.createdAt) ||
          remoteRelayEvent == null) {
        setState(() {
          remoteRelayEvent = event;
        });
        whenStop(handleRemoteRelays);
      }
    });
  }

  Future<void> handleRemoteRelays() async {
    var relaysUpdatedTime = relayProvider.updatedTime();
    if (remoteRelayEvent != null &&
        (relaysUpdatedTime == null ||
            remoteRelayEvent!.createdAt - relaysUpdatedTime > 60 * 5)) {
      var result = await ConfirmDialog.show(context,
          I18n.of(context).Find_clouded_relay_list_do_you_want_to_download);
      if (result == true) {
        List<String> list = [];
        for (var tag in remoteRelayEvent!.tags) {
          if (tag.length > 1) {
            var key = tag[0];
            var value = tag[1];
            if (key == "r") {
              list.add(value);
            }
          }
        }
        setState(() {
          relayProvider.setRelayListAndUpdate(list);
        });
      }
    }
  }
}
