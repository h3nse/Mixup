import 'package:flutter/material.dart';

class DishPreview extends StatefulWidget {
  const DishPreview({super.key});

  @override
  State<DishPreview> createState() => _DishPreviewState();
}

class _DishPreviewState extends State<DishPreview> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: Container(
        alignment: const Alignment(0.0, 0.0),
        decoration: BoxDecoration(border: Border.all(color: Colors.black)),
        child: const Text("Dish Preview"),
      ),
    );
  }
}
