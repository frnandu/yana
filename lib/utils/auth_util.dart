import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/widgets.dart';
import 'package:local_auth/local_auth.dart';

import '../i18n/i18n.dart';

class AuthUtil {
  static Future<bool> authenticate(BuildContext context, String reason,
      {bool showFail = true}) async {
    I18n s = I18n.of(context);
    var localAuth = LocalAuthentication();
    try {
      bool didAuthenticate = await localAuth.authenticate(
        localizedReason: reason,
      );
      if (!didAuthenticate && showFail) {
        BotToast.showText(text: s.Verify_failure);
      }
      return didAuthenticate;
    } catch (e) {
      BotToast.showText(text: s.Verify_error);
    }
    return false;
  }
}
