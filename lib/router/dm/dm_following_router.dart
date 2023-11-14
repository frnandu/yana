import 'package:flutter/material.dart';
import 'package:yana/main.dart';
import 'package:yana/provider/notice_provider.dart';
import 'package:pointycastle/ecc/api.dart';
import 'package:provider/provider.dart';

import '../../nostr/nip04/nip04.dart';
import '../../provider/dm_provider.dart';
import '../../provider/index_provider.dart';
import '../../utils/index_taps.dart';
import 'dm_notice_item_component.dart';
import 'dm_session_list_item_component.dart';

class DMFollowingRouter extends StatefulWidget {
  ECDHBasicAgreement? agreement;
  ScrollDirectionCallback scrollCallback;

  DMFollowingRouter({this.agreement, required this.scrollCallback});

  @override
  State<StatefulWidget> createState() {
    return _DMFollowingRouter();
  }
}

class _DMFollowingRouter extends State<DMFollowingRouter> {
  @override
  Widget build(BuildContext context) {
    var _dmProvider = Provider.of<DMProvider>(context);
    var details = _dmProvider.followingList;
    var allLength = details.length;

    var _noticeProvider = Provider.of<NoticeProvider>(context);
    var notices = _noticeProvider.notices;
    bool hasNewNotice = _noticeProvider.hasNewMessage();
    int flag = 0;
    if (notices.isNotEmpty) {
      allLength += 1;
      flag = 1;
    }

    ScrollController scrollController = ScrollController();
    scrollController.addListener(() {
      widget.scrollCallback.call(scrollController.position.userScrollDirection);
    });

    return ListView.builder(
      controller: scrollController,
      itemBuilder: (context, index) {
        if (index >= allLength) {
          return null;
        }

        if (index == 0 && flag > 0) {
          return DMNoticeItemComponent(
            newestNotice: notices.last,
            hasNewMessage: hasNewNotice,
          );
        } else {
          var detail = details[index - flag];
          String content = NIP04.decrypt(detail.dmSession.newestEvent!.content,
              widget.agreement!, detail.dmSession.pubkey);

          // return Text(metadataProvider.getMetadata(detail.dmSession.pubkey)!.name!+" "+content);
          return DMSessionListItemComponent(
            key: ValueKey(detail.dmSession.pubkey),
            detail: detail,
            agreement: widget.agreement,
          );
        }
      },
      itemCount: allLength,
    );
  }
}
