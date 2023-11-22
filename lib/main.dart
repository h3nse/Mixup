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

  runApp(const MixupApp());
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Mixup"),
      ),
      body: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const LevelSelect(),
            ),
          );
        },
        child: const Text("Play"),
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
  List<String>? levels;

  @override
  void initState() {
    super.initState();
    _getLevels();
  }

  Future<void> _getLevels() async {
    final response = await supabase.from('levels').select('name');
    if (response != null) {
      setState(() {
        levels =
            (response as List).map((item) => item['name'].toString()).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Select level"),
      ),
      body: ListView.builder(
        itemCount: levels?.length ?? 0,
        itemBuilder: (context, index) => Text(levels?[index] ?? ''),
      ),
    );
  }
}
