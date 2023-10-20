import 'package:flutter/cupertino.dart';

class OpenStatus {
  static const OPEN = 1;
  static const CLOSE = -1;
}

class EnumObj {
  final dynamic value;
  late Widget widget;

  EnumObj(
    this.value,
    String? name, {Widget? widget}
  ) {
    if (widget!=null) {
      this.widget = widget!;
    } else {
      widget = Text(name??"");
    }
  }
}
