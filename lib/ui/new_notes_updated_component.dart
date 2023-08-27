import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:flutter/material.dart';
import 'package:yana/ui/user_pic_component.dart';
import 'package:yana/utils/base.dart';

import '../main.dart';
import '../nostr/event.dart';

class NewNotesUpdatedComponent extends StatelessWidget {
  Function? onTap;
  String text;

  List<Event> newEvents;

  NewNotesUpdatedComponent({super.key, required this.newEvents, required this.text, this.onTap});

  @override
  Widget build(BuildContext context) {
    var themeData = Theme.of(context);
    var mainColor = themeData.primaryColor;
    Color? textColor = Colors.white;

    int maxAvatars = 10;
    double maxWidth = 100;
    double width = 20;
    int count = newEvents.length > maxAvatars ? maxAvatars : newEvents.length;
    double distance = (maxWidth - count * width) / count;

    if (distance > 3) {
      distance = 3;
    }

    List<String> pubKeys = newEvents.map((e) => e.pubKey).toSet().take(
        maxAvatars).toList();
    return GestureDetector(
        onTap: () {
          if (onTap != null) {
            onTap!();
          }
        },
        child:
        Container(
            padding: const EdgeInsets.only(
              top: 4,
              bottom: 4,
              left: Base.BASE_PADDING,
              right: Base.BASE_PADDING,
            ),
            decoration: BoxDecoration(
              color: mainColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(children: [
              Text(
                "↑",
                style: TextStyle(
                    color: textColor, fontSize: settingProvider.fontSize + 4),
              ),
              RowSuper(
                innerDistance: distance, //,
                outerDistance: 5.0,
                children: pubKeys.map((pubKey) {
                  return UserPicComponent(pubkey: pubKey, width: width + 10);
                }).toList(), //
              ),
              Text(text,style: TextStyle(color: textColor),
              )
            ]))
    );
  }
}
