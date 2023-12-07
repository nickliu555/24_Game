import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

const startTimeSeconds = 180;
const reduceTimeInterval = 20;
Color textColor = Colors.indigoAccent;
Timer timer = Timer.periodic(const Duration(seconds: 1), (timer) {});
int secondCount = startTimeSeconds;
VoidCallback showGameEndDialog = () => null;
bool stopped = false;
int stoppedSecondCount = 0;
int stoppedMinuteCount = 0;
int timeDecrementInterval = 1;

class TimerWidget extends StatefulWidget {
  @override
  TimerWidgetState createState() => TimerWidgetState();

  TimerWidget(Key? key, VoidCallback endGame) : super(key: key) {
    showGameEndDialog = endGame;
  }

  int getSeconds() {
    return secondCount;
  }
}

class TimerWidgetState extends State<TimerWidget> {
  @override
  void initState() {
    super.initState();
    secondCount = startTimeSeconds;
    timeDecrementInterval = 1;
    stopped = false;
    textColor = Colors.indigoAccent;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          if (stopped) return;

          if (secondCount > 0) {
            secondCount = secondCount - timeDecrementInterval;
          } else {
            showGameEndDialog();
            timer.cancel();
          }
        });
      });
    });
  }

  void reduceTime() {
    setState(() {
      secondCount = max(0, secondCount - reduceTimeInterval);
      textColor = Colors.red;
    });
  }

  void stopStartTime() {
    setState(() {
      stopped = !stopped;
      timeDecrementInterval = 1 - timeDecrementInterval;
    });
  }

  Widget build(BuildContext context) {
    int seconds = secondCount % 60;
    int minutes = (secondCount / 60).floor();
    Text ret = Text(
        minutes.toString().padLeft(2, "0") +
            ":" +
            seconds.toString().padLeft(2, "0"),
        style: TextStyle(fontSize: 25, color: textColor));
    textColor = Colors.indigoAccent;
    return ret;
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }
}
