import 'package:flutter/material.dart';
import 'package:mixup_app/Global/functions.dart';
import 'package:mixup_app/Global/player.dart';
import 'package:mixup_app/Pages/game_states/game_running_page/managers/local_manager.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

final supabase = sb.Supabase.instance.client;

class GameEnding extends StatefulWidget {
  const GameEnding({super.key});

  @override
  State<GameEnding> createState() => _GameEndingState();
}

class _GameEndingState extends State<GameEnding> {
  void resetPlayer() async {
    supabase.from('players').update({'held_item': ''}).eq('id', Player().id);
    Player().heldItem = '';
    Provider.of<LocalManager>(context, listen: false).changeHeldItem('');
    Provider.of<LocalManager>(context, listen: false).changeProcessing(false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: ElevatedButton(
              onPressed: () {
                resetPlayer();
                changeGameState('Lobby');
              },
              child: const Text("Back to lobby"))),
    );
  }
}
