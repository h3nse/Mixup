import 'package:flutter/material.dart';
import 'package:mixup_app/Pages/game_states/game_running_widgets/display_manager.dart';
import 'package:provider/provider.dart';

class ButtonsBelowImage extends StatefulWidget {
  const ButtonsBelowImage({super.key});

  @override
  State<ButtonsBelowImage> createState() => _ButtonsBelowImageState();
}

class _ButtonsBelowImageState extends State<ButtonsBelowImage> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 70,
        width: 300,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ElevatedButton(onPressed: () {}, child: const Text('Scan')),
            ElevatedButton(
                onPressed: () {
                  Provider.of<DisplayManager>(context, listen: false)
                      .changeItemImage('');
                },
                child: const Text('Discard Item'))
          ],
        ));
  }
}
