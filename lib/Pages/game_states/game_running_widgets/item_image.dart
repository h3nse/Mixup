import 'package:flutter/material.dart';

class ItemImage extends StatefulWidget {
  const ItemImage({super.key});

  @override
  State<ItemImage> createState() => _ItemImageState();
}

class _ItemImageState extends State<ItemImage> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      width: 200,
      child: Container(
        alignment: const Alignment(0.0, 0.0),
        decoration: BoxDecoration(border: Border.all(color: Colors.black)),
        child: const Text("Item Image"),
      ),
    );
  }
}
