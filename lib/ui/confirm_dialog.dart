import 'package:flutter/material.dart';
import 'package:yana/utils/router_util.dart';

import '../i18n/i18n.dart';

class ConfirmDialog {
  static Future<bool?> show(BuildContext context, String content, {bool onlyCancel = false}) async {
    var s = I18n.of(context);
    return await showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text(""),
            content: Text(content),
            actions: <Widget>[
              TextButton(
                child: Text(s.Cancel),
                onPressed: () {
                  Navigator.pop(context, false);
                },
              ),
              onlyCancel? Container():
              TextButton(
                child: Text(s.Confirm),
                onPressed: () async {
                  RouterUtil.back(context, true);
                },
              ),
            ],
          );
        });
  }
}
