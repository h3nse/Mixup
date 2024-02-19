import 'package:flutter/material.dart';
import 'package:flutter_timer_countdown/flutter_timer_countdown.dart';
import 'package:mixup_app/Global/functions.dart';
import 'package:mixup_app/Pages/game_states/game_running_page/managers/host_manager.dart';
import 'package:provider/provider.dart';

class GameTimer extends StatefulWidget {
  const GameTimer({super.key});

  @override
  State<GameTimer> createState() => _GameTimerState();
}

class _GameTimerState extends State<GameTimer> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: TimerCountdown(
        format: CountDownTimerFormat.minutesSeconds,
        enableDescriptions: false,
        spacerWidth: 5,
        timeTextStyle: const TextStyle(fontSize: 32),
        endTime: DateTime.now().add(
          Duration(minutes: 5),
        ),
        onEnd: () {
          changeGameState('Ending');
          Provider.of<HostManager>(context, listen: false).stopTimer();
        },
      ),
    );
  }
}
