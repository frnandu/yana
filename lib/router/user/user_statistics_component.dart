import 'dart:async';

import 'package:bot_toast/bot_toast.dart';
import 'package:convert/convert.dart';
import 'package:dart_ndk/nips/nip01/event.dart';
import 'package:dart_ndk/nips/nip01/filter.dart';
import 'package:dart_ndk/nips/nip02/contact_list.dart';
import 'package:dart_ndk/nips/nip65/read_write_marker.dart';
import 'package:flutter/material.dart';
import 'package:yana/ui/enum_selector_component.dart';
import 'package:yana/utils/base_consts.dart';

import '../../i18n/i18n.dart';
import '../../main.dart';
import '../../models/event_mem_box.dart';
import '../../nostr/event.dart';
import '../../nostr/nip02/contact_list.dart';
import '../../nostr/relay_metadata.dart';
import '../../ui/cust_state.dart';
import '../../utils/base.dart';
import '../../utils/number_format_util.dart';
import '../../utils/router_path.dart';
import '../../utils/router_util.dart';
import '../../utils/string_util.dart';

class UserStatisticsComponent extends StatefulWidget {
  String pubkey;

  Function(Nip02ContactList)? onContactListLoaded;

  UserStatisticsComponent(
      {super.key, required this.pubkey, this.onContactListLoaded});

  @override
  State<StatefulWidget> createState() {
    return _UserStatisticsComponent();
  }
}

class _UserStatisticsComponent extends CustState<UserStatisticsComponent> {
  static const Duration REFRESH_METADATA_DURATION = Duration(minutes: 10);

  EventMemBox? zapEventBox;
  Map<String, ReadWriteMarker> relayMap = {};
  Nip02ContactList? contactList;

  // followedMap
  Map<String, Nip01Event>? followedMap;

  int length = 0;
  int relaysNum = 0;
  int? zapNum;
  int? followedNum;

  bool isLocal = false;

  @override
  void initState() {
    isLocal = widget.pubkey == nostr!.publicKey;
    // if (isLocal && widget.userNostr == null) {
    //   widget.userNostr = nostr;
    // }
    // if (!isLocal && widget.userNostr != null) {
    //   loadContactList(widget.userNostr!);
    // }
    load();
  }

  void load() async {
    relayManager.loadMissingRelayListsFromNip65OrNip02([widget.pubkey]).then(
      (value) {
        setState(() {
          relayMap = relayManager.getRelayMarkerMap(widget.pubkey) ?? {};
          contactList = relayManager.getContactList(widget.pubkey);
          if (widget.onContactListLoaded != null && contactList != null) {
            widget.onContactListLoaded!(contactList!);
          }
        });
      },
    );
    refreshContactListIfNeededAsync(widget.pubkey);
    onFollowedTap();
    onZapTap();
  }

  void refreshContactListIfNeededAsync(String pubkey) {
    Nip02ContactList? nip02 = relayManager.getContactList(pubkey);
    int sometimeAgo = DateTime.now()
            .subtract(REFRESH_METADATA_DURATION)
            .millisecondsSinceEpoch ~/
        1000;
    if (nip02 == null ||
        nip02.loadedTimestamp == null ||
        nip02.loadedTimestamp! < sometimeAgo) {
      relayManager.loadContactList(pubkey!, forceRefresh: true).then(
        (newContactList) {
          if (newContactList != null &&
              (nip02 == null ||
                  (nip02!.createdAt < newContactList.createdAt))) {
            if (widget.onContactListLoaded != null && newContactList != null) {
              widget.onContactListLoaded!(contactList!);
            }
            setState(() {
              contactList = newContactList;
            });
          }
        },
      );
    }
  }

