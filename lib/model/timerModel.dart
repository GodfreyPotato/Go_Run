import 'dart:async';

import 'package:flutter/material.dart';

class Timermodel extends ChangeNotifier {
  Timer? _timer;
  int elapsedSeconds = 0;
  int minutes = 0;
  int seconds = 0;
  // Circular percent loops every 60 seconds
  double percent = 0;
  bool isJogStarted = false;

  void startStopwatch() {
    isJogStarted = true;
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      elapsedSeconds++;
      minutes = elapsedSeconds ~/ 60;
      seconds = elapsedSeconds % 60;
      percent = (elapsedSeconds % 60) / 60;
      notifyListeners();
    });
  }

  void stopStopwatch() {
    _timer?.cancel();
    isJogStarted = false;

    notifyListeners();
  }

  void reset() {
    elapsedSeconds = 0;
    minutes = 0;
    seconds = 0;
    // Circular percent loops every 60 seconds
    percent = 0;
    notifyListeners();
  }
}
