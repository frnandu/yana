import 'package:flutter/material.dart';

import '../utils/base.dart';
import '../utils/base_consts.dart';
import '../utils/router_util.dart';

class EnumSelectorComponent extends StatelessWidget {
  final List<EnumObj> list;
  final bool showSearchInput;

  Widget Function(BuildContext, EnumObj)? enumItemBuild;

  EnumSelectorComponent(
      {required this.list, this.enumItemBuild, required this.showSearchInput});

  static Future<EnumObj?> show(BuildContext context, List<EnumObj> list,
      {bool showSearchInput = false}) async {
    return await showDialog<EnumObj?>(
      context: context,
      builder: (_context) {
        return EnumSelectorComponent(
          list: list,
          showSearchInput: showSearchInput,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var themeData = Theme.of(context);
    Color cardColor = themeData.cardColor;
    var maxHeight = MediaQuery.of(context).size.height;

    List<Widget> widgets = [];
    for (var i = 0; i < list.length; i++) {
      var enumObj = list[i];
      if (enumItemBuild != null) {
        widgets.add(enumItemBuild!(context, enumObj));
      } else {
        widgets.add(EnumSelectorItemComponent(
          enumObj: enumObj,
          isLast: i == list.length - 1,
        ));
      }
    }

    Widget main = Column(children: [
      TextField(
        autofocus: true,
        textAlign: TextAlign.center,
        cursorColor: themeData.primaryColor,
        style: const TextStyle(fontSize: 80, fontFamily: 'Geist.Mono'),
        // textDirection: TextDirection.ltr,
        controller: amountInputcontroller,
        keyboardType:
        TextInputType.numberWithOptions(decimal: !satsInput),
        inputFormatters: <TextInputFormatter>[
          satsInput
              ? FilteringTextInputFormatter.digitsOnly
              : FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))
        ],
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: "  0",
          hintTextDirection: TextDirection.ltr,
          hintStyle: TextStyle(
              fontSize: 80,
              color: themeData.disabledColor,
              fontFamily: 'Geist.Mono'),
          contentPadding: const EdgeInsets.only(right: 20),
        ),
      ),
      Container(
          width: double.infinity,
          padding: const EdgeInsets.only(
            left: Base.BASE_PADDING,
            right: Base.BASE_PADDING,
            top: Base.BASE_PADDING_HALF,
            bottom: Base.BASE_PADDING_HALF,
          ),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(15)),
            color: cardColor,
          ),
          constraints: BoxConstraints(
            maxHeight: maxHeight * 0.8,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: widgets,
            ),
          ))
    ]);

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
            height: double.infinity,
            padding: const EdgeInsets.only(
              left: Base.BASE_PADDING,
              right: Base.BASE_PADDING,
            ),
            child: GestureDetector(
              onTap: () {},
              child: main,
            ),
            alignment: Alignment.center,
          ),
        ),
      ),
    );
  }
}

class EnumSelectorItemComponent extends StatelessWidget {
  static const double HEIGHT = 44;

  final EnumObj enumObj;

  final bool isLast;

  Function(EnumObj)? onTap;

  Color? color;

  EnumSelectorItemComponent({
    required this.enumObj,
    this.isLast = false,
    this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    var themeData = Theme.of(context);
    var dividerColor = themeData.dividerColor;

    Widget main = Container(
      padding: const EdgeInsets.only(
          left: Base.BASE_PADDING + 5, right: Base.BASE_PADDING + 5),
      child: enumObj.widget,
    );

    return GestureDetector(
      onTap: () {
        if (onTap != null) {
          onTap!(enumObj);
        } else {
          RouterUtil.back(context, enumObj);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: color,
          border:
              isLast ? null : Border(bottom: BorderSide(color: dividerColor)),
        ),
        alignment: Alignment.center,
        height: HEIGHT,
        child: main,
      ),
    );
  }
}
