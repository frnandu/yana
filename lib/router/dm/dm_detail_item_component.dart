import 'package:dart_ndk/nips/nip01/amber_event_signer.dart';
import 'package:dart_ndk/nips/nip01/event.dart';
import 'package:dart_ndk/nips/nip01/helpers.dart';
import 'package:dart_ndk/nips/nip04/nip04.dart';
import 'package:flutter/material.dart';
import 'package:get_time_ago/get_time_ago.dart';
import 'package:pointycastle/export.dart' as pointycastle;
import 'package:provider/provider.dart';
import 'package:yana/main.dart';
import 'package:yana/ui/content/content_decoder.dart';
import 'package:yana/utils/router_path.dart';
import 'package:yana/utils/router_util.dart';

import '../../provider/dm_provider.dart';
import '../../provider/setting_provider.dart';
import '../../ui/user_pic_component.dart';
import '../../utils/base.dart';
import '../../utils/base_consts.dart';

class DMDetailItemComponent extends StatefulWidget {
  String sessionPubkey;

  Nip01Event event;

  bool isLocal;

  DMDetailItemComponent({
    required this.sessionPubkey,
    required this.event,
    required this.isLocal,
  });

  @override
  State<StatefulWidget> createState() {
    return _DMDetailItemComponent();
  }
}

class _DMDetailItemComponent extends State<DMDetailItemComponent> {
  static const double IMAGE_WIDTH = 34;

  static const double BLANK_WIDTH = 50;
  late DMProvider provider;

  String content = '';

  Future<void> decryptContent() async {
    if (Helpers.isBlank(content) && widget.event.content.contains('iv=')) {
      var a = await provider.decrypt(widget.event.content, widget.sessionPubkey);
      if (a != null) {
        setState(() {
          content = a;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    provider = Provider.of<DMProvider>(context, listen: false);
    var _settingProvider = Provider.of<SettingProvider>(context);
    var themeData = Theme.of(context);
    var mainColor = themeData.primaryColor;
    Widget userHeadWidget = Container(
      margin: const EdgeInsets.only(top: 2),
      child: UserPicComponent(
        pubkey: widget.event.pubKey,
        width: IMAGE_WIDTH,
      ),
    );
    // var maxWidth = mediaDataCache.size.width;
    var smallTextSize = themeData.textTheme.bodySmall!.fontSize;
    var hintColor = themeData.hintColor;

    String timeStr = GetTimeAgo.parse(DateTime.fromMillisecondsSinceEpoch(widget.event.createdAt * 1000));

    decryptContent();
    // if (loggedUserSigner is AmberEventSigner) {
    // } else {
    //   final agreement = Nip04.getAgreement(loggedUserSigner!.getPrivateKey()!);
    //   content = await loggedUserSigner.decrypt(widget.event.content, agreement, widget.sessionPubkey);
    // }

    var contentWidget = Container(
      margin: const EdgeInsets.only(
        left: Base.BASE_PADDING_HALF,
        right: Base.BASE_PADDING_HALF,
      ),
      child: Column(
        crossAxisAlignment: !widget.isLocal ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            timeStr,
            style: TextStyle(
              color: hintColor,
              fontSize: smallTextSize,
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 4),
            padding: const EdgeInsets.all(Base.BASE_PADDING_HALF),
            // constraints:
            //     BoxConstraints(maxWidth: (maxWidth - IMAGE_WIDTH) * 0.85),
            decoration: BoxDecoration(
              // color: Colors.red,
              color: mainColor.withOpacity(0.3),
              borderRadius: const BorderRadius.all(Radius.circular(5)),
            ),
            // child: SelectableText(content),
            child: Column(
              crossAxisAlignment: widget.isLocal ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: ContentDecoder.decode(
                context,
                content,
                widget.event,
                showLinkPreview: _settingProvider.linkPreview == OpenStatus.OPEN,
              ),
            ),
          ),
        ],
      ),
    );

    // if (!widget.isLocal) {
    userHeadWidget = GestureDetector(
      onTap: () {
        RouterUtil.router(context, RouterPath.USER, widget.event.pubKey);
      },
      child: userHeadWidget,
    );
    // }

    List<Widget> list = [];
    if (widget.isLocal) {
      list.add(Container(width: BLANK_WIDTH));
      list.add(Expanded(child: contentWidget));
      list.add(userHeadWidget);
    } else {
      list.add(userHeadWidget);
      list.add(Expanded(child: contentWidget));
      list.add(Container(width: BLANK_WIDTH));
    }

    return Container(
      padding: EdgeInsets.all(Base.BASE_PADDING_HALF),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: list,
      ),
    );
  }
}
