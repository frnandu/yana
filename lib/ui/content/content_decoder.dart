import 'package:ndk/entities.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../nostr/nip19/nip19.dart';
import '../../nostr/nip19/nip19_tlv.dart';
import '../../provider/setting_provider.dart';
import '../../utils/base.dart';
import '../../utils/base64.dart';
import '../../utils/platform_util.dart';
import '../../utils/string_util.dart';
import '../cust_state.dart';
import '../event/event_quote_component.dart';
import '../event/images_tile_view.dart';
import 'content_custom_emoji_component.dart';
import 'content_event_tag_infos.dart';
import 'content_image_component.dart';
import 'content_link_component.dart';
import 'content_link_pre_component.dart';
import 'content_lnbc_component.dart';
import 'content_mention_user_component.dart';
import 'content_relay_component.dart';
import 'content_tag_component.dart';
import 'content_video_component.dart';

class ContentDecoder {
  static const OTHER_LIGHTNING = "lightning=";

  static const LIGHTNING = "lightning:";

  static const LNBC = "lnbc";

  static const NOTE_REFERENCES = "nostr:";

  static const NOTE_REFERENCES_AT = "@nostr:";

  static const MENTION_USER = "@npub";

  static const MENTION_NOTE = "@note";

  static const LNBC_NUM_END = "1p";

  static String _addToHandledStr(String handledStr, String subStr) {
    if (StringUtil.isBlank(handledStr)) {
      return subStr;
    } else {
      return "$handledStr $subStr";
    }
  }

  // static String _closeHandledStr(String handledStr, List<dynamic> inlines) {
  //   if (StringUtil.isNotBlank(handledStr)) {
  //     inlines.add(Text(handledStr));
  //     // inlines.add(handledStr);
  //   }
  //   return "";
  // }

  static String _closeHandledStr(String handledStr, List<dynamic> inlines) {
    if (StringUtil.isNotBlank(handledStr)) {
      // inlines.add(Text(handledStr));
      inlines.add(handledStr);
    }
    return "";
  }

  static void _closeInlines(List<dynamic> inlines, List<Widget> list, {Function? textOnTap}) {
    if (inlines.isNotEmpty) {
      if (inlines.length == 1) {
        if (inlines[0] is String) {
          // list.add(TextTranslateComponent(
          //   inlines[0],
          //   textOnTap: textOnTap,
          // ));
          list.add(LineTranslateComponent(
            []..add(inlines[0]),
            textOnTap: textOnTap,
          ));
        } else {
          list.add(inlines[0]);
        }
      } else {
        // List<InlineSpan> spans = [];
        // for (var inline in inlines) {
        //   if (inline is String) {
        //     spans.add(WidgetSpan(
        //         child: TextTranslateComponent(
        //       inline + " ",
        //       textOnTap: textOnTap,
        //     )));
        //   } else {
        //     spans.add(WidgetSpan(child: inline));
        //   }
        // }
        // list.add(Text.rich(TextSpan(children: spans)));

        list.add(LineTranslateComponent(
          []..addAll(inlines),
          textOnTap: textOnTap,
        ));
      }
      inlines.clear();
    } else {
      list.add(LineTranslateComponent(
        []..addAll([Container()]),
      ));
    }
  }

  static void _closeInlines2(List<dynamic> inlines, List<Widget> list, {Function? textOnTap}) {
    if (inlines.isNotEmpty) {
      if (inlines.length == 1) {
        if (inlines[0] is String) {
          // list.add(TextTranslateComponent(
          //   inlines[0],
          //   textOnTap: textOnTap,
          // ));
          // list.add(LineTranslateComponent(
          //   []..add(inlines[0]),
          //   textOnTap: textOnTap,
          // ));
        } else {
          list.add(inlines[0]);
        }
      } else {
        List<InlineSpan> spans = [];
        for (var inline in inlines) {
          if (inline is String) {
            //     spans.add(WidgetSpan(
            //         child: TextTranslateComponent(
            //       inline + " ",
            //       textOnTap: textOnTap,
            //     )));
          } else {
            spans.add(WidgetSpan(child: inline));
          }
        }
        list.add(Text.rich(TextSpan(children: spans)));

        // list.add(LineTranslateComponent(
        //   []..addAll(inlines),
        //   textOnTap: textOnTap,
        // ));
      }
      inlines.clear();
    }
  }

