import 'package:dart_ndk/nips/nip01/event.dart';
import 'package:dart_ndk/nips/nip01/event_signer.dart';
import '/js/js_helper.dart' as js;

class Nip07EventSigner extends EventSigner {
  @override
  Future<void> sign(Nip01Event event) async {
    event.sig = await js.signSchnorrAsync(event.id);
    // if (kDebugMode) {
    //   BotToast.showText(text: signedEvent.toString());
    //   print("SIGNED EVENT: " + signedEvent.toString());
    // }
  }
}