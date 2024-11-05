import 'package:flutter/foundation.dart';
import 'package:ndk/domain_layer/entities/relay_set.dart';
import 'package:ndk/ndk.dart';

import '../main.dart';
import '../models/dm_session_info.dart';
import '../nostr/event_kind.dart' as kind;
import '../nostr/nip04/dm_session.dart';
import '../utils/peddingevents_later_function.dart';
import '../utils/string_util.dart';

class DMProvider extends ChangeNotifier with PenddingEventsLaterFunction {
  List<DMSessionDetail> _followingList = [];

  List<DMSessionDetail> _knownList = [];

  List<DMSessionDetail> _unknownList = [];

  Map<String, DMSession> _sessions = {};

  Map<String, DMSessionInfo> infoMap = {};

  String? localPubkey;

  List<DMSessionDetail> get followingList => _followingList;

  List<DMSessionDetail> get knownList => _knownList;

  List<DMSessionDetail> get unknownList => _unknownList;

  DMSession? getSession(String pubkey) {
    return _sessions[pubkey];
  }

  DMSessionDetail findOrNewADetail(String pubkey) {
    for (var detail in knownList) {
      if (detail.dmSession.pubkey == pubkey) {
        return detail;
      }
    }

    for (var detail in _unknownList) {
      if (detail.dmSession.pubkey == pubkey) {
        return detail;
      }
    }

    var dmSession = DMSession(pubkey: pubkey);
    DMSessionDetail detail = DMSessionDetail(dmSession);
    detail.info = DMSessionInfo(pubkey: pubkey, readedTime: 0);

    return detail;
  }

  void updateReadedTime(DMSessionDetail? detail) {
    if (detail != null &&
        // detail.info != null &&
        detail.dmSession.newestEvent != null) {
      bool create = detail.info == null;
      bool hasNewMessage = detail.hasNewMessage();
      detail.info ??= DMSessionInfo(pubkey: detail.dmSession.pubkey);
      detail.info!.keyIndex = settingProvider.privateKeyIndex!;
      double now = DateTime.now().millisecondsSinceEpoch / 1000;
      detail.info!.readedTime = now.toInt();

      // if (create || hasNewMessage) {
      //   create ? DMSessionInfoDB.insert(detail.info!) : DMSessionInfoDB.update(
      //       detail.info!);
      //   dmProvider.infoMap[detail.dmSession.pubkey] = detail.info!;
      // }
      notifyListeners();
    }
  }

  void addEventAndUpdateReadedTime(DMSessionDetail detail, Nip01Event event) {
    penddingEvents.add(event);
    eventLaterHandle(penddingEvents, updateUI: true);
    updateReadedTime(detail);
  }

  Future<DMSessionDetail> addDmSessionToKnown(DMSessionDetail detail) async {
    bool create = detail.info == null;
    detail.info ??= DMSessionInfo(pubkey: detail.dmSession.pubkey, readedTime: detail.dmSession.newestEvent!.createdAt);
    detail.info!.keyIndex = settingProvider.privateKeyIndex!;
    detail.info!.known = 1;

    // create ? await DMSessionInfoDB.insert(detail.info!) : await DMSessionInfoDB.update(detail.info!);

    // DMSessionInfo o = DMSessionInfo(pubkey: pubkey);
    // o.keyIndex = keyIndex;
    // o.readedTime = detail.dmSession.newestEvent!.createdAt;
    // await DMSessionInfoDB.insert(o);

    dmProvider.infoMap[detail.dmSession.pubkey] = detail.info!;

    unknownList.remove(detail);
    knownList.add(detail);

    _sortDetailList();
    notifyListeners();

    return detail;
  }

  int _initSince = 0;

  Future<void> initDMSessions(String localPubkey) async {
    _sessions.clear();
    _followingList.clear();
    _knownList.clear();
    _unknownList.clear();
    infoMap.clear();
    _initSince = 0;

    this.localPubkey = localPubkey;
    // var keyIndex = settingProvider.privateKeyIndex!;
    List<Nip01Event>? events = await cacheManager.loadEvents(kinds: [kind.EventKind.DIRECT_MESSAGE]);

    events = events.where((element) => element.pubKey == localPubkey || element.pTags.contains(localPubkey)).toList();
    // await EventDB.list(
    //     keyIndex, kind.EventKind.DIRECT_MESSAGE, 0, 10000000);
    events.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    if (events.isNotEmpty) {
      // find the newest event, subscribe behind the new newest event
      _initSince = events.first.createdAt;
    }
    // if (kDebugMode) {
    //   EasyLoading.show(status: "Loaded ${events.length} DM events from DB");
    // }
    Map<String, List<Nip01Event>> eventListMap = {};
    for (var event in events) {
      // print("dmEvent");
      // print(event.toJson());
      var pubkey = _getPubkey(localPubkey, event);
      if (StringUtil.isNotBlank(pubkey)) {
        var list = eventListMap[pubkey!];
        if (list == null) {
          list = [];
          eventListMap[pubkey] = list;
        }
        list.add(event);
      }
    }

    infoMap = {};
    // var infos = await DMSessionInfoDB.all(keyIndex);
    // for (var info in infos) {
    //   infoMap[info.pubkey!] = info;
    // }

    for (var entry in eventListMap.entries) {
      var pubkey = entry.key;
      var list = entry.value;

      var session = DMSession(pubkey: pubkey);
      session.addEvents(list);

      _sessions[pubkey] = session;

      var info = infoMap[pubkey];
      var detail = DMSessionDetail(session, info: info);
      if ((await contactListProvider.contacts()).contains(pubkey)) {
        _followingList.add(detail);
      } else {
        if (info != null && info.known == 1) {
          _knownList.add(detail);
        } else {
          _unknownList.add(detail);
        }
      }
    }
    query();

    _sortDetailList();
    notifyListeners();
  }

