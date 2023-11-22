import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load(fileName: ".env"); // Load .env variables

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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Select level"),
      ),
      body: ListView(
        children: const [Text('Test'), Text('Test 2')],
      ),
    );
  }
}
