@JS()
library script.js;

import 'dart:js_util';

import 'package:js/js.dart';
import 'package:yana/nostr/event.dart';

// This function will do Promise to return something
@JS()
external dynamic getPublicKey();

// This function will open new popup window for given URL.
@JS()
external dynamic signEvent(Event event);