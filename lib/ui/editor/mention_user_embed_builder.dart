import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

import '../content/content_mention_user_component.dart';
import 'cust_embed_types.dart';

class MentionUserEmbedBuilder extends EmbedBuilder {
  bool get expanded => false;

  @override
  Widget build(BuildContext context, EmbedContext embedContext) {
    var pubkey = embedContext.node.value.data;
    return AbsorbPointer(
      child: Container(
        margin: const EdgeInsets.only(
          left: 4,
          right: 4,
        ),
        child: ContentMentionUserComponent(pubkey: pubkey),
      ),
    );
  }

  @override
  String get key => CustEmbedTypes.mention_user;
}
