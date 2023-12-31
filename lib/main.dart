import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mixup_app/barcode_scanner.dart';
import 'dart:async';

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

/// Singleton for storing local information about the player. Name could be removed in future passes.
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
  final _lobbyStream = Supabase.instance.client.from('lobbies').stream(
      primaryKey: ['id']); // Subscribing to stream of updates from database.

  void _addPlayerToLevel(int lobbyid) async {
    await supabase
        .from('players')
        .update({'lobby_id': lobbyid}).eq('id', Player().id);
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
                subtitle: const Text(
                    "player count: "), // Doesnt actually display any number currently.
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
  final supabase = Supabase.instance.client;

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
        page = const GameRunning();
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

class GameRunning extends StatefulWidget {
  const GameRunning({super.key});

  @override
  State<GameRunning> createState() => _GameRunningState();
}

class _GameRunningState extends State<GameRunning> {
  String heldItem = '';
  final itemDeclaration = '<item>';
  final processDeclaration = '<process>';
  // All items in the game, and which processes can be used on them.
  final items = {
    'Tomato': ['cut'],
    'Spaghetti': ['boil'],
    'Meat': ['cut', 'fry']
  };
  final processWait = {'cut': 3, 'fry': 6, 'boil': 10};
  bool processing = false;

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

  void handleProcessTimeout(splitItem, rawItem) {
    splitItem.remove(rawItem);
    splitItem.sort((String a, String b) {
      return a.compareTo(b);
    });
    splitItem.insert(0, rawItem);
    heldItem = splitItem.join("_");
    processing = false;
    setState(() {});
  }

  /// Formats the name of the item to include the process. Sorts processes alphabetically if there's multiple.
  void _handleProcessScan(String scannedProcess) {
    if (heldItem == '') {
      return;
    }
    var splitItem = "${heldItem}_$scannedProcess".split('_');
    final rawItem = splitItem[0];

    if (!heldItem.contains(scannedProcess) &&
        items[rawItem]!.contains(scannedProcess)) {
      setState(() {
        processing = true;
      });
      Timer(Duration(seconds: processWait[scannedProcess] ?? 0),
          () => handleProcessTimeout(splitItem, rawItem));
    }
  }

  /// The data in the QR-codes start with a declaration <> of what type they are.
  void _handleScan(String scan) {
    if (itemDeclaration.matchAsPrefix(scan) != null) {
      scan = scan.replaceAll('<item>', '');
      _handleItemScan(scan);
    } else if (processDeclaration.matchAsPrefix(scan) != null) {
      scan = scan.replaceAll('<process>', '');
      _handleProcessScan(scan);
    }
  }

  /// Images are placed in /assets and are named after a naming convention.
  Image _getImageFromItem() {
    String imagePath = 'assets/$heldItem.jpg';
    if (heldItem == '') {
      imagePath = 'assets/No_item.jpg';
    }
    return Image.asset(imagePath);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          (processing) ? const Text('Processing...') : Container(),
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
