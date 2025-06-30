import 'package:flutter/material.dart';
import 'package:ndk/ndk.dart';
import 'package:ndk/entities.dart';
import 'package:yana/main.dart';
import 'package:ndk/domain_layer/entities/contact_list.dart';

class FollowersProvider extends ChangeNotifier {
  Map<String, Nip01Event> _followedMap = {};
  NdkResponse? _followersSubscription;
  String? _pubkey;

  Map<String, Nip01Event> get followedMap => _followedMap;
  int get followersCount => _followedMap.length;

  void subscribe(String pubkey) {
    if (_pubkey == pubkey && _followersSubscription != null) {
      // already subscribed
      return;
    }
    _pubkey = pubkey;
    _followedMap = {};
    notifyListeners();

    _closeSubscription();

    Filter filter = Filter(kinds: [ContactList.kKind], pTags: [pubkey]);

    _followersSubscription = ndk.requests.subscription(
      name: "followers-provider",
      filters: [filter],
      explicitRelays: ndk.relays.globalState.relays.keys,
    );
    _followersSubscription!.stream.listen((event) {
      var oldEvent = _followedMap[event.pubKey];
      if (oldEvent == null || event.createdAt > oldEvent.createdAt) {
        _followedMap[event.pubKey] = event;
        notifyListeners();
      }
    });
  }

  void closeSubscription() {
    _closeSubscription();
    _pubkey = null;
    _followedMap.clear();
    notifyListeners();
  }

  void _closeSubscription() {
    if (_followersSubscription != null) {
      ndk.requests.closeSubscription(_followersSubscription!.requestId);
      _followersSubscription = null;
    }
  }

  @override
  void dispose() {
    _closeSubscription();
    super.dispose();
  }
}
