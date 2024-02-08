import 'package:flutter/material.dart';
import 'package:mixup_app/Pages/game_states/game_running_widgets/buttons_below_image.dart';
import 'package:mixup_app/Pages/game_states/game_running_widgets/dish_preview.dart';
import 'package:mixup_app/Pages/game_states/game_running_widgets/game_timer.dart';
import 'package:mixup_app/Pages/game_states/game_running_widgets/item_image.dart';

class MainGameScreen extends StatefulWidget {
  const MainGameScreen({super.key});

  @override
  State<MainGameScreen> createState() => _MainGameScreenState();
}

class _MainGameScreenState extends State<MainGameScreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          GameTimer(),
          DishPreview(),
          SizedBox(
            height: 100,
          ),
          ItemImage(),
          SizedBox(
            height: 10,
          ),
          ButtonsBelowImage(),
        ],
      ),
    );
  }
}
