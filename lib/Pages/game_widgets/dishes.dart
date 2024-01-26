import 'package:flutter/material.dart';

/// Will eventually hold the current dish, but right now is just a placeholder.
class DishPreview extends StatefulWidget {
  const DishPreview({super.key});

  @override
  State<DishPreview> createState() => _DishPreviewState();
}

class _DishPreviewState extends State<DishPreview> {
  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 50,
      width: 100,
    );
  }
}
