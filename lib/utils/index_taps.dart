import '../config/app_features.dart';

class IndexTaps {
  static int get WALLET {
    if (AppFeatures.isWalletOnly) return 0;
    return -1;
  }

  static int get FOLLOW {
    if (AppFeatures.isWalletOnly) return -1;
    if (AppFeatures.enableSocial) return 0;
    return -1;
  }

  static int get SEARCH {
    if (AppFeatures.isWalletOnly) return -1;
    if (AppFeatures.enableSocial) {
      return AppFeatures.enableSearch ? 1 : -1;
    } else {
      return AppFeatures.enableSearch ? 0 : -1;
    }
  }

  static int get DM {
    if (AppFeatures.isWalletOnly) return -1;
    if (AppFeatures.enableSocial) {
      if (AppFeatures.enableSearch) {
        return AppFeatures.enableDm ? 2 : -1;
      } else {
        return AppFeatures.enableDm ? 1 : -1;
      }
    } else {
      if (AppFeatures.enableSearch) {
        return AppFeatures.enableDm ? 1 : -1;
      } else {
        return AppFeatures.enableDm ? 0 : -1;
      }
    }
  }

  static int get NOTIFICATIONS {
    if (AppFeatures.isWalletOnly) return -1;
    if (AppFeatures.enableSocial) {
      if (AppFeatures.enableNotifications) {
        if (AppFeatures.enableSearch) {
          return AppFeatures.enableDm ? 3 : 2;
        } else {
          return AppFeatures.enableDm ? 2 : 1;
        }
      } else {
        return -1;
      }
    } else {
      if (AppFeatures.enableNotifications) {
        if (AppFeatures.enableSearch) {
          return AppFeatures.enableDm ? 2 : 1;
        } else {
          return AppFeatures.enableDm ? 1 : 0;
        }
      } else {
        return -1;
      }
    }
  }
}
