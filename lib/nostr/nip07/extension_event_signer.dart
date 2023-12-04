import 'package:dart_ndk/nips/nip01/event.dart';
import 'package:dart_ndk/nips/nip01/event_signer.dart';
import 'package:dart_ndk/nips/nip01/helpers.dart';
import '/js/js_helper.dart' as js;

class Nip07EventSigner extends EventSigner {

  String publicKey;

  Nip07EventSigner(this.publicKey);

  @override
  Future<void> sign(Nip01Event event) async {
    event.sig = await js.signSchnorrAsync(event.id);
    // if (kDebugMode) {
    //   EasyLoading.show(status: signedEvent.toString());
    //   print("SIGNED EVENT: " + signedEvent.toString());
    // }
  }

  @override
  String getPublicKey() {
    return publicKey;
  }

  @override
  bool canSign() {
    return Helpers.isNotBlank(publicKey);
  }

  @override
  Future<String?> decrypt(String msg, String destPubKey) {
    // TODO: implement decrypt
    throw UnimplementedError();
  }

  @override
  String? getPrivateKey() {
    throw UnimplementedError();
  }

  @override
  Future<String?> encrypt(String msg, String destPubKey) {
    // TODO: implement encrypt
    throw UnimplementedError();
  }
}