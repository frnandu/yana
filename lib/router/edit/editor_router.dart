import 'package:ndk/domain_layer/entities/metadata.dart';
import 'package:ndk/domain_layer/entities/nip_01_event.dart';
import 'package:ndk/domain_layer/entities/read_write.dart';
import 'package:ndk/domain_layer/entities/relay_set.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:intl/intl.dart';
import 'package:ndk/shared/helpers/relay_helper.dart';
import 'package:pointycastle/ecc/api.dart';
import 'package:yana/main.dart';
import 'package:yana/nostr/nip172/community_id.dart';
import 'package:yana/router/edit/poll_input_component.dart';
import 'package:yana/router/index/index_app_bar.dart';
import 'package:yana/ui/editor/lnbc_embed_builder.dart';
import 'package:yana/ui/editor/mention_event_embed_builder.dart';
import 'package:yana/ui/editor/mention_user_embed_builder.dart';
import 'package:yana/ui/editor/pic_embed_builder.dart';
import 'package:yana/ui/editor/tag_embed_builder.dart';
import 'package:yana/ui/editor/video_embed_builder.dart';
import 'package:yana/utils/base.dart';
import 'package:yana/utils/router_util.dart';

import '../../i18n/i18n.dart';
import '../../nostr/event_relation.dart';
import '../../ui/cust_state.dart';
import '../../ui/editor/cust_embed_types.dart';
import '../../ui/editor/custom_emoji_embed_builder.dart';
import '../../ui/editor/editor_mixin.dart';
import '../../ui/editor/search_mention_user_component.dart';
import '../../utils/string_util.dart';
import 'editor_notify_item_component.dart';

class EditorRouter extends StatefulWidget {
  static double appbarHeight = 56;

  // dm arg
  ECDHBasicAgreement? agreement;

  // dm arg
  String? pubkey;

  List<List<String>> tags = [];

  List<List<String>> tagsAddedWhenSend = [];

  List<dynamic> tagPs = [];

  int? mentionWordEditingStart;
  int? mentionWordEditingEnd;

  List<quill.BlockEmbed>? initEmbeds;

  EditorRouter({super.key,
    required this.tags,
    required this.tagsAddedWhenSend,
    required this.tagPs,
    this.pubkey,
    this.initEmbeds,
  });

  static Future<Nip01Event?> open(
    BuildContext context, {
    List<List<String>>? tags,
    List<List<String>>? tagsAddedWhenSend,
    List<dynamic>? tagPs,
    String? pubkey,
    List<quill.BlockEmbed>? initEmbeds,
  }) {
    tags ??= [];
    tagsAddedWhenSend ??= [];
    tagPs ??= [];

    var editor = EditorRouter(
      tags: tags,
      tagsAddedWhenSend: tagsAddedWhenSend,
      tagPs: tagPs,
      pubkey: pubkey,
      initEmbeds: initEmbeds,
    );

    return RouterUtil.push(context, MaterialPageRoute(builder: (context) {
      return editor;
    }));
    // return Navigator.push(context, MaterialPageRoute(builder: (context) {
    //   return editor;
    // }));
  }

  @override
  State<StatefulWidget> createState() {
    return _EditorRouter();
  }
}

class _EditorRouter extends CustState<EditorRouter> with EditorMixin {
  List<EditorNotifyItem>? notifyItems;

  List<EditorNotifyItem> editorNotifyItems = [];

  @override
  void initState() {
    super.initState();
    handleFocusInit();
  }

