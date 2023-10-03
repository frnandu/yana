import 'package:yana/utils/string_util.dart';

import '../client_utils/keys.dart';

/// A single contact for use with [ContactList]
class Contact {

  static const PETNAME_COMMUNITY = "_COMMUNITY";
  static const PETNAME_TAG = "_TAG";
  static const PETNAME_EVENT = "_EVENT";

  /// Creates a new [Contact].
  ///
  /// [publicKey] is a public key to identify the contact.
  /// [url] is a relay URL where events from [publicKey] can be found.
  /// [petname] is a local name (nickname) for the profile.
  ///
  /// An [ArgumentError] is thrown if [publicKey] is invalid or if [url] is not
  /// a valid relay URL.
  Contact({required this.publicKey, this.url = '', this.petname = ''}) {
    if (!keyIsValid(publicKey)) {
      throw ArgumentError.value(publicKey, 'publicKey', 'Invalid key');
    }
    if (url.isNotEmpty &&
        !url.contains(RegExp(
            r'^(wss?:\/\/)([0-9]{1,3}(?:\.[0-9]{1,3}){3}|[^:]+):?([0-9]{1,5})?$'))) {
      throw ArgumentError.value(url, 'url', 'Invalid relay address');
    }
  }

  /// The contact's public key.
  final String publicKey;

  /// A known good relay URL for the contact.
  final String url;

  /// The contact's petname (nickname).
  final String petname;

  Map<String, Object?> toDB(String pubKey) {
    return toDBFromValues(pubKey, publicKey, petname, url);
  }
  
  static Map<String, Object?> toDBFromValues(String pubKey, String contact, String? petname, String? url) {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['pub_key'] = pubKey;
    data['contact'] = contact;
    if (StringUtil.isNotBlank(petname)) {
      data['petname'] = petname;
    }
    if (StringUtil.isNotBlank(url)) {
      data['relay'] = url;
    }
    return data;
  }
}
