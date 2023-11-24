import 'package:flutter/cupertino.dart';

class OpenStatus {
  static const OPEN = 1;
  static const CLOSE = -1;
}

class EnumObj {
  final dynamic value;
  Widget? widget;

  EnumObj(
    this.value,
    String? name, {Widget? widget}
  ) {
    if (widget!=null) {
      this.widget = widget!;
    } else {
      this.widget = Text(name??"");
    }
  }
}
