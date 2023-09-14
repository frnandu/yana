import 'package:yana/nostr/event.dart';
import 'package:yana/nostr/nip47/nwc_kind.dart';

class NwcRequestInfo {

  String supportedCommand;

  NwcRequestInfo({
    required this.supportedCommand,
  });

  static NwcRequestInfo? fromEvent(Event event) {
    if (event.kind == NwcKind.INFO_REQUEST) {
      return NwcRequestInfo(
        supportedCommand: event.content,
      );
    }

    return null;
  }
}
