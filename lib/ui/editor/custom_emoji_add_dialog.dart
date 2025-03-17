import 'dart:developer';

import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter/material.dart';
import 'package:yana/models/custom_emoji.dart';

import '../../utils/base.dart';
import '../../i18n/i18n.dart';
import '../../main.dart';
import '../../utils/router_util.dart';
import '../../utils/string_util.dart';
import '../content/content_custom_emoji_component.dart';

class CustomEmojiAddDialog extends StatefulWidget {
  const CustomEmojiAddDialog({super.key});

  @override
  State<StatefulWidget> createState() {
    return _CustomEmojiAddDialog();
  }

  static Future<CustomEmoji?> show(BuildContext context) async {
    return await showDialog<CustomEmoji>(
      context: context,
      builder: (_context) {
        return CustomEmojiAddDialog();
      },
    );
  }
}

class _CustomEmojiAddDialog extends State<CustomEmojiAddDialog> {
  late TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    var s = I18n.of(context);
    var themeData = Theme.of(context);
    Color cardColor = themeData.cardColor;
    var mainColor = themeData.primaryColor;
    var titleFontSize = themeData.textTheme.bodyLarge!.fontSize;

    List<Widget> list = [];

    list.add(Container(
      margin: const EdgeInsets.only(bottom: Base.BASE_PADDING),
      child: Text(
        s.Add_Custom_Emoji,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: titleFontSize,
        ),
      ),
    ));

    list.add(Container(
      margin: EdgeInsets.only(bottom: Base.BASE_PADDING),
      child: TextField(
        controller: controller,
        minLines: 1,
        maxLines: 1,
        autofocus: true,
        decoration: InputDecoration(
          hintText: s.Input_Custom_Emoji_Name,
          border: OutlineInputBorder(borderSide: BorderSide(width: 1)),
        ),
      ),
    ));

    List<Widget> imageWidgetList = [
      GestureDetector(
        onTap: pickPicture,
        child: Icon(Icons.image),
      )
    ];
    if (StringUtil.isNotBlank(filepath)) {
      imageWidgetList.add(ContentCustomEmojiComponent(imagePath: filepath!));
    }

    list.add(Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: imageWidgetList,
    ));

    list.add(Container(
      margin: EdgeInsets.only(
        top: Base.BASE_PADDING,
        bottom: 6,
      ),
      child: Ink(
        decoration: BoxDecoration(color: mainColor),
        child: InkWell(
          onTap: () {
            _onComfirm();
          },
          highlightColor: mainColor.withOpacity(0.2),
          child: Container(
            color: mainColor,
            height: 40,
            alignment: Alignment.center,
            child: Text(
              I18n.of(context).Confirm,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    ));

    var main = Container(
      padding: EdgeInsets.all(Base.BASE_PADDING),
      decoration: BoxDecoration(
        color: cardColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: list,
      ),
    );

    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.2),
      body: FocusScope(
        // autofocus: true,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            RouterUtil.back(context);
          },
          child: Container(
            width: double.infinity,
            // height: double.infinity,
            padding: const EdgeInsets.only(
              left: Base.BASE_PADDING,
              right: Base.BASE_PADDING,
            ),
            alignment: Alignment.center,
            child: GestureDetector(
              onTap: () {},
              child: main,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> pickPicture() async {
    // final images = await Uploader.pick(context);
    // filepath = images!=null?images[0]:null;
    // TODO
    setState(() {});
  }

  static const _regExp = r"^[ZA-ZZa-z0-9_]+$";

  String? filepath;

  Future<void> _onComfirm() async {
    var s = I18n.of(context);
    var text = controller.text;
    if (StringUtil.isBlank(text)) {
      EasyLoading.show(status: s.Input_can_not_be_null);
      return;
    }

    if (RegExp(_regExp).firstMatch(text) == null) {
      EasyLoading.show(status: s.Input_parse_error);
      return;
    }

    EasyLoading.show(status: "...");
    try {
      // var imagePath = await Uploader.upload(
      //   filepath!,
      //   imageService: settingProvider.imageService,
      // );
      // log("$text $imagePath");
      //
      // if (StringUtil.isBlank(imagePath)) {
      //   EasyLoading.show(status: s.Upload_fail);
      //   return;
      // }
      //
      // filepath = imagePath;
    } finally {
      EasyLoading.dismiss();
    }

    RouterUtil.back(context, CustomEmoji(name: text, filepath: filepath));
  }
}