  @override
  Widget doBuild(BuildContext context) {
    var s = I18n.of(context);
    // if (widget.userNostr == null || relays == null) {
    //   return Container();
    // }
    // if (pubkey != null && pubkey != widget.pubkey) {
    //   // arg changed! reset
    //   contactList = null;
    //   zapEventBox = null;
    //   followedMap = null;
    //
    //   length = 0;
    //   relaysNum = 0;
    //   followedTagsLength = 0;
    //   followedCommunitiesLength = 0;
    //   zapNum = null;
    //   followedNum = null;
    // }
    // pubkey = widget.pubkey;

    List<Widget> list = [];

    // if (isLocal) {
    //   list.add(
    //       Selector<ContactListProvider, int>(builder: (context, num, child) {
    //     return UserStatisticsItemComponent(
    //       num: num,
    //       name: s.Following,
    //       onTap: onFollowingTap,
    //       onLongPressStart: onLongPressStart,
    //       onLongPressEnd: onLongPressEnd,
    //     );
    //   }, selector: (context, _provider) {
    //     return relayMap.length;
    //   }));
    // } else {
    if (contactList != null) {
      length = contactList!.contacts.length;
    }
    list.add(UserStatisticsItemComponent(
        num: length, name: s.Following, onTap: onFollowingTap));
    // }

    list.add(UserStatisticsItemComponent(
      num: followedNum ?? 0,
      name: s.Followers,
      onTap: () {
        if (followedMap != null) {
          var pubkeys = followedMap!.keys.toList();
          RouterUtil.router(context, RouterPath.FOLLOWED, pubkeys);
        }
      },
      formatNum: true,
    ));

    list.add(UserStatisticsItemComponent(
      num: zapNum ?? 0,
      name: "Zap",
      onTap: () {
        if (zapEventBox != null) {
          zapEventBox!.sort();
          var list = zapEventBox!.all();
          RouterUtil.router(context, RouterPath.USER_ZAP_LIST, list);
        }
      },
      formatNum: true,
    ));

    // if (isLocal) {
    //   list.add(Selector<RelayProvider, int>(builder: (context, num, child) {
    //     return UserStatisticsItemComponent(
    //         num: num, name: s.Relays, onTap: onRelaysTap);
    //   }, selector: (context, _provider) {
    //     return _provider.total();
    //   }));
    // } else {
    list.add(UserStatisticsItemComponent(
        num: relayMap.length, name: s.Relays, onTap: onRelaysTap));
    // }

    // if (isLocal) {
    //   list.add(
    //       Selector<ContactListProvider, int>(builder: (context, num, child) {
    //     return UserStatisticsItemComponent(
    //       num: num,
    //       name: s.Followed_Tags,
    //       onTap: onFollowedTagsTap,
    //     );
    //   }, selector: (context, _provider) {
    //     return _provider.totalFollowedTags();
    //   }));
    // } else {
    list.add(UserStatisticsItemComponent(
        num: contactList != null ? contactList!.followedTags.length : 0,
        name: s.Followed_Tags,
        onTap: onFollowedTagsTap));
    // }

    // if (isLocal) {
    //   list.add(
    //       Selector<ContactListProvider, int>(builder: (context, num, child) {
    //     return UserStatisticsItemComponent(
    //       num: num,
    //       name: s.Followed_Communities,
    //       onTap: onFollowedCommunitiesTap,
    //     );
    //   }, selector: (context, _provider) {
    //     return contactList!=null? contactList!.followedCommunities.length : 0;
    //   }));
    // } else {
    list.add(UserStatisticsItemComponent(
        num: contactList != null ? contactList!.followedCommunities.length : 0,
        name: s.Followed_Communities,
        onTap: onFollowedCommunitiesTap));
    // }

    return Container(
      margin: const EdgeInsets.only(bottom: Base.BASE_PADDING),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: list,
      ),
    );
  }

  String? fetchLocalContactsId;

  EventMemBox? localContactBox;

  void onLongPressStart(LongPressStartDetails d) {
    if (fetchLocalContactsId == null) {
      fetchLocalContactsId = StringUtil.rndNameStr(16);
      localContactBox = EventMemBox(sortAfterAdd: false);
      // var filter = Filter(
      //     authors: [widget.pubkey], kinds: [kind.EventKind.CONTACT_LIST]);
      // TODO use dart_ndk
      // widget.userNostr!.query([filter.toJson()], (event) {
      //   localContactBox!.add(event);
      // }, id: fetchLocalContactsId);
      BotToast.showText(text: I18n.of(context).Begin_to_load_Contact_History);
    }
  }

  Future<void> onLongPressEnd(LongPressEndDetails d) async {
    if (fetchLocalContactsId != null) {
      // widget.userNostr!.unsubscribe(fetchLocalContactsId!);
      fetchLocalContactsId = null;

      var format = FixedDateTimeFormatter("YYYY-MM-DD hh:mm:ss");

      localContactBox!.sort();
      var list = localContactBox!.all();

      List<EnumObj> enumList = [];
      for (var event in list) {
        var _contactList = ContactList.fromJson(event.tags);
        var dt = DateTime.fromMillisecondsSinceEpoch(event.createdAt * 1000);
        enumList.add(
            EnumObj(event, "${format.encode(dt)} (${_contactList.total()})"));
      }

      var result = await EnumSelectorComponent.show(context, enumList);
      if (result != null) {
        var event = result.value as Event;
        var _contactList = ContactList.fromJson(event.tags);
        RouterUtil.router(
            context, RouterPath.USER_HISTORY_CONTACT_LIST, _contactList);
      }
    }
  }

  String queryId = "";

  String queryId2 = "";

  @override
  Future<void> onReady(BuildContext context) async {
    // if (!isLocal) {
    // relayProvider.initStaticForRelaysAndMetadataNostr(widget.pubkey);
    // List<Future> futures = staticForRelaysAndMetadataNostr!.allRelays().map((e) => e.future!,).toList();
    //
    // await Future.wait(futures).onError((error, stackTrace) {return List.of([]);}).then((sockets) async {
    //   await relayProvider.getRelays(widget.pubkey, (relays) async {
    //     if (!_disposed) {
    //       await relayProvider.getContacts(widget.pubkey, (contacts) {
    //         if (!_disposed) {
    //           if (widget.onContactListLoaded != null && contacts != null) {
    //             widget.onContactListLoaded!(contacts!);
    //           }
    //           setState(() {
    //             contactList = contacts;
    //             this.relays = relays;
    //             relaysNum = relays.length;
    //           });
    //           onFollowedTap();
    //           onZapTap();
    //         }
    //       });
    //     }
    //   });
    // });
    // loadContactList(widget.userNostr ?? nostr!);
    // }
  }

  // void loadContactList(Nostr targetNostr) {
  //   queryId = StringUtil.rndNameStr(16);
  //   var filter = Filter(
  //       authors: [widget.pubkey],
  //       limit: 1,
  //       kinds: [kind.EventKind.CONTACT_LIST]);
  //   targetNostr.query([filter.toJson()], (event) {
  //     // BotToast.showText(text: "loaded contact list from "+event.sources.toString()+" with ${event.tags.length} contacts");
  //
  //     if (((contactListEvent != null &&
  //                 event.createdAt > contactListEvent!.createdAt) ||
  //             contactListEvent == null) &&
  //         !_disposed) {
  //       setState(() {
  //         contactListEvent = event;
  //         contactList = CustContactList.fromJson(contactListEvent!.tags);
  //         if (widget.onContactListLoaded != null && contactList != null) {
  //           widget.onContactListLoaded!(contactList!);
  //         }
  //       });
  //       onFollowedTap();
  //       onZapTap();
  //     }
  //   }, id: queryId, onComplete: () {});
  // }

  onFollowingTap() {
    if (contactList != null) {
      RouterUtil.router(context, RouterPath.USER_CONTACT_LIST, contactList);
    } else if (isLocal) {
      var cl = contactListProvider.nip02ContactList;
      if (cl != null) {
        RouterUtil.router(context, RouterPath.USER_CONTACT_LIST, cl);
      }
    }
  }

  onFollowedTagsTap() {
    if (contactList != null) {
      RouterUtil.router(context, RouterPath.FOLLOWED_TAGS_LIST, contactList);
    } else if (isLocal) {
      var cl = contactListProvider.nip02ContactList;
      if (cl != null) {
        RouterUtil.router(context, RouterPath.FOLLOWED_TAGS_LIST, cl);
      }
    }
  }

  String followedSubscribeId = "";

  StreamSubscription<Nip01Event>? _followersSubscription;

  onFollowedTap() async {
    if (followedMap == null) {
      followedMap = {};

      Filter filter =
          Filter(kinds: [Nip02ContactList.kind], pTags: [widget.pubkey]);

      Stream<Nip01Event> stream = await relayManager.requestRelays(
          feedRelaySet!.map.keys.toList()
            ..addAll(myInboxRelays!.map.keys.toList()),
          filter,
          idleTimeout: 10);
      _followersSubscription = stream.listen((event) {
        var oldEvent = followedMap![event.pubKey];
        if (oldEvent == null || event.createdAt > oldEvent.createdAt) {
          followedMap![event.pubKey] = event;
          if (!_disposed) {
            setState(() {
              followedNum = followedMap!.length;
            });
          }
        }
      });

      followedNum = 0;
    }
  }

  onRelaysTap() {
    if (relayMap.isNotEmpty) {
      List<RelayMetadata> relays = relayMap.entries
          .map((entry) => RelayMetadata.full(
              url: entry.key,
              read: entry.value.isRead,
              write: entry.value.isWrite,
              count: 0))
          .toList();
      RouterUtil.router(context, RouterPath.USER_RELAYS, relays);
    } else if (isLocal) {
      RouterUtil.router(context, RouterPath.RELAYS);
    }
  }

  String zapSubscribeId = "";

  onZapTap() async {
    // if (zapEventBox == null) {
    //   zapEventBox = EventMemBox(sortAfterAdd: false);
    //   // pull zap event
    //   // var filter = Filter(kinds: [kind.EventKind.ZAP], p: [widget.pubkey]);
    //   zapSubscribeId = StringUtil.rndNameStr(12);
    //   Stream<Nip01Event> stream = await relayManager.requestRelays(
    //       feedRelayMap.keys.toList(),
    //       Filter(kinds: [kind.EventKind.ZAP], pTags: [widget.pubkey]));
    //   stream.listen(
    //     (event) {
    //       // print(filter);
    //       // TODO use dart_ndk
    //       // staticForRelaysAndMetadataNostr!.query([filter.toJson()], (event) {
    //       if (event.kind == kind.EventKind.ZAP && zapEventBox!.add(event)) {
    //         if (!_disposed) {
    //           setState(() {
    //             zapNum = zapNum! + ZapNumUtil.getNumFromZapEvent(event);
    //           });
    //         }
    //       }
    //     },
    //     // id: zapSubscribeId
    //   );
    //
    //   zapNum = 0;
    // } else {
    //   // Router to vist list
    // }
  }

  @override
  void dispose() {
    super.dispose();
    if (_followersSubscription != null) {
      _followersSubscription!.cancel();
    }
    _disposed = true;
    // checkAndUnsubscribe(queryId);
    // checkAndUnsubscribe(queryId2);
    // checkAndUnsubscribe(zapSubscribeId);
  }

  void checkAndUnsubscribe(String queryId) {
    // if (StringUtil.isNotBlank(queryId) && widget.userNostr != null) {
    //   try {
    //     widget.userNostr!.unsubscribe(queryId);
    //   } catch (e) {}
    // }
  }

  bool _disposed = false;

  onFollowedCommunitiesTap() {
    if (contactList != null) {
      RouterUtil.router(context, RouterPath.FOLLOWED_COMMUNITIES, contactList);
    } else if (isLocal) {
      var cl = contactListProvider.nip02ContactList;
      if (cl != null) {
        RouterUtil.router(context, RouterPath.FOLLOWED_COMMUNITIES, cl);
      }
    }
  }
}

