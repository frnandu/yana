import 'package:flutter/material.dart';

class Button extends StatelessWidget {
  String text;
  Widget? before;
  Widget? after;

  double height;
  double? width;
  double fontSize;
  Color? fontColor;
  bool fill;
  bool border;
  GestureTapCallback onTap;

  Button({super.key, required this.text, required this.onTap, this.before, this.after, this.height=48, this.width, this.fill = true, this.fontSize=16, this.border=true, this.fontColor});

  @override
  Widget build(BuildContext context) {
    var themeData = Theme.of(context);
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: onTap,
      child: Container(
        height: height,
        width: width,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        clipBehavior: border?  Clip.antiAlias : Clip.none,
        decoration: border? ShapeDecoration(
          color: fill? themeData.primaryColor : null,
          shape: RoundedRectangleBorder(
            side: BorderSide(width: 1, color: themeData.primaryColor),
            borderRadius: BorderRadius.circular(8),
          )
        ): null,
        // ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            before?? Container(),
            Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: fontColor??(fill?Colors.white:themeData.textTheme.labelSmall!.color),
                fontSize: fontSize,
                fontFamily: 'Geist',
                fontWeight: FontWeight.w700,
              ),
            ),
            after ?? Container(),
          ],
        ),
      ),
    );
  }
}
