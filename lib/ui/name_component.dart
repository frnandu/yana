import 'package:dart_ndk/entities.dart';
import 'package:flutter/material.dart';
import 'package:yana/ui/nip05_valid_component.dart';

import '../nostr/nip19/nip19.dart';
import '../utils/string_util.dart';

class NameComponent extends StatefulWidget {
  String pubkey;

  Metadata? metadata;

  bool showNip05;

  double? fontSize;

  Color? fontColor;

  NameComponent({super.key,
    required this.pubkey,
    this.metadata,
    this.showNip05 = true,
    this.fontSize,
    this.fontColor,
  });

  @override
  State<StatefulWidget> createState() {
    return _NameComponnet();
  }
}

class _NameComponnet extends State<NameComponent> {
  @override
  Widget build(BuildContext context) {
    var themeData = Theme.of(context);
    // var textSize = themeData.textTheme.bodyMedium!.fontSize;
    var textSize = themeData.textTheme.bodyLarge!.fontSize;
    var smallTextSize = themeData.textTheme.bodySmall!.fontSize;
    Color hintColor = themeData.hintColor;
    var metadata = widget.metadata;
    String nip19Name = !widget.pubkey.startsWith("npub") ? Nip19.encodeSimplePubKey(widget.pubkey) : widget.pubkey;
    String displayName = "";
    String name = "";
    if (widget.fontColor != null) {
      hintColor = widget.fontColor!;
    }

    if (metadata != null) {
      if (StringUtil.isNotBlank(metadata.displayName)) {
        displayName = metadata.displayName!;
        if (StringUtil.isNotBlank(metadata.name)) {
          name = metadata.name!;
        }
      } else if (StringUtil.isNotBlank(metadata.name)) {
        displayName = metadata.name!;
      }

      // TODO
      // if (metadata.valid != null && metadata.valid! > 0) {
      //   nip05Status = 2;
      // }
    }

    List<InlineSpan> nameList = [];

    if (StringUtil.isBlank(displayName)) {
      displayName = nip19Name;
    }
    nameList.add(TextSpan(
      text: StringUtil.breakWord(displayName),
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: widget.fontSize ?? textSize,
        color: widget.fontColor,
        overflow: TextOverflow.fade,
      ),
    ));
    if (StringUtil.isNotBlank(name) && name.trim().toLowerCase()!=displayName.trim().toLowerCase()) {
      nameList.add(WidgetSpan(
        child: Container(
          margin: EdgeInsets.only(left: 2),
          child: Text(
            StringUtil.breakWord("@$name"),
            style: TextStyle(
              fontSize: smallTextSize,
              color: hintColor,
            ),
          ),
        ),
      ));
    }

    Widget nip05Widget = Container();
    if (metadata!=null && StringUtil.isNotBlank(metadata.nip05) && widget.showNip05) {
      nip05Widget = Container(
        margin: const EdgeInsets.only(left: 3, bottom:2),
        child: Nip05ValidComponent(metadata: widget.metadata!),
      );
    }

    nameList.add(WidgetSpan(child: nip05Widget));

    return Text.rich(
      TextSpan(children: nameList),
      maxLines: 3,
    );
  }
}
