import 'dart:convert';

import 'package:dart_ndk/entities.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:yana/ui/zap_gen_dialog.dart';

import '../../i18n/i18n.dart';
import '../../main.dart';
import '../../models/event_reactions.dart';
import '../../nostr/event_kind.dart';
import '../../nostr/event_relation.dart';
import '../../nostr/nip19/nip19.dart';
import '../../nostr/nip19/nip19_tlv.dart';
import '../../nostr/nip57/zap_action.dart';
import '../../provider/event_reactions_provider.dart';
import '../../router/edit/editor_router.dart';
import '../../utils/number_format_util.dart';
import '../../utils/router_path.dart';
import '../../utils/router_util.dart';
import '../../utils/string_util.dart';
import '../editor/cust_embed_types.dart';
import '../event_delete_callback.dart';
import '../event_reply_callback.dart';

class EventReactionsComponent extends StatefulWidget {
  ScreenshotController screenshotController;

  Nip01Event event;

  EventRelation eventRelation;

  Function? onMuteProfile;

  bool showDetailBtn;

  EventReactionsComponent({
    required this.screenshotController,
    required this.event,
    required this.eventRelation,
    this.showDetailBtn = true,
    this.onMuteProfile
  });

  @override
  State<StatefulWidget> createState() {
    return _EventReactionsComponent();
  }
}

class _EventReactionsComponent extends State<EventReactionsComponent> {
  EventReactions? eventReactions;
  bool zapping = false;
  bool muting = false;

