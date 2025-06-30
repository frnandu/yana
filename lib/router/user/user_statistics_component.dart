import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ndk/entities.dart';
import 'package:ndk/ndk.dart';
import 'package:provider/provider.dart';
import 'package:yana/provider/followers_provider.dart';
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

  int length = 0;
  int? zapNum;

  bool isLocal = false;

  @override
  void initState() {
    super.initState();
    isLocal = widget.pubkey == loggedUserSigner!.getPublicKey();
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

    if (loggedUserSigner != null &&
        loggedUserSigner!.getPublicKey() == widget.pubkey) {
      list.add(Consumer<FollowersProvider>(
        builder: (context, provider, child) {
          return UserStatisticsItemComponent(
            num: provider.followersCount,
            name: s.Followers,
            onTap: () {
              if (provider.followedMap.isNotEmpty) {
                var pubkeys = provider.followedMap.keys.toList();
                context.push(RouterPath.FOLLOWED, extra: pubkeys);
              }
            },
            formatNum: true,
          );
        },
      ));

      list.add(UserStatisticsItemComponent(
        num: zapNum ?? 0,
        name: "Zap",
        onTap: () {
          if (zapEventBox != null) {
            zapEventBox!.sort();
            var list = zapEventBox!.all();
            context.push(RouterPath.USER_ZAP_LIST, extra: list);
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

  @override
  Future<void> onReady(BuildContext context) async {}

  onFollowingTap() {
    if (contactList != null) {
      context.push(RouterPath.USER_CONTACT_LIST, extra: widget.pubkey);
    } else if (isLocal) {
      var cl =
          contactListProvider?.getContactList(loggedUserSigner!.getPublicKey());
      if (cl != null) {
        context.push(RouterPath.USER_CONTACT_LIST, extra: widget.pubkey);
      }
    }
  }

  onFollowedTagsTap() {
    if (contactList != null) {
      context.push(RouterPath.FOLLOWED_TAGS_LIST, extra: contactList);
    } else if (isLocal) {
      var cl =
          contactListProvider?.getContactList(loggedUserSigner!.getPublicKey());
      if (cl != null) {
        context.push(RouterPath.FOLLOWED_TAGS_LIST, extra: cl);
      }
    }
  }

  NdkResponse? _zapsSubscription;

  onRelaysTap() {
    if (userRelayList != null && userRelayList!.relays.isNotEmpty) {
      List<RelayMetadata> relays = userRelayList!.relays.entries
          .map((entry) => RelayMetadata.full(
              url: entry.key,
              read: entry.value.isRead,
              write: entry.value.isWrite,
              count: 0))
          .toList();
      context.push(RouterPath.USER_RELAYS, extra: relays);
    } else if (isLocal) {
      context.push(RouterPath.RELAYS);
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

  @override
  void dispose() {
    super.dispose();
    _disposed = true;
    if (_zapsSubscription != null) {
      ndk.requests.closeSubscription(_zapsSubscription!.requestId);
      _zapsSubscription = null;
    }
  }

  bool _disposed = false;

  onFollowedCommunitiesTap() {
    if (contactList != null) {
      context.push(RouterPath.FOLLOWED_COMMUNITIES, extra: contactList);
    } else if (isLocal) {
      var cl =
          contactListProvider?.getContactList(loggedUserSigner!.getPublicKey());
      if (cl != null) {
        context.push(RouterPath.FOLLOWED_COMMUNITIES, extra: cl);
      }
    }
  }
}

class UserStatisticsItemComponent extends StatelessWidget {
  int? num;

  String name;

  Function onTap;

  bool formatNum;

  UserStatisticsItemComponent({
    required this.num,
    required this.name,
    required this.onTap,
    this.formatNum = false,
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
      child: Container(
        margin: EdgeInsets.only(left: Base.BASE_PADDING),
        child: Row(children: list),
      ),
    );
  }
}
