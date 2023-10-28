import 'package:flutter/material.dart';
import 'package:yana/router/dm/dm_following_router.dart';
import 'package:yana/utils/string_util.dart';

import '../../nostr/nip04/nip04.dart';
import '../../main.dart';
import '../../provider/index_provider.dart';
import 'dm_known_list_router.dart';
import 'dm_unknown_list_router.dart';

class DMRouter extends StatefulWidget {
  TabController tabController;
  ScrollDirectionCallback scrollCallback;

  DMRouter({required this.tabController, required this.scrollCallback});

  @override
  State<StatefulWidget> createState() {
    return _DMRouter();
  }
}

class _DMRouter extends State<DMRouter> {
  @override
  Widget build(BuildContext context) {
    var themeData = Theme.of(context);
    //loggedUserSigner.decrypt(msg)
    // TODO use dart_ndk WTF??!?!
    // bool isPrivate = StringUtil.isNotBlank(nostr!.privateKey);
    var agreement = loggedUserSigner!.canSign() ? NIP04.getAgreement(loggedUserSigner!.getPrivateKey()!) : null;
    //
    return Container(
      color: themeData.scaffoldBackgroundColor,
      child: TabBarView(
        controller: widget.tabController,
        children: [
          DMFollowingRouter(agreement: agreement, scrollCallback: widget.scrollCallback),
          DMKnownListRouter(agreement: agreement, scrollCallback: widget.scrollCallback),
          DMUnknownListRouter(agreement: agreement, scrollCallback: widget.scrollCallback),
        ],
      ),
    );
  }
}
