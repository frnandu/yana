import 'package:isar/isar.dart';

part 'relay_metadata.g.dart';

@embedded
class RelayMetadata {
  String? addr;

  bool? read;

  bool? write;

  @ignore
  int? count;

  RelayMetadata();

  RelayMetadata.full({
    this.addr,
    this.read,
    this.write,
    this.count
  });

  @ignore
  bool get isValidWss {
    String a = addr!=null ? addr!.trim() : "";
    return a.startsWith("wss://") || a.startsWith("ws://");
  }

  static List<RelayMetadata> fromJson(Map<String, Object?> e) {
    List<String> read = e["read"].toString().split(",");
    List<String> write = e["write"].toString().split(",");
    Set<String> all = {};
    all.addAll(read);
    all.addAll(write);
    return all.map((e) => RelayMetadata.full(addr: e, read: read.contains(e), write: write.contains(e)))
        .toList();
  }

  static Map<String, Object?> toFullJson(String pubKey,
      List<RelayMetadata> list, int updated_at) {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['pub_key'] = pubKey;
    List<String> read = [];
    List<String> write = [];
    for (var e in list) {
      if (e.read != null && e.read!) {
        read.add(e.addr!);
      }
      if (e.write != null && e.write!) {
        write.add(e.addr!);
      }
    }
    data['read'] = read.join(',');
    data['write'] = write.join(',');
    data['updated_at'] = updated_at;
    return data;
  }
}
