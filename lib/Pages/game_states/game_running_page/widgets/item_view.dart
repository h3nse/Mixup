import 'package:flutter/material.dart';
import 'package:mixup_app/Global/player.dart';
import 'package:mixup_app/Pages/game_states/game_running_page/widgets/buttons_below_image.dart';
import 'package:mixup_app/Pages/game_states/game_running_page/managers/local_manager.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

final supabase = sb.Supabase.instance.client;

class ItemView extends StatefulWidget {
  const ItemView({super.key});

  @override
  State<ItemView> createState() => _ItemViewState();
}

class _ItemViewState extends State<ItemView> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final localManager = Provider.of<LocalManager>(context, listen: false);
      supabase.channel('players').on(
          sb.RealtimeListenTypes.postgresChanges,
          sb.ChannelFilter(
              event: 'UPDATE',
              schema: 'public',
              table: 'players',
              filter: 'id=eq.${Player().id}'), (payload, [ref]) {
        localManager.changeHeldItemLocally(payload['new']['held_item']);
      }).subscribe();
    });
  }

  @override
  Widget build(BuildContext context) {
    Image getImageFromItem(String item) {
      String imagePath = 'assets/$item.jpg';
      if (item == '') {
        imagePath = 'assets/No_item.jpg';
      }
      return Image.asset(imagePath);
    }

    return Column(
      children: [
        Consumer<LocalManager>(builder: (context, localManager, child) {
          return SizedBox(
              height: 200, child: getImageFromItem(localManager.heldItem));
        }),
        const SizedBox(
          height: 10,
        ),
        const ButtonsBelowImage()
      ],
    );
  }
}
