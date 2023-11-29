import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mixup_app/barcode_scanner.dart';

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
                  final gameid = games[index]['id'];
                  _addPlayerToLevel(gameid);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Game(
                              gameID: gameid,
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

class Level {
  String name = '';
  int gameDuration = 0;
  Map<String, dynamic> dishes = {};
}

class Game extends StatefulWidget {
  final int gameID;
  const Game({super.key, required this.gameID});

  @override
  State<Game> createState() => _GameState();
}

class _GameState extends State<Game> {
  final level = Level();
  var gameState = 'Lobby';
  final supabase = Supabase.instance.client;

  void _getLevel() async {
    final levelID =
        await supabase.from('games').select('level_id').eq('id', widget.gameID);
    final dbLevel = await supabase
        .from('levels')
        .select('name, game_duration, dishes')
        .eq('id', levelID[0]['level_id'])
        .single();

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
        .from('games')
        .update({'game_state': 'Running'}).eq('id', widget.gameID);
    setState(() {
      gameState = 'Running'; // For testing
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
        page = const GameRunning();
        break;
      case 'Ending':
        break;
    }
    return page;
  }
}

class Lobby extends StatelessWidget {
  const Lobby(
      {super.key, required this.levelName, required this.startFunction});

  final String levelName;
  final Function startFunction;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(levelName)),
      body: ElevatedButton(
          onPressed: () {
            startFunction();
          },
          child: const Text('Start')),
    );
  }
}

class GameRunning extends StatefulWidget {
  const GameRunning({super.key});

  @override
  State<GameRunning> createState() => _GameRunningState();
}

class _GameRunningState extends State<GameRunning> {
  String heldItem = '';
  String itemDeclaration = '<item>';
  String processDeclaration = '<process>';
  final items = {
    'Tomato': ['cut'],
    'Spaghetti': ['boil'],
    'Meat': ['cut', 'fry']
  };

  void _setItem(String item) {
    setState(() {
      heldItem = item;
    });
  }

  void _handleItemScan(String scannedItem) {
    if (heldItem != '') {
      return;
    } else {
      _setItem(scannedItem);
    }
  }

  void _handleProcessScan(String scannedProcess) {
    if (heldItem == '') {
      return;
    }
    print('SORT OG heldItem: $heldItem');
    var splitItem = heldItem.split('_');
    print('SORT splitItem: $splitItem');
    final rawItem = splitItem[0];
    print('SORT rawItem: $rawItem');

    print(
        "SORT if statement result: ${!heldItem.contains(scannedProcess) && items[rawItem]!.contains(scannedProcess)}");

    if (!heldItem.contains(scannedProcess) &&
        items[rawItem]!.contains(scannedProcess)) {
      heldItem = "${heldItem}_$scannedProcess";
      var splitItem = heldItem.split('_');
      print('SORT new heldItem: $heldItem');
      splitItem.remove(rawItem);
      print('SORT split item with raw removed: $splitItem');
      splitItem.sort((a, b) {
        return a.compareTo(b);
      });
      print('SORT sorted splitItem: $splitItem');
      splitItem.insert(0, rawItem);
      heldItem = splitItem.join("_");
      print("SORT final heldItem: $heldItem");

      setState(() {});
    }
  }

  void _handleScan(String res) {
    if (itemDeclaration.matchAsPrefix(res) != null) {
      res = res.replaceAll('<item>', '');
      _handleItemScan(res);
    } else if (processDeclaration.matchAsPrefix(res) != null) {
      res = res.replaceAll('<process>', '');
      _handleProcessScan(res);
    }
  }

  Image _getImageFromItem() {
    String imagePath = 'assets/$heldItem.jpg';
    if (heldItem == '') {
      imagePath = 'assets/No_item.jpg';
    } else {
      imagePath = 'assets/$heldItem.jpg';
    }
    return Image.asset(imagePath);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const DishPreview(),
          _getImageFromItem(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () async {
                  String? result = await Navigator.of(context).push<String>(
                    MaterialPageRoute(
                      builder: (context) =>
                          const BarcodeScannerWithoutController(),
                    ),
                  );
                  if (result != null) {
                    _handleScan(result);
                  }
                },
                child: const Text("Scan"),
              ),
              const SizedBox(
                width: 50,
              ),
              ElevatedButton(
                  onPressed: () {
                    _setItem('');
                  },
                  child: const Text('Discard item'))
            ],
          ),
        ],
      ),
    );
  }
}

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
