import 'dart:async';

import 'package:flutter/material.dart';

Timer timer = Timer.periodic(const Duration(seconds: 1), (timer) {});
int secondCount = 0;
int minuteCount = 0;
int timeIncrementInterval = 1;

class ClockWidget extends StatefulWidget {
  @override
  ClockWidgetState createState() => ClockWidgetState();

  void stop() {
    timeIncrementInterval = 0;
  }

  void reset() {
    secondCount = -1;
    minuteCount = 0;
    timeIncrementInterval = 1;
  }

  int getSeconds() {
    return secondCount;
  }

  int getMinutes() {
    return minuteCount;
  }
}

class ClockWidgetState extends State<ClockWidget> {
  @override
  void initState() {
    super.initState();
    secondCount = 0;
    minuteCount = 0;
    timeIncrementInterval = 1;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          secondCount = secondCount + timeIncrementInterval;
          if (secondCount >= 60) {
            secondCount = 0;
            ++minuteCount;
          }
        });
      });
    });
  }

  Widget build(BuildContext context) {
    return Text(
        minuteCount.toString().padLeft(2, "0") +
            ":" +
            secondCount.toString().padLeft(2, "0"),
        style: const TextStyle(fontSize: 25, color: Colors.indigoAccent));
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }
}
