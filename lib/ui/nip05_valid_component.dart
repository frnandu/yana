import 'package:ndk/entities.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yana/main.dart';

import '../provider/metadata_provider.dart';

class Nip05ValidComponent extends StatefulWidget {
  Metadata metadata;

  Nip05ValidComponent({required this.metadata});

  @override
  State<StatefulWidget> createState() {
    return _Nip05ValidComponent();
  }
}

class _Nip05ValidComponent extends State<Nip05ValidComponent> {
  bool? valid;

  @override
  Widget build(BuildContext context) {
    var themeData = Theme.of(context);
    var smallTextSize = themeData.textTheme.bodySmall!.fontSize;

    Color iconColor = Colors.red;
    var iconData = Icons.warning_amber_outlined;
    if (valid == null) {
      iconColor = Colors.yellow;
      iconData = Icons.downloading;
    } else if (valid!) {
      iconColor = Colors.grey;
      iconData = Icons.verified;
    }

    return Container(
        margin: const EdgeInsets.only(top: 2),
        child: Icon(
          iconData,
          color: iconColor,
          size: smallTextSize,
        ));
  }

  @override
  void initState() {
    Future(() async {
      setState(() async {
        valid = await metadataProvider.isNip05Valid(widget.metadata);
      });
    });
  }
}
