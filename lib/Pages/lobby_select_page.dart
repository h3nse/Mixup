import 'package:flutter/material.dart';
import 'package:mixup_app/Global/player.dart';
import 'package:mixup_app/Pages/game_state.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class LobbySelectPage extends StatefulWidget {
  const LobbySelectPage({super.key});

  @override
  State<LobbySelectPage> createState() => _LobbySelectPageState();
}

class _LobbySelectPageState extends State<LobbySelectPage> {
  final _lobbyStream = supabase.from('lobbies').stream(
      primaryKey: ['id']); // Subscribing to stream of updates from database.

  void _addPlayerToLevel(int lobbyid) async {
    await supabase.from('players').update({
      'lobby_id': lobbyid,
    }).eq('id', Player().id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Select lobby"),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _lobbyStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          final lobbies = snapshot.data!;

          return ListView.builder(
            itemCount: lobbies.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(lobbies[index]['name']),
                onTap: () {
                  final lobbyid = lobbies[index]['id'];
                  _addPlayerToLevel(lobbyid);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => GameState(lobbyID: lobbyid)));
                },
              );
            },
          );
        },
      ),
    );
  }
}
