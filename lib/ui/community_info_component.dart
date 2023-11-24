import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:yana/ui/content/content_decoder.dart';
import 'package:yana/utils/base.dart';
import 'package:yana/provider/contact_list_provider.dart';
import 'package:yana/utils/string_util.dart';
import 'package:provider/provider.dart';

import '../nostr/nip172/community_info.dart';
import '../main.dart';

class CommunityInfoComponent extends StatefulWidget {
  CommunityInfo info;

  CommunityInfoComponent({required this.info});

  @override
  State<StatefulWidget> createState() {
    return _CommunityInfoComponent();
  }
}

class _CommunityInfoComponent extends State<CommunityInfoComponent> {
  static const double IMAGE_WIDTH = 40;

  @override
  Widget build(BuildContext context) {
    var themeData = Theme.of(context);
    var cardColor = themeData.cardColor;

    Widget? imageWidget;
    if (StringUtil.isNotBlank(widget.info.image)) {
      imageWidget = CachedNetworkImage(
        imageUrl: widget.info!.image!,
        width: IMAGE_WIDTH,
        height: IMAGE_WIDTH,
        fit: BoxFit.cover,
        placeholder: (context, url) => CircularProgressIndicator(),
        errorWidget: (context, url, error) => Icon(Icons.error),
        cacheManager: localCacheManager,
      );
    }

    Widget followBtn =
        Selector<ContactListProvider, bool>(builder: (context, exist, child) {
      IconData iconData = Icons.star_border;
      Color? color;
      if (exist) {
        iconData = Icons.star;
        color = Colors.yellow;
      }

      return GestureDetector(
        onTap: () async {
          bool finished = false;
          Future.delayed(const Duration(seconds: 1),() {
            if (!finished) {
              EasyLoading.show(status: "Refreshing from relays before action...", maskType: EasyLoadingMaskType.black);
            }
          });
          if (exist) {
            contactListProvider
                .removeCommunity(widget.info.communityId.toAString());
          } else {
            contactListProvider
                .addCommunity(widget.info.communityId.toAString());
          }
          finished = true;
          EasyLoading.dismiss();
        },
        child: Container(
          margin: const EdgeInsets.only(
            left: Base.BASE_PADDING_HALF,
            right: Base.BASE_PADDING_HALF,
          ),
          child: Icon(
            iconData,
            color: color,
          ),
        ),
      );
    }, selector: (context, _provider) {
      return _provider.followsCommunity(widget.info.communityId.toAString());
    });

    List<Widget> list = [
      Container(
        margin: EdgeInsets.only(bottom: Base.BASE_PADDING_HALF),
        child: Row(
          children: [
            Container(
              alignment: Alignment.center,
              height: IMAGE_WIDTH,
              width: IMAGE_WIDTH,
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(IMAGE_WIDTH / 2),
                color: Colors.grey,
              ),
              child: imageWidget,
            ),
            Container(
              margin: const EdgeInsets.only(
                left: Base.BASE_PADDING,
              ),
              child: Text(
                widget.info.communityId.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            followBtn,
          ],
        ),
      ),
    ];

    list.addAll(ContentDecoder.decode(context, widget.info.description, null));

    return Container(
      decoration: BoxDecoration(color: cardColor),
      padding: EdgeInsets.all(Base.BASE_PADDING),
      margin: EdgeInsets.only(bottom: Base.BASE_PADDING_HALF),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: list,
      ),
    );
  }
}
