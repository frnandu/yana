import 'package:ndk/entities.dart';
import 'package:flutter/material.dart';

import '../../utils/base.dart';
import '../../utils/string_util.dart';
import '../content/content_decoder.dart';
import 'metadata_top_component.dart';
import 'user_badges_component.dart';

class MetadataComponent extends StatefulWidget {
  final String _pubKey;

  final Metadata? _metadata;

  final bool _jumpable;

  final bool _showBadges;

  final bool _userPicturePreview;

  final bool _followsYou;

  const MetadataComponent({super.key,
    required String pubKey,
    Metadata? metadata,
    bool jumpable = false,
    bool showBadges = false,
    bool userPicturePreview = false,
    bool followsYou = false
  }) : _pubKey = pubKey, _metadata = metadata, _jumpable = jumpable, _showBadges = showBadges, _userPicturePreview = userPicturePreview, _followsYou = followsYou;

  @override
  State<StatefulWidget> createState() {
    return _MetadataComponent();
  }
}

class _MetadataComponent extends State<MetadataComponent> {
  @override
  Widget build(BuildContext context) {
    List<Widget> mainList = [];

    mainList.add(MetadataTopComponent(
      pubkey: widget._pubKey,
      metadata: widget._metadata,
      jumpable: widget._jumpable,
      userPicturePreview: widget._userPicturePreview,
      followsYou:  widget._followsYou,
    ));

    if (widget._showBadges) {
      mainList.add(UserBadgesComponent(
        pubkey: widget._pubKey,
      ));
    }
    var themeData = Theme.of(context);

    if (widget._metadata != null &&
        StringUtil.isNotBlank(widget._metadata!.about)) {
      mainList.add(
        Container(
          width: double.maxFinite,
          padding: const EdgeInsets.only(
            top: Base.BASE_PADDING_HALF,
            left: Base.BASE_PADDING,
            right: Base.BASE_PADDING,
            bottom: Base.BASE_PADDING,
          ),
          // child: Text(widget.metadata!.about!),
          child: SizedBox(
            width: double.maxFinite,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: ContentDecoder.decode(
                context,
                widget._metadata!.about!,
                null,
                showLinkPreview: false,
              ),
            ),
          ),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: mainList,
    );
  }
}
