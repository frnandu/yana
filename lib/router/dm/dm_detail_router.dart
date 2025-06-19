import 'package:go_router/go_router.dart';
import 'package:ndk/domain_layer/entities/metadata.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:provider/provider.dart';
import 'package:yana/nostr/nip04/dm_session.dart';
import 'package:yana/ui/cust_state.dart';
import 'package:yana/ui/editor/editor_mixin.dart';

import '../../i18n/i18n.dart';
import '../../main.dart';
import '../../provider/dm_provider.dart';
import '../../provider/metadata_provider.dart';
import '../../ui/editor/custom_emoji_embed_builder.dart';
import '../../ui/editor/lnbc_embed_builder.dart';
import '../../ui/editor/mention_event_embed_builder.dart';
import '../../ui/editor/mention_user_embed_builder.dart';
import '../../ui/editor/pic_embed_builder.dart';
import '../../ui/editor/tag_embed_builder.dart';
import '../../ui/editor/video_embed_builder.dart';
import '../../ui/name_component.dart';
import '../../utils/base.dart';
import '../../utils/router_path.dart';
import '../../utils/router_util.dart';
import 'dm_detail_item_component.dart';

class DMDetailRouter extends StatefulWidget {
  const DMDetailRouter({super.key});

  @override
  State<StatefulWidget> createState() {
    return _DMDetailRouter();
  }
}

class _DMDetailRouter extends CustState<DMDetailRouter> with EditorMixin {
  DMSessionDetail? detail;

  String content = '';

  List<String> contacts = [];
  @override
  void initState() {
    super.initState();
    handleFocusInit();
    Future(() async {
      setState(() async {
        contacts = contactListProvider != null
            ? await contactListProvider!.contacts()
            : [];
      });
    });
  }

  @override
  Widget doBuild(BuildContext context) {
    var themeData = Theme.of(context);
    var textColor = themeData.textTheme.bodyMedium!.color;
    var scaffoldBackgroundColor = themeData.scaffoldBackgroundColor;

    var hintColor = themeData.hintColor;
    var s = I18n.of(context);

    var arg = RouterUtil.routerArgs(context);
    if (arg == null) {
      context.pop();
      return Container();
    }
    detail = arg as DMSessionDetail;

    var nameComponnet = FutureBuilder<Metadata?>(
        future: metadataProvider.getMetadata(detail!.dmSession.pubkey),
        builder: (context, snapshot) {
          return GestureDetector(
              onTap: () {
                context.go(RouterPath.USER, extra: detail!.dmSession.pubkey);
              },
              child: NameComponent(
                pubkey: detail!.dmSession.pubkey,
                metadata: snapshot.data,
              ));
        });

    var localPubkey = loggedUserSigner!.getPublicKey();

    List<Widget> list = [];

    var listWidget = Selector<DMProvider, DMSession?>(
      builder: (context, session, child) {
        if (session == null) {
          return Container();
        }

        return ListView.builder(
          itemBuilder: (context, index) {
            var event = session.get(index);
            if (event == null) {
              return null;
            }

            return DMDetailItemComponent(
              sessionPubkey: detail!.dmSession.pubkey,
              event: event,
              isLocal: localPubkey == event.pubKey,
            );
          },
          reverse: true,
          itemCount: session.length(),
          dragStartBehavior: DragStartBehavior.down,
        );
      },
      selector: (context, _provider) {
        return _provider.getSession(detail!.dmSession.pubkey);
      },
    );

    list.add(Expanded(
      child: Container(
        margin: const EdgeInsets.only(
          bottom: Base.BASE_PADDING,
        ),
        child: listWidget,
      ),
    ));

    list.add(Container(
      decoration: BoxDecoration(
        color: scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            offset: Offset(0, -5),
            blurRadius: 10,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(child: Container()
              // quill.QuillProvider(
              //     configurations: quill.QuillConfigurations(
              //       controller: editorController,
              //     ),
              //     child: quill.QuillEditor.basic(
              //         focusNode: focusNode,
              //         scrollController: ScrollController(),
              //         configurations: quill.QuillEditorConfigurations(placeholder: s.What_s_happening, embedBuilders: [
              //           MentionUserEmbedBuilder(),
              //           MentionEventEmbedBuilder(),
              //           PicEmbedBuilder(),
              //           VideoEmbedBuilder(),
              //           LnbcEmbedBuilder(),
              //           TagEmbedBuilder(),
              //           CustomEmojiEmbedBuilder(),
              //         ])))
              // child: quill.QuillEditor(
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
              //   maxHeight: 300,
              // ),
              ),
          TextButton(
            onPressed: send,
            style: const ButtonStyle(),
            child: Text(
              s.Send,
              style: TextStyle(
                color: textColor,
                fontSize: 16,
              ),
            ),
          )
        ],
      ),
    ));

