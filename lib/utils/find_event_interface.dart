import 'package:dart_ndk/nips/nip01/event.dart';

abstract class FindEventInterface {
  List<Nip01Event> findEvent(String str, {int? limit = 5});
}
