import 'package:flutter/material.dart';
import 'package:mixup_app/Global/helper_functions.dart';
import 'package:mixup_app/Pages/game_states/game_running_page.dart';
import 'package:mixup_app/Pages/game_states/lobby_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

/// For storing information about the current level.
class Level {
  String name = '';
  int gameDuration = 0;
  Map<String, dynamic> dishes = {};
}

class GameState extends StatefulWidget {
  final String lobbyCode;
  const GameState({super.key, required this.lobbyCode});

  @override
  State<GameState> createState() => _GameStateState();
}

class _GameStateState extends State<GameState> {
  late int lobbyID;
  final level = Level();
  var gameState = 'Lobby';

  // Gets level details from database and assigns it to our level class.
  void _getLevel() async {
    var dbLevel = await supabase
        .from('lobbies')
        .select('levels(name, game_duration, dishes)')
        .eq('id', lobbyID)
        .single();
    dbLevel = dbLevel['levels'];

    level.name = dbLevel['name'];
    level.gameDuration = dbLevel['game_duration'];
    level.dishes = dbLevel['dishes'];
    setState(() {});
  }

  @override
  void initState() {
    lobbyID = convertStringToNumbers(widget.lobbyCode);
    _getLevel();
    super.initState();
  }

  void _startGame() async {
    await supabase
        .from('lobbies')
        .update({'game_state': 'Running'}).eq('id', lobbyID);
    setState(() {
      // For testing. gameState should read from the database in the future.
      gameState = 'Running';
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget page = const Placeholder();
    switch (gameState) {
      case 'Lobby':
        page = Lobby(
          lobbyCode: widget.lobbyCode,
          startFunction: _startGame,
        );
        break;
      case 'Running':
        page = GameRunning(
          lobbyID: lobbyID,
        );
        break;
      case 'Ending':
        break;
    }
    return page;
  }
}
