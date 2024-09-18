// ignore_for_file: unnecessary_overrides

import 'package:isar/isar.dart';
import 'package:ndk/entities.dart';

part 'db_user_relay_list.g.dart';

@Collection(inheritance: false)
class DbUserRelayList extends UserRelayList {
  String get id => pubKey;

  @override
  String get pubKey => super.pubKey;

  @override
  int get createdAt => super.createdAt;

  @override
  int get refreshedTimestamp => super.refreshedTimestamp;

  List<DbRelayListItem> get items => super
      .relays
      .entries
      .map((entry) => DbRelayListItem(entry.key, entry.value))
      .toList();

  DbUserRelayList(
      {required super.pubKey,
      required List<DbRelayListItem> items,
      required super.createdAt,
      required super.refreshedTimestamp})
      : super(relays: {for (var item in items) item.url: item.marker});

  static DbUserRelayList fromUserRelayList(UserRelayList userRelayList) {
    return DbUserRelayList(
        pubKey: userRelayList.pubKey,
        items: userRelayList.relays.entries
            .map((entry) => DbRelayListItem(entry.key, entry.value))
            .toList(),
        createdAt: userRelayList.createdAt,
        refreshedTimestamp: userRelayList.refreshedTimestamp);
  }
}

@embedded
class DbRelayListItem {
  String url;
  ReadWriteMarker marker;

  DbRelayListItem(this.url, this.marker);
}
