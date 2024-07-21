import 'package:dart_ndk/domain_layer/entities/nip_01_event.dart';
import 'package:flutter/material.dart';

class EventReplyCallback extends InheritedWidget {
  Function(Nip01Event) onReplyCallback;

  EventReplyCallback({
    super.key,
    required super.child,
    required this.onReplyCallback,
  });

  static EventReplyCallback? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<EventReplyCallback>();
  }

  @override
  bool updateShouldNotify(covariant EventReplyCallback oldWidget) {
    return false;
  }

  void onReply(Nip01Event event) {
    onReplyCallback(event);
  }
}
