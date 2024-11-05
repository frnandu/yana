import 'package:ndk/domain_layer/entities/contact_list.dart';
import 'package:ndk/domain_layer/entities/metadata.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../main.dart';
import '../../provider/metadata_provider.dart';
import '../../ui/editor/search_mention_user_component.dart';
import '../../utils/base.dart';
import '../../utils/platform_util.dart';
import '../../utils/router_path.dart';
import '../../utils/router_util.dart';

class UserContactListComponent extends StatefulWidget {
  ContactList contactList;

  UserContactListComponent({required this.contactList});

  @override
  State<StatefulWidget> createState() {
    return _UserContactListComponent();
  }
}

class _UserContactListComponent extends State<UserContactListComponent> {
  ScrollController _controller = ScrollController();

  List<String>? list;

  @override
  Widget build(BuildContext context) {
    list ??= widget.contactList.contacts;

    Widget main = ListView.builder(
      controller: _controller,
      itemBuilder: (context, index) {
        var contact = list![index];
        return Container(
            margin: const EdgeInsets.only(bottom: Base.BASE_PADDING_HALF),
            child: FutureBuilder<Metadata?>(
                future: metadataProvider.getMetadata(contact),
                builder: (context, snapshot) {
                  return snapshot.hasData != null
                      ? SearchMentionUserItemComponent(
                          metadata: snapshot.data!,
                          onTap: (metadata) {
                            RouterUtil.router(context, RouterPath.USER, metadata.pubKey);
                          },
                          width: 400)
                      : Container();
                }));
      },
      itemCount: list!.length,
    );

    if (PlatformUtil.isTableMode()) {
      main = GestureDetector(
        onVerticalDragUpdate: (detail) {
          _controller.jumpTo(_controller.offset - detail.delta.dy);
        },
        behavior: HitTestBehavior.translucent,
        child: main,
      );
    }

    return main;
  }
}
