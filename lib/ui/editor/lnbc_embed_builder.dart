import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:yana/ui/content/content_lnbc_component.dart';

import 'cust_embed_types.dart';

class LnbcEmbedBuilder extends EmbedBuilder {
  @override
  Widget build(BuildContext context, EmbedContext embedContext) {
    var lnbcStr = embedContext.node.value.data;
    return AbsorbPointer(
      child: ContentLnbcComponent(lnbc: lnbcStr),
    );
  }

  @override
  String get key => CustEmbedTypes.lnbc;
}
