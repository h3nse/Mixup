import 'package:flutter/material.dart';
import 'package:mixup_app/Global/player.dart';

class Lobby extends StatefulWidget {
  const Lobby(
      {super.key, required this.levelCode, required this.startFunction});

  final String levelCode;
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
          title: Text("Lobby code: ${widget.levelCode}")),
      body: Column(
        children: [
          (Player().isHost)
              ? ElevatedButton(
                  onPressed: () {
                    widget.startFunction();
                  },
                  child: const Text('Start'))
              : Container(),
        ],
      ),
    );
  }
}
