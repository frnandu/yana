import 'dart:convert';

import 'package:bot_toast/bot_toast.dart';
import 'package:convert/convert.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yana/models/relay_status.dart';
import 'package:yana/provider/contact_list_provider.dart';
import 'package:yana/provider/relay_provider.dart';
import 'package:yana/ui/enum_selector_component.dart';
import 'package:yana/utils/base_consts.dart';
import 'package:yana/utils/client_connected.dart';

import '../../i18n/i18n.dart';
import '../../main.dart';
import '../../models/event_mem_box.dart';
import '../../nostr/event.dart';
import '../../nostr/event_kind.dart' as kind;
import '../../nostr/filter.dart';
import '../../nostr/nip02/cust_contact_list.dart';
import '../../nostr/nip57/zap_num_util.dart';
import '../../nostr/nostr.dart';
import '../../nostr/relay.dart';
import '../../nostr/relay_metadata.dart';
import '../../ui/cust_state.dart';
import '../../utils/base.dart';
import '../../utils/number_format_util.dart';
import '../../utils/router_path.dart';
import '../../utils/router_util.dart';
import '../../utils/string_util.dart';

class UserStatisticsComponent extends StatefulWidget {
  String pubkey;

  Function(CustContactList)? onContactListLoaded;

  UserStatisticsComponent(
      {super.key, required this.pubkey, this.onContactListLoaded});

  @override
  State<StatefulWidget> createState() {
    return _UserStatisticsComponent();
  }
}

class _UserStatisticsComponent extends CustState<UserStatisticsComponent> {
  Event? contactListEvent;

  CustContactList? contactList;

  Event? relaysEvent;

  List<RelayMetadata>? relays;

  EventMemBox? zapEventBox;

  // followedMap
  Map<String, Event>? followedMap;

  int length = 0;
  int relaysNum = 0;
  int followedTagsLength = 0;
  int followedCommunitiesLength = 0;
  int? zapNum;
  int? followedNum;

  bool isLocal = false;

  String? pubkey;

  @override
  void initState() {
    if (!isLocal) {
      doQuery();
    }
  }

