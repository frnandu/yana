import 'dart:async';

import 'package:ndk/domain_layer/entities/filter.dart';
import 'package:ndk/domain_layer/entities/nip_01_event.dart';
import 'package:flutter/material.dart';
import 'package:ndk/presentation_layer/request_response.dart';
import 'package:provider/provider.dart';
import 'package:widget_size/widget_size.dart';
import 'package:yana/provider/community_info_provider.dart';
import 'package:yana/ui/community_info_component.dart';
import 'package:yana/utils/base.dart';

import '../../main.dart';
import '../../models/event_mem_box.dart';
import '../../nostr/event_kind.dart' as kind;
import '../../nostr/nip172/community_id.dart';
import '../../nostr/nip172/community_info.dart';
import '../../provider/setting_provider.dart';
import '../../ui/cust_state.dart';
import '../../ui/event/event_list_component.dart';
import '../../ui/event_delete_callback.dart';
import '../../utils/base_consts.dart';
import '../../utils/peddingevents_later_function.dart';
import '../../utils/router_util.dart';
import '../edit/editor_router.dart';

class CommunityDetailRouter extends StatefulWidget {
  const CommunityDetailRouter({super.key});

  @override
  State<StatefulWidget> createState() {
    return _CommunityDetailRouter();
  }
}

class _CommunityDetailRouter extends CustState<CommunityDetailRouter> with PenddingEventsLaterFunction {
  EventMemBox box = EventMemBox();

  CommunityId? communityId;

  ScrollController _controller = ScrollController();

  bool showTitle = false;

  double infoHeight = 80;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      if (_controller.offset > infoHeight * 0.8 && !showTitle) {
        setState(() {
          showTitle = true;
        });
      } else if (_controller.offset < infoHeight * 0.8 && showTitle) {
        setState(() {
          showTitle = false;
        });
      }
    });
  }

  @override
  Widget doBuild(BuildContext context) {
    if (communityId == null) {
      var arg = RouterUtil.routerArgs(context);
      if (arg != null) {
        communityId = arg as CommunityId;
      }
    }
    if (communityId == null) {
      RouterUtil.back(context);
      return Container();
    }
    var _settingProvider = Provider.of<SettingProvider>(context);
    var themeData = Theme.of(context);
    var bodyLargeFontSize = themeData.textTheme.bodyLarge!.fontSize;

    Widget? appBarTitle;
    if (showTitle) {
      appBarTitle = Text(
        communityId!.title,
        style: TextStyle(
          fontSize: bodyLargeFontSize,
          overflow: TextOverflow.ellipsis,
        ),
      );
    }

    Widget main = EventDeleteCallback(
      onDeleteCallback: onDeleteCallback,
      child: ListView.builder(
        controller: _controller,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Selector<CommunityInfoProvider, CommunityInfo?>(builder: (context, info, child) {
              if (info == null) {
                return Container();
              }

              return WidgetSize(
                onChange: (s) {
                  infoHeight = s.height;
                },
                child: CommunityInfoComponent(info: info!),
              );
            }, selector: (context, _provider) {
              return _provider.getCommunity(communityId!.toAString());
            });
          }

          var event = box.get(index - 1);
          if (event == null) {
            return null;
          }
          return EventListComponent(
            event: event,
            showVideo: _settingProvider.videoPreview == OpenStatus.OPEN,
            showCommunity: false,
          );
        },
        itemCount: box.length() + 1,
      ),
    );

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
        actions: [
          GestureDetector(
            onTap: addToCommunity,
            child: Container(
              margin: const EdgeInsets.only(
                left: Base.BASE_PADDING,
                right: Base.BASE_PADDING,
              ),
              child: Icon(
                Icons.add,
                color: themeData.appBarTheme.titleTextStyle!.color,
              ),
            ),
          )
        ],
        title: appBarTitle,
      ),
      body: main,
    );
  }

  @override
  Future<void> onReady(BuildContext context) async {
    if (communityId != null) {
      queryEvents();
    }
  }

  NdkResponse? subscription;

  void queryEvents() async {
    if (subscription!=null) {
      await ndk.closeSubscription(subscription!.requestId);
    }
    var filter = Filter(kinds: [
      Nip01Event.TEXT_NODE_KIND,
      kind.EventKind.LONG_FORM,
      kind.EventKind.FILE_HEADER,
      kind.EventKind.POLL,
    ], aTags: [
      communityId!.toAString()
    ], limit: 100);

    subscription = ndk.subscription(filters: [filter], relaySet:  myInboxRelaySet!);
    subscription!.stream.listen((event) {
      onEvent(event);
    });
  }

  void onEvent(Nip01Event event) {
    later(event, (list) {
      box.addList(list);
      setState(() {});
    }, null);
  }

  @override
  void dispose() {
    super.dispose();
    disposeLater();

    if (subscription!=null) {
      ndk.closeSubscription(subscription!.requestId);
    }
  }

  onDeleteCallback(Nip01Event event) {
    box.delete(event.id);
    setState(() {});
  }

  Future<void> addToCommunity() async {
    if (communityId != null) {
      List<String> aTag = ["a", communityId!.toAString()];
      if (myOutboxRelaySet != null && myOutboxRelaySet!.urls.isNotEmpty) {
        aTag.add(myOutboxRelaySet!.urls.first);
      }

      var event = await EditorRouter.open(context, tags: [aTag]);
      if (event != null) {
        queryEvents();
      }
    }
  }
}
