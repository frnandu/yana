import 'dart:convert';

import 'package:bot_toast/bot_toast.dart';
import 'package:dart_ndk/nips/nip01/event.dart';
import 'package:dart_ndk/nips/nip01/filter.dart';
import 'package:dart_ndk/nips/nip01/metadata.dart';
import 'package:dart_ndk/relay.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yana/models/event_find_util.dart';
import 'package:yana/router/search/search_action_item_component.dart';
import 'package:yana/router/search/search_actions.dart';
import 'package:yana/utils/when_stop_function.dart';

import '../../i18n/i18n.dart';
import '../../main.dart';
import '../../models/event_mem_box.dart';
import '../../nostr/client_utils/keys.dart';
import '../../nostr/event_kind.dart' as kind;
import '../../nostr/nip19/nip19.dart';
import '../../nostr/nip19/nip19_tlv.dart';
import '../../provider/relay_provider.dart';
import '../../provider/setting_provider.dart';
import '../../ui/confirm_dialog.dart';
import '../../ui/cust_state.dart';
import '../../ui/editor/search_mention_user_component.dart';
import '../../ui/event/event_list_component.dart';
import '../../ui/event_delete_callback.dart';
import '../../utils/base_consts.dart';
import '../../utils/load_more_event.dart';
import '../../utils/peddingevents_later_function.dart';
import '../../utils/platform_util.dart';
import '../../utils/router_path.dart';
import '../../utils/router_util.dart';
import '../../utils/string_util.dart';

class SearchRouter extends StatefulWidget {
  const SearchRouter({super.key});

  @override
  State<StatefulWidget> createState() {
    return _SearchRouter();
  }
}

