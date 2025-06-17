import '../config/app_features.dart';

class RouterPath {
  static const String INDEX = "/";
  static const String EDITOR = "/editor";
  static const String NOTICES = "/notices";
  static const String KEY_BACKUP = "/keyBackup";
  static const String WALLET = "/wallet";
  static const String WALLET_TRANSACTIONS = "/wallet/transactions";
  static const String WALLET_RECEIVE = "/wallet/receive";
  static const String WALLET_RECEIVE_INVOICE = "/wallet/receive/invoice";
  static const String WALLET_SEND = "/wallet/send";
  static const String WALLET_SEND_CONFIRM = "/wallet/send/confirm";
  static const String NWC = "/nwc";
  static const String RELAYS = "/relays";
  static const String USER = "/user";
  static const String PROFILE_EDITOR = "/profileEditor";
  static const String USER_CONTACT_LIST = "/userContactList";
  static const String USER_HISTORY_CONTACT_LIST = "/userHistoryContactList";
  static const String USER_ZAP_LIST = "/userZapList";
  static const String USER_RELAYS = "/userRelays";
  static const String RELAY_SET = "/relaySet";
  static const String RELAY_LIST = "/relayList";
  static const String MUTE_LIST = "/muteList";
  static String DM_DETAIL = AppFeatures.enableDm ? "/dmDetail" : "/dmDetail_disabled";
  static const String THREAD_DETAIL = "/threadDetail";
  static const String EVENT_DETAIL = "/eventDetail";
  static const String TAG_DETAIL = "/tagDetail";
  static const String SETTING = "/setting";
  static const String SETTINGS_WALLET = "/setting/wallet";
  static const String QRSCANNER = "/qrScanner";
  static const String RELAY_INFO = "/relayInfo";
  static const String FOLLOWED_TAGS_LIST = "/followedTagsList";
  static const String COMMUNITY_DETAIL = "/communityDetail";
  static const String FOLLOWED_COMMUNITIES = "/followedCommunities";
  static const String FOLLOWED = "/followed";
  static String SEARCH = AppFeatures.enableSearch ? "/search" : "/search_disabled";
  static const String LOGIN = "/login";
}