class UserStatisticsItemComponent extends StatelessWidget {
  int? num;

  String name;

  Function onTap;

  bool formatNum;

  Function(LongPressStartDetails)? onLongPressStart;

  Function(LongPressEndDetails)? onLongPressEnd;

  UserStatisticsItemComponent({
    required this.num,
    required this.name,
    required this.onTap,
    this.formatNum = false,
    this.onLongPressStart,
    this.onLongPressEnd,
  });

  @override
  Widget build(BuildContext context) {
    var themeData = Theme.of(context);
    var hintColor = themeData.hintColor;
    var fontSize = themeData.textTheme.bodyLarge!.fontSize;

    List<Widget> list = [];
    if (num != null) {
      var numStr = num.toString();
      if (formatNum) {
        numStr = NumberFormatUtil.format(num!);
      }

      list.add(Text(
        numStr,
        style: TextStyle(
          fontSize: fontSize,
        ),
      ));
    }
    list.add(Container(
      margin: EdgeInsets.only(left: 4),
      child: Text(
        name,
        style: TextStyle(
          color: hintColor,
          fontSize: fontSize,
        ),
      ),
    ));

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        onTap();
      },
      onLongPressStart: onLongPressStart,
      onLongPressEnd: onLongPressEnd,
      child: Container(
        margin: EdgeInsets.only(left: Base.BASE_PADDING),
        child: Row(children: list),
      ),
    );
  }
}
