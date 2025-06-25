import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:ndk/ndk.dart';
import 'package:ndk_amber/data_layer/repositories/signers/amber_event_signer.dart';
import 'package:yana/config/app_features.dart';
import 'package:yana/main.dart';
import 'package:yana/nostr/client_utils/keys.dart';
import 'package:yana/nostr/nip07/extension_event_signer.dart';
import 'package:yana/nostr/nip19/nip19.dart';
import 'package:yana/provider/data_util.dart';
import 'package:yana/utils/platform_util.dart';
import 'package:yana/utils/string_util.dart';
import '/js/js_helper.dart' as js;

class Base {
  static const double BASE_PADDING = 12;
  static const double BASE_PADDING_HALF = 6;
  static double BASE_FONT_SIZE = 16;
  static double BASE_FONT_SIZE_PC = 16;
}

Future<void> doLogin(
    String key, bool pubOnly, bool newKey, bool isExternalSigner) async {
  EasyLoading.showToast("Initializing...",
      dismissOnTap: true,
      duration: const Duration(seconds: 15),
      maskType: EasyLoadingMaskType.black);

  if (StringUtil.isBlank(key)) {
    EasyLoading.showError("Private key is null",
        dismissOnTap: true, duration: const Duration(seconds: 3));
    return;
  }
  try {
    bool isPublic = pubOnly || Nip19.isPubkey(key);
    if (Nip19.isPubkey(key) || Nip19.isPrivateKey(key)) {
      key = Nip19.decode(key);
    }
    sharedPreferences.remove(DataKey.NOTIFICATIONS_TIMESTAMP);
    sharedPreferences.remove(DataKey.FEED_POSTS_TIMESTAMP);
    sharedPreferences.remove(DataKey.FEED_REPLIES_TIMESTAMP);
    if (AppFeatures.enableNotifications) {
      notificationsProvider?.clear();
      newNotificationsProvider?.clear();
    }
    followEventProvider?.clear();
    followNewEventProvider?.clear();
    await settingProvider.addAndChangeKey(key, !isPublic, isExternalSigner,
        updateUI: false);
    bool isPrivate = !isPublic;
    String publicKey = isPrivate ? getPublicKey(key) : key;
    EventSigner eventSigner = settingProvider.isExternalSignerKey
        ? AmberEventSigner(publicKey: publicKey, amberFlutterDS: amberFlutterDS)
        : isPrivate || !PlatformUtil.isWeb()
            ? Bip340EventSigner(
                privateKey: isPrivate ? key : null, publicKey: publicKey)
            : Nip07EventSigner(await js.getPublicKeyAsync());
    ndk.accounts.loginExternalSigner(signer: eventSigner);

    await initRelayManager(isPublic ? key : getPublicKey(key), newKey);
  } catch (e) {
    EasyLoading.showError(e.toString(), duration: const Duration(seconds: 5));
  }
}

Future<void> initRelayManager(String publicKey, bool newKey) async {
  await initRelays(newKey: newKey);
  await EasyLoading.dismiss();
  await EasyLoading.showToast("loading feed...",
      dismissOnTap: true,
      duration: const Duration(seconds: 15),
      maskType: EasyLoadingMaskType.black);
  followEventProvider?.loadCachedFeed();
  if (AppFeatures.enableWallet) {
    nwcProvider?.init();
  }
  settingProvider.notifyListeners();
  await EasyLoading.dismiss();

  firstLogin = true;
}
