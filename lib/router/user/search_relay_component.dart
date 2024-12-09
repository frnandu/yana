import 'package:flutter/material.dart';
import 'package:ndk/domain_layer/entities/relay.dart';
import 'package:ndk/domain_layer/entities/relay_connectivity.dart';

import '../../main.dart';
import '../../utils/base.dart';
import '../../utils/string_util.dart';
import '../../utils/when_stop_function.dart';
import '../relays/relays_item_component.dart';

class SearchRelayComponent extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SearchRelayComponent();
  }
}

class _SearchRelayComponent extends State<SearchRelayComponent>
    with WhenStopFunction {
  double itemWidth = 50;

  @override
  Widget build(BuildContext context) {
    var contentWidth = mediaDataCache.size.width - 4 * Base.BASE_PADDING;
    itemWidth = (contentWidth - 10) / 2;


    List<Widget> userWidgetList = [];
    for (var url in urls) {
      userWidgetList.add(SearchRelayItemComponent(
        url: url,
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

  List<String> urls = [];

  void handleSearch(String? text) {
    urls.clear();

    if (StringUtil.isNotBlank(text)) {
      // var list = cacheManager.searchMetadatas(text!, searchMemLimit).toList();
      // urls = list;
    }

    setState(() {});
  }
}

class SearchRelayItemComponent extends StatelessWidget {
  static const double IMAGE_WIDTH = 50;

  final String url;

  final double width;

  Function(String)? onTap;

  PopupMenuButton? popupMenuButton;

  SearchRelayItemComponent({super.key,
    required this.url,
    required this.width,
    this.onTap,
    this.popupMenuButton
  });

  @override
  Widget build(BuildContext context) {
    var themeData = Theme.of(context);
    var mainColor = themeData.primaryColor;
    var cardColor = themeData.cardColor;
    Color hintColor = themeData.hintColor;

    // Widget? imageWidget = UserPicComponent(
    //   pubkey: metadata.pubKey!,
    //   width: IMAGE_WIDTH,
    // );
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

    // String nip19Name = Nip19.encodeSimplePubKey(metadata.pubKey!);
    // String displayName = nip19Name;
    // String name = "";
    // if (StringUtil.isNotBlank(metadata.displayName)) {
    //   displayName = metadata.displayName!;
    //   if (StringUtil.isNotBlank(metadata.name)) {
    //     name = metadata.name!;
    //   } else {
    //     name = nip19Name;
    //   }
    // } else {
    //   if (StringUtil.isNotBlank(metadata.name)) {
    //     displayName = metadata.name!;
    //     name = nip19Name;
    //   } else {
    //     displayName = nip19Name;
    //   }
    // }
    RelayConnectivity? relay =ndk.relays.getRelayConnectivity(url);

    // Widget main = Container(
    //   width: width,
    //   color: cardColor,
    //   padding: const EdgeInsets.all(Base.BASE_PADDING_HALF),
    //   child: Row(
    //     children: [
    //       // relay!=null && relay!.info!=null ?
    //       // Container(
    //       //   alignment: Alignment.center,
    //       //   height: IMAGE_WIDTH,
    //       //   width: IMAGE_WIDTH,
    //       //   clipBehavior: Clip.hardEdge,
    //       //   decoration: BoxDecoration(
    //       //     borderRadius: BorderRadius.circular(IMAGE_WIDTH / 2),
    //       //     color: Colors.grey,
    //       //   ),
    //       //   child: Container(),
    //       // ),
    //       //
    //       ,
    // Expanded(
    //         child: Container(
    //           padding: const EdgeInsets.only(left: Base.BASE_PADDING_HALF),
    //           child: Column(
    //             crossAxisAlignment: CrossAxisAlignment.start,
    //             children: [Text(url)
    //               // NameComponent(pubkey: metadata.pubKey!, metadata: metadata)
    //               // // Text(
    //               // //   displayName,
    //               // //   style: const TextStyle(
    //               // //     fontWeight: FontWeight.bold,
    //               // //   ),
    //               // //   overflow: TextOverflow.ellipsis,
    //               // // ),
    //               // ,
    //               // StringUtil.isNotBlank(metadata.nip05)?
    //               // Text(
    //               //   metadata.cleanNip05!,
    //               //   style: TextStyle(
    //               //     fontSize: 12,
    //               //     color: hintColor,
    //               //   ),
    //               //   overflow: TextOverflow.ellipsis,
    //               // ):Container(),
    //             ],
    //           ),
    //         ),
    //       ),
    //     ],
    //   ),
    // );

    return GestureDetector(
      onTap: () {
        if (onTap!=null) {
          onTap!(url);
        }
        // RouterUtil.back(context, metadata.pubKey);
      },
      child: RelaysItemComponent(relay: relay, url: url, showConnection: false, showStats: false, popupMenuButton: popupMenuButton, onAdd: onTap!=null? (url) {
        onTap!(url);
      } : null)
      ,
    );
  }
}
