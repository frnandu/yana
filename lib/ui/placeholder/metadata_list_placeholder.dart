import 'package:flutter/material.dart';
import 'package:yana/ui/placeholder/metadata_placeholder.dart';

class MetadataListPlaceholder extends StatelessWidget {
  Function? onRefresh;

  MetadataListPlaceholder({super.key, this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: RefreshIndicator(
        onRefresh: () async {
          if (onRefresh != null) {
            onRefresh!();
          }
        },
        child: ListView.builder(
          itemBuilder: (BuildContext context, int index) {
            return MetadataPlaceholder();
          },
          itemCount: 10,
        ),
      ),
    );
  }
}
