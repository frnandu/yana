import 'package:yana/nostr/relay_metadata.dart';


class RelayList {

  String? pub_key;

  String get id => pub_key!;

  List<RelayMetadata>? relays;

  int? timestamp;

  static Map<String, List<RelayMetadata>> cached = {};

}
