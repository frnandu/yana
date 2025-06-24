import 'dart:convert';

import 'package:ndk/entities.dart';
import 'package:ndk/shared/nips/nip25/reactions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yana/ui/content/content_video_component.dart';
import 'package:yana/utils/platform_util.dart';

import '../../i18n/i18n.dart';
import '../../main.dart';
import '../../nostr/event_kind.dart' as kind;
import '../../nostr/event_relation.dart';
import '../../nostr/nip19/nip19.dart';
import '../../nostr/nip19/nip19_tlv.dart';
import '../../nostr/nip23/long_form_info.dart';
import '../../provider/metadata_provider.dart';
import '../../provider/setting_provider.dart';
import '../../utils/base.dart';
import '../../utils/base_consts.dart';
import '../../utils/router_path.dart';
import 'package:go_router/go_router.dart';
import '../../utils/string_util.dart';
import '../confirm_dialog.dart';
import '../content/content_decoder.dart';
import '../content/content_image_component.dart';
import '../content/content_link_component.dart';
import '../content/content_tag_component.dart';
import '../content/markdown/markdown_mention_event_inline_syntax.dart';
import '../content/markdown/markdown_mention_user_inline_syntax.dart';
import '../content/markdown/markdown_nevent_inline_syntax.dart';
import '../content/markdown/markdown_nprofile_inline_syntax.dart';
import '../content/markdown/markdown_nrelay_inline_syntax copy.dart';
import 'event_poll_component.dart';
import 'event_quote_component.dart';
import 'event_reactions_component.dart';
import 'event_top_component.dart';

class EventMainComponent extends StatefulWidget {
  // ScreenshotController screenshotController;

  Nip01Event event;

  String? pagePubkey;

  bool showReplying;

  Function? textOnTap;

  bool showVideo;

  bool imageListMode;

  bool showDetailBtn;

  bool showLongContent;

  bool showSubject;

  bool showReactions;

  bool showCommunity;

  bool addDivider;

  bool highlight;

  bool mutedProfile = false;

  EventRelation? eventRelation;

  EventMainComponent({
    super.key,
    // required this.screenshotController,
    required this.event,
    this.pagePubkey,
    this.showReplying = true,
    this.textOnTap,
    this.showVideo = false,
    this.imageListMode = false,
    this.showDetailBtn = true,
    this.showLongContent = false,
    this.showReactions = true,
    this.showSubject = true,
    this.showCommunity = true,
    this.eventRelation,
    this.addDivider = true,
    this.highlight = false,
  });

  @override
  State<StatefulWidget> createState() {
    return _EventMainComponent();
  }
}

class _EventMainComponent extends State<EventMainComponent> {
  bool showWarning = false;
  List<String> _imageLinks = [];
  final GlobalKey _contentKey = GlobalKey();
  double textHeight = 0;

  bool _isExpanded = false;
  final double _collapsedHeight = 500.0;

  late EventRelation eventRelation;

  List<String> _extractImages(String content) {
    List<String> imageLinks = [];
    RegExp exp = RegExp(r"(https?:\/\/[^\s]+)");
    Iterable<RegExpMatch> matches = exp.allMatches(content);
    for (var match in matches) {
      var link = match.group(0);
      if (link!.endsWith(".jpg") ||
          link.endsWith(".jpeg") ||
          link.endsWith(".png") ||
          link.endsWith(".webp") ||
          link.contains(".avif") ||
          link.contains(".mp4") ||
          link.endsWith(".gif")) {
        imageLinks.add(link);
      }
    }
    return imageLinks;
  }

  void _parseContent() {
    _imageLinks = _extractImages(widget.event.content);
  }