  @override
  Widget doBuild(BuildContext context) {
    var s = I18n.of(context);
    if (pubkey != null && pubkey != widget.pubkey) {
      // arg changed! reset
      contactListEvent = null;
      contactList = null;
      relaysEvent = null;
      relays = null;
      zapEventBox = null;
      followedMap = null;

      length = 0;
      relaysNum = 0;
      followedTagsLength = 0;
      followedCommunitiesLength = 0;
      zapNum = null;
      followedNum = null;
    }
    pubkey = widget.pubkey;

    isLocal = widget.pubkey == nostr!.publicKey;

    List<Widget> list = [];

    if (isLocal) {
      list.add(
          Selector<ContactListProvider, int>(builder: (context, num, child) {
        return UserStatisticsItemComponent(
          num: num,
          name: s.Following,
          onTap: onFollowingTap,
          onLongPressStart: onLongPressStart,
          onLongPressEnd: onLongPressEnd,
        );
      }, selector: (context, _provider) {
        return _provider.total();
      }));
    } else {
      if (contactList != null) {
        length = contactList!.list().length;
      }
      list.add(UserStatisticsItemComponent(
          num: length, name: s.Following, onTap: onFollowingTap));
    }

    list.add(UserStatisticsItemComponent(
      num: followedNum??0,
      name: s.Followers,
      onTap: onFollowedTap,
      formatNum: true,
    ));

    list.add(UserStatisticsItemComponent(
      num: zapNum??0,
      name: "Zap",
      onTap: onZapTap,
      formatNum: true,
    ));

    if (isLocal) {
      list.add(Selector<RelayProvider, int>(builder: (context, num, child) {
        return UserStatisticsItemComponent(
            num: num, name: s.Relays, onTap: onRelaysTap);
      }, selector: (context, _provider) {
        return _provider.total();
      }));
    } else {
      if (relays != null) {
        relaysNum = relays!.length;
      }
      list.add(UserStatisticsItemComponent(
          num: relaysNum, name: s.Relays, onTap: onRelaysTap));
    }

    if (isLocal) {
      list.add(
          Selector<ContactListProvider, int>(builder: (context, num, child) {
        return UserStatisticsItemComponent(
          num: num,
          name: s.Followed_Tags,
          onTap: onFollowedTagsTap,
        );
      }, selector: (context, _provider) {
        return _provider.totalFollowedTags();
      }));
    } else {
      if (contactList != null) {
        followedTagsLength = contactList!.tagList().length;
      }
      list.add(UserStatisticsItemComponent(
          num: followedTagsLength,
          name: s.Followed_Tags,
          onTap: onFollowedTagsTap));
    }

    if (isLocal) {
      list.add(
          Selector<ContactListProvider, int>(builder: (context, num, child) {
        return UserStatisticsItemComponent(
          num: num,
          name: s.Followed_Communities,
          onTap: onFollowedCommunitiesTap,
        );
      }, selector: (context, _provider) {
        return _provider.totalfollowedCommunities();
      }));
    } else {
      if (contactList != null) {
        followedCommunitiesLength =
            contactList!.followedCommunitiesList().length;
      }
      list.add(UserStatisticsItemComponent(
          num: followedCommunitiesLength,
          name: s.Followed_Communities,
          onTap: onFollowedCommunitiesTap));
    }

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
      var filter = Filter(
          authors: [widget.pubkey], kinds: [kind.EventKind.CONTACT_LIST]);
      nostr!.query([filter.toJson()], (event) {
        localContactBox!.add(event);
      }, id: fetchLocalContactsId);
      BotToast.showText(text: I18n.of(context).Begin_to_load_Contact_History);
    }
  }

  Future<void> onLongPressEnd(LongPressEndDetails d) async {
    if (fetchLocalContactsId != null) {
      nostr!.unsubscribe(fetchLocalContactsId!);
      fetchLocalContactsId = null;

      var format = FixedDateTimeFormatter("YYYY-MM-DD hh:mm:ss");

      localContactBox!.sort();
      var list = localContactBox!.all();

      List<EnumObj> enumList = [];
      for (var event in list) {
        var _contactList = CustContactList.fromJson(event.tags);
        var dt = DateTime.fromMillisecondsSinceEpoch(event.createdAt * 1000);
        enumList.add(
            EnumObj(event, "${format.encode(dt)} (${_contactList.total()})"));
      }

      var result = await EnumSelectorComponent.show(context, enumList);
      if (result != null) {
        var event = result.value as Event;
        var _contactList = CustContactList.fromJson(event.tags);
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
    //   doQuery();
    // }
    onFollowedTap();
    onZapTap();
  }

  void doQuery() {
    // {
    //   queryId = StringUtil.rndNameStr(16);
    //   var filter = Filter(
    //       authors: [widget.pubkey],
    //       limit: 1,
    //       kinds: [kind.EventKind.CONTACT_LIST]);
    //   nostr!.query([filter.toJson()], (event) {
    //     if (((contactListEvent != null &&
    //                 event.createdAt > contactListEvent!.createdAt) ||
    //             contactListEvent == null) &&
    //         !_disposed) {
    //       setState(() {
    //         contactListEvent = event;
    //         contactList = CustContactList.fromJson(event.tags);
    //         if (widget.onContactListLoaded != null && contactList != null) {
    //           widget.onContactListLoaded!(contactList!);
    //         }
    //       });
    //     }
    //   }, id: queryId, onComplete: () {
    //
    //   });
    // }

    {
      queryId2 = StringUtil.rndNameStr(16);
      var filter = Filter(
          authors: [widget.pubkey],
          limit: 1,
          kinds: [kind.EventKind.RELAY_LIST_METADATA]);
      nostr!.query(
          [filter.toJson()],
          (event) {
            // BotToast.showText(text: "loaded relay list from "+event.sources.toString()+" with ${event.tags.length} relays");
            if (((relaysEvent != null &&
                        event.createdAt > relaysEvent!.createdAt) ||
                    relaysEvent == null) &&
                !_disposed) {
              Nostr targetNostr = Nostr(publicKey: widget.pubkey);
              List<RelayMetadata>? relays = [];
              for (var tag in event.tags) {
                if (tag is List<dynamic>) {
                  var length = tag.length;
                  bool write = true;
                  bool read = true;
                  if (length > 1) {
                    var name = tag[0];
                    var value = tag[1];
                    if (name == "r") {
                      if (length > 2) {
                        var operType = tag[2];
                        if (operType == "read") {
                          write = false;
                        } else if (operType == "write") {
                          read = false;
                        }
                      }
                      relays!.add(RelayMetadata(value, read, write));
                      // RelayStatus status = RelayStatus(value);
                      // status.connected = ClientConneccted.CONNECTED;
                      // targetNostr.addRelay(Relay(value,status), checkInfo: false);
                    }
                  }
                }
              }
              setState(() {
                relaysEvent = event;
                this.relays = relays;
              });
            }
          },
          id: queryId2,
          // onComplete: () {
          //   loadContactList(nostr!);
          // }
    );
    }
    loadContactList(nostr!);
  }

  void loadContactList(Nostr targetNostr) {
    queryId = StringUtil.rndNameStr(16);
    var filter = Filter(
        authors: [widget.pubkey],
        limit: 1,
        kinds: [kind.EventKind.CONTACT_LIST]);
    targetNostr.query(
        [filter.toJson()],
        (event) {
          // BotToast.showText(text: "loaded contact list from "+event.sources.toString()+" with ${event.tags.length} contacts");

          if (((contactListEvent != null &&
                      event.createdAt > contactListEvent!.createdAt) ||
                  contactListEvent == null) &&
              !_disposed) {
            setState(() {
              contactListEvent = event;
              contactList = CustContactList.fromJson(contactListEvent!.tags);
              if (widget.onContactListLoaded != null && contactList != null) {
                widget.onContactListLoaded!(contactList!);
              }
            });
          }
          if (((relaysEvent != null &&
              event.createdAt > relaysEvent!.createdAt) ||
              relaysEvent == null) && StringUtil.isNotBlank(event.content) &&
              !_disposed) {
            Map<String,dynamic> json = jsonDecode(event.content);
            relaysEvent = event;
            List<RelayMetadata>? relays = [];
            for (var entry in json.entries) {
              bool write=true;
              bool read=true;
              write = entry.value["write"];
              read = entry.value["read"];
              relays!.add(RelayMetadata(entry.key.toString(), read, write));
            }
            setState(() {
              relaysEvent = event;
              this.relays = relays;
            });
          }
        },
        id: queryId,
        onComplete: () {
        });
  }

  onFollowingTap() {
    if (contactList != null) {
      RouterUtil.router(context, RouterPath.USER_CONTACT_LIST, contactList);
    } else if (isLocal) {
      var cl = contactListProvider.contactList;
      if (cl != null) {
        RouterUtil.router(context, RouterPath.USER_CONTACT_LIST, cl);
      }
    }
  }

  onFollowedTagsTap() {
    if (contactList != null) {
      RouterUtil.router(context, RouterPath.FOLLOWED_TAGS_LIST, contactList);
    } else if (isLocal) {
      var cl = contactListProvider.contactList;
      if (cl != null) {
        RouterUtil.router(context, RouterPath.FOLLOWED_TAGS_LIST, cl);
      }
    }
  }

  String followedSubscribeId = "";

  onFollowedTap() {
    if (followedMap == null) {
      // load data
      followedMap = {};
      // pull zap event
      Map<String, dynamic> filter = {};
      filter["kinds"] = [kind.EventKind.CONTACT_LIST];
      filter["#p"] = [widget.pubkey];
      followedSubscribeId = StringUtil.rndNameStr(12);
      nostr!.query([filter], (e) {
        var oldEvent = followedMap![e.pubKey];
        if (oldEvent == null || e.createdAt > oldEvent.createdAt) {
          followedMap![e.pubKey] = e;
          if (!_disposed) {
            setState(() {
              followedNum = followedMap!.length;
            });
          }
        }
      }, id: followedSubscribeId);

      followedNum = 0;
    } else {
      // jump to see
      var pubkeys = followedMap!.keys.toList();
      RouterUtil.router(context, RouterPath.FOLLOWED, pubkeys);
    }
  }

  onRelaysTap() {
    if (relays != null && relays!.isNotEmpty) {
      RouterUtil.router(context, RouterPath.USER_RELAYS, relays);
    } else if (isLocal) {
      RouterUtil.router(context, RouterPath.RELAYS);
    }
  }

  String zapSubscribeId = "";

  onZapTap() {
    if (zapEventBox == null) {
      zapEventBox = EventMemBox(sortAfterAdd: false);
      // pull zap event
      var filter = Filter(kinds: [kind.EventKind.ZAP], p: [widget.pubkey]);
      zapSubscribeId = StringUtil.rndNameStr(12);
      // print(filter);
      nostr!.query([filter.toJson()], (event) {
        if (event.kind == kind.EventKind.ZAP && zapEventBox!.add(event)) {
          if (!_disposed) {
            setState(() {
              zapNum = zapNum! + ZapNumUtil.getNumFromZapEvent(event);
            });
          }
        }
      }, id: zapSubscribeId);

      zapNum = 0;
    } else {
      // Router to vist list
      zapEventBox!.sort();
      var list = zapEventBox!.all();
      RouterUtil.router(context, RouterPath.USER_ZAP_LIST, list);
    }
  }

  @override
  void dispose() {
    super.dispose();

    _disposed = true;
    checkAndUnsubscribe(queryId);
    checkAndUnsubscribe(queryId2);
    checkAndUnsubscribe(zapSubscribeId);
    checkAndUnsubscribe(followedSubscribeId);
  }

  void checkAndUnsubscribe(String queryId) {
    if (StringUtil.isNotBlank(queryId)) {
      try {
        nostr!.unsubscribe(queryId);
      } catch (e) {}
    }
  }

  bool _disposed = false;

  onFollowedCommunitiesTap() {
    if (contactList != null) {
      RouterUtil.router(context, RouterPath.FOLLOWED_COMMUNITIES, contactList);
    } else if (isLocal) {
      var cl = contactListProvider.contactList;
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
