// ignore_for_file: unnecessary_overrides

import 'package:isar/isar.dart';
import 'package:ndk/ndk.dart';
import 'package:ndk/shared/helpers/list_casting.dart';

part 'db_event.g.dart';

@Collection(inheritance: false)
class DbEvent extends Nip01Event {
  @override
  String get id => super.id;

  @override
  String get pubKey => super.pubKey;

  @override
  int get kind => super.kind;

  @override
  int get createdAt => super.createdAt;

  @override
  List<List<String>> get tags => super.tags;

  @override
  List<String> get pTags {
    List<String> pTags = super.tags.where((element) {
      List<dynamic> a = element;
      if (a.isNotEmpty && a.first.toString() == "p") {
        return true;
      }
          return false;
    }).map((e) {
      List<dynamic> list = e as List;
      return list.length == 2 ? list[1].toString() : "";
    }).toList();
    return pTags;
  }

  @override
  String get content => super.content;

  @override
  @embedded
  String get sig => super.sig;

  @override
  @embedded
  bool? get validSig => super.validSig;

  @override
  @embedded
  List<String> get sources => super.sources;

  DbEvent(
      {required super.pubKey,
      required super.kind,
      required super.tags,
      required super.content,
      super.createdAt,
      required String sig,
      bool? validSig,
      required List<String> sources}) {
    super.sig = sig;
    super.validSig = validSig;
    super.sources = sources;
  }

  static DbEvent fromNip01Event(Nip01Event event) {
    DbEvent dbEvent = DbEvent(
        pubKey: event.pubKey,
        kind: event.kind,
        tags: event.tags,
        content: event.content,
        createdAt: event.createdAt,
        sig: event.sig,
        validSig: event.validSig,
        sources: event.sources);
    // dbEvent.sig = event.sig;
    // dbEvent.validSig = event.validSig;
    // dbEvent.sources = event.sources;
    return dbEvent;
  }
}