  @override
  Widget build(BuildContext context) {
    var _eventReactionsProvider = Provider.of<EventReactionsProvider>(context);

    var s = I18n.of(context);
    var themeData = Theme.of(context);
    var fontSize = themeData.textTheme.bodyMedium!.fontSize!;
    var mediumFontSize = themeData.textTheme.bodyMedium!.fontSize;
    var popFontStyle = TextStyle(
      fontSize: mediumFontSize,
    );

    return Selector<EventReactionsProvider, EventReactions?>(
      builder: (context, eventReactions, child) {
        int replyNum = 0;
        int repostNum = 0;
        int likeNum = 0;
        int zapNum = 0;
        Color likeColor = themeData.hintColor;
        Color repostColor = themeData.hintColor;
        Color replyColor = themeData.hintColor;
        Color zapColor = themeData.hintColor;
        // && widget.event.pubKey == loggedUserSigner!.getPublicKey()

        if (eventReactions != null) {
          replyNum = eventReactions.replies.length;
          repostNum = eventReactions.repostNum;
          likeNum = eventReactions.likeNum;
          zapNum = eventReactions.zapNum;
          this.eventReactions = eventReactions;
          if (eventReactions.hasMyReply) {
            replyColor = themeData.primaryColor;
          }
          if (eventReactions.hasMyRepost) {
            repostColor = themeData.primaryColor;
          }
          if (eventReactions.myLikeEvents != null &&
              eventReactions.myLikeEvents!.isNotEmpty) {
            likeColor = Colors.red;
          }
          if (eventReactions.hasMyZap) {
            zapColor = Colors.orange;
          }
        }
        // TODO should reaction if only 1 kind
        //String? reaction = eventReactions?.reaction;

        return Container(
          margin: const EdgeInsets.only(top:10),
          height: 40,
          child: Row(
            children: [
              Expanded(
                  child: EventReactionNumComponent(
                num: replyNum,
                iconData: Icons.mode_comment_outlined,
                onTap: onCommmentTap,
                color: replyNum > 0 ? replyColor : themeData.disabledColor,
                fontSize: fontSize,
              )),
              // Expanded(
              //     child: EventReactionNumComponent(
              //   num: repostNum,
              //   iconData: Icons.repeat,
              //   onTap: onRepostTap,
              //   color: hintColor,
              //   fontSize: fontSize,
              // )),
              Expanded(
                child: PopupMenuButton<String>(
                  tooltip: s.Repost,
                  itemBuilder: (context) {
                    return [
                      PopupMenuItem(
                        value: "repost",
                        child: Text(s.Repost),
                      ),
                      PopupMenuItem(
                        value: "quote",
                        child: Text(s.Quote),
                      ),
                    ];
                  },
                  onSelected: onRepostTap,
                  child: EventReactionNumComponent(
                    num: repostNum,
                    iconData: Icons.repeat,
                    color:
                        repostNum > 0 ? repostColor : themeData.disabledColor,
                    fontSize: fontSize,
                  ),
                ),
              ),
              Expanded(
                  child: EventReactionNumComponent(
                num: likeNum,
                iconData: Icons.favorite_border,
                onTap: onLikeTap,
                color: likeNum > 0 ? likeColor : themeData.disabledColor,
                fontSize: fontSize,
              )),
              Expanded(
                child: PopupMenuButton<int>(
                  tooltip: "Zap",
                  itemBuilder: (context) {
                    return [
                      PopupMenuItem(
                        value: 21,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.bolt, color: Colors.orange),
                            Text(" Zap 21", style: popFontStyle)
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 69,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.bolt, color: Colors.orange),
                            Text(" Zap 69", style: popFontStyle)
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 210,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.bolt, color: Colors.orange),
                            Text(" Zap 210", style: popFontStyle)
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 420,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.bolt, color: Colors.orange),
                            Text(" Zap 420", style: popFontStyle)
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 2100,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.bolt, color: Colors.orange),
                            Text(" Zap 2100", style: popFontStyle)
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 4200,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.bolt, color: Colors.orange),
                            Text(" Zap 4200", style: popFontStyle)
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: -1,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.bolt, color: Colors.orange),
                            Text(" ${s.Custom}", style: popFontStyle)
                          ],
                        ),
                      ),
                    ];
                  },
                  onSelected: onZapSelect,
                  child: zapping
                      ? SpinKitFadingCircle(
                          color: themeData.disabledColor,
                          size: 20.0,
                        )
                      : EventReactionNumComponent(
                          num: zapNum,
                          iconData: Icons.bolt,
                          onTap: null,
                          onLongPress: genZap,
                          color:
                              zapNum > 0 ? zapColor : themeData.disabledColor,
                          fontSize: fontSize,
                        ),
                ),
              ),
              muting
                  ? SpinKitFadingCircle(
                color: themeData.disabledColor,
                size: 20.0,
              ): Container(
                child: PopupMenuButton<String>(
                  tooltip: s.More,
                  itemBuilder: (context) {
                    List<PopupMenuEntry<String>> list = [
                      PopupMenuItem(
                        value: "copyEvent",
                        child: Text(s.Copy_Note_Json, style: popFontStyle),
                      ),
                      PopupMenuItem(
                        value: "copyPubkey",
                        child: Text(s.Copy_Note_Pubkey, style: popFontStyle),
                      ),
                      PopupMenuItem(
                        value: "copyId",
                        child: Text(s.Copy_Note_Id, style: popFontStyle),
                      ),
                      PopupMenuDivider(),
                    ];

                    if (widget.showDetailBtn) {
                      list.add(PopupMenuItem(
                        value: "detail",
                        child: Text(s.Detail, style: popFontStyle),
                      ));
                    }

                    list.add(PopupMenuDivider());
                    if (widget.eventRelation.pubkey == loggedUserSigner!.getPublicKey()) {
                      list.add(PopupMenuItem(
                        value: "broadcast",
                        child: Text("Re-Broadcast", style: popFontStyle),
                      ));
                    }
                    list.add(PopupMenuItem(
                      value: "share",
                      child: Text(s.Share, style: popFontStyle),
                    ));
                    list.add(PopupMenuItem(
                      value: "mute-public",
                      child: Text("Mute profile (public)", style: popFontStyle),
                    ));
                    list.add(PopupMenuItem(
                      value: "mute-private",
                      child: Text("Mute profile (private)", style: popFontStyle),
                    ));

                    if (widget.event.pubKey == loggedUserSigner!.getPublicKey()) {
                      list.add(PopupMenuDivider());
                      list.add(PopupMenuItem(
                        value: "delete",
                        child: Text(
                          s.Delete,
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: mediumFontSize,
                          ),
                        ),
                      ));
                    }

                    return list;
                  },
                  onSelected: onPopupSelected,
                  child: Icon(
                    Icons.more_horiz,
                    size: 16,
                    color: themeData.disabledColor,
                  ),
                ),
              ),
            ],
          ),
        );
      },
      selector: (context, _provider) {
        return _provider.get(widget.event.id, pubKey: widget.event.pubKey);
      },
      shouldRebuild: (previous, next) {
        if ((previous == null && next != null) ||
            (previous != null &&
                next != null &&
                (previous.replies.length != next.replies.length ||
                    previous.repostNum != next.repostNum ||
                    previous.likeNum != next.likeNum ||
                    previous.zapNum != next.zapNum))) {
          return true;
        }

        return false;
      },
    );
  }

  void onShareTap() {
    var nevent = Nevent(
        id: widget.event.id, relays: widget.event.sources, author: widget.event.pubKey);
    String share = 'https://njump.me/${NIP19Tlv.encodeNevent(nevent).replaceAll("nostr:","")}';
    Share.share(share);
  }

  void onPopupSelected(String value) async {
    if (value == "copyEvent") {
      var text = jsonEncode(widget.event.toJson());
      _doCopy(text);
    } else if (value == "copyPubkey") {
      var text = Nip19.encodePubKey(widget.event.pubKey);
      _doCopy(text);
    } else if (value == "copyId") {
      var text = Nip19.encodeNoteId(widget.event.id);
      _doCopy(text);
    } else if (value == "share") {
      onShareTap();
    } else if (value == "detail") {
      RouterUtil.router(context, RouterPath.EVENT_DETAIL, widget.event);
    } else if (value == "star") {
      // TODO star event
    } else if (value == "broadcast") {
      Set<String> relays = {};
      relays.addAll(myOutboxRelaySet!.urls.toList());
      if (settingProvider.inboxForReactions == 1) {
        List<String> pubKeys = widget.event.pTags;
        if (pubKeys.length == 1) {
          relays.addAll(await getInboxRelays(pubKeys.first));
        } else if (pubKeys.isNotEmpty) {
          EasyLoading.show(status: 'Calculating inbox relays of participants...', maskType: EasyLoadingMaskType.black, dismissOnTap: true);
          RelaySet inboxRelaySet = await relayManager
              .calculateRelaySet(
              name: "replyInboxRelaySet",
              ownerPubKey: loggedUserSigner!.getPublicKey(),
              pubKeys: pubKeys,
              direction: RelayDirection.inbox,
              relayMinCountPerPubKey: settingProvider
                  .broadcastToInboxMaxCount);
          relays.addAll(inboxRelaySet.urls.toSet());
          relays.removeWhere((element) => relayManager.blockedRelays.contains(element));
          EasyLoading.dismiss();
        }
      }
      List<String>? results = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return MultiSelect(items: relays!.toList(), selectedItems: relays!.toList().take(myOutboxRelaySet!.urls.length+settingProvider
              .broadcastToInboxMaxCount).toList(), sending: false,);
        },
      );
      if (results!=null && results.isNotEmpty) {
        // await showDialog(
        //   context: context,
        //   builder: (BuildContext context) {
        //     return MultiSelect(items: results!, selectedItems: [], sending: true,);
        //   },
        // );
        await relayManager.broadcastEvent(widget.event, results, loggedUserSigner!);
        widget.event.sources.addAll(results);
        cacheManager.saveEvent(widget.event);
      }

    } else if (value.startsWith("mute-")) {
      setState(() {
        muting = true;
      });
      Nip51List muteList = await nostr.broadcastAddNip51ListElement(Nip51List.MUTE, Nip51List.PUB_KEY, widget.event.pubKey, myOutboxRelaySet!.urls, loggedUserSigner!, private: value=="mute-private");
      filterProvider.muteList = muteList;
      filterProvider.notifyListeners();
      setState(() {
        muting = false;
      });
      if (widget.onMuteProfile!=null) {
        widget.onMuteProfile!();
      }
      // TODO how to make this event dissapear??
    } else if (value == "delete") {
      setState(() {
        muting = true;
      });

      Set<String> urlsToBroadcast = (await broadcastUrls(widget.event.pubKey)).toSet()..addAll(widget.event.sources);
      await relayManager.reconnectRelays(urlsToBroadcast);
      await nostr!.broadcastDeletion(widget.event.id, urlsToBroadcast, loggedUserSigner!);

      followEventProvider.deleteEvent(widget.event.id);
      notificationsProvider.deleteEvent(widget.event.id);

      var deleteCallback = EventDeleteCallback.of(context);
      if (deleteCallback != null) {
        deleteCallback.onDelete(widget.event);
      }
      if (widget.onMuteProfile!=null) {
        widget.onMuteProfile!();
      }
      setState(() {
        muting = false;
      });
    }
  }

  void _doCopy(String text) {
    Clipboard.setData(ClipboardData(text: text)).then((_) {
      // EasyLoading.show(status: I18n.of(context).Copy_success);
    });
  }

  @override
  void dispose() {
    super.dispose();
    var id = widget.event.id;
    eventReactionsProvider.removePendding(id);
  }

  @override
  void deactivate() {
    super.deactivate();
    var id = widget.event.id;
    eventReactionsProvider.removePendding(id);
  }

  @override
  void activate() {
    super.activate();
    var id = widget.event.id;
    // eventReactionsProvider.removePendding(id);
  }

  Future<void> onCommmentTap() async {
    var er = widget.eventRelation;
    List<dynamic> tags = [];
    List<dynamic> tagsAddedWhenSend = [];
    String relayAddr = "";
    if (widget.event.sources.isNotEmpty) {
      relayAddr = widget.event.sources[0];
    }
    String directMarked = "reply";
    if (StringUtil.isBlank(er.rootId)) {
      directMarked = "root";
    }
    tagsAddedWhenSend.add(["e", widget.event.id, relayAddr, directMarked]);

    List<dynamic> tagPs = [];
    if (widget.event.pubKey!=loggedUserSigner!.getPublicKey()) {
      tagPs.add(["p", widget.event.pubKey]);
    }
    if (er.tagPList.isNotEmpty) {
      for (var p in er.tagPList) {
        if (p!=loggedUserSigner!.getPublicKey()) {
          tagPs.add(["p", p]);
        }
      }
    }
    if (StringUtil.isNotBlank(er.rootId)) {
      String relayAddr = "";
      if (StringUtil.isNotBlank(er.rootRelayAddr)) {
        relayAddr = er.rootRelayAddr!;
      }
      tags.add(["e", er.rootId, relayAddr, "root"]);
    }

    // TODO reply maybe change the placeholder in editor router.
    var event = await EditorRouter.open(context,
        tags: tags, tagsAddedWhenSend: tagsAddedWhenSend, tagPs: tagPs, pubkey:widget.event.pubKey);
    if (event != null) {
      eventReactionsProvider.addEventAndHandle(event);
      var callback = EventReplyCallback.of(context);
      if (callback != null) {
        callback.onReply(event);
      }
    }
  }

  Future<void> onRepostTap(String value) async {
    if (loggedUserSigner!.canSign()) {
      if (value == "repost") {
        String? relayAddr;
        if (widget.event.sources.isNotEmpty) {
          relayAddr = widget.event.sources[0];
        }
        var content = jsonEncode(widget.event.toJson());

        List<dynamic> tag = ["e", widget.event.id];
        if (StringUtil.isNotBlank(relayAddr)) {
          tag.add(relayAddr);
        }
        Nip01Event event = Nip01Event(
            pubKey: loggedUserSigner!.getPublicKey(),
            kind: EventKind.REPOST,
            tags: [tag],
            content: content,
            createdAt: DateTime
                .now()
                .millisecondsSinceEpoch ~/ 1000);
        Iterable<String> urlsToBroadcast = await broadcastUrls(widget.event.pubKey);
        await relayManager.reconnectRelays(urlsToBroadcast);

        await relayManager.broadcastEvent(
            event, urlsToBroadcast, loggedUserSigner!);

        eventReactionsProvider.addRepost(widget.event.id);

      } else if (value == "quote") {
        var event = await EditorRouter.open(context, initEmbeds: [
          quill.CustomBlockEmbed(CustEmbedTypes.mention_event, widget.event.id)
        ]);
      }
    }
  }

  void onLikeTap() async {
    if (loggedUserSigner!.canSign()) {
      Iterable<String> urlsToBroadcast = await broadcastUrls(widget.event.pubKey);
      await relayManager.reconnectRelays(urlsToBroadcast);

      if (eventReactions?.myLikeEvents == null ||
          eventReactions!.myLikeEvents!.isEmpty) {
        // like
        Nip01Event likeEvent = await nostr!.broadcastReaction(
            widget.event.id, urlsToBroadcast, loggedUserSigner!);
        if (likeEvent != null) {
          eventReactionsProvider.addLike(widget.event.id, likeEvent);
        }
      } else {
        for (var event in eventReactions!.myLikeEvents!) {
          await nostr!.broadcastDeletion(
              event.id, urlsToBroadcast, loggedUserSigner!);
        }
        eventReactionsProvider.deleteLike(widget.event.id);
      }
    }
  }

  Future<void> onZapSelect(int sats) async {
    setState(() {
      zapping = true;
    });
    if (sats < 0) {
      genZap();
    } else {
      await ZapAction.handleZap(context, sats, widget.event.pubKey,
          eventId: widget.event.id, onZapped: (success) {
            setState(() {
              zapping = false;
            });
          });
    }
  }

  void genZap() {
    ZapGenDialog.show(context, widget.event.pubKey, eventId: widget.event.id, onZapped: (success) {
      setState(() {
        zapping=false;
      });
    });
  }
}

class EventReactionNumComponent extends StatelessWidget {
  IconData iconData;

  int num;

  GestureTapCallback? onTap;

  GestureLongPressCallback? onLongPress;

  Color color;

  double fontSize;

  EventReactionNumComponent({super.key,
    required this.iconData,
    required this.num,
    this.onTap,
    this.onLongPress,
    required this.color,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    Widget? main;
    var iconWidget = Icon(
      iconData,
      size: 20,
      color: color,
    );
    if (num != 0) {
      String numStr = NumberFormatUtil.format(num);

      main = Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          iconWidget,
          Container(
            margin: const EdgeInsets.only(left: 4),
            child: Text(
              numStr,
              style: TextStyle(color: color, fontSize: fontSize),
            ),
          ),
        ],
      );
    } else {
      main = iconWidget;
    }

    if (onTap != null || onLongPress != null) {
      return GestureDetector(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Container(
          alignment: Alignment.center,
          child: main,
        ),
      );
    } else {
      return Container(
        alignment: Alignment.center,
        child: main,
      );
    }
  }
}