  static ContentDecoderInfo _decodeTest(String content) {
    content = content.trim();
    // content = content.replaceAll("\r\n", "\n");
    // content = content.replaceAll("\n\n", "\n");
    var strs = content.split("\n");

    ContentDecoderInfo info = ContentDecoderInfo();
    for (var str in strs) {
      List<dynamic> inlines = [];
      String handledStr = "";

      var subStrs = str.split(" ");
      info.strs.add(subStrs);
      for (var subStr in subStrs) {
        if (subStr.indexOf("http") == 0) {
          // link, image, video etc
          var pathType = getPathType(subStr);
          if (pathType == "image") {
            info.imageNum++;
          }
        }
      }
    }

    return info;
  }

  static List<Widget> decode(
    BuildContext context,
    String? content,
    Nip01Event? event, {
    Function? textOnTap,
    bool showImage = true,
    bool showVideo = false,
    bool showLinkPreview = true,
    bool imageListMode = false,
  }) {
    if (StringUtil.isBlank(content) && event != null) {
      content = event.content;
    }
    List<Widget> list = [];
    List<String> imageList = [];

    var decodeInfo = _decodeTest(content!);
    ContentEventTagInfos? tagInfos;
    if (event != null) {
      tagInfos = ContentEventTagInfos.fromEvent(event);
    }

    for (var subStrs in decodeInfo.strs) {
      List<dynamic> inlines = [];
      String handledStr = "";

      ///
      /// 1、str: add to handledStr
      /// 2、inline: put handledStr to inlines, put currentInline to inlines, new a new handledStr
      /// 3、block: put handledStr to inlines, put inlines to list as a line, put block to list as a line, new a new handledStr
      /// 4、if handledStr not empty, put to inlines, put inlines to list as a line
      ///
      for (var subStr in subStrs) {
        if (subStr.indexOf("http") == 0) {
          // link, image, video etc
          handledStr =
              handleHttpLink(subStr, showImage, imageList, imageListMode, decodeInfo, handledStr, inlines, list, textOnTap, showVideo, showLinkPreview);
        } else if ((subStr.indexOf(NOTE_REFERENCES) == 0 || subStr.indexOf(NOTE_REFERENCES_AT) == 0)) {
          // var key = subStr.replaceFirst(NOTE_REFERENCES_AT, "");
          // key = key.replaceFirst(NOTE_REFERENCES, "");

          handledStr = handleNostrReference(subStr, handledStr, inlines, list, textOnTap, showVideo);
        } else if (subStr.indexOf(MENTION_USER) == 0) {
          var key = subStr.replaceFirst("@", "");
          // inline
          // mention user
          key = Nip19.decode(key);
          handledStr = _closeHandledStr(handledStr, inlines);
          inlines.add(ContentMentionUserComponent(pubkey: key));
        } else if (subStr.indexOf(MENTION_NOTE) == 0) {
          var key = subStr.replaceFirst("@", "");
          // block
          key = Nip19.decode(key);
          handledStr = _closeHandledStr(handledStr, inlines);
          _closeInlines(inlines, list, textOnTap: textOnTap);
          var widget = EventQuoteComponent(
            id: key,
            showVideo: showVideo,
          );
          list.add(widget);
        } else if (subStr.indexOf(LNBC) == 0) {
          // block
          handledStr = _closeHandledStr(handledStr, inlines);
          _closeInlines(inlines, list, textOnTap: textOnTap);
          var w = ContentLnbcComponent(lnbc: subStr);
          list.add(w);
        } else if (subStr.indexOf(LIGHTNING) == 0) {
          // block
          handledStr = _closeHandledStr(handledStr, inlines);
          _closeInlines(inlines, list, textOnTap: textOnTap);
          var w = ContentLnbcComponent(lnbc: subStr);
          list.add(w);
        } else if (subStr.contains(OTHER_LIGHTNING)) {
          // block
          handledStr = _closeHandledStr(handledStr, inlines);
          _closeInlines(inlines, list, textOnTap: textOnTap);
          var w = ContentLnbcComponent(lnbc: subStr);
          list.add(w);
        } else if (subStr.indexOf("#[") == 0 && subStr.length > 3 && event != null) {
          // mention
          var endIndex = subStr.indexOf("]");
          var indexStr = subStr.substring(2, endIndex);
          var index = int.tryParse(indexStr);
          if (index != null && event.tags.length > index) {
            var tag = event.tags[index];
            if (tag.length > 1) {
              var tagType = tag[0];
              if (tagType == "e") {
                // block
                // mention event
                handledStr = _closeHandledStr(handledStr, inlines);
                _closeInlines(inlines, list, textOnTap: textOnTap);
                var widget = EventQuoteComponent(
                  id: tag[1],
                  showVideo: showVideo,
                );
                list.add(widget);
              } else if (tagType == "p") {
                // inline
                // mention user
                handledStr = _closeHandledStr(handledStr, inlines);
                inlines.add(ContentMentionUserComponent(pubkey: tag[1]));
              } else {
                handledStr = _addToHandledStr(handledStr, subStr);
              }
            }
          }
        } else if (subStr.indexOf("#") == 0 && subStr.indexOf("[") != 1 && subStr.length > 1 && subStr.substring(1) != "#") {
          // inline
          // tag
          handledStr = _closeHandledStr(handledStr, inlines);
          inlines.add(ContentTagComponent(tag: subStr));
        } else {
          var length = subStr.length;
          if (length > 2) {
            if (subStr.substring(0, 1) == ":" && subStr.substring(length - 1) == ":" && tagInfos != null) {
              var imagePath = tagInfos.emojiMap[subStr];
              if (StringUtil.isNotBlank(imagePath)) {
                handledStr = _closeHandledStr(handledStr, inlines);
                inlines.add(ContentCustomEmojiComponent(imagePath: imagePath!));
                continue;
              }
            }
          }

          handledStr = _addToHandledStr(handledStr, subStr);
        }
      }

      handledStr = _closeHandledStr(handledStr, inlines);
      _closeInlines(inlines, list, textOnTap: textOnTap);
    }

    // if (imageListMode && decodeInfo.imageNum > 1) {
    //   // showImageList in bottom
    //   List<Widget> imageWidgetList = [];
    //   var index = 0;
    //   for (var image in imageList) {
    //     imageWidgetList.add(SliverToBoxAdapter(
    //       child: Container(
    //         decoration: BoxDecoration(
    //           borderRadius: BorderRadius.circular(10),
    //         ),
    //         margin: const EdgeInsets.only(right: Base.BASE_PADDING_HALF),
    //         width: CONTENT_IMAGE_LIST_HEIGHT,
    //         height: CONTENT_IMAGE_LIST_HEIGHT,
    //         child: ContentImageComponent(
    //           imageUrl: image,
    //           imageList: imageList,
    //           imageIndex: index,
    //           height: CONTENT_IMAGE_LIST_HEIGHT,
    //           width: CONTENT_IMAGE_LIST_HEIGHT,
    //           // imageBoxFix: BoxFit.fitWidth,
    //         ),
    //       ),
    //     ));
    //     index++;
    //   }
    //
    //   list.add(SizedBox(
    //     height: CONTENT_IMAGE_LIST_HEIGHT,
    //     width: double.infinity,
    //     child: CustomScrollView(
    //       slivers: imageWidgetList,
    //       scrollDirection: Axis.horizontal,
    //     ),
    //   ));
    // }
    if (imageList.isNotEmpty) {
      list.add(ImagesTileView(images: imageList));
    }

    return list;
  }

