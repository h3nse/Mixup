import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mixup_app/Global/constants.dart';

class HostManager extends ChangeNotifier {
  late Timer _orderTimer;

  setupOrderTimer() {
    final random = Random();
    final duration = Duration(
        seconds: Constants.orderTimerInterval[0] +
            random.nextInt(Constants.orderTimerInterval[1] -
                Constants.orderTimerInterval[0]));
    _orderTimer = Timer(
      duration,
      () {
        print('Order timer called');
        setupOrderTimer();
      },
    );
  }

  void stopTimer() {
    _orderTimer.cancel();
  }
}
