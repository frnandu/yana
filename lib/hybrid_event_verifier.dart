import 'dart:ui';

import 'package:ndk/data_layer/repositories/verifiers/bip340_event_verifier.dart';
import 'package:ndk/domain_layer/entities/nip_01_event.dart';
import 'package:flutter/services.dart';
import 'package:hex/hex.dart';
import 'package:yana/main.dart';
import 'package:yana/utils/platform_util.dart';

class HybridEventVerifier extends Bip340EventVerifier {

  static const platform = MethodChannel('flutter.native/helper');

  @override
  Future<bool> verify(Nip01Event event) async {
    if (PlatformUtil.isWeb()) {
      /// TODO implement JS binding for fast verification with some JS lib
      return true;
    }
    if (PlatformUtil.isAndroid() && appState != AppLifecycleState.inactive) {
      return await platform.invokeMethod("verifySignature", {
        "signature": HEX.decode(event.sig),
        "hash": HEX.decode(event.id),
        "pubKey": HEX.decode(event.pubKey)
      });
    }
    return await super.verify(event);
  }
}