  static String handleNostrReference(String subStr, String handledStr, List<dynamic> inlines, List<Widget> list, Function? textOnTap, bool showVideo) {
    // var key = subStr.replaceFirst(NOTE_REFERENCES_AT, "");
    // key = key.replaceFirst(NOTE_REFERENCES, "");

    RegExpMatch? match = Nip19.nip19regex.firstMatch(subStr);

    if (match != null) {
      var key = match.group(2)! + match.group(3)!;
      String? otherStr;

      if (Nip19.isPubkey(key)) {
        // inline
        // mention user
        if (key.length > Nip19.NPUB_LENGTH) {
          otherStr = key.substring(Nip19.NPUB_LENGTH);
          key = key.substring(0, Nip19.NPUB_LENGTH);
        }
        key = Nip19.decode(key);
        handledStr = _closeHandledStr(handledStr, inlines);
        inlines.add(ContentMentionUserComponent(pubkey: key));
      } else if (Nip19.isNoteId(key)) {
        // block
        if (key.length > Nip19.NOTEID_LENGTH) {
          otherStr = key.substring(Nip19.NOTEID_LENGTH);
          key = key.substring(0, Nip19.NOTEID_LENGTH);
        }
        key = Nip19.decode(key);
        handledStr = _closeHandledStr(handledStr, inlines);
        _closeInlines(inlines, list, textOnTap: textOnTap);
        var widget = EventQuoteComponent(
          id: key,
          showVideo: showVideo,
        );
        list.add(widget);
      } else if (NIP19Tlv.isNprofile(key)) {
        var nprofile = NIP19Tlv.decodeNprofile(key);
        if (nprofile != null) {
          // inline
          // mention user
          handledStr = _closeHandledStr(handledStr, inlines);
          inlines.add(ContentMentionUserComponent(pubkey: nprofile.pubkey));
        } else {
          handledStr = _addToHandledStr(handledStr, subStr);
        }
      } else if (NIP19Tlv.isNrelay(key)) {
        var nrelay = NIP19Tlv.decodeNrelay(key);
        if (nrelay != null) {
          // inline
          handledStr = _closeHandledStr(handledStr, inlines);
          inlines.add(ContentRelayComponent(nrelay.addr));
        } else {
          handledStr = _addToHandledStr(handledStr, subStr);
        }
      } else if (NIP19Tlv.isNevent(key)) {
        var nevent = NIP19Tlv.decodeNevent(key);
        if (nevent != null) {
          // block
          handledStr = _closeHandledStr(handledStr, inlines);
          _closeInlines(inlines, list, textOnTap: textOnTap);
          var widget = EventQuoteComponent(
            id: nevent.id,
            showVideo: showVideo,
          );
          list.add(widget);
        } else {
          handledStr = _addToHandledStr(handledStr, subStr);
        }
      } else if (NIP19Tlv.isNaddr(key)) {
        var naddr = NIP19Tlv.decodeNaddr(key);
        if (naddr != null) {
          if (StringUtil.isNotBlank(naddr.id) && naddr.kind == Nip01Event.kTextNodeKind) {
            // block
            handledStr = _closeHandledStr(handledStr, inlines);
            _closeInlines(inlines, list, textOnTap: textOnTap);
            var widget = EventQuoteComponent(
              id: naddr.id,
              showVideo: showVideo,
            );
            list.add(widget);
          } else if (StringUtil.isNotBlank(naddr.author) && naddr.kind == Metadata.kKind) {
            // inline
            handledStr = _closeHandledStr(handledStr, inlines);
            inlines.add(ContentMentionUserComponent(pubkey: naddr.author));
          } else {
            handledStr = _addToHandledStr(handledStr, subStr);
          }
        } else {
          handledStr = _addToHandledStr(handledStr, subStr);
        }
      } else {
        handledStr = _addToHandledStr(handledStr, subStr);
      }

      if (StringUtil.isNotBlank(otherStr)) {
        handledStr = _addToHandledStr(handledStr, otherStr!);
      }
    }
    return handledStr;
  }

