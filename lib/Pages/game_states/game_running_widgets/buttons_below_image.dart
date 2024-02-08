import 'package:flutter/material.dart';

class ButtonsBelowImage extends StatefulWidget {
  const ButtonsBelowImage({super.key});

  @override
  State<ButtonsBelowImage> createState() => _ButtonsBelowImageState();
}

class _ButtonsBelowImageState extends State<ButtonsBelowImage> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 70,
      width: 300,
      child: Container(
        alignment: const Alignment(0.0, 0.0),
        decoration: BoxDecoration(border: Border.all(color: Colors.black)),
        child: const Text("Buttons"),
      ),
    );
  }
}
