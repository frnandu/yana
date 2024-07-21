import 'package:dart_ndk/domain_layer/entities/nip_01_event.dart';

abstract class FindEventInterface {
  List<Nip01Event> findEvent(String str, {int? limit = 5});
}