    list.add(buildEditorBtns(showShadow: false, height: null));
    if (emojiShow) {
      list.add(buildEmojiSelector());
    }
    if (customEmojiShow) {
      list.add(buildCustomEmojiSelector());
    }

    Widget main = Container(
      width: double.maxFinite,
      height: double.maxFinite,
      child: Column(children: list),
    );

    if (detail!.info == null && detail!.dmSession.newestEvent != null) {
      if (!contacts.contains(detail!.dmSession.pubkey)) {
        main = SizedBox(
          width: double.maxFinite,
          height: double.maxFinite,
          child: Stack(
            children: [
              Positioned.fill(child: main),
              Positioned(
                child: GestureDetector(
                  onTap: addDmSessionToKnown,
                  child: Container(
                    margin: const EdgeInsets.all(Base.BASE_PADDING),
                    height: 30,
                    width: double.maxFinite,
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Center(
                      child: Text(
                        s.Add_to_known_list,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            context.pop();
          },
          child: Icon(
            Icons.arrow_back_ios,
            color: themeData.appBarTheme.titleTextStyle!.color,
          ),
        ),
        title: nameComponnet,
      ),
      body: main,
    );
  }

  Future<void> send() async {
    var cancelFunc = EasyLoading.show(status: "Sending...");
    try {
      var event = await doDocumentSave();
      if (event == null) {
        EasyLoading.show(status: I18n.of(context).Send_fail);
        return;
      }
      dmProvider!.addEventAndUpdateReadedTime(detail!, event);
      editorController.clear();
      setState(() {});
    } finally {
      EasyLoading.dismiss();
    }
  }

  Future<void> addDmSessionToKnown() async {
    var _detail = await dmProvider!.addDmSessionToKnown(detail!);
    setState(() {
      detail = _detail;
    });
  }

  @override
  Future<void> onReady(BuildContext context) async {
    if (detail != null &&
        // detail!.info != null &&
        detail!.dmSession.newestEvent != null) {
      // detail!.info!.readedTime = detail!.dmSession.newestEvent!.createdAt;
      // DMSessionInfoDB.update(detail!.info!);
      dmProvider!.updateReadedTime(detail);
    }
  }

  // Future<void> jumpToWriteMessage() async {
  //   var pubkey = detail!.dmSession.pubkey;
  //   List<dynamic> tags = [
  //     ["p", pubkey]
  //   ];
  //   var event = await EditorRouter.open(
  //     context,
  //     agreement: agreement,
  //     pubkey: pubkey,
  //     tags: tags,
  //     tagsAddedWhenSend: [],
  //   );
  //   if (event != null) {
  //     dmProvider.addEventAndUpdateReadedTime(detail!, event);
  //     setState(() {});
  //   }
  // }

  @override
  BuildContext getContext() {
    return context;
  }

  @override
  String? getPubkey() {
    return detail!.dmSession.pubkey;
  }

  @override
  List<List<String>> getTags() {
    var pubkey = detail!.dmSession.pubkey;
    List<List<String>> tags = [
      ["p", pubkey]
    ];
    return tags;
  }

  @override
  List<List<String>> getTagsAddedWhenSend() {
    return [];
  }

  @override
  void updateUI() {
    setState(() {});
  }

  @override
  bool isDM() {
    return true;
  }
}
