import 'package:flutter/material.dart';

class GameEnding extends StatefulWidget {
  const GameEnding({super.key, required this.resetFunction});

  final Function resetFunction;

  @override
  State<GameEnding> createState() => _GameEndingState();
}

class _GameEndingState extends State<GameEnding> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: ElevatedButton(
              onPressed: () {
                widget.resetFunction();
              },
              child: const Text("Back to lobby"))),
    );
  }
}
