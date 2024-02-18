import 'package:flutter/material.dart';
import 'package:mixup_app/Global/functions.dart';
import 'package:mixup_app/Pages/game_states/game_ending_page.dart';
import 'package:mixup_app/Pages/game_states/game_running_page/game_running_page.dart';
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
  var gameState = 'Lobby';
  // final level = Level();

  // Gets level details from database and assigns it to our level class.
  // void _getLevel() async {
  //   var dbLevel = await supabase
  //       .from('lobbies')
  //       .select('levels(name, game_duration, dishes)')
  //       .eq('id', lobbyID)
  //       .single();
  //   dbLevel = dbLevel['levels'];

  //   level.name = dbLevel['name'];
  //   level.gameDuration = dbLevel['game_duration'];
  //   level.dishes = dbLevel['dishes'];
  //   setState(() {});
  // }

  @override
  void initState() {
    lobbyID = convertStringToNumbers(widget.lobbyCode);
    // _getLevel();
    super.initState();
    supabase.channel('lobbies').on(
        RealtimeListenTypes.postgresChanges,
        ChannelFilter(
            event: 'UPDATE',
            schema: 'public',
            table: 'lobbies',
            filter: 'id=eq.$lobbyID'), (payload, [ref]) {
      setState(() {
        gameState = payload['new']['game_state'];
      });
    }).subscribe();
  }

  void changeGameState(String gameState) async {
    await supabase
        .from('lobbies')
        .update({'game_state': gameState}).eq('id', lobbyID);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Widget page = const Placeholder();
    switch (gameState) {
      case 'Lobby':
        page = Lobby(
          lobbyCode: widget.lobbyCode,
        );
        break;
      case 'Running':
        page = const MainGameScreen();
        break;
      case 'Ending':
        page = const GameEnding();
        break;
    }
    return page;
  }
}
