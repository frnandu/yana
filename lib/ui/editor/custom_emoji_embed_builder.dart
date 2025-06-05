import 'package:flutter/src/painting/text_style.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:yana/ui/content/content_custom_emoji_component.dart';
import 'package:yana/ui/editor/cust_embed_types.dart';
import 'package:yana/models/custom_emoji.dart';

class CustomEmojiEmbedBuilder extends EmbedBuilder {
  bool get expanded => false;

  @override
  Widget build(BuildContext context, EmbedContext embedContext) {
    var customEmoji = embedContext.node.value.data as CustomEmoji;
    return ContentCustomEmojiComponent(imagePath: customEmoji.filepath!);
  }

  @override
  String get key => CustEmbedTypes.custom_emoji;
}
