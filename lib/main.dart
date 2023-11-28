import 'dart:ffi';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env"); // Load .env variables

  // Initialize supabase
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: dotenv.env['SUPA_PROJECT_URL'] ?? '',
    anonKey: dotenv.env['SUPA_ANON_KEY'] ?? '',
  );

  Player().id = Random().nextInt(10000);

  runApp(const MixupApp());
}

class Player {
  static final Player _instance = Player._internal("", 0);
  String name;
  int id;

  factory Player() {
    return _instance;
  }

  Player._internal(this.name, this.id);
}

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
  final supabase = Supabase.instance.client;
  final nameController = TextEditingController();

  void addPlayer() async {
    await supabase
        .from('players')
        .insert({'player_name': Player().name, 'id': Player().id});
  }

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
          ElevatedButton(
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
          ),
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
  final supabase = Supabase.instance.client;
  final _gameStream =
      Supabase.instance.client.from('games').stream(primaryKey: ['id']);

  void _addPlayerToLevel(int gameid) async {
    await supabase
        .from('_players_games')
        .insert({'player_id': Player().id, 'game_id': gameid});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Select game"),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _gameStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          final games = snapshot.data!;

          return ListView.builder(
            itemCount: games.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(games[index]['name']),
                subtitle: const Text("player count: "),
                onTap: () {
                  _addPlayerToLevel(games[index]['id']);
                },
              );
            },
          );
        },
      ),
    );
  }
}

class GameLobby extends StatefulWidget {
  const GameLobby({super.key});

  @override
  State<GameLobby> createState() => _GameLobbyState();
}

class _GameLobbyState extends State<GameLobby> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Select game"),
      ),
    );
  }
}
