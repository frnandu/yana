import 'package:flutter/material.dart';

class EventBitcoinIconComponent extends StatelessWidget {
  const EventBitcoinIconComponent({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          width: 8,
          color: Colors.amber[600]!.withOpacity(0.5),
          style: BorderStyle.solid,
        ),
        borderRadius: BorderRadius.circular(54),
      ),
      child: Icon(
        Icons.bolt,
        color: Colors.amber[600]!.withOpacity(0.5),
        size: 100,
      ),
    );
  }
}
