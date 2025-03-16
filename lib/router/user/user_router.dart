import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_list_view/flutter_list_view.dart';
import 'package:ndk/ndk.dart';
import 'package:provider/provider.dart';
import 'package:yana/provider/filter_provider.dart';

import '../../main.dart';
import '../../models/event_mem_box.dart';
import '../../nostr/event_kind.dart' as kind;
import '../../nostr/nip19/nip19.dart';
import '../../provider/metadata_provider.dart';
import '../../provider/setting_provider.dart';
import '../../ui/appbar4stack.dart';
import '../../ui/cust_state.dart';
import '../../ui/event/event_list_component.dart';
import '../../ui/user/metadata_component.dart';
import '../../utils/base_consts.dart';
import '../../utils/load_more_event.dart';
import '../../utils/peddingevents_later_function.dart';
import '../../utils/router_util.dart';
import '../../utils/string_util.dart';
import 'user_statistics_component.dart';

class UserRouter extends StatefulWidget {
  String? pubKey;

  UserRouter({super.key, this.pubKey});

  @override
  State<StatefulWidget> createState() {
    return _UserRouter();
  }
}

class _UserRouter extends CustState<UserRouter>
    with PenddingEventsLaterFunction, LoadMoreEvent {
  final GlobalKey<NestedScrollViewState> globalKey = GlobalKey();

  ScrollController _controller = ScrollController();
  NdkResponse? subscription;

  String? pubkey;

  bool disposed = false;

  bool showTitle = false;

  bool followsYou = false;

  bool showAppbarBG = false;

  EventMemBox box = EventMemBox();

  @override
  void initState() {
    super.initState();

    queryLimit = 100;
    _controller.addListener(() {
      var _showTitle = false;
      var _showAppbarBG = false;

      var offset = _controller.offset;
      if (offset > showTitleHeight) {
        _showTitle = true;
      }
      if (offset > showAppbarBGHeight) {
        _showAppbarBG = true;
      }

      if (_showTitle != showTitle || _showAppbarBG != showAppbarBG) {
        setState(() {
          showTitle = _showTitle;
          showAppbarBG = _showAppbarBG;
        });
      }
    });
  }

  /// the offset to show title, bannerHeight + 50;
  double showTitleHeight = 50;

  /// the offset to appbar background color, showTitleHeight + 100;
  double showAppbarBGHeight = 50 + 100;

  @override
  Widget doBuild(BuildContext context) {
    var _settingProvider = Provider.of<SettingProvider>(context);
    var _metadataProvider = Provider.of<MetadataProvider>(context);
    var _filterProvider = Provider.of<FilterProvider>(context);

    if (StringUtil.isBlank(pubkey) || subscription == null) {
      pubkey = RouterUtil.routerArgs(context) as String?;
      if (StringUtil.isBlank(pubkey)) {
        RouterUtil.back(context);
        return Container();
      }
      doQuery();
      // var events = followEventProvider.eventsByPubkey(pubkey!);
      // if (events != null && events.isNotEmpty) {
      //   box.addList(events);
      // }
    } else {
      var arg = RouterUtil.routerArgs(context);
      if (arg != null && arg is String) {
        if (arg != pubkey) {
          // arg change! reset.
          box.clear();
          until = null;

          pubkey = arg;
          if (subscription == null) {
            doQuery();
          }
        }
      }
    }
    preBuild();

    var paddingTop = mediaDataCache.padding.top;
    var maxWidth = mediaDataCache.size.width;

    showTitleHeight = maxWidth / 3 + 50;
    showAppbarBGHeight = showTitleHeight + 100;

    var themeData = Theme.of(context);
    var cardColor = themeData.cardColor;

    return FutureBuilder<Metadata?>(
        future: metadataProvider.getMetadata(pubkey!),
        builder: (context, snapshot) {
          var metadata = snapshot.data;
          Color? appbarBackgroundColor = Colors.transparent;
          if (showAppbarBG) {
            appbarBackgroundColor = Colors.white.withOpacity(0.5);
          }
          Widget? appbarTitle;
          if (showTitle) {
            String nip19Name = Nip19.encodeSimplePubKey(pubkey!);
            String displayName = nip19Name;
            if (metadata != null) {
              if (StringUtil.isNotBlank(metadata.getName())) {
                displayName = metadata.getName()!;
              }

              appbarTitle = Container(
                alignment: Alignment.center,
                child: Text(
                  displayName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              );
            }
          }
          var appBar = Appbar4Stack(
            backgroundColor: appbarBackgroundColor,
            title: appbarTitle,
          );

          Widget main = NestedScrollView(
            key: globalKey,
            controller: _controller,
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                SliverToBoxAdapter(
                  child: MetadataComponent(
                    pubKey: pubkey!,
                    metadata: metadata,
                    showBadges: true,
                    userPicturePreview: true,
                    followsYou: followsYou,
                  ),
                ),
                SliverToBoxAdapter(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: UserStatisticsComponent(
                      pubkey: pubkey!,
                      // userNostr: userNostr,
                      onContactListLoaded: (contactList) {
                        if (!disposed &&
                            loggedUserSigner != null &&
                            contactList.contacts
                                .contains(loggedUserSigner!.getPublicKey())) {
                          setState(() {
                            followsYou = true;
                          });
                        }
                      },
                    ),
                  ),
                ),
              ];
            },
            body: MediaQuery.removePadding(
              removeTop: true,
              context: context,
              child: FlutterListView(
                  delegate: FlutterListViewDelegate(
                (BuildContext context, int index) {
                  var event = box.get(index);
                  if (event == null) {
                    return null;
                  }
                  return EventListComponent(
                    event: event,
                    showVideo: _settingProvider.videoPreview == OpenStatus.OPEN,
                  );
                },
                childCount: box.length(),
              )),
            ),
          );

          return Scaffold(
              backgroundColor: themeData.scaffoldBackgroundColor,
              body: Stack(
                children: [
                  main,
                  Positioned(
                    top: paddingTop,
                    child: Container(
                      width: maxWidth,
                      child: appBar,
                    ),
                  ),
                ],
              ));
        });
  }

  @override
  Future<void> onReady(BuildContext context) async {
    if (globalKey.currentState != null) {
      var controller = globalKey.currentState!.innerController;
      controller.addListener(() {
        loadMoreScrollCallback(controller);
      });
    }
  }

  void onEvent(Nip01Event event, {bool saveToCache = false}) {
    if (event.pubKey != pubkey) {
      print("WTF $event");
      return;
    }
    later(event, (list) {
      bool added = box.addList(list);
      if (saveToCache && added) {
        cacheManager.saveEvents(list);
      }
      setState(() {});
    }, null);
  }

  @override
  void deactivate() {
    super.deactivate();
    unSubscribe();
  }

  @override
  void dispose() {
    super.dispose();
    disposed = true;
    unSubscribe();
    disposeLater();
  }

  @override
  void activate() {
    super.activate();
    if (subscription == null) {
      doQuery();
    }
  }

  @override
  void reassemble() {
    super.reassemble();
    if (subscription == null) {
      doQuery();
    }
  }

  void unSubscribe() {
    if (subscription != null) {
      ndk.requests.closeSubscription(subscription!.requestId);
      subscription = null;
      box.clear();
    }
  }

  List<int> queryEventKinds() {
    return [
      Nip01Event.kTextNodeKind,
      kind.EventKind.REPOST,
      kind.EventKind.GENERIC_REPOST,
      kind.EventKind.LONG_FORM,
      kind.EventKind.FILE_HEADER,
      kind.EventKind.POLL,
    ];
  }

  @override
  void doQuery() {
    Future(() async {
      if (subscription == null) {
        if (box.isEmpty()) {
          List<Nip01Event>? cachedEvents =
              await cacheManager.loadEvents(pubKeys: [
            pubkey!
          ], kinds: [
            Nip01Event.kTextNodeKind,
            // kind.EventKind.REPOST,
            // kind.EventKind.GENERIC_REPOST,
            // kind.EventKind.LONG_FORM,
            // kind.EventKind.FILE_HEADER,
            // kind.EventKind.POLL,
          ]); //queryEventKinds());
          print("USER loaded ${cachedEvents.length} events from cache DB");
          for (var event in cachedEvents) {
            onEvent(event, saveToCache: false);
          }
        }

        if (myInboxRelaySet == null || myOutboxRelaySet == null) {
          return;
        }
        preQuery();

        var filter = Filter(
          kinds: queryEventKinds(),
          until: until,
          authors: [pubkey!],
          limit: queryLimit,
        );
        RelaySet relaySet = myInboxRelaySet!;
        if (pubkey == loggedUserSigner!.getPublicKey()) {
          relaySet = myOutboxRelaySet!;
        } else if (feedRelaySet != null && settingProvider.gossip == 1) {
          relaySet = feedRelaySet!;
        }
        subscription = ndk.requests.subscription(
            name: "user-sub", filters: [filter], relaySet: relaySet);
        subscription!.stream.listen((event) {
          onEvent(event,
              saveToCache: pubkey == loggedUserSigner!.getPublicKey());
        });
      }
    });
  }

  @override
  EventMemBox getEventBox() {
    return box;
  }
}
