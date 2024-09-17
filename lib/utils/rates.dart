import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import '../models/currency.dart';

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

  static Map<String,Currency>? currencies;

  static Future<Map<String,Currency>?> loadCurrencies() async {
    if (currencies==null) {
      // Step 1: Load the JSON string from the asset
      String jsonString = await rootBundle.loadString('assets/currencies-with-flags.json');

      // Step 2: Decode the JSON string
      List<dynamic> jsonData = jsonDecode(jsonString);

      currencies = {
        for (var item in jsonData)
          item['code']: Currency.fromJson(item)
      };
    }
    return currencies;
  }

  static final String RATES_API_ENDPOINT =
      "https://api.coingecko.com/api/v3/exchange_rates";

  static Map<String, dynamic>? rates = null;
  static DateTime? lastFetchTime;
  static const Duration refreshAfter = Duration(hours: 1);

  static Future<Map<String, dynamic>?> fiatCurrencies() async {
    if (rates != null &&
        lastFetchTime != null &&
        lastFetchTime!.isBefore(DateTime.now().add(refreshAfter))) {
      return rates;
    }
    Uri uri = Uri.parse(RATES_API_ENDPOINT).replace(scheme: 'https');
    try {
      final response = await http.get(uri);
      final decodedResponse =
          jsonDecode(utf8.decode(response.bodyBytes)) as Map;
      if (decodedResponse.containsKey("rates")) {
        rates = decodedResponse["rates"];
        lastFetchTime = DateTime.now();
        return rates;
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    return null;
  }

  static Future<Map<String, dynamic>?> fiatCurrency(String currency) async {
    Map<String, dynamic>? rates = await fiatCurrencies();
    if (rates != null && rates.containsKey(currency)) {
      return rates[currency];
    }
    return null;
  }
}
