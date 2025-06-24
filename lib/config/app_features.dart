// lib/config/app_features.dart

class AppFeatures {
  // Define feature flags based on buildConfigFields in build.gradle
  // The keys (e.g., 'ENABLE_WALLET') must match exactly what's in build.gradle.
  static const bool enableWallet =
      bool.fromEnvironment('ENABLE_WALLET', defaultValue: false);
  static const bool enableSocial =
      bool.fromEnvironment('ENABLE_SOCIAL', defaultValue: false);
  static const bool enableCommunities =
      bool.fromEnvironment('ENABLE_COMMUNITIES', defaultValue: false);
  static const bool enableDm =
      bool.fromEnvironment('ENABLE_DM', defaultValue: false);
  static const bool enableSearch =
      bool.fromEnvironment('ENABLE_SEARCH', defaultValue: false);
  static const bool enableNotifications =
      bool.fromEnvironment('ENABLE_NOTIFICATIONS', defaultValue: false);

  // Helper method to check if only wallet feature is enabled
  static bool get isWalletOnly =>
      enableWallet &&
      !enableSocial &&
      !enableCommunities &&
      !enableDm &&
      !enableSearch &&
      !enableNotifications;

  // Helper method to print active features, useful for debugging
  static void printActiveFeatures() {
    print('Active App Features:');
    print('  Wallet: $enableWallet');
    print('  Social: $enableSocial');
    print('  Communities: $enableCommunities');
    print('  DM: $enableDm');
    print('  Search: $enableSearch');
    print('  Notifications: $enableNotifications');
    print('  Wallet Only: $isWalletOnly');
  }
}
