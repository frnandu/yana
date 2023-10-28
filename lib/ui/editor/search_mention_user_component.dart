import 'package:dart_ndk/nips/nip01/metadata.dart';
import 'package:flutter/material.dart';

import '../../main.dart';
import '../../nostr/nip19/nip19.dart';
import '../../utils/base.dart';
import '../../utils/string_util.dart';
import '../../utils/when_stop_function.dart';
import '../name_component.dart';
import '../user_pic_component.dart';
import 'search_mention_component.dart';

class SearchMentionUserComponent extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SearchMentionUserComponent();
  }
}

class _SearchMentionUserComponent extends State<SearchMentionUserComponent>
    with WhenStopFunction {
  double itemWidth = 50;

  @override
  Widget build(BuildContext context) {
    var contentWidth = mediaDataCache.size.width - 4 * Base.BASE_PADDING;
    itemWidth = (contentWidth - 10) / 2;

    return SearchMentionComponent(
      resultBuildFunc: resultBuild,
      handleSearchFunc: handleSearch,
    );
  }

  Widget resultBuild() {
    List<Widget> userWidgetList = [];
    for (var metadata in metadatas) {
      userWidgetList.add(SearchMentionUserItemComponent(
        metadata: metadata,
        width: itemWidth,
        onTap: (metadata) {

        },
      ));
    }
    return SingleChildScrollView(
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.only(
          top: Base.BASE_PADDING_HALF,
          bottom: Base.BASE_PADDING_HALF,
        ),
        child: Container(
          width: itemWidth * 2 + 10,
          child: Wrap(
            children: userWidgetList,
            spacing: 10,
            runSpacing: 10,
          ),
        ),
      ),
    );
  }

  static const int searchMemLimit = 100;

  List<Metadata> metadatas = [];

  void handleSearch(String? text) {
    metadatas.clear();

    if (StringUtil.isNotBlank(text)) {
      var list = metadataProvider.findUser(text!, limit: searchMemLimit);
      metadatas = list;
    }

    setState(() {});
  }
}

class SearchMentionUserItemComponent extends StatelessWidget {
  static const double IMAGE_WIDTH = 50;

  final Metadata metadata;

  final double width;

  Function(Metadata) onTap;

  SearchMentionUserItemComponent({super.key,
    required this.metadata,
    required this.width,
    required this.onTap
  });

  @override
  Widget build(BuildContext context) {
    var themeData = Theme.of(context);
    var mainColor = themeData.primaryColor;
    var cardColor = themeData.cardColor;
    Color hintColor = themeData.hintColor;

    Widget? imageWidget = UserPicComponent(
      pubkey: metadata.pubKey!,
      width: IMAGE_WIDTH,
    );
    //
    // if (StringUtil.isNotBlank(metadata.picture)) {
    //   imageWidget = CachedNetworkImage(
    //     imageUrl: metadata.picture!,
    //     width: IMAGE_WIDTH,
    //     height: IMAGE_WIDTH,
    //     fit: BoxFit.cover,
    //     placeholder: (context, url) => CircularProgressIndicator(),
    //     errorWidget: (context, url, error) => Icon(Icons.error),
    //     cacheManager: localCacheManager,
    //   );
    // }

    String nip19Name = Nip19.encodeSimplePubKey(metadata.pubKey!);
    String displayName = nip19Name;
    String name = "";
    if (StringUtil.isNotBlank(metadata.displayName)) {
      displayName = metadata.displayName!;
      if (StringUtil.isNotBlank(metadata.name)) {
        name = metadata.name!;
      } else {
        name = nip19Name;
      }
    } else {
      if (StringUtil.isNotBlank(metadata.name)) {
        displayName = metadata.name!;
        name = nip19Name;
      } else {
        displayName = nip19Name;
      }
    }

    var main = Container(
      width: width,
      color: cardColor,
      padding: EdgeInsets.all(Base.BASE_PADDING_HALF),
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

    Expanded(
            child: Container(
              padding: const EdgeInsets.only(left: Base.BASE_PADDING_HALF),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  NameComponent(pubkey: metadata.pubKey!, metadata: metadata)
                  // Text(
                  //   displayName,
                  //   style: const TextStyle(
                  //     fontWeight: FontWeight.bold,
                  //   ),
                  //   overflow: TextOverflow.ellipsis,
                  // ),
                  ,
                  StringUtil.isNotBlank(metadata.nip05)?
                  Text(
                    metadata.cleanNip05!,
                    style: TextStyle(
                      fontSize: 12,
                      color: hintColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ):Container(),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    return GestureDetector(
      onTap: () {
        onTap(metadata);
        // RouterUtil.back(context, metadata.pubKey);
      },
      child: main,
    );
  }
}