  void _sortDetailList() {
    _doSortDetailList(_followingList);
    _doSortDetailList(_knownList);
    _doSortDetailList(_unknownList);
  }

  int howManyNewDMSessionsWithNewMessages(List<DMSessionDetail> list) {
    int count = 0;
    list.forEach((element) {
      if (element.hasNewMessage()) {
        count++;
      }
    });
    return count;
  }

  void _doSortDetailList(List<DMSessionDetail> detailList) {
    detailList.sort((detail0, detail1) {
      return detail1.dmSession.newestEvent!.createdAt - detail0.dmSession.newestEvent!.createdAt;
    });

    // // copy to a new list for provider update
    // var length = detailList.length;
    // List<DMSessionDetail> newlist =
    //     List.generate(length, (index) => detailList[index]);
    // return newlist;
  }

  String? _getPubkey(String? localPubkey, Nip01Event event) {
    if (event.pubKey != localPubkey) {
      return event.pubKey;
    }

    for (var tag in event.tags) {
      if (tag[0] == "p") {
        return tag[1] as String;
      }
    }

    return null;
  }

  Future<bool> _addEvent(String localPubkey, Nip01Event event) async {
    var pubkey = _getPubkey(localPubkey, event);
    if (StringUtil.isBlank(pubkey)) {
      return false;
    }

    var session = _sessions[pubkey];
    if (session == null) {
      session = DMSession(pubkey: pubkey!);
      _sessions[pubkey] = session;
      if (this.localPubkey != null) {
        var detail = DMSessionDetail(session);
        var pubkey = _getPubkey(localPubkey, event);
        if ((await contactListProvider.contacts()).contains(pubkey)) {
          _followingList.add(detail);
        } else {
          _unknownList.add(detail);
        }
      }
    }
    var addResult = session.addEvent(event);

    if (addResult) {
      session = session.clone();
      _sessions[pubkey!] = session;
    }
    if (_initSince < event.createdAt) {
      _initSince = event.createdAt;
    }

    return addResult;
  }

  NdkResponse? subscription;

  void query() {
    if (!loggedUserSigner!.canSign()) {
      return;
    }
    if (subscription != null) {
      ndk.relays.closeSubscription(subscription!.requestId);
    }
    var sentFilter = Filter(
      kinds: [kind.EventKind.DIRECT_MESSAGE],
      authors: [loggedUserSigner!.getPublicKey()],
      since: _initSince != 0 ? _initSince + 1 : null,
    );
    var receivedFilter = Filter(
      kinds: [kind.EventKind.DIRECT_MESSAGE],
      pTags: [loggedUserSigner!.getPublicKey()],
      since: _initSince != 0 ? _initSince + 1 : null,
    );
    RelaySet relaySet = myInboxRelaySet!;
    subscription = ndk.requests.subscription(name:"dms-sub",filters: [receivedFilter], relaySet: relaySet);
    subscription!.stream.listen((event) {
      onEvent(event);
    });

    ndk.requests.query(cacheRead:false, filters: [sentFilter], relaySet: relaySet).stream.listen((event) {
          onEvent(event);
        });
  }

  void onEvent(Nip01Event event) {
    later(event, eventLaterHandle, null);
  }

  void eventLaterHandle(List<Nip01Event> events, {bool updateUI = true}) async {
    bool updated = false;
    // var keyIndex = settingProvider.privateKeyIndex!;
    // if (kDebugMode) {
    //   EasyLoading.showSuccess("Loaded ${events.length} DM events from relays", duration: const Duration(seconds: 5));
    // }
    List<Nip01Event> toSave = [];
    for (var event in events) {
      var addResult = await _addEvent(localPubkey!, event);
      // save to local
      if (addResult) {
        toSave.add(event);
        updated = true;
      }
    }

    if (updated) {
      cacheManager.saveEvents(toSave);
      _sortDetailList();
      if (updateUI) {
        notifyListeners();
      }
    }
  }

  void clear() {
    _sessions.clear();
    _followingList.clear();
    _knownList.clear();
    _unknownList.clear();

    notifyListeners();
  }

  Future<String?> decrypt(String content, String pubkey) async {
    return await loggedUserSigner!.decrypt(content, pubkey);
  }
}

class DMSessionDetail {
  DMSession dmSession;
  DMSessionInfo? info;

  DMSessionDetail(this.dmSession, {this.info});

  bool hasNewMessage() {
    // if (info == null) {
    //   return false;
    // } else
    if (dmSession.newestEvent != null && (info != null && info!.readedTime! < dmSession.newestEvent!.createdAt)) {
      return true;
    }
    return false;
  }
}
