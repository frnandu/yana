import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../i18n/i18n.dart';
import '../../provider/notice_provider.dart';
import '../edit/editor_router.dart';
import 'notice_list_item_component.dart';

class NoticeRouter extends StatefulWidget {
  const NoticeRouter({super.key});

  @override
  State<StatefulWidget> createState() {
    return _NoticeRouter();
  }
}

class _NoticeRouter extends State<NoticeRouter> {
  @override
  Widget build(BuildContext context) {
    var s = I18n.of(context);

    var _noticeProvider = Provider.of<NoticeProvider>(context);
    var notices = _noticeProvider.notices;
    var length = notices.length;

    Widget? main;
    if (length == 0) {
      main = Container(
        child: Center(
          child: GestureDetector(
            onTap: () {
              EditorRouter.open(context);
            },
            child: Text(s.Notices),
          ),
        ),
      );
    } else {
      main = ListView.builder(
        itemBuilder: (BuildContext context, int index) {
          var notice = notices[length - 1 - index];
          return NoticeListItemComponent(
            notice: notice,
          );
        },
        itemCount: length,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(s.Notices),
      ),
      body: main,
    );
  }
}
