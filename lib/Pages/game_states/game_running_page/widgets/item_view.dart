import 'package:flutter/material.dart';
import 'package:mixup_app/Pages/game_states/game_running_page/widgets/buttons_below_image.dart';
import 'package:mixup_app/Pages/game_states/game_running_page/managers/local_manager.dart';
import 'package:provider/provider.dart';

class ItemView extends StatefulWidget {
  const ItemView({super.key});

  @override
  State<ItemView> createState() => _ItemViewState();
}

class _ItemViewState extends State<ItemView> {
  @override
  Widget build(BuildContext context) {
    final localManager = Provider.of<LocalManager>(context);

    Image getImageFromItem(String item) {
      String imagePath = 'assets/$item.jpg';
      if (item == '') {
        imagePath = 'assets/No_item.jpg';
      }
      return Image.asset(imagePath);
    }

    return Column(
      children: [
        SizedBox(height: 200, child: getImageFromItem(localManager.heldItem)),
        const SizedBox(
          height: 10,
        ),
        const ButtonsBelowImage()
      ],
    );
  }
}
