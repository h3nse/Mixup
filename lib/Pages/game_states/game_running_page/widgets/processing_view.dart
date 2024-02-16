import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mixup_app/Pages/game_states/game_running_widgets/local_manager.dart';
import 'package:provider/provider.dart';
import 'package:timer_count_down/timer_count_down.dart';

class ProcessingView extends StatefulWidget {
  const ProcessingView({super.key});

  @override
  State<ProcessingView> createState() => _ProcessingViewState();
}

class _ProcessingViewState extends State<ProcessingView> {
  @override
  Widget build(BuildContext context) {
    final localManager = Provider.of<LocalManager>(context);

    void handleProcessTimeout(splitItem, rawItem) {
      splitItem.remove(rawItem);
      splitItem.sort((String a, String b) {
        return a.compareTo(b);
      });
      splitItem.insert(0, rawItem);
      Provider.of<LocalManager>(context, listen: false)
          .changeHeldItem(splitItem.join("_"));
      Provider.of<LocalManager>(context, listen: false).changeProcessing(false);
    }

    return Column(
      children: [
        Text(
          "${localManager.processStatement}...",
          style: const TextStyle(fontSize: 24),
        ),
        Countdown(
          seconds: localManager.processTimer,
          build: (BuildContext context, double time) => Text(
            NumberFormat("0", "en_US").format(time).toString(),
            style: const TextStyle(fontSize: 100),
          ),
          onFinished: () {
            handleProcessTimeout(localManager.splitItem, localManager.rawitem);
          },
        ),
      ],
    );
  }
}
