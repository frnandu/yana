import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yana/nostr/relay_metadata.dart';

import '../../main.dart';
import '../../models/event_mem_box.dart';
import '../../models/metadata.dart';
import '../../models/relay_status.dart';
import '../../nostr/event_kind.dart' as kind;
import '../../nostr/filter.dart';
import '../../nostr/nip02/contact.dart';
import '../../nostr/nip19/nip19.dart';
import '../../nostr/nostr.dart';
import '../../nostr/relay.dart';
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
  const UserRouter({super.key});

  @override
  State<StatefulWidget> createState() {
    return _UserRouter();
  }
}

class _UserRouter extends CustState<UserRouter>
    with PenddingEventsLaterFunction, LoadMoreEvent {
  final GlobalKey<NestedScrollViewState> globalKey = GlobalKey();

  ScrollController _controller = ScrollController();

  String? pubkey;

  Nostr? userNostr;

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
    if (StringUtil.isBlank(pubkey)) {
      pubkey = RouterUtil.routerArgs(context) as String?;
      if (StringUtil.isBlank(pubkey)) {
        RouterUtil.back(context);
        return Container();
      }
      var events = followEventProvider.eventsByPubkey(pubkey!);
      if (events != null && events.isNotEmpty) {
        box.addList(events);
      }
    } else {
      var arg = RouterUtil.routerArgs(context);
      if (arg != null && arg is String) {
        if (arg != pubkey) {
          // arg change! reset.
          box.clear();
          until = null;

          pubkey = arg;
          doQuery();
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

    return Selector<MetadataProvider, Metadata?>(
      shouldRebuild: (previous, next) {
        return previous != next;
      },
      selector: (context, _metadataProvider) {
        return _metadataProvider.getMetadata(pubkey!);
      },
      builder: (context, metadata, child) {
        Color? appbarBackgroundColor = Colors.transparent;
        if (showAppbarBG) {
          appbarBackgroundColor = Colors.white.withOpacity(0.5);
        }
        Widget? appbarTitle;
        if (showTitle) {
          String nip19Name = Nip19.encodeSimplePubKey(pubkey!);
          String displayName = nip19Name;
          if (metadata != null) {
            if (StringUtil.isNotBlank(metadata.displayName)) {
              displayName = metadata.displayName!;
            }

            appbarTitle = Container(
              alignment: Alignment.center,
              child: Text(
                displayName,
                style: TextStyle(
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
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
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
              // Container(
              //     margin: const EdgeInsets.only(top: Base.BASE_PADDING_HALF),
              //     padding: const EdgeInsets.only(
              //       left: Base.BASE_PADDING * 2,
              //       bottom: Base.BASE_PADDING / 2,
              //       top: Base.BASE_PADDING / 2,
              //     ),
              //     decoration: BoxDecoration(
              //         border: Border(
              //             top: BorderSide(
              //               width: 1,
              //               color: themeData.hintColor,
              //             )))),
              SliverToBoxAdapter(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: userNostr!=null ? UserStatisticsComponent(
                    pubkey: pubkey!,
                    userNostr: userNostr,
                    onContactListLoaded: (contactList) {
                      Contact? c = contactList.getContact(nostr!.publicKey);
                      if (nostr != null &&
                          contactList.getContact(nostr!.publicKey) != null) {
                        setState(() {
                          followsYou = true;
                        });
                      }
                    },
                  ) : Container(),
                ),
              ),
            ];
          },
          body: MediaQuery.removePadding(
            removeTop: true,
            context: context,
            child: ListView.builder(
              itemBuilder: (BuildContext context, int index) {
                var event = box.get(index);
                if (event == null) {
                  return null;
                }
                return EventListComponent(
                  event: event,
                  showVideo: _settingProvider.videoPreview == OpenStatus.OPEN,
                );
              },
              itemCount: box.length(),
            ),
          ),
        );

        return Scaffold(
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
      },
    );
  }

  String? subscribeId;

  List<RelayMetadata> relays = [];

  @override
  Future<void> onReady(BuildContext context) async {
    await relayProvider.getRelays(pubkey!, (relays) async {
      if (userNostr == null) {
        if (pubkey != nostr!.publicKey) {
          // use relays for user where he/she writes
          Set<String> uniqueRelays = Set<String>.from(relays
              .where((element) => element.write != null && element.write!)
              .map((e) => e.addr));
          userNostr =
              Nostr(privateKey: nostr!.privateKey, publicKey: nostr!.publicKey);

          List<Future<bool>> futures = [];

          uniqueRelays.forEach((adr) async {
            String? relayAddr = Relay.clean(adr);
            if (relayAddr == null) {
              return;
            }

            Relay r = Relay(
              relayAddr,
              RelayStatus(relayAddr),
              access: WriteAccess.readWrite,
            );
            try {
              futures.add(userNostr!.addRelay(r, checkInfo: false));
              // await userNostr!.addRelay(r, checkInfo: false, connect: true);
            } catch (e) {
              log(
                  "relay $relayAddr add to temp nostr for broadcasting of nip065 relay list: ${e
                      .toString()}");
            }
          });
          final startTime = DateTime.now();
          await Future.wait(futures).onError((error, stackTrace) => List.of([]));
          final endTime = DateTime.now();
          final duration = endTime.difference(startTime);
          print("addRelays for ${uniqueRelays.length} parallel Future.wait(futures) took:${duration.inMilliseconds} ms");

        } else {
          userNostr = nostr;
        }
      }
      setState(() {
        this.relays = relays;
      });

      doQuery();
    });

    if (globalKey.currentState != null) {
      var controller = globalKey.currentState!.innerController;
      controller.addListener(() {
        loadMoreScrollCallback(controller);
      });
    }

    metadataProvider.update(pubkey!);
  }

  void onEvent(event) {
    later(event, (list) {
      box.addList(list);
      setState(() {});
    }, null);
  }

  @override
  void dispose() {
    super.dispose();
    disposeLater();

    if (userNostr != null) {
      if (StringUtil.isNotBlank(subscribeId)) {
        try {
          userNostr!.unsubscribe(subscribeId!);
        } catch (e) {}
      }
      try {
        userNostr!.close();
      } catch (e) {}
    }
  }

  void unSubscribe() {
    if (userNostr != null) {
      userNostr!.unsubscribe(subscribeId!);
    }
    subscribeId = null;
  }

  @override
  void doQuery() {
    preQuery();
    if (StringUtil.isNotBlank(subscribeId)) {
      unSubscribe();
    }

    // load event from relay
    var filter = Filter(
      kinds: [
        kind.EventKind.TEXT_NOTE,
        kind.EventKind.REPOST,
        kind.EventKind.GENERIC_REPOST,
        kind.EventKind.LONG_FORM,
        kind.EventKind.FILE_HEADER,
        kind.EventKind.POLL,
      ],
      until: until,
      authors: [pubkey!],
      limit: queryLimit,
    );
    subscribeId = StringUtil.rndNameStr(16);

    var activeRelays = userNostr!.activeRelays();
    if (!box.isEmpty() && activeRelays.isNotEmpty) {
      var oldestCreatedAts = box.oldestCreatedAtByRelay(
        activeRelays,
      );
      Map<String, List<Map<String, dynamic>>> filtersMap = {};
      for (var relay in activeRelays) {
        var oldestCreatedAt = oldestCreatedAts.createdAtMap[relay.url];
        filter.until = oldestCreatedAt;
        filtersMap[relay.url] = [filter.toJson()];
      }
      userNostr!.queryByFilters(filtersMap, onEvent, id: subscribeId);
    } else {
      userNostr!.query([filter.toJson()], onEvent, id: subscribeId);
    }
  }

  @override
  EventMemBox getEventBox() {
    return box;
  }
}
