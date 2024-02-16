import 'package:flutter/material.dart';

class GameTimer extends StatefulWidget {
  const GameTimer({super.key});

  @override
  State<GameTimer> createState() => _GameTimerState();
}

class _GameTimerState extends State<GameTimer> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: Container(
        alignment: const Alignment(0.0, 0.0),
        decoration: BoxDecoration(border: Border.all(color: Colors.black)),
        child: const Text("Game Timer"),
      ),
    );
  }
}
