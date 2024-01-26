import 'package:flutter/material.dart';
import 'package:mixup_app/Global/helper_functions.dart';
import 'package:mixup_app/Global/player.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class Lobby extends StatefulWidget {
  const Lobby(
      {super.key, required this.lobbyCode, required this.startFunction});

  final String lobbyCode;
  final Function startFunction;

  @override
  State<Lobby> createState() => _LobbyState();
}

class _LobbyState extends State<Lobby> {
  late int lobbyID;
  late final _playerStream;

  void setup() {
    lobbyID = convertStringToNumbers(widget.lobbyCode);
    _playerStream = supabase
        .from('players')
        .stream(primaryKey: ['id'])
        .order('id', ascending: true)
        .eq('lobby_id', lobbyID);
  }

  @override
  void initState() {
    super.initState();
    setup();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text("Lobby code: ${widget.lobbyCode}")),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          (Player().isHost)
              ? ElevatedButton(
                  onPressed: () {
                    widget.startFunction();
                  },
                  child: const Text('Start'))
              : Container(),
          StreamBuilder(
            stream: _playerStream,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              final players = snapshot.data! as List<Map<String, dynamic>>;

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: players.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(players[index]['player_name']),
                    subtitle:
                        Text('Player nr. ${players[index]['playerNumber']}'),
                  );
                },
              );
            },
          )
        ],
      ),
    );
  }
}
