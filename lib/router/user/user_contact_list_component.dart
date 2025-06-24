import 'package:flutter/material.dart';
import 'package:flutter_list_view/flutter_list_view.dart';
import 'package:ndk/domain_layer/entities/contact_list.dart';
import 'package:ndk/domain_layer/entities/metadata.dart';

import '../../main.dart';
import '../../ui/editor/search_mention_user_component.dart';
import 'package:go_router/go_router.dart';

import '../../utils/base.dart';
import '../../utils/platform_util.dart';
import '../../utils/router_path.dart';

class UserContactListComponent extends StatefulWidget {
  ContactList contactList;

  UserContactListComponent({required this.contactList});

  @override
  State<StatefulWidget> createState() {
    return _UserContactListComponent();
  }
}

class _UserContactListComponent extends State<UserContactListComponent> {
  final _controller = FlutterListViewController();

  List<String>? list;

  @override
  Widget build(BuildContext context) {
    list ??= widget.contactList.contacts;

    Widget main = FlutterListView(
        controller: _controller,
        delegate: FlutterListViewDelegate(
          (BuildContext context, int index) {
            var contact = list![index];
            return Container(
                margin: const EdgeInsets.only(bottom: Base.BASE_PADDING_HALF),
                child: FutureBuilder<Metadata?>(
                    future: metadataProvider.getMetadata(contact),
                    builder: (context, snapshot) {
                      return snapshot.hasData
                          ? SearchMentionUserItemComponent(
                              metadata: snapshot.data!,
                              onTap: (metadata) {
                                context.push(RouterPath.USER,
                                    extra: metadata.pubKey);
                              },
                              width: 400)
                          : Container();
                    }));
          },
          childCount: list!.length,
        ));

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
