import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:ndk/domain_layer/entities/contact_list.dart';
import 'package:yana/utils/router_path.dart';
import 'package:yana/main.dart';
import 'package:yana/provider/contact_list_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../utils/base.dart';

class TagInfoComponent extends StatefulWidget {
  final String tag;

  final double height;

  bool jumpable;

  ContactList? contactList;

  TagInfoComponent(
      {super.key,
      required this.tag,
      this.height = 80,
      this.jumpable = false,
      this.contactList});

  @override
  State<StatefulWidget> createState() {
    return _TagInfoComponent();
  }
}

class _TagInfoComponent extends State<TagInfoComponent> {
  @override
  Widget build(BuildContext context) {
    var themeData = Theme.of(context);
    var cardColor = themeData.cardColor;
    var bodyLargeFontSize = themeData.textTheme.bodyLarge!.fontSize;

    IconData iconData = Icons.star_border;
    Color? color;
    bool exist = contactListProvider.containTagInContactList(
        widget.contactList, widget.tag);
    if (exist) {
      iconData = Icons.star;
      color = themeData.primaryColor;
    }

    var main = Container(
      height: widget.height,
      color: cardColor,
      alignment: Alignment.center,
      margin: const EdgeInsets.only(bottom: Base.BASE_PADDING_HALF),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "#${widget.tag}",
            style: TextStyle(
              fontSize: bodyLargeFontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
          GestureDetector(
            onTap: () async {
              bool finished = false;
              Future.delayed(const Duration(seconds: 1), () {
                if (!finished) {
                  EasyLoading.show(
                      status: "Refreshing from relays before action...",
                      maskType: EasyLoadingMaskType.black);
                }
              });
              if (exist) {
                await contactListProvider.removeTag(widget.tag);
              } else {
                await contactListProvider.addTag(widget.tag);
              }
              finished = true;
              EasyLoading.dismiss();
            },
            child: Container(
              margin: const EdgeInsets.only(left: Base.BASE_PADDING_HALF),
              child: Icon(
                iconData,
                color: color,
              ),
            ),
          )
        ],
      ),
    );

    if (widget.jumpable) {
      return GestureDetector(
        onTap: () {
          context.go(RouterPath.TAG_DETAIL, extra: widget.tag);
        },
        behavior: HitTestBehavior.translucent,
        child: main,
      );
    } else {
      return main;
    }
  }
}
