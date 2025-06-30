enum VideoAutoplayPreference {
  always,
  wifiOnly,
  never,
}

extension VideoAutoplayPreferenceExtension on VideoAutoplayPreference {
  String get displayName {
    switch (this) {
      case VideoAutoplayPreference.always:
        return 'Always';
      case VideoAutoplayPreference.wifiOnly:
        return 'Only on Wifi';
      case VideoAutoplayPreference.never:
        return 'Never';
    }
  }
}
