import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:ndk/domain_layer/entities/nip_01_event.dart';
import 'package:flutter/material.dart';
import 'package:yana/ui/user_pic_component.dart';
import 'package:yana/utils/base.dart';

import '../main.dart';

class NewNotesUpdatedComponent extends StatelessWidget {
  Function? onTap;
  String _text;

  List<Nip01Event> newEvents;

  NewNotesUpdatedComponent(
      {super.key, required this.newEvents, required String text, this.onTap})
      : _text = text;

  @override
  Widget build(BuildContext context) {
    var themeData = Theme.of(context);
    var mainColor = themeData.primaryColor;
    Color? textColor = Colors.white;

    int maxAvatars = 3;
    double maxWidth = 30;
    double width = 20;
    int count = newEvents.length > maxAvatars ? maxAvatars : newEvents.length;
    double distance = (maxWidth - count * width) / count;

    if (distance > 3) {
      distance = 3;
    }
    Set<String> pubKeysSet =
        newEvents.map((e) => e.pubKey).toSet();
    List<String> pubKeys = pubKeysSet.take(maxAvatars).toList();
    final plus = pubKeysSet.length - maxAvatars;
    var plusText = "+$plus";
    if (plus>1000) {
      plusText = "+${plus/1000}k";
    }
    return GestureDetector(
        onTap: () {
          if (onTap != null) {
            onTap!();
          }
        },
        child: Container(
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
                children: [
                  ...pubKeys.map((pubKey) {
                    return UserPicComponent(pubkey: pubKey, width: width + 10);
                  }),
                  newEvents.length > maxAvatars
                      ? Container(
                          width: width + 10,
                          // Match the width of other items
                          height: width + 10,
                          // Make it circular with equal width/height
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color:
                                themeData.cardColor, // Or any color you prefer
                          ),
                          child: Center(
                            child: Text(
                              plusText,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 10, // Adjust as needed
                              ),
                            ),
                          ),
                        )
                      : Container(),
                ], //
              ),
              Text(
                _text,
                style: TextStyle(color: textColor),
              )
            ])));
  }
}
