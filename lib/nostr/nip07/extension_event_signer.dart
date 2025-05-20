import 'package:ndk/domain_layer/entities/nip_01_event.dart';
import 'package:ndk/domain_layer/repositories/event_signer.dart';
import 'package:ndk/shared/nips/nip01/helpers.dart';
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
  Future<String?> decrypt(String msg, String destPubKey, { String? id }) {
    // TODO: implement decrypt
    throw UnimplementedError();
  }

  @override
  Future<String?> encrypt(String msg, String destPubKey, { String? id }) {
    // TODO: implement encrypt
    throw UnimplementedError();
  }

  @override
  Future<String?> decryptNip44({required String ciphertext, required String senderPubKey}) {
    throw UnimplementedError();
  }

  @override
  Future<String?> encryptNip44({required String plaintext, required String recipientPubKey}) {
    throw UnimplementedError();
  }
}