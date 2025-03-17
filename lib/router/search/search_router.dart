import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_list_view/flutter_list_view.dart';
import 'package:ndk/ndk.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yana/models/event_find_util.dart';
import 'package:yana/router/search/search_actions.dart';
import 'package:yana/utils/when_stop_function.dart';

import '../../i18n/i18n.dart';
import '../../main.dart';
import '../../models/event_mem_box.dart';
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

  final scrollController = FlutterListViewController();

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
    Widget body = FlutterListView(
        controller: scrollController,
        delegate:
        FlutterListViewDelegate((BuildContext context, int index) {
          Metadata? metadata;

          if (index < metadatasFromCache.length) {
            metadata = metadatasFromCache[index];
          } else if (index <
              (metadatasFromCache.length + metadatasFromSearch.length)) {
            metadata = metadatasFromSearch[index - metadatasFromCache.length];
          } else {
            var event = events[
                index - metadatasFromCache.length - metadatasFromSearch.length];
            if (event.kind == Metadata.kKind) {
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
          if (metadata != null && metadata.pubKey != null) {
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
        childCount: metadatasFromCache.length +
            metadatasFromSearch.length +
            events.length));

    if (StringUtil.isBlank(controller.text)) {
      // bool anyNip50 = myInboxRelaySet!=null &&ndk.relays.getConnectedRelays(myInboxRelaySet!.urls).any((relay) => relay.info!=null && relay.info!.nips!=null && relay.info!.nips.contains(50));
//       if (searchRelays==null || searchRelays.isEmpty) {
//         body = SearchActionItemComponent(onTap: () async {
//           bool finished = false;
//           Future.delayed(const Duration(milliseconds: 500), () {
//             if (!finished) {
//               EasyLoading.show(status: 'Loading relay list...', maskType: EasyLoadingMaskType.black, dismissOnTap: true);
//             }
//           });
//           Nip51List? list = await ndk.relays.getSingleNip51List(Nip51List.SEARCH_RELAYS, loggedUserSigner!);
//           finished = true;
//           EasyLoading.dismiss();
//           RouterUtil.router(context, RouterPath.L, list!=null? list : Nip51List(pubKey: loggedUserSigner!.getPublicKey(), kind: Nip51List.SEARCH_RELAYS, privateRelays: searchRelays, createdAt: Helpers.now));
//         },
//             title: "⚠ Your search relay list is empty.\nAdd some relays >>");
// //            You have no relays with search capabilities (NIP-50 support).\nConsider adding some (ex.: wss://relay.nostr.band), otherwise ONLY your contacts metadata will be searched.\nClick to relay settings >>");
//       }
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
    Nip01Event.kTextNodeKind,
    kind.EventKind.REPOST,
    kind.EventKind.GENERIC_REPOST,
    kind.EventKind.LONG_FORM,
    kind.EventKind.FILE_HEADER,
    kind.EventKind.POLL,
    Metadata.kKind,
    kind.EventKind.COMMUNITY_DEFINITION
  ];

  EventMemBox eventMemBox = EventMemBox();

  Map<String, dynamic>? filterMap;

  @override
  void doQuery() {
    preQuery();
    List<String> relaysWithNip50 = searchRelays.isNotEmpty
        ? searchRelays
        : [
            "wss://relay.nostr.band",
            "wss://relay.noshere.com"
          ]; //!=null? searchRelays.where((url) {
    //   Relay? relay =ndk.relays.getRelay(url);
    //   return relay!=null? relay.supportsNip(50) : false;
    // }).toList() : [];

    if (!eventMemBox.isEmpty()) {
      filterMap!["until"] = eventMemBox.oldestEvent;
    } else {
      if (until != null) {
        filterMap!["until"] = until;
      }
    }
    // RelayManager relayManager = RelayManager();
    //ndk.relays.cacheManager = cacheManager;
    //ndk.relays.connect(urls: relaysWithNip50).then((value) {
    var search = filterMap!["search"];
    NdkResponse response = ndk
        .requests.query(explicitRelays: relaysWithNip50, filters: [Filter.fromMap(filterMap!)]);
    response.stream.listen((event) {
      if (search == controller.text.trim()) {
        onQueryEvent(event);
      }
    });
  }

  void onQueryEvent(Nip01Event event) {
    if (event.kind == Metadata.kKind) {
      var jsonObj = jsonDecode(event.content);
      Metadata metadata = Metadata.fromJson(jsonObj);
      metadata.pubKey = event.pubKey;
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
    // subscribeId = null;
  }

  void onEditingComplete() async {
    // hideKeyBoard();
    searchAction = SearchActions.searchPubkeyEvent;

    var value = controller.text;
    value = value.trim();
    // if (StringUtil.isBlank(value)) {
    //   EasyLoading.show(status: S.of(context).Empty_text_may_be_ban_by_relays);
    // }

    // List<String>? authors;
    // if (StringUtil.isNotBlank(value) && value.indexOf("npub") == 0) {
    //   try {
    //     var result = Nip19.decode(value);
    //     authors = [result];
    //   } catch (e) {
    //     print(e.toString());
    //     // TODO handle error
    //     return;
    //   }
    // } else {
    //   if (StringUtil.isNotBlank(value)) {
    //     authors = [value];
    //   }
    // }

    eventMemBox = EventMemBox();
    until = null;
    filterMap = Filter(kinds: searchEventKinds, limit: queryLimit).toMap();
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

  static const int searchCacheLimit = 20;

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

  searchMetadataFromCache() async {
    // hideKeyBoard();
    metadatasFromCache.clear();
    searchAction = SearchActions.searchMetadataFromCache;

    var text = controller.text;
    if (StringUtil.isNotBlank(text)) {
      var list = await cacheManager.searchMetadatas(text, searchCacheLimit);
      setState(() {
        metadatasFromCache = list.toList();
      });
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
      var list = EventFindUtil.findEvent(text, limit: searchCacheLimit);
      setState(() {
        events = list;
      });
    }
  }

  String? searchAction;

  List<String> searchAbles = [];

  String lastText = "";

  checkInput() async {
    if (lastText == controller.text) {
      return;
    }
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
      await searchMetadataFromCache();
      if (Nip19.isPubkey(text)) {
        searchAbles.add(SearchActions.openPubkey);
        metadatasFromSearch.clear();

        ndk.metadata.loadMetadata(Nip19.decode(text)).then((metadata) {
          setState(() {
            if (metadata != null) {
              metadatasFromSearch = [metadata];
            }
          });
        });
      }
      if (Nip19.isNoteId(text)) {
        searchAbles.add(SearchActions.openNoteId);
      }
      if (text.trim().length >= 3 && metadatasFromCache.length < 20) {
        searchNoteContent();
      }
      // searchAbles.add(SearchActions.searchMetadataFromCache);
      // searchAbles.add(SearchActions.searchEventFromCache);
      // searchAbles.add(SearchActions.searchPubkeyEvent);
      // searchAbles.add(SearchActions.searchNoteContent);
    }

    lastText = text;
    // setState(() {});
  }

  Future<void> handleScanner() async {
    String result = await RouterUtil.router(context, RouterPath.QRSCANNER);
    if (StringUtil.isNotBlank(result)) {
      result = result.replaceAll("nostr:", "");
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
          EasyLoading.show(status: I18n.of(context).Copy_success);
        });
      }
    }
  }

  searchNoteContent() {
    // hideKeyBoard();
    searchAction = SearchActions.searchPubkeyEvent;

    var value = controller.text.trim();
    // value = value.trim();
    // if (StringUtil.isBlank(value)) {
    //   EasyLoading.show(status: S.of(context).Empty_text_may_be_ban_by_relays);
    // }

    eventMemBox = EventMemBox();
    until = null;
    filterMap = Filter(kinds: searchEventKinds, limit: queryLimit).toMap();
    // filterMap!.remove("authors");
    filterMap!["search"] = value;
    penddingEvents.clear;
    doQuery();
  }
}