  static String handleHttpLink(String subStr, bool showImage, List<String> imageList, bool imageListMode, ContentDecoderInfo decodeInfo, String handledStr,
      List<dynamic> inlines, List<Widget> list, Function? textOnTap, bool showVideo, bool showLinkPreview) {
    // link, image, video etc
    var pathType = getPathType(subStr);
    if (pathType == "image") {
      if (showImage) {
        imageList.add(subStr);
        if (false && imageListMode && decodeInfo.imageNum > 1) {
          // inline
          handledStr = handledStr.trim();
          var imagePlaceholder = Container(
            margin: const EdgeInsets.only(left: 4),
            child: const Icon(
              Icons.image,
              size: 15,
            ),
          );
          if (StringUtil.isBlank(handledStr) && inlines.isEmpty) {
            // add to pre line
            var listLength = list.length;
            if (listLength > 0) {
              var lastListWidget = list[listLength - 1];
              List<InlineSpan> spans = [];
              if (lastListWidget is SelectableText) {
                if (lastListWidget.data != null) {
                  spans.add(TextSpan(text: lastListWidget.data!));
                } else if (lastListWidget.textSpan != null) {
                  spans.addAll(lastListWidget.textSpan!.children!);
                }
              } else {
                spans.add(WidgetSpan(child: lastListWidget));
              }
              spans.add(WidgetSpan(child: imagePlaceholder));

              list[listLength - 1] = SelectableText.rich(
                TextSpan(children: spans),
                onTap: () {
                  if (textOnTap != null) {
                    textOnTap();
                  }
                },
              );
            }
          } else {
            if (StringUtil.isNotBlank(handledStr)) {
              handledStr = _closeHandledStr(handledStr, inlines);
            }
            inlines.add(imagePlaceholder);
          }
        } else {
          // // block
          handledStr = _closeHandledStr(handledStr, inlines);
          _closeInlines(inlines, list, textOnTap: textOnTap);
          //
          // var imageIndex = imageList.length - 1;
          // var imageWidget = ContentImageComponent(
          //   imageUrl: subStr,
          //   imageList: imageList,
          //   imageIndex: imageIndex,
          // );
          //list.add(imageWidget);
          // list.add(ImagesTileView(images: imageList));
        }
      } else {
        // inline
        handledStr = _closeHandledStr(handledStr, inlines);
        inlines.add(ContentLinkComponent(link: subStr));
      }
    } else if (pathType == "video") {
      if (showVideo && !PlatformUtil.isPC()) {
        // block
        handledStr = _closeHandledStr(handledStr, inlines);
        _closeInlines(inlines, list, textOnTap: textOnTap);
        var w = ContentVideoComponent(url: subStr);
        list.add(w);
      } else {
        // inline
        handledStr = _closeHandledStr(handledStr, inlines);
        inlines.add(ContentLinkComponent(link: subStr));
      }
      // // TODO need to handle, this is temp handle
      // handledStr = _addToHandledStr(handledStr, subStr);
    } else if (pathType == "link") {
      if (!showLinkPreview) {
        // inline
        handledStr = _closeHandledStr(handledStr, inlines);
        inlines.add(ContentLinkComponent(link: subStr));
      } else {
        // block
        handledStr = _closeHandledStr(handledStr, inlines);
        _closeInlines(inlines, list, textOnTap: textOnTap);
        // if (!PlatformUtil.isPC() &&
        //     (subStr.contains("youtube.com") ||
        //         subStr.contains("youtu.be"))) {
        //   var w = ContnetYoutubeComponent(
        //     link: subStr,
        //   );
        //   list.add(w);
        // } else {
        var w = ContentLinkPreComponent(
          link: subStr,
        );
        list.add(w);
        // }
      }
    }
    return handledStr;
  }

