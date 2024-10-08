import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:yana/nostr/nip19/nip19.dart';
import 'package:yana/nostr/nip19/nip19_tlv.dart';

import '../../event/event_quote_component.dart';

class MarkdownMentionEventElementBuilder implements MarkdownElementBuilder {
  static const String TAG = "mentionEvent";

  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    var pureText = element.textContent;
    var nip19Text = pureText.replaceFirst("nostr:", "");

    String? key;

    if (Nip19.isNoteId(nip19Text)) {
      key = Nip19.decode(nip19Text);
    } else if (NIP19Tlv.isNevent(nip19Text)) {
      var nevent = NIP19Tlv.decodeNevent(nip19Text);
      if (nevent != null) {
        print(nevent.relays);
        key = nevent.id;
      }
    } else if (NIP19Tlv.isNaddr(nip19Text)) {
      var naddr = NIP19Tlv.decodeNaddr(nip19Text);
      if (naddr != null) {
        print(naddr.relays);
        key = naddr.id;
      }
    }

    if (key != null) {
      return EventQuoteComponent(
        id: key,
      );
    }
    return null;

  }

  @override
  void visitElementBefore(md.Element element) {}

  @override
  Widget? visitText(md.Text text, TextStyle? preferredStyle) {}
  
  @override
  Widget? visitElementAfterWithContext(BuildContext context, md.Element element, TextStyle? preferredStyle, TextStyle? parentStyle) {
    // TODO: implement visitElementAfterWithContext
    throw UnimplementedError();
  }

  @override
  bool isBlockElement() {
    return false;
  }
}
