import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../utils/base.dart';
import '../utils/base_consts.dart';
import '../utils/router_util.dart';

class EnumSelectorComponent extends StatefulWidget {
  final List<EnumObj> list;
  final Widget Function(BuildContext, EnumObj)? enumItemBuild;

  const EnumSelectorComponent({
    super.key,
    required this.list,
    this.enumItemBuild,
  });

  static Future<EnumObj?> show(BuildContext context, List<EnumObj> list) async {
    return await showDialog<EnumObj?>(
      context: context,
      builder: (_context) {
        return EnumSelectorComponent(
          list: list,
        );
      },
    );
  }

  @override
  State<EnumSelectorComponent> createState() => _EnumSelectorComponentState();
}

class _EnumSelectorComponentState extends State<EnumSelectorComponent> {
  late TextEditingController _searchController;
  late List<EnumObj> _filteredList;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _filteredList = widget.list;
    _searchController.addListener(_filterList);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterList);
    _searchController.dispose();
    super.dispose();
  }

  void _filterList() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredList = widget.list.where((enumObj) {
        // Try to extract text from the widget if it's RichText or Text
        String itemText = enumObj.value.toLowerCase();
        if (enumObj.widget is RichText) {
          final richText = enumObj.widget as RichText;
          itemText = richText.text.toPlainText().toLowerCase();
        } else if (enumObj.widget is Text) {
          final textWidget = enumObj.widget as Text;
          if (textWidget.data != null) {
            itemText = textWidget.data!.toLowerCase();
          }
        }
        return itemText.contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    var themeData = Theme.of(context);
    Color cardColor = themeData.cardColor;
    var maxHeight = MediaQuery.of(context).size.height;

    List<Widget> widgets = [];
    for (var i = 0; i < _filteredList.length; i++) {
      var enumObj = _filteredList[i];
      if (widget.enumItemBuild != null) {
        widgets.add(widget.enumItemBuild!(context, enumObj));
      } else {
        widgets.add(EnumSelectorItemComponent(
          enumObj: enumObj,
          isLast: i == _filteredList.length - 1,
        ));
      }
    }

    Widget searchField = Padding(
      padding: const EdgeInsets.symmetric(horizontal: Base.BASE_PADDING, vertical: Base.BASE_PADDING_HALF),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search currency...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: themeData.scaffoldBackgroundColor, // Or another suitable color
        ),
      ),
    );

    Widget mainContent = Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(15)),
        color: cardColor,
      ),
      constraints: BoxConstraints(
        maxHeight: maxHeight * 0.7, // Adjusted to make space for search bar
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          searchField,
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: widgets.isEmpty && _searchController.text.isNotEmpty
                    ? [Padding(padding: const EdgeInsets.all(16.0), child: Text("No currency found"))]
                    : widgets,
              ),
            ),
          ),
        ],
      ),
    );

    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.2),
      body: FocusScope(
        // autofocus: true,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            context.pop();
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
              child: mainContent,
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
          context.pop(enumObj);
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
