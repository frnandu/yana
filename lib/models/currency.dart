class Currency {
  final String code;
  final String name;
  final String country;
  final String countryCode;
  final String? flag;

  Currency({
    required this.code,
    required this.name,
    required this.country,
    required this.countryCode,
    this.flag,
  });

  // Factory constructor to create an instance from a map (parsed JSON)
  factory Currency.fromJson(Map<String, dynamic> json) {
    return Currency(
      code: json['code'],
      name: json['name'],
      country: json['country'],
      countryCode: json['countryCode'],
      flag: json['flag'],
    );
  }

  // Method to convert object back to JSON
  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
      'country': country,
      'countryCode': countryCode,
      'flag': flag,
    };
  }
}