  static const double CONTENT_IMAGE_LIST_HEIGHT = 90;

  static String? getPathType(String path) {
    if (path.indexOf(BASE64.PREFIX) == 0) {
      return "image";
    }

    var strs = path.split("?");
    var strs2 = strs[0].split("#");
    var index = strs2[0].lastIndexOf(".");
    if (index ==  -1) {
      return null;
    }

    path = strs2[0];
    var n = path.substring(index);
    n = n.toLowerCase();

    if (n == ".png" || n == ".jpg" || n == ".jpeg" || n == ".gif" || n == ".webp") {
      return "image";
    } else if (n == ".mp4" || n == ".mov" || n == ".wmv" || n == ".m3u8") {
      return "video";
    } else {
      if (path.contains("void.cat/d/")) {
        return "image";
      }
      return "link";
    }
  }
}

class LineTranslateComponent extends StatefulWidget {
  List<dynamic> inlines;

  Function? textOnTap;

  LineTranslateComponent(this.inlines, {this.textOnTap});

  @override
  State<StatefulWidget> createState() {
    return _LineTranslateComponent();
  }
}

class _LineTranslateComponent extends CustState<LineTranslateComponent> {
  Map<String, String> targetTextMap = {};

  String sourceText = "";

  static const double MARGIN = 4;

