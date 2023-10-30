import 'package:dart_ndk/nips/nip01/event.dart';
import 'package:dart_ndk/nips/nip01/filter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:yana/nostr/nip172/community_id.dart';
import 'package:yana/nostr/nip172/community_info.dart';

import '../main.dart';
import '../nostr/event_kind.dart' as kind;
import '../utils/later_function.dart';
import '../utils/string_util.dart';

class CommunityInfoProvider extends ChangeNotifier with LaterFunction {
  Map<String, CommunityInfo> _cache = {};

  Map<String, int> _handingIds = {};

  List<String> _needPullIds = [];

  List<Nip01Event> _penddingEvents = [];

  CommunityInfo? getCommunity(String aid) {
    var ci = _cache[aid];
    if (ci != null) {
      return ci;
    }

    // add to query
    if (!_needPullIds.contains(aid)) {
      _needPullIds.add(aid);
    }
    later(_laterCallback, null);

    return null;
  }

  void _laterCallback() {
    if (_needPullIds.isNotEmpty) {
      _laterSearch();
    }

    if (_penddingEvents.isNotEmpty) {
      _handlePenddingEvents();
    }
  }

  void _laterSearch() {
    List<CommunityId> ids = [];
    for (var idStr in _needPullIds) {
      var communityId = CommunityId.fromString(idStr);
      if (communityId!=null) {
        ids.add(communityId);
      }

      // var filter = Filter(
      //     kinds: [kind.EventKind.COMMUNITY_DEFINITION],
      //     authors: [communityId.pubkey]);
      // var queryArg = filter.toMap();
      // queryArg["#d"] = [communityId.title];
      // filters.add(queryArg);
    }

    var filter = Filter(kinds: [
      kind.EventKind.COMMUNITY_DEFINITION,
    ], authors: ids.map((e) => e.pubkey).toList());
    relayManager.query(filter, myInboxRelaySet!).then((stream) {
      stream.listen((event) {
        _onEvent(event);
      });
    });

    for (var pubkey in _needPullIds) {
      _handingIds[pubkey] = 1;
    }
    _needPullIds.clear();
  }

  void _onEvent(Nip01Event event) {
    _penddingEvents.add(event);
    later(_laterCallback, null);
  }

  void _handlePenddingEvents() {
    bool updated = false;

    for (var event in _penddingEvents) {
      var communityInfo = CommunityInfo.fromEvent(event);
      if (communityInfo != null) {
        var aid = communityInfo.communityId.toAString();
        var oldInfo = _cache[aid];
        if (oldInfo == null || oldInfo.createdAt < communityInfo.createdAt) {
          _cache[aid] = communityInfo;
          updated = true;
        }
      }
    }
    _penddingEvents.clear;

    if (updated) {
      notifyListeners();
    }
  }
}
