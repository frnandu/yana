import 'package:dart_ndk/nips/nip01/event.dart';

import '../nostr/event.dart';

Future<String> getPublicKeyAsync() {
  return Future.value("");
}

Future<Event> signEventAsync(Nip01Event event) {
  return Future.value(null);
}

Future<String> signSchnorrAsync(String msg) {
  return Future.value(null);
}
