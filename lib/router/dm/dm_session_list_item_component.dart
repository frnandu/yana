import 'package:flutter/material.dart';
import 'package:get_time_ago/get_time_ago.dart';
import 'package:pointycastle/export.dart' as pointycastle;
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:yana/models/metadata.dart';
import 'package:yana/nostr/nip04/nip04.dart';
import 'package:yana/provider/dm_provider.dart';
import 'package:yana/provider/metadata_provider.dart';
import 'package:yana/ui/name_component.dart';
import 'package:yana/ui/point_component.dart';
import 'package:yana/ui/user_pic_component.dart';
import 'package:yana/utils/base.dart';
import 'package:yana/utils/router_path.dart';
import 'package:yana/utils/router_util.dart';

import '../../utils/string_util.dart';

class DMSessionListItemComponent extends StatefulWidget {
  DMSessionDetail detail;

  pointycastle.ECDHBasicAgreement? agreement;

  DMSessionListItemComponent({
    super.key,
    required this.detail,
    this.agreement,
  });

  @override
  State<StatefulWidget> createState() {
    return _DMSessionListItemComponent();
  }
}

class _DMSessionListItemComponent extends State<DMSessionListItemComponent> {
  static const double IMAGE_WIDTH = 34;

  String? content;

  @override
  void initState() {
    if (widget.agreement != null) {
      content = NIP04.decrypt(widget.detail.dmSession.newestEvent!.content,
          widget.agreement!, widget.detail.dmSession.pubkey);
    }
    if (content != null) {
      content = content!.replaceAll("\r", " ");
      content = content!.replaceAll("\n", " ");
    }
  }

  @override
  Widget build(BuildContext context) {
    var themeData = Theme.of(context);
    var mainColor = themeData.primaryColor;
    var hintColor = themeData.hintColor;
    var smallTextSize = themeData.textTheme.bodySmall!.fontSize;

    var dmSession = widget.detail.dmSession;

    var leftWidget = Container(
      margin: const EdgeInsets.only(top: 4),
      child: UserPicComponent(
        pubkey: dmSession.pubkey,
        width: IMAGE_WIDTH,
      ),
    );

    var lastEvent = dmSession.newestEvent!;

    bool hasNewMessage = widget.detail.hasNewMessage();

    List<Widget> contentList = [
      Expanded(
        child: Text(
          StringUtil.breakWord(content ?? ""),
          style: TextStyle(
            fontSize: smallTextSize,
            color: themeData.hintColor,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      )
    ];
    if (hasNewMessage) {
      contentList.add(PointComponent(color: mainColor));
    }

    var main = Container(
      padding: const EdgeInsets.all(Base.BASE_PADDING),
      decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(
        width: 1,
        color: hintColor,
      ))),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          leftWidget,
          Expanded(
            child: Container(
              padding: const EdgeInsets.only(
                left: Base.BASE_PADDING,
                right: Base.BASE_PADDING,
                top: 4,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                          child: SizedBox(
                              width: 200,
                              child: Selector<MetadataProvider, Metadata?>(
                                builder: (context, metadata, child) {
                                  return NameComponent(
                                    pubkey: dmSession.pubkey,
                                    showNip05: false,
                                    metadata: metadata,
                                  );
                                },
                                selector: (context, _provider) {
                                  return _provider.getMetadata(
                                      widget.detail.dmSession.pubkey);
                                },
                              ))),
                      // Expanded(
                      //   child:
                      Container(
                        padding: const EdgeInsets.only(left:Base.BASE_PADDING),
                        alignment: Alignment.centerRight,
                        child: Text(
                          GetTimeAgo.parse(DateTime.fromMillisecondsSinceEpoch(
                              lastEvent.createdAt * 1000 ), pattern: "dd MMM HH:mm"),
                          style: TextStyle(
                            fontSize: smallTextSize,
                            color: themeData.disabledColor,
                          ),
                        ),
                      ),
                      // ),
                    ],
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 2),
                    child: Row(children: contentList),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    return GestureDetector(
      onTap: () {
        RouterUtil.router(context, RouterPath.DM_DETAIL, widget.detail);
      },
      child: main,
    );
  }
}
