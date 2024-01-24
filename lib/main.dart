import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mixup_app/game_running.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mixup_app/barcode_scanner.dart';
import 'dart:async';
import 'player.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env"); // Load .env variables

  // Initialize supabase
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: dotenv.env['SUPA_PROJECT_URL'] ?? '',
    anonKey: dotenv.env['SUPA_ANON_KEY'] ?? '',
  );

  Player().id = Random()
      .nextInt(10000); // Set player ID. Just a random number for testing.

  runApp(const MixupApp());
}

final supabase = Supabase.instance.client;

class MixupApp extends StatelessWidget {
  const MixupApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
              seedColor: const Color.fromARGB(255, 188, 29, 161)),
        ),
        home: const HomePage());
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final nameController = TextEditingController();
  bool validPlayerRegistration = false;

  void addPlayer() async {
    await supabase.from('players').insert({
      'player_name': Player().name,
      'id': Player().id,
      'playerNumber': Player().playerNumber
    });
  }

  void handlePlayerScan(scan) {
    if ("<player>".matchAsPrefix(scan) == null) {
      return;
    }
    scan = scan.replaceAll('<player>', '');
    final playerNumber = int.parse(scan);
    setState(() {
      Player().playerNumber = playerNumber;
      validPlayerRegistration = true;
    });
  }

  // Remove from memory(?) when route changes
  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Mixup"),
      ),
      body: Column(
        children: [
          TextFormField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: ("Enter your username"),
            ),
          ),
          (validPlayerRegistration)
              ? Text("Player Number: ${Player().playerNumber.toString()}")
              : Container(),
          ElevatedButton(
              onPressed: () async {
                String? result = await Navigator.of(context).push<String>(
                  MaterialPageRoute(
                    builder: (context) =>
                        const BarcodeScannerWithoutController(),
                  ),
                );
                if (result != null) {
                  handlePlayerScan(result);
                }
              },
              child: const Text("Register player number")),
          (validPlayerRegistration)
              ? ElevatedButton(
                  onPressed: () {
                    if (nameController.text == "") {
                      Player().name = "Unnamed";
                    } else {
                      Player().name = nameController.text;
                    }
                    addPlayer();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LevelSelect(),
                      ),
                    );
                  },
                  child: const Text("Play"),
                )
              : Container(),
        ],
      ),
    );
  }
}

class LevelSelect extends StatefulWidget {
  const LevelSelect({super.key});

  @override
  State<LevelSelect> createState() => _LevelSelectState();
}

class _LevelSelectState extends State<LevelSelect> {
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
                        builder: (context) => Game(
                              lobbyID: lobbyid,
                            )),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

/// For storing information about the current level.
class Level {
  String name = '';
  int gameDuration = 0;
  Map<String, dynamic> dishes = {};
}

class Game extends StatefulWidget {
  final int lobbyID;
  const Game({super.key, required this.lobbyID});

  @override
  State<Game> createState() => _GameState();
}

class _GameState extends State<Game> {
  final level = Level();
  var gameState = 'Lobby';

  // Gets level details from database and assigns it to our level class.
  void _getLevel() async {
    var dbLevel = await supabase
        .from('lobbies')
        .select('levels(name, game_duration, dishes)')
        .eq('id', widget.lobbyID)
        .single();
    dbLevel = dbLevel['levels'];

    level.name = dbLevel['name'];
    level.gameDuration = dbLevel['game_duration'];
    level.dishes = dbLevel['dishes'];
    setState(() {});
  }

  @override
  void initState() {
    _getLevel();
    super.initState();
  }

  void _startGame() async {
    await supabase
        .from('lobbies')
        .update({'game_state': 'Running'}).eq('id', widget.lobbyID);
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
          levelName: level.name,
          startFunction: _startGame,
        );
        break;
      case 'Running':
        page = GameRunning(
          lobbyID: widget.lobbyID,
        );
        break;
      case 'Ending':
        break;
    }
    return page;
  }
}

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

/// Will eventually hold the current dish, but right now is just a placeholder.
class DishPreview extends StatefulWidget {
  const DishPreview({super.key});

  @override
  State<DishPreview> createState() => _DishPreviewState();
}

class _DishPreviewState extends State<DishPreview> {
  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 50,
      width: 100,
    );
  }
}
