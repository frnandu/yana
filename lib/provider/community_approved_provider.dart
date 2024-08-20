import 'package:ndk/domain_layer/entities/nip_01_event.dart';
import 'package:flutter/material.dart';
import 'package:yana/main.dart';
import 'package:yana/nostr/nip172/community_id.dart';
import 'package:yana/utils/later_function.dart';

import '../nostr/event_kind.dart' as kind;

class CommunityApprovedProvider extends ChangeNotifier with LaterFunction {
  Map<String, int> _approvedMap = {};

  List<String> eids = [];

  List<Nip01Event> penddingEvents = [];

  bool check(String pubkey, String eid, {CommunityId? communityId}) {
    if (_approvedMap[eid] != null || communityId == null) {
      return true;
    }

    if (contactListProvider.contacts().contains(pubkey) ||
        pubkey == loggedUserSigner!.getPublicKey()) {
      return true;
    }

    // plan to query
    eids.add(eid);
    later(laterFunction, null);

    return false;
  }

  void laterFunction() {
    if (eids.isNotEmpty) {
      // load
      Map<String, dynamic> filter = {};
      filter["kinds"] = [kind.EventKind.COMMUNITY_APPROVED];
      List<String> ids = [];
      ids.addAll(eids);
      filter["#e"] = ids;
      eids.clear();
      /// TODO use dart_ndk
      // nostr!.query([filter], onEvent);
    }

    if (penddingEvents.isNotEmpty) {
      bool updated = false;

      for (var e in penddingEvents) {
        var eid = e.getEId();
        if (eid != null) {
          // TODO need to check pubkey is Moderated or not.
          if (_approvedMap[eid] == null) {
            updated = true;
          }

          _approvedMap[eid] = 1;
        }
      }

      penddingEvents.clear();
      if (updated) {
        notifyListeners();
      }
    }
  }

  void onEvent(Nip01Event e) {
    penddingEvents.add(e);
    later(laterFunction, null);
  }
}
