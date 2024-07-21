@JS()
library script.js;

import 'dart:js_util';

import 'package:dart_ndk/domain_layer/entities/nip_01_event.dart';
import 'package:js/js.dart';

// This function will do Promise to return something
@JS()
external dynamic getPublicKey();

// This function will open new popup window for given URL.
@JS()
external dynamic signEvent(Nip01Event event);


// This function will open new popup window for given URL.
@JS()
external dynamic signSchnorr(String msg);

Future<String> getPublicKeyAsync() async {
  return await promiseToFuture(await getPublicKey());
}

Future<Nip01Event> signEventAsync(Nip01Event event) async {
  return await promiseToFuture(await signEvent(event));
}

Future<String> signSchnorrAsync(String msg) async {
  return await promiseToFuture(await signSchnorr(msg));
}