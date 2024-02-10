import 'package:flutter/material.dart';
import 'package:mixup_app/Pages/game_states/game_running_widgets/buttons_below_image.dart';
import 'package:mixup_app/Pages/game_states/game_running_widgets/dish_preview.dart';
import 'package:mixup_app/Pages/game_states/game_running_widgets/game_timer.dart';
import 'package:mixup_app/Pages/game_states/game_running_widgets/display_manager.dart';
import 'package:provider/provider.dart';

class MainGameScreen extends StatefulWidget {
  const MainGameScreen({super.key});

  @override
  State<MainGameScreen> createState() => _MainGameScreenState();
}

class _MainGameScreenState extends State<MainGameScreen> {
  @override
  Widget build(BuildContext context) {
    final displayManager = Provider.of<DisplayManager>(context);
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const GameTimer(),
          const DishPreview(),
          const SizedBox(
            height: 100,
          ),
          SizedBox(height: 200, child: displayManager.itemImage),
          const SizedBox(
            height: 10,
          ),
          const ButtonsBelowImage(),
        ],
      ),
    );
  }
}
