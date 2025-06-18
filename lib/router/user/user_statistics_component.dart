import 'dart:async';

import 'package:convert/convert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:ndk/entities.dart';
import 'package:ndk/ndk.dart';
import 'package:yana/utils/base_consts.dart';

import '../../i18n/i18n.dart';
import '../../main.dart';
import '../../models/event_mem_box.dart';
import '../../nostr/event_kind.dart';
import '../../nostr/nip57/zap_num_util.dart';
import '../../nostr/relay_metadata.dart';
import '../../ui/cust_state.dart';
import 'package:go_router/go_router.dart';

import '../../utils/base.dart';
import '../../utils/number_format_util.dart';
import '../../utils/router_path.dart';
import '../../utils/string_util.dart';

class UserStatisticsComponent extends StatefulWidget {
  String pubkey;

  Function(ContactList)? onContactListLoaded;

  UserStatisticsComponent(
      {super.key, required this.pubkey, this.onContactListLoaded});

  @override
  State<StatefulWidget> createState() {
    return _UserStatisticsComponent();
  }
}

class _UserStatisticsComponent extends CustState<UserStatisticsComponent> {
  static const Duration REFRESH_METADATA_DURATION = Duration(minutes: 60);

  EventMemBox? zapEventBox;
  UserRelayList? userRelayList;
  ContactList? contactList;

  // followedMap
  Map<String, Nip01Event>? followedMap;

  int length = 0;
  int relaysNum = 0;
  int? zapNum;
  int? followedNum;

  bool isLocal = false;

  @override
  void initState() {
    isLocal = widget.pubkey == loggedUserSigner!.getPublicKey();
    // if (isLocal && widget.userNostr == null) {
    //   widget.userNostr = nostr;
    // }
    // if (!isLocal && widget.userNostr != null) {
    //   loadContactList(widget.userNostr!);
    // }
    load();
  }

  void load() async {
    refreshContactListIfNeededAsync(widget.pubkey);
    await ndk.userRelayLists.loadMissingRelayListsFromNip65OrNip02(
        [widget.pubkey],
        forceRefresh: true).then(
      (value) async {
        userRelayList = await cacheManager.loadUserRelayList(widget.pubkey);
        contactList = await cacheManager.loadContactList(widget.pubkey);
        if (!_disposed) {
          setState(() {
            if (widget.onContactListLoaded != null && contactList != null) {
              widget.onContactListLoaded!(contactList!);
            }
          });
        }
      },
    );
    if (loggedUserSigner != null &&
        loggedUserSigner!.getPublicKey() == widget.pubkey) {
      queryFollowers();
      queryZaps();
    }
  }

  void refreshContactListIfNeededAsync(String pubkey) async {
    contactList = await cacheManager.loadContactList(pubkey);
    int sometimeAgo = DateTime.now()
            .subtract(REFRESH_METADATA_DURATION)
            .millisecondsSinceEpoch ~/
        1000;
    if (contactList == null ||
        contactList!.loadedTimestamp == null ||
        contactList!.loadedTimestamp! < sometimeAgo) {
      ndk.follows.getContactList(pubkey, forceRefresh: true).then(
        (newContactList) {
          if (newContactList != null &&
              (contactList == null ||
                  (contactList!.createdAt < newContactList.createdAt))) {
            if (widget.onContactListLoaded != null && newContactList != null) {
              widget.onContactListLoaded!(newContactList!);
            }
            if (!_disposed) {
              setState(() {
                contactList = newContactList;
              });
            }
          }
        },
      );
    } else {
      if (!_disposed) {
        setState(() {});
      }
    }
  }

