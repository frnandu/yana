import 'package:isar/isar.dart';
import 'package:ndk/ndk.dart';


part 'db_metadata.g.dart';

@Collection(inheritance: true)
class DbMetadata extends Metadata {
  String get id => pubKey;

  List<String>? get splitDisplayNameWords =>
      displayName?.trim().toLowerCase().split(" ");

  List<String>? get splitNameWords => name?.trim().toLowerCase().split(" ");

  DbMetadata(
      {super.pubKey = "",
      super.name,
      super.displayName,
      super.picture,
      super.banner,
      super.website,
      super.about,
      super.nip05,
      super.lud16,
      super.lud06,
      super.updatedAt,
      super.refreshedTimestamp});

  static DbMetadata fromMetadata(Metadata metadata) {
    return DbMetadata(
        pubKey: metadata.pubKey,
        name: metadata.name,
        displayName: metadata.displayName,
        picture: metadata.picture,
        banner: metadata.banner,
        website: metadata.website,
        about: metadata.about,
        nip05: metadata.nip05,
        lud16: metadata.lud16,
        lud06: metadata.lud06,
        updatedAt: metadata.updatedAt,
        refreshedTimestamp: metadata.refreshedTimestamp);
  }
}