  void _checkIfContentExceedsHeight() {
    // Wait for next frame to ensure rendering is complete

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _parseContent();
      });
      // }
    });
  }
  // void _checkIfContentExceedsHeight() {
  //   // Calculate the total content height
  //   final textHeight = _calculateTextHeight(widget.event.content);
  //   final imageHeight = _imageLinks.isEmpty ? 0 : 200; // Image height + spacing
  //   final totalHeight = textHeight + imageHeight;
  //
  //   // If content exceeds collapsed height, show the button; + image height so post with images get more space
  //   if (totalHeight > _collapsedHeight + imageHeight) {
  //     setState(() {
  //       _shouldShowButton = true;
  //     });
  //   }
  // }

  double _calculateTextHeight(String text) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(color: Color(0xFFE1E8ED), fontSize: 17),
      ),
      maxLines: null,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: MediaQuery.of(context).size.width - 60);

    return textPainter.height;
  }

  @override
  void initState() {
    super.initState();

    // // Check if content needs "Show More" button after first layout
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   if (mounted)
    _checkIfContentExceedsHeight();
    // });

    if (widget.eventRelation == null) {
      eventRelation = EventRelation.fromEvent(widget.event);
    } else {
      eventRelation = widget.eventRelation!;
    }
  }

  @override
  Widget build(BuildContext context) {
    var _settingProvider = Provider.of<SettingProvider>(context);
    if (eventRelation.id != widget.event.id) {
      // change when thread root load lazy
      eventRelation = EventRelation.fromEvent(widget.event);
    }
    if (textHeight == 0) {
      textHeight = _calculateTextHeight(widget.event.content) + 1;
    }

    bool imagePreview = _settingProvider.imagePreview == null ||
        _settingProvider.imagePreview == OpenStatus.OPEN;
    bool videoPreview = widget.showVideo;
    if (_settingProvider.videoPreview != null) {
      videoPreview = _settingProvider.videoPreview == OpenStatus.OPEN;
    }

    var themeData = Theme.of(context);
    var hintColor = themeData.hintColor;
    var smallTextSize = themeData.textTheme.bodySmall!.fontSize;
    var largeTextSize = themeData.textTheme.bodyLarge!.fontSize;
    var mainColor = themeData.primaryColor;

    Color? contentCardColor = themeData.cardColor;
    if (contentCardColor == Colors.white) {
      contentCardColor = Colors.grey[300];
    }
    // if (widget.highlight) {
    //   contentCardColor = Colors.grey[600];
    // }

    Nip01Event? repostEvent;
    if ((widget.event.kind == kind.EventKind.REPOST ||
            widget.event.kind == kind.EventKind.GENERIC_REPOST) &&
        widget.event.content.contains("\"pubkey\"")) {
      try {
        var jsonMap = jsonDecode(widget.event.content);
        repostEvent = Nip01Event.fromJson(jsonMap);

        // set source to repost event
        if (repostEvent.id == eventRelation.rootId &&
            StringUtil.isNotBlank(eventRelation.rootRelayAddr)) {
          repostEvent.sources.add(eventRelation.rootRelayAddr!);
        } else if (repostEvent.id == eventRelation.replyId &&
            StringUtil.isNotBlank(eventRelation.replyRelayAddr)) {
          repostEvent.sources.add(eventRelation.replyRelayAddr!);
        }
      } catch (e) {
        print(e);
      }
    }

    if (_settingProvider.autoOpenSensitive == OpenStatus.OPEN) {
      showWarning = true;
    }
    if (widget.mutedProfile || !filterProvider.filter(widget.event)) {
      return Container();
    }

    List<Widget> list = [];
    if (showWarning || !eventRelation.warning) {
      if (widget.event.kind == kind.EventKind.LONG_FORM) {
        var longFormMargin = EdgeInsets.only(bottom: Base.BASE_PADDING_HALF);

        List<Widget> subList = [];
        var longFormInfo = LongFormInfo.fromEvent(widget.event);
        if (StringUtil.isNotBlank(longFormInfo.title)) {
          subList.add(
            Container(
              margin: longFormMargin,
              child: Text(
                longFormInfo.title!,
                maxLines: 10,
                style: TextStyle(
                  fontSize: largeTextSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        }
        if (longFormInfo.topics.isNotEmpty) {
          List<Widget> topicWidgets = [];
          for (var topic in longFormInfo.topics) {
            topicWidgets.add(ContentTagComponent(tag: "#$topic"));
          }

          subList.add(Container(
            margin: longFormMargin,
            child: Wrap(
              children: topicWidgets,
            ),
          ));
        }
        if (StringUtil.isNotBlank(longFormInfo.summary)) {
          Widget summaryTextWidget = Text(
            longFormInfo.summary!,
            style: TextStyle(
              color: hintColor,
            ),
          );
          subList.add(
            Container(
              width: double.infinity,
              margin: longFormMargin,
              child: summaryTextWidget,
            ),
          );
        }
        if (StringUtil.isNotBlank(longFormInfo.image)) {
          subList.add(Container(
            margin: longFormMargin,
            child: ContentImageComponent(
              imageUrl: longFormInfo.image!,
            ),
          ));
        }

        list.add(
          Container(
            width: double.maxFinite,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: subList,
            ),
          ),
        );

        if (widget.showLongContent) {
          var markdownWidget = buildMarkdownWidget(themeData);

          list.add(Container(
            width: double.infinity,
            child: RepaintBoundary(child: markdownWidget),
          ));
        }

        if (widget.showReactions) {
          list.add(EventReactionsComponent(
            // screenshotController: widget.screenshotController,
            event: widget.event,
            eventRelation: eventRelation,
            showDetailBtn: widget.showDetailBtn,
            onMuteProfile: onMuteProfile,
          ));
        }
      } else if (widget.event.kind == kind.EventKind.REPOST ||
          widget.event.kind == kind.EventKind.GENERIC_REPOST) {
        list.add(Container(
          alignment: Alignment.centerLeft,
          child: Text("Repost"),
        ));
        if (repostEvent != null) {
          list.add(EventQuoteComponent(
            event: repostEvent,
            showReactions: widget.showReactions,
            showVideo: widget.showVideo,
          ));
        } else if (StringUtil.isNotBlank(eventRelation.rootId)) {
          list.add(EventQuoteComponent(
            id: eventRelation.rootId,
            showReactions: widget.showReactions,
            showVideo: widget.showVideo,
          ));
        } else {
          list.add(
            buildContentWidget(_settingProvider, imagePreview, videoPreview),
          );
        }
      } else {
        if (widget.showReplying &&
            eventRelation.tagPList.isNotEmpty &&
            eventRelation.tagEList.isNotEmpty) {
          if (widget.event.kind != Reaction.kKind) {
            var textStyle = TextStyle(
              color: hintColor,
              fontSize: smallTextSize,
            );
            List<Widget> replyingList = [];
            var length = eventRelation.tagPList.length;
            replyingList.add(Text(
              "Replying: ",
              style: textStyle,
            ));
            int maxPTags = 20;
            for (var index = 0; index < length; index++) {
              if (index < maxPTags) {
                var p = eventRelation.tagPList[index];
                var isLast = index < length - 1 ? false : true;
                replyingList.add(EventReplyingcomponent(pubkey: p));
                if (!isLast) {
                  replyingList.add(Text(
                    " & ",
                    style: textStyle,
                  ));
                }
              } else {
                replyingList.add(Text(
                  " ${length - 20} more",
                  style: textStyle,
                ));
                break;
              }
            }
            list.add(Container(
              width: double.maxFinite,
              padding: const EdgeInsets.only(
                bottom: Base.BASE_PADDING_HALF,
              ),
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: replyingList,
              ),
            ));

            if (eventRelation.replyId != null) {
              list.add(EventQuoteComponent(
                id: eventRelation.replyId,
                showReactions: false, //widget.showReactions,
                showVideo: widget.showVideo,
              ));
            } else if (eventRelation.rootId != null) {
              list.add(EventQuoteComponent(
                id: eventRelation.rootId,
                showReactions: false, //widget.showReactions,
                showVideo: widget.showVideo,
              ));
            }
          } else {
            list.add(
              buildContentWidget(_settingProvider, imagePreview, videoPreview),
            );
            if (eventRelation.rootId != null) {
              list.add(EventQuoteComponent(
                id: eventRelation.rootId,
                showReactions: false, //widget.showReactions,
                showVideo: widget.showVideo,
              ));
            }
          }
        } else {
          // hide the reply note subject!
          if (widget.showSubject) {
            if (StringUtil.isNotBlank(eventRelation.subject)) {
              list.add(Container(
                width: double.infinity,
                alignment: Alignment.centerLeft,
                margin: EdgeInsets.only(bottom: Base.BASE_PADDING_HALF),
                child: Text(
                  eventRelation.subject!,
                  maxLines: 10,
                  style: TextStyle(
                    fontSize: largeTextSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ));
            }
          }
        }

        if (widget.event.kind != Metadata.kKind &&
            widget.event.kind != Reaction.kKind) {
          list.add(
            buildContentWidget(_settingProvider, imagePreview, videoPreview),
          );
        }
        if (widget.event.kind == kind.EventKind.POLL) {
          list.add(EventPollComponent(
            event: widget.event,
          ));
        }

        if (widget.event.kind == kind.EventKind.FILE_HEADER) {
          String? m;
          String? url;
          for (var tag in widget.event.tags) {
            if (tag.length > 1) {
              var key = tag[0];
              var value = tag[1];
              if (key == "url") {
                url = value;
              } else if (key == "m") {
                m = value;
              }
            }
          }

          if (StringUtil.isNotBlank(url)) {
            //  show and decode depend m
            if (StringUtil.isNotBlank(m)) {
              if (m!.indexOf("image/") == 0) {
                list.add(ContentImageComponent(imageUrl: url!));
              } else if (m.indexOf("video/") == 0 &&
                  widget.showVideo &&
                  !PlatformUtil.isPC()) {
                list.add(ContentVideoComponent(url: url!));
              } else {
                list.add(ContentLinkComponent(link: url!));
              }
            } else {
              var fileType = ContentDecoder.getPathType(url!);
              if (fileType == "image") {
                list.add(ContentImageComponent(imageUrl: url));
              } else if (fileType == "video" && !PlatformUtil.isPC()) {
                if (settingProvider.videoPreview != OpenStatus.OPEN &&
                    (settingProvider.videoPreview == OpenStatus.OPEN ||
                        widget.showVideo)) {
                  list.add(ContentVideoComponent(url: url));
                } else {
                  list.add(ContentLinkComponent(link: url));
                }
              } else {
                list.add(ContentLinkComponent(link: url));
              }
            }
          }
        }

        final imageHeight =
            _imageLinks.isEmpty ? 0 : 200; // Image height + spacing
        final totalHeight = textHeight + imageHeight;

        final shouldShowButton = totalHeight > _collapsedHeight + imageHeight;

        // Show More button if needed
        // list.add(Text(
        //     "${totalHeight} > ${_collapsedHeight} + ${imageHeight} = ${totalHeight > _collapsedHeight + imageHeight}, shouldShowButton:${shouldShowButton} _isExpanded:${_isExpanded}, imageLinks:$_imageLinks  "));
        if (shouldShowButton) {
          list.add(const SizedBox(height: 8));
          list.add(
            GestureDetector(
              onTap: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  decoration: BoxDecoration(
                    color: themeData.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _isExpanded ? "Show Less" : "Show More",
                    style: TextStyle(
                      color: themeData.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          );
        }

        if (widget.event.kind != kind.EventKind.ZAP_RECEIPT &&
            widget.showReactions) {
          list.add(EventReactionsComponent(
              // screenshotController: widget.screenshotController,
              event: widget.event,
              eventRelation: eventRelation,
              showDetailBtn: widget.showDetailBtn,
              onMuteProfile: onMuteProfile));
        } else {
          list.add(Container(
            height: Base.BASE_PADDING,
          ));
        }
      }
    } else {
      list.add(buildWarningWidget(largeTextSize!, mainColor));
    }

    List<Widget> eventAllList = [];

    if (eventRelation.communityId != null && widget.showCommunity) {
      var communityTitle = Row(
        children: [
          Icon(
            Icons.groups,
            size: largeTextSize,
            color: hintColor,
          ),
          Container(
            margin: const EdgeInsets.only(
              left: Base.BASE_PADDING_HALF,
              right: 3,
            ),
            child: Text(
              "From",
              style: TextStyle(
                color: hintColor,
                fontSize: smallTextSize,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              context.go(RouterPath.COMMUNITY_DETAIL,
                  extra: eventRelation.communityId);
            },
            child: Text(
              eventRelation.communityId!.title,
              style: TextStyle(
                fontSize: smallTextSize,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      );

      eventAllList.add(Container(
        // color: contentCardColor,
        padding: const EdgeInsets.only(
          left: Base.BASE_PADDING + 4,
          right: Base.BASE_PADDING + 4,
          bottom: Base.BASE_PADDING_HALF,
        ),
        child: communityTitle,
      ));
    }
    eventAllList.add(Container(
      // color: contentCardColor,
      padding: const EdgeInsets.only(
        top: Base.BASE_PADDING,
      ),
    ));

    eventAllList.add(EventTopComponent(
      // color: contentCardColor,
      event: widget.event,
      pagePubkey: widget.pagePubkey,
    ));

    eventAllList.add(Container(
      // color: contentCardColor,
      width: double.maxFinite,
      padding: const EdgeInsets.only(
        left: Base.BASE_PADDING,
        right: Base.BASE_PADDING,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: list,
      ),
    ));

    if (widget.addDivider) {
      eventAllList.add(Container(
        color: themeData.disabledColor,
        padding: const EdgeInsets.only(bottom: 1),
      ));
    }

    return Column(
        // mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: eventAllList);
  }

  bool forceShowLongContnet = false;

  bool hideLongContent = false;

  Widget buildContentWidget(
      SettingProvider _settingProvider, bool imagePreview, bool videoPreview) {
    List<Widget> content = ContentDecoder.decode(
      context,
      null,
      widget.event,
      textOnTap: widget.textOnTap,
      showImage: imagePreview,
      showVideo: videoPreview,
      showLinkPreview: _settingProvider.linkPreview == OpenStatus.OPEN,
      imageListMode: widget.imageListMode,
    );
    final imageHeight = _imageLinks.isEmpty ? 0 : 200; // Image height + spacing
    final totalHeight = textHeight + imageHeight;

    final shouldShowButton = totalHeight > _collapsedHeight + imageHeight;

    var main = SizedBox(
        width: double.maxFinite,
        child: ConstrainedBox(
            constraints: BoxConstraints(
                // Only apply max height when not expanded AND content needs to be constrained
                maxHeight: !_isExpanded && shouldShowButton
                    ? _collapsedHeight
                    : double.infinity),
            child: ClipRect(
                // Only clip when not expanded and should show button
                clipBehavior: (!_isExpanded && shouldShowButton)
                    ? Clip.hardEdge
                    : Clip.none,
                child: SingleChildScrollView(
                  physics: NeverScrollableScrollPhysics(),
                  child: Column(
                      key: _contentKey,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: content),
                  // content,
                  // Column(
                  //     crossAxisAlignment: CrossAxisAlignment.start,
                  //     mainAxisSize: MainAxisSize.min,
                  //     children: content,
                ))));

    return main;
  }

  buildMarkdownWidget(ThemeData themeData) {
    // handle old mention, replace to NIP-27 style: nostr:note1xxxx or nostr:npub1xxx
    var content = widget.event.content;
    var tagLength = widget.event.tags.length;
    for (var i = 0; i < tagLength; i++) {
      var tag = widget.event.tags[i];
      String? link;

      if (tag is List && tag.length > 1) {
        var key = tag[0];
        var value = tag[1];
        if (key == "e") {
          link = "nostr:${Nip19.encodeNoteId(value)}";
        } else if (key == "p") {
          link = "nostr:${Nip19.encodePubKey(value)}";
        }
      }

      if (StringUtil.isNotBlank(link)) {
        content = content.replaceAll("#[$i]", link!);
      }
    }

    return MarkdownBody(
      data: content,
      selectable: true,
      // builders: {
      //   MarkdownMentionUserElementBuilder.TAG:
      //       MarkdownMentionUserElementBuilder(),
      //   MarkdownMentionEventElementBuilder.TAG:
      //       MarkdownMentionEventElementBuilder(),
      //   MarkdownNrelayElementBuilder.TAG: MarkdownNrelayElementBuilder(),
      // },
      blockSyntaxes: [],
      inlineSyntaxes: [
        MarkdownMentionEventInlineSyntax(),
        MarkdownMentionUserInlineSyntax(),
        MarkdownNeventInlineSyntax(),
        MarkdownNprofileInlineSyntax(),
        MarkdownNrelayInlineSyntax(),
      ],
      imageBuilder: (Uri uri, String? title, String? alt) {
        if (settingProvider.imagePreview == OpenStatus.CLOSE) {
          return ContentLinkComponent(
            link: uri.toString(),
            title: title,
          );
        }
        return ContentImageComponent(imageUrl: uri.toString());
      },
      styleSheet: MarkdownStyleSheet(
        a: TextStyle(
          color: themeData.highlightColor,
          // decoration: TextDecoration.underline,
        ),
      ),
      onTapLink: (String text, String? href, String title) async {
        // print("text $text href $href title $title");
        if (StringUtil.isNotBlank(href)) {
          if (href!.indexOf("http") == 0) {
            launchUrl(Uri.parse(href), mode: LaunchMode.externalApplication);
            // WebViewRouter.open(context, href);
          } else if (href.indexOf("nostr:") == 0) {
            var link = href.replaceFirst("nostr:", "");
            if (Nip19.isPubkey(link)) {
              // jump user page
              var pubkey = Nip19.decode(link);
              if (StringUtil.isNotBlank(pubkey)) {
                context.push(RouterPath.USER, extra: pubkey);
              }
            } else if (NIP19Tlv.isNprofile(link)) {
              var nprofile = NIP19Tlv.decodeNprofile(link);
              if (nprofile != null) {
                context.push(RouterPath.USER, extra: nprofile.pubkey);
              }
            } else if (Nip19.isNoteId(link)) {
              var noteId = Nip19.decode(link);
              if (StringUtil.isNotBlank(noteId)) {
                context.push(RouterPath.EVENT_DETAIL, extra: noteId);
              }
            } else if (NIP19Tlv.isNevent(link)) {
              var nevent = NIP19Tlv.decodeNevent(link);
              if (nevent != null) {
                context.push(RouterPath.EVENT_DETAIL, extra: nevent.id);
              }
            } else if (NIP19Tlv.isNaddr(link)) {
              var naddr = NIP19Tlv.decodeNaddr(link);
              if (naddr != null) {
                context.push(RouterPath.EVENT_DETAIL, extra: naddr.id);
              }
            } else if (NIP19Tlv.isNrelay(link)) {
              var nrelay = NIP19Tlv.decodeNrelay(link);
              if (nrelay != null) {
                var result = await ConfirmDialog.show(
                    context, I18n.of(context).Add_this_relay_to_local);
                if (result == true) {
                  await relayProvider.addRelay(nrelay.addr);
                }
              }
            }
          }
        }
      },
    );
  }

  Widget buildWarningWidget(double largeTextSize, Color mainColor) {
    var s = I18n.of(context);

    return Container(
      margin:
          EdgeInsets.only(bottom: Base.BASE_PADDING, top: Base.BASE_PADDING),
      width: double.maxFinite,
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.warning),
              Container(
                margin: EdgeInsets.only(left: Base.BASE_PADDING_HALF),
                child: Text(
                  s.Content_warning,
                  style: TextStyle(fontSize: largeTextSize),
                ),
              )
            ],
          ),
          Text(s.This_note_contains_sensitive_content),
          GestureDetector(
            onTap: () {
              setState(() {
                showWarning = true;
              });
            },
            child: Container(
              margin: const EdgeInsets.only(top: Base.BASE_PADDING_HALF),
              padding: const EdgeInsets.only(
                top: 4,
                bottom: 4,
                left: Base.BASE_PADDING,
                right: Base.BASE_PADDING,
              ),
              decoration: BoxDecoration(
                color: mainColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                s.Show,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  onMuteProfile() {
    setState(() {
      widget.mutedProfile = true;
    });
  }
}

class EventReplyingcomponent extends StatefulWidget {
  String pubkey;

  EventReplyingcomponent({required this.pubkey});

  @override
  State<StatefulWidget> createState() {
    return _EventReplyingcomponent();
  }
}

class _EventReplyingcomponent extends State<EventReplyingcomponent> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          context.push(RouterPath.USER, extra: widget.pubkey);
        },
        child: FutureBuilder<Metadata?>(
            future: metadataProvider.getMetadata(widget.pubkey),
            builder: (context, snapshot) {
              var metadata = snapshot.data;
              var themeData = Theme.of(context);
              var hintColor = themeData.hintColor;
              var smallTextSize = themeData.textTheme.bodySmall!.fontSize;
              String nip19Name = Nip19.encodeSimplePubKey(widget.pubkey);
              String displayName = "";

              if (metadata != null) {
                if (StringUtil.isNotBlank(metadata.displayName)) {
                  displayName = metadata.displayName!;
                } else if (StringUtil.isNotBlank(metadata.name)) {
                  displayName = metadata.name!;
                }
              }

              if (StringUtil.isBlank(displayName)) {
                displayName = nip19Name;
              }

              return Text(
                displayName,
                style: TextStyle(
                  color: hintColor,
                  fontSize: smallTextSize,
                  // fontWeight: FontWeight.bold,
                ),
              );
            }));
  }
}
