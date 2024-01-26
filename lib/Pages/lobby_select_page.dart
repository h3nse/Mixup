import 'package:flutter/material.dart';
import 'package:mixup_app/Global/helper_functions.dart';
import 'package:mixup_app/Global/player.dart';
import 'package:mixup_app/Pages/game_state.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:math';

final supabase = Supabase.instance.client;

class LobbySelectPage extends StatefulWidget {
  const LobbySelectPage({super.key});

  @override
  State<LobbySelectPage> createState() => _LobbySelectPageState();
}

class _LobbySelectPageState extends State<LobbySelectPage> {
  final int codeLength = 4;
  final lobbyCodeController = TextEditingController();

  Future _addPlayerToLobby(int lobbyid) async {
    await supabase.from('players').update({
      'lobby_id': lobbyid,
    }).eq('id', Player().id);
  }

  Future<String> _createLobby() async {
    String code = generateRandomCode();
    int id = convertStringToNumbers(code);
    await supabase
        .from('lobbies')
        .insert({'id': id, 'level_id': 1}); // Starting off on level one
    _addPlayerToLobby(id);
    Player().isHost = true;
    return code;
  }

  String generateRandomCode() {
    final random = Random();
    const availableChars =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz';
    final randomString = List.generate(codeLength,
            (index) => availableChars[random.nextInt(availableChars.length)])
        .join();
    return randomString;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text("Join or Host a lobby!"),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextFormField(
              controller: lobbyCodeController,
              decoration: const InputDecoration(
                labelText: ("Enter a lobby code"),
              ),
            ),
            ElevatedButton(
                onPressed: () async {
                  String attemptedCode = lobbyCodeController.text;
                  if (attemptedCode == '') return;
                  try {
                    await _addPlayerToLobby(
                        convertStringToNumbers(attemptedCode));
                    if (context.mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              GameState(lobbyCode: attemptedCode),
                        ),
                      );
                    }
                  } catch (_) {}
                },
                child: const Text('Join lobby')),
            const Text(
              'Or...',
              style: TextStyle(fontSize: 24, fontStyle: FontStyle.italic),
            ),
            ElevatedButton(
                onPressed: () async {
                  String lobbyCode = await _createLobby();
                  if (context.mounted) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                GameState(lobbyCode: lobbyCode)));
                  }
                },
                child: const Text('Create a new lobby'))
          ],
        ));
  }
}
