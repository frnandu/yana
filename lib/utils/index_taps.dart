import '../config/app_features.dart';

class IndexTaps {
  static int FOLLOW = 0;
  static int SEARCH = AppFeatures.enableSearch ? 1 : -1;
  static int DM = AppFeatures.enableSearch
      ? (AppFeatures.enableDm ? 2 : -1)
      : (AppFeatures.enableDm ? 1 : -1);
  static int NOTIFICATIONS = AppFeatures.enableSearch
      ? (AppFeatures.enableDm ? 3 : 2)
      : (AppFeatures.enableDm ? 2 : 1);
}
