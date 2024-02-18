import 'package:flutter/material.dart';
import 'package:flutter_timer_countdown/flutter_timer_countdown.dart';
import 'package:mixup_app/Global/functions.dart';

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
          Duration(minutes: 1),
        ),
        onEnd: () {
          changeGameState('Ending');
        },
      ),
    );
  }
}
