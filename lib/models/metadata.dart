import 'package:isar/isar.dart';

import '../utils/string_util.dart';

class Metadata {
  // Id id = Isar.autoIncrement;

  String? pubKey;

  String get id => pubKey!;

  String? name;
  String? displayName;
  String? picture;
  String? banner;
  String? website;
  String? about;
  String? nip05;
  String? lud16;
  String? lud06;
  int? updated_at;
  int? valid;

  Metadata({
    this.pubKey,
    this.name,
    this.displayName,
    this.picture,
    this.banner,
    this.website,
    this.about,
    this.nip05,
    this.lud16,
    this.lud06,
    this.updated_at,
    this.valid,
  });

  Metadata.fromJson(Map<String, dynamic> json) {
    pubKey = json['pub_key'];
    name = json['name'];
    displayName = json['display_name'];
    picture = json['picture'];
    banner = json['banner'];
    website = json['website'];
    about = json['about'];
    nip05 = json['nip05'];
    lud16 = json['lud16'];
    lud06 = json['lud06'];
    updated_at = json['updated_at'];
    valid = json['valid'];
  }

  Map<String, dynamic> toFullJson() {
    var data = toJson();
    data['pub_key'] = this.pubKey;
    return data;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['display_name'] = this.displayName;
    data['picture'] = this.picture;
    data['banner'] = this.banner;
    data['website'] = this.website;
    data['about'] = this.about;
    data['nip05'] = this.nip05;
    data['lud16'] = this.lud16;
    data['lud06'] = this.lud06;
    data['updated_at'] = this.updated_at;
    data['valid'] = this.valid;
    return data;
  }

  String getName() {
    if (displayName != null && StringUtil.isNotBlank(displayName)) {
      return displayName!;
    }
    if (name != null && StringUtil.isNotBlank(name)) {
      return name!;
    }
    return pubKey!;
  }

  String? getPictureOrRobohash() {
    return StringUtil.isNotBlank(picture)
        ? picture
        : StringUtil.robohash(pubKey!);
  }

  bool matchesSearch(String str) {
    str = str.trim().toLowerCase();
    String d = displayName != null ? displayName!.toLowerCase()! : "";
    String n = name != null ? name!.toLowerCase()! : "";
    String str2 = " " + str;
    return d.startsWith(str) ||
        d.contains(str2) ||
        n.startsWith(str) ||
        n.contains(str2);
  }

  static Map<String, Metadata> cached = {};

  // static Future<Metadata?> loadFromDB(String pubKey,
  //     {bool useCache = true}) async {
  //   Metadata? metadata = useCache ? cached[pubKey] : null;
  //   if (metadata == null) {
  //     final metadata = await DB
  //         .getIsar()
  //         .metadatas
  //         .filter()
  //         .pubKeyEqualTo(pubKey)
  //         .findFirst();
  //     if (metadata != null) {
  //       print("LOADED metadata from DATABASE for $pubKey");
  //       cached[pubKey] = metadata!;
  //     }
  //   } else {
  //     print("LOADED metadata from MEMORY for $pubKey");
  //   }
  //   return metadata;
  // }
  //
  // static Future<int> writeToDB(Metadata metadata) async {
  //   if (metadata.pubKey!=null) {
  //     cached[metadata.pubKey!] = metadata;
  //     return await DB.getIsar().writeTxn(() async {
  //       return await DB
  //           .getIsar()
  //           .metadatas
  //           .putByIndex("pubKey", metadata);
  //     });
  //   }
  //   return 0;
  // }
  //
  // static Future<void> deleteAllFromDB() async {
  //   await DB.getIsar().writeTxn(() async {
  //     await DB.getIsar().metadatas.clear();
  //   });
  // }
  //
  // static Future<List<Metadata>> loadAllFromDB() {
  //   return DB.getIsar().metadatas.where().findAll();
  // }
}
