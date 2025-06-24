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
  static String USER = AppFeatures.enableSocial ? "/user" : "/user_disabled";
  static const String PROFILE_EDITOR = "/profileEditor";
  static String USER_CONTACT_LIST = AppFeatures.enableSocial
      ? "/userContactList"
      : "/userContactList_disabled";
  static String USER_HISTORY_CONTACT_LIST = AppFeatures.enableSocial
      ? "/userHistoryContactList"
      : "/userHistoryContactList_disabled";
  static String USER_ZAP_LIST =
      AppFeatures.enableSocial ? "/userZapList" : "/userZapList_disabled";
  static String USER_RELAYS =
      AppFeatures.enableSocial ? "/userRelays" : "/userRelays_disabled";
  static const String RELAY_SET = "/relaySet";
  static const String RELAY_LIST = "/relayList";
  static const String MUTE_LIST = "/muteList";
  static String DM_DETAIL =
      AppFeatures.enableDm ? "/dmDetail" : "/dmDetail_disabled";
  static String THREAD_DETAIL =
      AppFeatures.enableSocial ? "/threadDetail" : "/threadDetail_disabled";
  static String EVENT_DETAIL =
      AppFeatures.enableSocial ? "/eventDetail" : "/eventDetail_disabled";
  static String TAG_DETAIL =
      AppFeatures.enableSocial ? "/tagDetail" : "/tagDetail_disabled";
  static const String SETTING = "/setting";
  static const String SETTINGS_WALLET = "/setting/wallet";
  static const String QRSCANNER = "/qrScanner";
  static const String RELAY_INFO = "/relayInfo";
  static String FOLLOWED_TAGS_LIST = AppFeatures.enableSocial
      ? "/followedTagsList"
      : "/followedTagsList_disabled";
  static String COMMUNITY_DETAIL = AppFeatures.enableSocial
      ? "/communityDetail"
      : "/communityDetail_disabled";
  static String FOLLOWED_COMMUNITIES = AppFeatures.enableSocial
      ? "/followedCommunities"
      : "/followedCommunities_disabled";
  static String FOLLOWED =
      AppFeatures.enableSocial ? "/followed" : "/followed_disabled";
  static String SEARCH =
      AppFeatures.enableSearch ? "/search" : "/search_disabled";
  static const String LOGIN = "/login";
}