  late TranslateLanguage sourceLanguage;

  TranslateLanguage? targetLanguage;

  bool showSource = false;

  @override
  Widget doBuild(BuildContext context) {
    var _settingProvider = Provider.of<SettingProvider>(context);
    var themeData = Theme.of(context);
    var smallTextSize = themeData.textTheme.bodySmall!.fontSize;
    var fontSize = themeData.textTheme.bodyMedium!.fontSize;
    var iconWidgetWidth = fontSize! + 4;
    var hintColor = themeData.hintColor;

    if (isInited) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        checkAndTranslate();
      });
    }

    List<InlineSpan> spans = [];

    if (targetLanguage != null && sourceLanguage != null && targetTextMap.isNotEmpty) {
      // translate
      TextSpan? translateTips = TextSpan(
        text: " <- -> ",
        style: TextStyle(
          color: hintColor,
        ),
      );
      for (var inline in widget.inlines) {
        if (inline is String) {
          var targetInline = targetTextMap[inline];
          if (StringUtil.isNotBlank(targetInline)) {
            spans.add(TextSpan(text: "$targetInline "));

            if (showSource) {
              spans.add(translateTips);
              spans.add(TextSpan(
                text: "${inline} ",
                style: TextStyle(
                  color: hintColor,
                ),
              ));
            }
          } else {
            spans.add(TextSpan(text: "${inline} "));
          }
        } else {
          spans.add(WidgetSpan(child: inline));
        }
      }

      var iconBtn = WidgetSpan(
        child: GestureDetector(
          onTap: () {
            setState(() {
              showSource = !showSource;
            });
          },
          child: Container(
            margin: const EdgeInsets.only(
              left: MARGIN,
              right: MARGIN,
            ),
            height: iconWidgetWidth,
            width: iconWidgetWidth,
            decoration: BoxDecoration(
              border: Border.all(width: 1, color: hintColor),
              borderRadius: BorderRadius.circular(iconWidgetWidth / 2),
            ),
            child: Icon(
              Icons.translate,
              size: smallTextSize,
              color: hintColor,
            ),
          ),
        ),
      );
      spans.add(iconBtn);
    } else {
      // no translate
      for (var inline in widget.inlines) {
        if (inline is String) {
          spans.add(TextSpan(text: "$inline "));
        } else {
          spans.add(WidgetSpan(child: inline));
        }
      }
    }

    return SelectableText.rich(
      TextSpan(children: spans),
      onTap: () {
        if (widget.textOnTap != null) {
          widget.textOnTap!();
        }
      },
    );
  }

  @override
  Future<void> onReady(BuildContext context) async {
    checkAndTranslate();
  }

  Future<void> checkAndTranslate() async {
    var newSourceText = "";

    for (var inline in widget.inlines) {
      if (inline is String) {
        newSourceText += inline;
      }
    }

    if (newSourceText.length > 1000) {
      return;
    }

    return;
  }
}

class TranslateLanguage {}

class ContentDecoderInfo {
  int imageNum = 0;
  List<List<String>> strs = [];
}
