import 'package:shared_preferences/shared_preferences.dart';

class DataUtil {
  static SharedPreferences? _prefs;

  static Future<SharedPreferences> getInstance() async {
    if (_prefs == null) {
      _prefs = await SharedPreferences.getInstance();
    }
    return _prefs!;
  }
}

class DataKey {
  static final String SETTING = "setting";

  static final String RELAY_UPDATED_TIME = "relayUpdatedTime";

  static final String DIRTYWORD_LIST = "dirtywordList";

  static final String CUSTOM_EMOJI_LIST = "customEmojiList";

  static final String NWC_PERMISSIONS = "nwcPermissions";

  static final String NWC_PUB_KEY= "nwcPubKey";

  static final String NWC_RELAY= "nwcRelay";

  static final String FEED_POSTS_TIMESTAMP= "feedPosts";

  static final String FEED_REPLIES_TIMESTAMP= "feedReplies";

  static final String NOTIFICATIONS_TIMESTAMP= "notificationsTimestamp";
}