class _SearchRouter extends CustState<SearchRouter>
    with PenddingEventsLaterFunction, LoadMoreEvent, WhenStopFunction {
  TextEditingController controller = TextEditingController();

  ScrollController loadableScrollController = ScrollController();

  ScrollController scrollController = ScrollController();

  FocusNode focusNode = FocusNode();

  @override
  Future<void> onReady(BuildContext context) async {
    bindLoadMoreScroll(loadableScrollController);

    controller.addListener(() {
      var hasText = StringUtil.isNotBlank(controller.text);
      if (!showSuffix && hasText) {
        setState(() {
          showSuffix = true;
        });
        // return;
      } else if (showSuffix && !hasText) {
        setState(() {
          showSuffix = false;
        });
      }

      whenStop(checkInput);
    });
  }

  bool showSuffix = false;

  @override
  Widget doBuild(BuildContext context) {
    var s = I18n.of(context);
    var _settingProvider = Provider.of<SettingProvider>(context);
    var _relayProvider = Provider.of<RelayProvider>(context);
    preBuild();

    Widget? suffixWidget;
    if (showSuffix) {
      suffixWidget = GestureDetector(
        onTap: () {
          controller.text = "";
          focusNode.requestFocus();
        },
        child: Icon(Icons.close),
      );
    } else {
      suffixWidget = !PlatformUtil.isTableMode()
          ? GestureDetector(
              onTap: () {
                handleScanner();
              },
              child: const Icon(Icons.qr_code_scanner),
            )
          : Container();
      //     onTap: handleScanner,
    }

    bool? loadable = true;
    var events = eventMemBox.all();
    // print("contacts: ${metadatasFromCache.length} profile: ${metadatasFromSearch.length} events: ${events.length}");
    Widget body = ListView.builder(
        controller: scrollController,
        itemBuilder: (BuildContext context, int index) {

          Metadata? metadata;

          if (index < metadatasFromCache.length) {
            metadata = metadatasFromCache[index];
          } else if (index < (metadatasFromCache.length + metadatasFromSearch.length) ) {
            metadata = metadatasFromSearch[index - metadatasFromCache.length];
          } else {
            var event = events[index - metadatasFromCache.length - metadatasFromSearch.length];
            if (event.kind == Metadata.KIND) {
              /// TODO use dart_ndk
              // var jsonObj = jsonDecode(event.content);
              // metadata = Metadata.fromJson(jsonObj);
              // metadata.pubKey = event.pubKey;
              // bool inMetadatasAlready = metadatasFromCache.any((element) =>
              // element.pubKey == metadata!.pubKey);
              // if (!metadata.matchesSearch(controller.text) ||
              //     inMetadatasAlready) {
              //   metadata = null;
              // }
            } else {
              return EventListComponent(
                          event: event,
                          showReactions: false,
                          showVideo: _settingProvider.videoPreview == OpenStatus.OPEN,
                        );
            }
          }
          if (metadata!=null && metadata.pubKey!=null) {
            return SearchMentionUserItemComponent(
                metadata: metadata,
                onTap: (metadata) {
                  RouterUtil.router(context, RouterPath.USER, metadata!.pubKey);
                },
                width: 400,
              );
          }
          return Container();
        },
        itemCount: metadatasFromCache.length + metadatasFromSearch.length + events.length);

    if (StringUtil.isBlank(controller.text)) {
      bool anyNip50 = myInboxRelaySet!=null && relayManager.getConnectedRelays(myInboxRelaySet!.urls).any((relay) => relay.info!=null && relay.info!.nips!=null && relay.info!.nips.contains(50));
      if (!anyNip50) {
        body = SearchActionItemComponent(onTap: () {
          RouterUtil.router(context, RouterPath.RELAYS);
        },
            title: "⚠ You have no relays with search capabilities (NIP-50 support).\nConsider adding some (ex.: wss://relay.nostr.band), otherwise ONLY your contacts metadata will be searched.\nClick to relay settings >>");
      }
    }

    // if (searchAction == SearchActions.searchEventFromCache) {
    //   loadable = false;
    //   body = Container(
    //     child: ListView.builder(
    //       controller: scrollController,
    //       itemBuilder: (BuildContext context, int index) {
    //         var event = events[index];
    //
    //         return EventListComponent(
    //           event: event,
    //           showVideo: _settingProvider.videoPreview == OpenStatus.OPEN,
    //         );
    //       },
    //       itemCount: events.length,
    //     ),
    //   );
    // } else if (searchAction == SearchActions.searchPubkeyEvent) {
    //   loadable = true;
    //   var events = eventMemBox.all();
    //   body = Container(
    //     child: ListView.builder(
    //       controller: loadableScrollController,
    //       itemBuilder: (BuildContext context, int index) {
    //         var event = events[index];
    //
    //         return EventListComponent(
    //           event: event,
    //           showVideo: _settingProvider.videoPreview == OpenStatus.OPEN,
    //         );
    //       },
    //       itemCount: itemLength,
    //     ),
    //   );
    // }
    // }
    if (body != null) {
      if (loadable != null && PlatformUtil.isTableMode()) {
        body = GestureDetector(
          onVerticalDragUpdate: (detail) {
            if (loadable == true) {
              loadableScrollController
                  .jumpTo(loadableScrollController.offset - detail.delta.dy);
            } else {
              scrollController
                  .jumpTo(scrollController.offset - detail.delta.dy);
            }
          },
          behavior: HitTestBehavior.translucent,
          child: body,
        );
      }
    } else {
      body = Container();
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: EventDeleteCallback(
        onDeleteCallback: onDeletedCallback,
        child: Container(
          child: Column(children: [
            Container(
              child: TextField(
                // autofocus: true,
                focusNode: focusNode,
                controller: controller,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  // hintText: "contacts, profiles by name, #hashtags",
                  suffixIcon: suffixWidget,
                ),
                onEditingComplete: onEditingComplete,
              ),
            ),
            Expanded(
              child: body,
            ),
          ]),
        ),
      ),
    );
  }

  List<int> searchEventKinds = [
    Nip01Event.TEXT_NODE_KIND,
    kind.EventKind.REPOST,
    kind.EventKind.GENERIC_REPOST,
    kind.EventKind.LONG_FORM,
    kind.EventKind.FILE_HEADER,
    kind.EventKind.POLL,
    Metadata.KIND
  ];

  String? subscribeId;

  EventMemBox eventMemBox = EventMemBox();

  // Filter? filter;
  Map<String, dynamic>? filterMap;

  @override
  void doQuery() {
    preQuery();

    if (subscribeId != null) {
      unSubscribe();
    }
    subscribeId = generatePrivateKey();

    if (!eventMemBox.isEmpty()) {
      List<Relay> activeRelays =
        relayManager.relays.keys.where((url) => relayManager.isRelayConnected(url)).map((url) => relayManager.getRelay(url)!).toList();
      var oldestCreatedAts = eventMemBox.oldestCreatedAtByRelay(activeRelays);
      Map<String, List<Map<String, dynamic>>> filtersMap = {};
      for (var relay in activeRelays) {
        var oldestCreatedAt = oldestCreatedAts.createdAtMap[relay.url];
        if (oldestCreatedAt != null) {
          filterMap!["until"] = oldestCreatedAt;
        }
        Map<String, dynamic> fm = {};
        for (var entry in filterMap!.entries) {
          fm[entry.key] = entry.value;
        }
        filtersMap[relay.url] = [fm];
      }
      // TODO use dart_ndk
      // nostr!.queryByFilters(filtersMap, onQueryEvent, id: subscribeId);
    } else {
      if (until != null) {
        filterMap!["until"] = until;
      }
      // TODO use dart_ndk
      // nostr!.query([filterMap!], onQueryEvent, id: subscribeId);
    }
  }

  void onQueryEvent(Nip01Event event) {
    if (event.kind == Metadata.KIND) {
      var jsonObj = jsonDecode(event.content);
      Metadata metadata = Metadata.fromJson(jsonObj);
      metadata.pubKey = event.pubKey;
      // metadatasFromSearch.add(metadata);
    } else {
      later(event, (list) {
        var addResult = eventMemBox.addList(list);
        if (addResult) {
          setState(() {});
        }
      }, null);
    }
  }

  void unSubscribe() {
    // nostr!.unsubscribe(subscribeId!);
    subscribeId = null;
  }

  void onEditingComplete() {
    // hideKeyBoard();
    searchAction = SearchActions.searchPubkeyEvent;

    var value = controller.text;
    value = value.trim();
    // if (StringUtil.isBlank(value)) {
    //   BotToast.showText(text: S.of(context).Empty_text_may_be_ban_by_relays);
    // }

    List<String>? authors;
    if (StringUtil.isNotBlank(value) && value.indexOf("npub") == 0) {
      try {
        var result = Nip19.decode(value);
        authors = [result];
      } catch (e) {
        print(e.toString());
        // TODO handle error
        return;
      }
    } else {
      if (StringUtil.isNotBlank(value)) {
        authors = [value];
      }
    }

    eventMemBox = EventMemBox();
    until = null;
    filterMap = Filter(kinds: searchEventKinds, authors: authors, limit: queryLimit).toMap();
    filterMap!.remove("search");
    penddingEvents.clear;
    doQuery();
  }

  void hideKeyBoard() {
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
      FocusManager.instance.primaryFocus?.unfocus();
    }
  }

  @override
  EventMemBox getEventBox() {
    return eventMemBox;
  }

  @override
  void dispose() {
    super.dispose();
    disposeLater();
    disposeWhenStop();
  }

  static const int searchMemLimit = 20;

  onDeletedCallback(Nip01Event event) {
    eventMemBox.delete(event.id);
    setState(() {});
  }

  openPubkey() {
    hideKeyBoard();
    var text = controller.text;
    if (StringUtil.isNotBlank(text)) {
      String pubkey = text;
      if (Nip19.isPubkey(text)) {
        pubkey = Nip19.decode(text);
      }

      RouterUtil.router(context, RouterPath.USER, pubkey);
    }
  }

  openNoteId() {
    hideKeyBoard();
    var text = controller.text;
    if (StringUtil.isNotBlank(text)) {
      String noteId = text;
      if (Nip19.isNoteId(text)) {
        noteId = Nip19.decode(text);
      }

      RouterUtil.router(context, RouterPath.EVENT_DETAIL, noteId);
    }
  }

  List<Metadata> metadatasFromCache = [];
  List<Metadata> metadatasFromSearch = [];

  searchMetadataFromCache() {
    // hideKeyBoard();
    metadatasFromCache.clear();
    searchAction = SearchActions.searchMetadataFromCache;

    var text = controller.text;
    if (StringUtil.isNotBlank(text)) {
      var list = metadataProvider.findUser(text, limit: searchMemLimit);

      // setState(() {
      //   metadatasFromCache = list;
      // });
    } else {
      setState(() {});
    }
  }

  List<Nip01Event> events = [];

  searchEventFromCache() {
    hideKeyBoard();
    events.clear();
    searchAction = SearchActions.searchEventFromCache;

    var text = controller.text;
    if (StringUtil.isNotBlank(text)) {
      var list = EventFindUtil.findEvent(text, limit: searchMemLimit);
      setState(() {
        events = list;
      });
    }
  }

  String? searchAction;

  List<String> searchAbles = [];

  String lastText = "";

  checkInput() {
    searchAction = null;
    searchAbles.clear();
    metadatasFromCache.clear();
    metadatasFromSearch.clear();
    eventMemBox.clear();

    var text = controller.text;
    // if (text == lastText) {
    //   return;
    // }

    if (StringUtil.isNotBlank(text)) {
      searchMetadataFromCache();
      if (text.trim().length>=3 && metadatasFromCache.length < 20) {
        searchNoteContent();
      }
      if (Nip19.isPubkey(text)) {
        searchAbles.add(SearchActions.openPubkey);
      }
      if (Nip19.isNoteId(text)) {
        searchAbles.add(SearchActions.openNoteId);
      }
      searchAbles.add(SearchActions.searchMetadataFromCache);
      searchAbles.add(SearchActions.searchEventFromCache);
      searchAbles.add(SearchActions.searchPubkeyEvent);
      searchAbles.add(SearchActions.searchNoteContent);
    }

    lastText = text;
    setState(() {});
  }

  Future<void> handleScanner() async {
    var result = await RouterUtil.router(context, RouterPath.QRSCANNER);
    if (StringUtil.isNotBlank(result)) {
      if (Nip19.isPubkey(result)) {
        var pubkey = Nip19.decode(result);
        RouterUtil.router(context, RouterPath.USER, pubkey);
      } else if (NIP19Tlv.isNprofile(result)) {
        var nprofile = NIP19Tlv.decodeNprofile(result);
        if (nprofile != null) {
          RouterUtil.router(context, RouterPath.USER, nprofile!.pubkey);
        }
      } else if (Nip19.isNoteId(result)) {
        var noteId = Nip19.decode(result);
        RouterUtil.router(context, RouterPath.EVENT_DETAIL, noteId);
      } else if (NIP19Tlv.isNevent(result)) {
        var nevent = NIP19Tlv.decodeNevent(result);
        if (nevent != null) {
          RouterUtil.router(context, RouterPath.EVENT_DETAIL, nevent.id);
        }
      } else if (NIP19Tlv.isNrelay(result)) {
        var nrelay = NIP19Tlv.decodeNrelay(result);
        if (nrelay != null) {
          var result = await ConfirmDialog.show(
              context, I18n.of(context).Add_this_relay_to_local);
          if (result == true) {
            await relayProvider.addRelay(nrelay.addr);
          }
        }
      } else if (result.indexOf("http") == 0) {
        launchUrl(Uri.parse(result), mode: LaunchMode.externalApplication);
        // WebViewRouter.open(context, result);
      } else {
        Clipboard.setData(ClipboardData(text: result)).then((_) {
          BotToast.showText(text: I18n.of(context).Copy_success);
        });
      }
    }
  }

  searchNoteContent() {
    // hideKeyBoard();
    searchAction = SearchActions.searchPubkeyEvent;

    var value = controller.text;
    value = value.trim();
    // if (StringUtil.isBlank(value)) {
    //   BotToast.showText(text: S.of(context).Empty_text_may_be_ban_by_relays);
    // }

    eventMemBox = EventMemBox();
    until = null;
    filterMap = Filter(kinds: searchEventKinds, limit: queryLimit).toMap();
    filterMap!.remove("authors");
    filterMap!["search"] = value;
    penddingEvents.clear;
    doQuery();
  }
}
