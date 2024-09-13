import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class RatesUtil {

  static fromJson(Map<dynamic, dynamic> json, String unit) {
    // final String name = json["name"] ?? '';
    // final String description = json["description"] ?? "";
    // final String pubKey = json["pubkey"] ?? "";
    // final String contact = json["contact"] ?? "";
    // String icon;
    // if (json["icon"]!=null) {
    //   icon = json["icon"];
    // } else {
    //   icon = "$url${url.endsWith("/")?"":"/"}favicon.ico";
    // }
    // final List<dynamic> nips = json["supported_nips"] ?? [];
    // final String software = json["software"] ?? "";
    // final String version = json["version"] ?? "";
    return 0;
  }

  static final String RATES_API_ENDPOINT = "https://api.coingecko.com/api/v3/exchange_rates";

  static Future<Map<String,dynamic>?> coinbase(String currency) async {
    Uri uri = Uri.parse(RATES_API_ENDPOINT).replace(scheme: 'https');
    try {
      final response = await http.get(uri);
      final decodedResponse = jsonDecode(utf8.decode(response.bodyBytes)) as Map;
      if (decodedResponse.containsKey("rates")) {
        Map<String,dynamic>? rates = decodedResponse["rates"];
        if (rates!=null && rates.containsKey(currency)) {
          return rates[currency];
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    return null;
  }
}