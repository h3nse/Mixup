import 'package:flutter/material.dart';

class Lobby extends StatefulWidget {
  const Lobby(
      {super.key, required this.levelName, required this.startFunction});

  final String levelName;
  final Function startFunction;

  @override
  State<Lobby> createState() => _LobbyState();
}

class _LobbyState extends State<Lobby> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(widget.levelName)),
      body: Column(
        children: [
          ElevatedButton(
              onPressed: () {
                widget.startFunction();
              },
              child: const Text('Start')),
        ],
      ),
    );
  }
}