  @override
  Widget doBuild(BuildContext context) {
    if (notifyItems == null) {
      notifyItems = [];
      for (var tagP in widget.tagPs) {
        if (tagP is List<dynamic> && tagP.length > 1) {
          notifyItems!.add(EditorNotifyItem(pubkey: tagP[1]));
        }
      }
    }

    var s = I18n.of(context);
    var themeData = Theme.of(context);
    var scaffoldBackgroundColor = themeData.scaffoldBackgroundColor;
    var mainColor = themeData.primaryColor;
    var hintColor = themeData.hintColor;
    var textColor = themeData.textTheme.bodyMedium!.color;
    var fontSize = themeData.textTheme.bodyMedium!.fontSize;
    var largeTextSize = themeData.textTheme.bodyLarge!.fontSize;

    List<Widget> list = [];

    if (widget.tags.isNotEmpty) {
      for (var tag in widget.tags) {
        if (tag.length > 1) {
          var tagName = tag[0];
          var tagValue = tag[1];

          if (tagName == "a") {
            // this note is add to community
            var aid = CommunityId.fromString(tagValue);
            if (aid != null) {
              list.add(Container(
                padding: const EdgeInsets.only(
                  left: Base.BASE_PADDING,
                  right: Base.BASE_PADDING,
                ),
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(right: Base.BASE_PADDING),
                      child: Icon(
                        Icons.groups,
                        size: largeTextSize,
                        color: hintColor,
                      ),
                    ),
                    Text(
                      aid.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ));
            }
          }
        }
      }
    }

    if ((notifyItems != null && notifyItems!.isNotEmpty) ||
        (editorNotifyItems.isNotEmpty)) {
      List<Widget> tagPsWidgets = [];
      tagPsWidgets.add(Text("${s.Notify}:"));
      for (var item in notifyItems!) {
        tagPsWidgets.add(EditorNotifyItemComponent(item: item));
      }
      for (var editorNotifyItem in editorNotifyItems) {
        var exist = notifyItems!.any((element) {
          return element.pubkey == editorNotifyItem.pubkey;
        });
        if (!exist) {
          tagPsWidgets.add(EditorNotifyItemComponent(item: editorNotifyItem));
        }
      }
      list.add(Container(
        padding:
            EdgeInsets.only(left: Base.BASE_PADDING, right: Base.BASE_PADDING),
        margin: EdgeInsets.only(bottom: Base.BASE_PADDING_HALF),
        width: double.maxFinite,
        child: Wrap(
          spacing: Base.BASE_PADDING_HALF,
          runSpacing: Base.BASE_PADDING_HALF,
          children: tagPsWidgets,
          crossAxisAlignment: WrapCrossAlignment.center,
        ),
      ));
    }

    if (showTitle) {
      list.add(buildTitleWidget());
    }

    if (createdAt != null) {
      var dateFormate = DateFormat("yyyy-MM-dd HH:mm");

      list.add(GestureDetector(
        onTap: selectedTime,
        behavior: HitTestBehavior.translucent,
        child: Container(
          margin: EdgeInsets.only(left: 10, bottom: Base.BASE_PADDING_HALF),
          child: Row(
            children: [
              const Icon(Icons.timer_outlined),
              Container(
                margin: const EdgeInsets.only(left: 4),
                child: Text(
                  dateFormate.format(createdAt!),
                ),
              ),
            ],
          ),
        ),
      ));
    }

    Widget quillWidget = quill.QuillProvider(
        configurations: quill.QuillConfigurations(
          controller: editorController,
        ),
        child: quill.QuillEditor.basic(
            focusNode: focusNode,
            scrollController: ScrollController(),
            configurations: quill.QuillEditorConfigurations(placeholder: s.What_s_happening, embedBuilders: [
              MentionUserEmbedBuilder(),
              MentionEventEmbedBuilder(),
              PicEmbedBuilder(),
              VideoEmbedBuilder(),
              LnbcEmbedBuilder(),
              TagEmbedBuilder(),
              CustomEmojiEmbedBuilder(),
            ])));

    // Widget quillWidget = quill.QuillEditor(
    //   placeholder: s.What_s_happening,
    //   controller: editorController,
    //   scrollController: ScrollController(),
    //   focusNode: focusNode,
    //   readOnly: false,
    //   embedBuilders: [
    //     MentionUserEmbedBuilder(),
    //     MentionEventEmbedBuilder(),
    //     PicEmbedBuilder(),
    //     VideoEmbedBuilder(),
    //     LnbcEmbedBuilder(),
    //     TagEmbedBuilder(),
    //     CustomEmojiEmbedBuilder(),
    //   ],
    //   scrollable: true,
    //   autoFocus: false,
    //   expands: false,
    //   // padding: EdgeInsets.zero,
    //   padding: const EdgeInsets.only(
    //     left: Base.BASE_PADDING,
    //     right: Base.BASE_PADDING,
    //   ),
    // );
    List<Widget> editorList = [];
    var editorInputWidget = Container(
      margin: const EdgeInsets.only(bottom: Base.BASE_PADDING, left: Base.BASE_PADDING, right: Base.BASE_PADDING ),
      child: quillWidget,
    );
    editorList.add(editorInputWidget);
    if (inputPoll) {
      editorList.add(PollInputComponent(
        pollInputController: pollInputController,
      ));
    }

    if (mentionResults != null && mentionResults.isNotEmpty) {
      editorList.add(ListView.builder(
          physics: const BouncingScrollPhysics(),
          shrinkWrap: true,
          itemBuilder: (context, index) {
            return SearchMentionUserItemComponent(
              metadata: mentionResults[index],
              width: 400,
              onTap: (metadata) {
                replaceMentionUser(metadata.pubKey);
              },
            );
          },
          itemCount: mentionResults.length));
    }

    list.add(Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          // focus to eidtor input widget
          focusNode.requestFocus();
        },
        child: Container(
          constraints: BoxConstraints(
              maxHeight: mediaDataCache.size.height -
                  mediaDataCache.padding.top -
                  EditorRouter.appbarHeight -
                  IndexAppBar.height),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: editorList,
            ),
          ),
        ),
      ),
    ));

    list.add(buildEditorBtns());
    if (emojiShow) {
      list.add(buildEmojiSelector());
    }
    if (customEmojiShow) {
      list.add(buildCustomEmojiSelector());
    }

    return Scaffold(
      appBar: AppBar(
        // title: Text("Note"),
        backgroundColor: scaffoldBackgroundColor,
        leading: TextButton(
          onPressed: () {
            RouterUtil.back(context);
          },
          style: const ButtonStyle(),
          child: Icon(
            Icons.arrow_back_ios,
            color: textColor,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Set<String> relays = {};
              relays.addAll(myOutboxRelaySet!.urls.toList());
              if (settingProvider.inboxForReactions == 1) {
                List<String> pubKeys = Nip01Event.getTags(widget.tagPs, "p");
                if (pubKeys.length == 1) {
                  for (var element in (await getInboxRelays(pubKeys.first))) {
                    String? cleanUrl = cleanRelayUrl(element);
                    if (cleanUrl!=null) {
                      relays.add(cleanUrl);
                    }
                  }
                } else if (pubKeys.isNotEmpty) {
                  EasyLoading.show(status: 'Calculating inbox relays of participants...', maskType: EasyLoadingMaskType.black, dismissOnTap: true);
                  RelaySet inboxRelaySet = await ndk
                      .relaySets.calculateRelaySet(
                      name: "replyInboxRelaySet",
                      ownerPubKey: loggedUserSigner!.getPublicKey(),
                      pubKeys: pubKeys,
                      direction: RelayDirection.inbox,
                      relayMinCountPerPubKey: settingProvider
                          .broadcastToInboxMaxCount);
                  inboxRelaySet.urls.forEach((element) {
                    String? cleanUrl = cleanRelayUrl(element);
                    if (cleanUrl!=null) {
                      relays.add(cleanUrl);
                    }
                  });

                  relays.removeWhere((element) =>ndk.relays.globalState.blockedRelays.contains(element));
                  EasyLoading.dismiss();
                }
              }
              // relays.removeWhere((element) => cleanRelayUrl(element)==null);
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
                documentSave(broadcastRelays: results);
              }
            },
            style: const ButtonStyle(),
            child: Text(
              s.Broadcast,
              style: TextStyle(
                color: textColor,
                fontSize: fontSize,
              ),
            ),
          ),
          // PopupMenuButton<String>(
          //     icon: const Icon(Icons.more_horiz_outlined),
          //     tooltip: "more",
          //     itemBuilder: (context) => [
          //       const PopupMenuItem(value: "choose", child: Text("Choose relays...")),
          //     ],
          //     onSelected: (value) async {
          //     })
        ],
      ),
      body: Column(
        children: list,
      ),
    );
  }

  void replaceMentionUser(String? value) {
    if (value != null && value.isNotEmpty && widget.mentionWordEditingStart!=null) {

      final length = widget.mentionWordEditingEnd! - widget.mentionWordEditingStart!;
      final index = editorController.selection.baseOffset;

      editorController.replaceText(index-length, length,
          quill.CustomBlockEmbed(CustEmbedTypes.mention_user, value), null);

      editorController.moveCursorToPosition(index + 1);

      focusNode.requestFocus();

      widget.mentionWordEditingEnd = null;
      widget.mentionWordEditingStart = null;
    }
  }


  @override
  Future<void> onReady(BuildContext context) async {
    if (widget.initEmbeds != null && widget.initEmbeds!.isNotEmpty) {
      {
        final index = editorController.selection.baseOffset;
        final length = editorController.selection.extentOffset - index;

        editorController.replaceText(index, length, "\n", null);

        editorController.moveCursorToPosition(index + 1);
      }

      for (var embed in widget.initEmbeds!) {
        final index = editorController.selection.baseOffset;
        final length = editorController.selection.extentOffset - index;

        editorController.replaceText(index, length, embed, null);

        editorController.moveCursorToPosition(index + 1);
      }

      editorController.moveCursorToPosition(0);
    }

    editorNotifyItems = [];
    editorController.addListener(() async {
      bool updated = false;
      Map<String, int> mentionUserMap = {};

      TextEditingValue value = editorController.plainTextEditingValue;

      var delta = editorController.document.toDelta();
      var operations = delta.toList();
      List<Metadata> list = [];
      for (var operation in operations) {
        if (operation.key == "insert") {
          if (operation.data is Map) {
            var m = operation.data as Map;
            var value = m["mentionUser"];
            if (StringUtil.isNotBlank(value)) {
              mentionUserMap[value] = 1;
            }
          } else if (operation.data is String) {
            String word =
                findPreviousWord(value.text, value.selection.baseOffset);
            if (word != null && (word[0] == "@" || word.length>1 && word[1] == "@")) {
              widget.mentionWordEditingStart = value.selection.baseOffset - word!.length;
              widget.mentionWordEditingEnd = value.selection.baseOffset;
              list = (await cacheManager.searchMetadatas(word.replaceAll("@", ""), 100)).toList();
            } else {
              widget.mentionWordEditingStart = null;
              widget.mentionWordEditingEnd = null;
            }
          }
        }
      }
      if (list.length != mentionResults.length) {
        setState(() {
          mentionResults = list;
        });
      }
      List<EditorNotifyItem> needDeleds = [];
      for (var item in editorNotifyItems!) {
        var exist = mentionUserMap.remove(item.pubkey);
        if (exist == null) {
          updated = true;
          needDeleds.add(item);
        }
      }
      editorNotifyItems!.removeWhere((element) => needDeleds.contains(element));

      if (mentionUserMap.isNotEmpty) {
        var entries = mentionUserMap.entries;
        for (var entry in entries) {
          updated = true;
          editorNotifyItems.add(EditorNotifyItem(pubkey: entry.key));
        }
      }

      if (updated) {
        setState(() {});
      }
    });
  }

  String findPreviousWord(String inputString, int position) {
    if (position <= 0 || position >= inputString.length) {
      return "Position out of bounds or at the beginning of the string.";
    }

    int start = position - 1;
    int end = position;

    // Move backward to find the beginning of the previous word
    while (start > 0 && inputString[start - 1] != ' ' && inputString[start - 1] != '\n') {
      start--;
    }
    return inputString.substring(start, end);
  }

  bool isReply() {
    for (var tag in getTagsAddedWhenSend()) {
      if (tag.length > 1) {
        var key = tag[0];
        var value = tag[1];

        if (key == "e") {
          return true;
        }
      }
    }
    return false;
  }

  Future<void> documentSave({List<String>? broadcastRelays}) async {
    bool reply = isReply();
    if (broadcastRelays==null) {
      if (reply) {
        broadcastRelays = await broadcastUrls(getPubkey());
      }
    }
    broadcastRelays ??= myOutboxRelaySet!.urls.toList();
    // bool? result = await ConfirmDialog.show(context, "Confirm broadcast to ${broadcastRelays.length} outbox relays");
    // if (result != null && result) {
      EasyLoading.showSuccess('Broadcasting to ${broadcastRelays.length} outbox relays...',
          maskType: EasyLoadingMaskType.black, dismissOnTap: true, duration: const Duration(seconds: 5));
      try {
        var event = await doDocumentSave(broadcastRelays: broadcastRelays);
        if (event == null) {
          EasyLoading.showError('Failed...');
          return;
        }
        if (reply) {
          EventRelation relation = EventRelation.fromEvent(event);
          if (relation.rootId != null) {
            eventReactionsProvider.addReply(relation.rootId!, event);
          }
        }
        await cacheManager.saveEvent(event);
        EasyLoading.showSuccess('Success!');
        RouterUtil.back(context, event);
      } finally {
        EasyLoading.dismiss();
      }
    // }
  }

  @override
  BuildContext getContext() {
    return context;
  }

  @override
  void updateUI() {
    setState(() {});
  }

  @override
  ECDHBasicAgreement? getAgreement() {
    return widget.agreement;
  }

  @override
  String? getPubkey() {
    return widget.pubkey;
  }

  @override
  List<List<String>> getTags() {
    return widget.tags;
  }

  @override
  List<List<String>> getTagsAddedWhenSend() {
    if ((notifyItems == null || notifyItems!.isEmpty) &&
        editorNotifyItems.isEmpty) {
      return widget.tagsAddedWhenSend;
    }

    List<List<String>> list = [];
    list.addAll(widget.tagsAddedWhenSend);
    for (var item in notifyItems!) {
      if (item.selected) {
        list.add(["p", item.pubkey]);
      }
    }

    for (var editorNotifyItem in editorNotifyItems) {
      var exist = notifyItems!.any((element) {
        return element.pubkey == editorNotifyItem.pubkey;
      });
      if (!exist) {
        if (editorNotifyItem.selected) {
          list.add(["p", editorNotifyItem.pubkey]);
        }
      }
    }

    return list;
  }

  @override
  bool isDM() {
    return false;
  }
}

