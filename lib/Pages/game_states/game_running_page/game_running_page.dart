import 'package:flutter/material.dart';
import 'package:mixup_app/Pages/game_states/game_running_page/widgets/dish_preview.dart';
import 'package:mixup_app/Pages/game_states/game_running_page/widgets/game_timer.dart';
import 'package:mixup_app/Pages/game_states/game_running_page/widgets/item_view.dart';
import 'package:mixup_app/Pages/game_states/game_running_page/managers/local_manager.dart';
import 'package:mixup_app/Pages/game_states/game_running_page/widgets/processing_view.dart';
import 'package:provider/provider.dart';

class MainGameScreen extends StatefulWidget {
  const MainGameScreen({super.key});

  @override
  State<MainGameScreen> createState() => _MainGameScreenState();
}

class _MainGameScreenState extends State<MainGameScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<LocalManager>(builder: (context, localManager, child) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const GameTimer(),
            const DishPreview(),
            const SizedBox(
              height: 100,
            ),
            localManager.processing ? const ProcessingView() : const ItemView()
          ],
        );
      }),
    );
  }
}
