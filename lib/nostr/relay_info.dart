/// A relay information document
class RelayInfo {
  /// Relay name
  final String name;

  /// Relay description
  final String description;

  /// Nostr public key of the relay admin
  final String pubKey;

  /// Alternative contact of the relay admin
  final String contact;

  /// Nostr Implementation Possibilities supported by the relay
  final List<dynamic> nips;

  /// Relay software description
  final String software;

  final String icon;

  /// Relay software version identifier
  final String version;

  RelayInfo._(this.name, this.description, this.pubKey, this.contact, this.nips,
      this.software, this.version, this.icon);

  factory RelayInfo.fromJson(Map<dynamic, dynamic> json, String url) {
    final String id = json["id"] ?? '';
    final String name = json["name"] ?? '';
    final String description = json["description"] ?? "";
    final String pubKey = json["pubkey"] ?? "";
    final String contact = json["contact"] ?? "";
    String icon;
    if (json["icon"]!=null) {
       icon = json["icon"];
    } else {
      if (name.startsWith("damus.io")) {
        icon = "https://damus.io/img/logo.png";
      } else if (id.startsWith("wss://relay.snort.social")) {
        icon = "https://snort.social/favicon.ico";
      } else {
        icon = "${url}/favicon.ico";
      }
    }
    final List<dynamic> nips = json["supported_nips"] ?? [];
    final String software = json["software"] ?? "";
    final String version = json["version"] ?? "";
    return RelayInfo._(
        name, description, pubKey, contact, nips, software, version, icon);
  }
}
