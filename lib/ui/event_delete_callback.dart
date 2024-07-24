import 'package:dart_ndk/domain_layer/entities/nip_01_event.dart';
import 'package:flutter/material.dart';

class EventDeleteCallback extends InheritedWidget {
  Function(Nip01Event) onDeleteCallback;

  EventDeleteCallback({
    super.key,
    required super.child,
    required this.onDeleteCallback,
  });

  static EventDeleteCallback? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<EventDeleteCallback>();
  }

  @override
  bool updateShouldNotify(covariant EventDeleteCallback oldWidget) {
    return false;
  }

  void onDelete(Nip01Event event) {
    onDeleteCallback(event);
  }
}
