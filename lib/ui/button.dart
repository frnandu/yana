import 'package:flutter/material.dart';

class Button extends StatelessWidget {
  String text;
  Widget? before;
  Widget? after;
  double height;
  double? width;
  GestureTapCallback onTap;

  Button({super.key, required this.text, required this.onTap, this.before, this.after, this.height=48, this.width});

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
        clipBehavior: Clip.antiAlias,
        decoration: ShapeDecoration(
          color: themeData.primaryColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            before?? Container(),
            Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontFamily: 'Geist',
                fontWeight: FontWeight.w700,
                height: 0.09,
              ),
            ),
            after ?? Container(),
          ],
        ),
      ),
    );
  }
}