  @override
  Widget doBuild(BuildContext context) {
    var s = I18n.of(context);

    List<Widget> list = [];

    if (contactList != null) {
      length = contactList!.contacts.length;
    }
    list.add(UserStatisticsItemComponent(
        num: length, name: s.Following, onTap: onFollowingTap));
    // }

    if (loggedUserSigner != null &&
        loggedUserSigner!.getPublicKey() == widget.pubkey) {
      list.add(UserStatisticsItemComponent(
        num: followedNum ?? 0,
        name: s.Followers,
        onTap: () {
          if (followedMap != null) {
            var pubkeys = followedMap!.keys.toList();
            context.go(RouterPath.FOLLOWED, extra: pubkeys);
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
            context.go(RouterPath.USER_ZAP_LIST, extra: list);
          }
        },
        formatNum: true,
      ));
    }
    list.add(UserStatisticsItemComponent(
        num: userRelayList != null ? userRelayList!.relays.length : 0,
        name: s.Relays,
        onTap: onRelaysTap));

    list.add(UserStatisticsItemComponent(
        num: contactList != null && contactList!.followedTags != null
            ? contactList!.followedTags!.length
            : 0,
        name: s.Followed_Tags,
        onTap: onFollowedTagsTap));

    list.add(UserStatisticsItemComponent(
        num: contactList != null && contactList!.followedCommunities != null
            ? contactList!.followedCommunities!.length
            : 0,
        name: s.Followed_Communities,
        onTap: onFollowedCommunitiesTap));

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
      // widget.userNostr!.query([filter.toMap()], (event) {
      //   localContactBox!.add(event);
      // }, id: fetchLocalContactsId);
      EasyLoading.show(status: I18n.of(context).Begin_to_load_Contact_History);
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
      // for (var event in list) {
      //   var _contactList = ContactList.fromJson(event.tags);
      //   var dt = DateTime.fromMillisecondsSinceEpoch(event.createdAt * 1000);
      //   enumList.add(
      //       EnumObj(event, "${format.encode(dt)} (${_contactList.total()})"));
      // }
      //
      // var result = await EnumSelectorComponent.show(context, enumList);
      // if (result != null) {
      //   var event = result.value as Event;
      //   var _contactList = ContactList.fromJson(event.tags);
      //   context.go(RouterPath.USER_HISTORY_CONTACT_LIST,
      //       extra: _contactList);
      // }
    }
  }

  String queryId = "";

  String queryId2 = "";

  @override
  Future<void> onReady(BuildContext context) async {}

  onFollowingTap() {
    if (contactList != null) {
      context.go(RouterPath.USER_CONTACT_LIST, extra: widget.pubkey);
    } else if (isLocal) {
      var cl =
          contactListProvider?.getContactList(loggedUserSigner!.getPublicKey());
      if (cl != null) {
        context.go(RouterPath.USER_CONTACT_LIST, extra: widget.pubkey);
      }
    }
  }

  onFollowedTagsTap() {
    if (contactList != null) {
      context.go(RouterPath.FOLLOWED_TAGS_LIST, extra: contactList);
    } else if (isLocal) {
      var cl =
          contactListProvider?.getContactList(loggedUserSigner!.getPublicKey());
      if (cl != null) {
        context.go(RouterPath.FOLLOWED_TAGS_LIST, extra: cl);
      }
    }
  }

  String followedSubscribeId = "";

  NdkResponse? _followersSubscription;
  NdkResponse? _zapsSubscription;

  queryFollowers() async {
    if (followedMap == null) {
      followedMap = {};

      Filter filter =
          Filter(kinds: [ContactList.kKind], pTags: [widget.pubkey]);

      _followersSubscription = ndk.requests.query(
        //ndk.relays.bootstrapRelays.toList()
        //   ..addAll(myInboxRelaySet!.urls),
        name: "user-stats-followers",
        timeout: const Duration(seconds: 60),
        filters: [filter],
        relaySet: myInboxRelaySet!,
      );
      _followersSubscription!.stream.listen((event) {
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
    if (userRelayList != null && userRelayList!.relays.isNotEmpty) {
      List<RelayMetadata> relays = userRelayList!.relays.entries
          .map((entry) => RelayMetadata.full(
              url: entry.key,
              read: entry.value.isRead,
              write: entry.value.isWrite,
              count: 0))
          .toList();
      context.go(RouterPath.USER_RELAYS, extra: relays);
    } else if (isLocal) {
      context.go(RouterPath.RELAYS);
    }
  }

  queryZaps() async {
    if (zapEventBox == null) {
      zapEventBox = EventMemBox(sortAfterAdd: false);
      // pull zap event
      _zapsSubscription = ndk.requests.query(
        //ndk.relays.bootstrapRelays.toList()
        //   ..addAll(myInboxRelaySet!.urls),
        name: "zap-receipts",
        filters: [
          Filter(kinds: [EventKind.ZAP_RECEIPT], pTags: [widget.pubkey])
        ],
        timeout: const Duration(seconds: 60),
        relaySet: myInboxRelaySet!,
      );
      _zapsSubscription!.stream.listen(
        (event) {
          if (event.kind == EventKind.ZAP_RECEIPT &&
              zapEventBox!.add(event, returnTrueOnNewSources: false)) {
            if (!_disposed) {
              setState(() {
                zapNum = zapNum! + ZapNumUtil.getNumFromZapEvent(event);
              });
            }
          }
        },
      );

      zapNum = 0;
    } else {
      // Router to vist list
    }
  }

  // @override
  // void deactivate() {
  //   super.deactivate();
  //   if (_followersSubscription != null) {
  //     ndk.relays.closeSubscription(_followersSubscription!.requestId);
  //     _followersSubscription=null;
  //   }
  //   if (_zapsSubscription != null) {
  //     ndk.relays.closeSubscription(_zapsSubscription!.requestId);
  //     _zapsSubscription=null;
  //   }
  // }

  @override
  void dispose() {
    super.dispose();
    _disposed = true;
    if (_followersSubscription != null) {
      ndk.requests.closeSubscription(_followersSubscription!.requestId);
      _followersSubscription = null;
    }
    if (_zapsSubscription != null) {
      ndk.requests.closeSubscription(_zapsSubscription!.requestId);
      _zapsSubscription = null;
    }
  }

  bool _disposed = false;

  onFollowedCommunitiesTap() {
    if (contactList != null) {
      context.go(RouterPath.FOLLOWED_COMMUNITIES, extra: contactList);
    } else if (isLocal) {
      var cl =
          contactListProvider?.getContactList(loggedUserSigner!.getPublicKey());
      if (cl != null) {
        context.go(RouterPath.FOLLOWED_COMMUNITIES, extra: cl);
      }
    }
  }

  onFollowedTap() {
    if (contactList != null) {
      context.go(RouterPath.USER_CONTACT_LIST, extra: widget.pubkey);
    } else if (isLocal) {
      var cl =
          contactListProvider?.getContactList(loggedUserSigner!.getPublicKey());
      if (cl != null) {
        context.go(RouterPath.USER_CONTACT_LIST, extra: widget.pubkey);
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
