import 'package:flutter/material.dart';
import 'package:mixup_app/Global/functions.dart';

class GameEnding extends StatefulWidget {
  const GameEnding({super.key});

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
                changeGameState('Lobby');
              },
              child: const Text("Back to lobby"))),
    );
  }
}
