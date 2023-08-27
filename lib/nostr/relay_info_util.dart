import 'dart:convert';
import 'package:http/http.dart' as http;
import 'relay_info.dart';

class RelayInfoUtil {
  static Future<RelayInfo> get(String url) async {
    Uri uri = Uri.parse(url).replace(scheme: 'https');
    final response = await http.get(uri,
        headers: {'Accept': 'application/nostr+json'});
    final decodedResponse = jsonDecode(utf8.decode(response.bodyBytes)) as Map;
    return RelayInfo.fromJson(decodedResponse, uri.toString());
  }
}