class MultiSelect extends StatefulWidget {
  final List<String> items;
  final List<String> selectedItems;
  final bool sending;
  const MultiSelect({Key? key, required this.items, required this.selectedItems, required this.sending}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MultiSelectState();
}

class _MultiSelectState extends State<MultiSelect> {
  // this variable holds the selected items
  List<String> _selectedItems = [];
  bool finished = false;

  @override
  void initState() {
    _selectedItems = widget.selectedItems;
  }
  // This function is triggered when a checkbox is checked or unchecked
  void _itemChange(String itemValue, bool isSelected) {
    setState(() {
      if (isSelected) {
        _selectedItems.add(itemValue);
      } else {
        _selectedItems.remove(itemValue);
      }
    });
  }

  // this function is called when the Cancel button is pressed
  void _cancel() {
    Navigator.pop(context);
  }

// this function is called when the Submit button is tapped
  void _submit() {
    Navigator.pop(context, _selectedItems);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: !widget.sending? const Text('Choose Relays & confirm'): const Text("Broadcasting..."),
      content: SizedBox(height:!widget.sending?400: null, child:SingleChildScrollView(
        child: ListBody(
          children: !widget.sending? widget.items
              .map((item) => CheckboxListTile(
            value: _selectedItems.contains(item),
            title: Text(item.replaceAll("ws://", "").replaceAll("wss://", ""), style: const TextStyle(fontWeight: FontWeight.w200, fontSize: 14)),
            controlAffinity: ListTileControlAffinity.leading,
            onChanged: (isChecked) => _itemChange(item, isChecked!),
          ))
              .toList()
          : widget.items.map((item) => Text(item.replaceAll("ws://", "").replaceAll("wss://", ""))).toList()
        ),
      )),
      actions: !widget.sending ? [
        TextButton(
          onPressed: _cancel,
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: const Text('Broadcast'),
        ),
      ] :
      [
        Text("Sending 1/10")
      ]
      ,
    );
  }
}