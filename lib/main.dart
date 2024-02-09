import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mixup_app/Pages/front_page.dart';
import 'package:mixup_app/Pages/game_states/game_running_widgets/display_manager.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';
import 'Global/player.dart';

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

  runApp(MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => DisplayManager())],
      child: const MixupApp()));
}

final supabase = Supabase.instance.client;
late int placeholder;

class MixupApp extends StatelessWidget {
  const MixupApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 188, 29, 161)),
      ),
      home: const FrontPage(),
    );
  }
}
