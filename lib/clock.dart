import 'dart:async';

import 'package:flutter/material.dart';

Timer timer = Timer.periodic(const Duration(seconds: 1), (timer) {});
int secondCount = 0;
int minuteCount = 0;
bool stopped = false;
int stoppedSecondCount = 0;
int stoppedMinuteCount = 0;

class ClockWidget extends StatefulWidget {
  @override
  ClockWidgetState createState() => ClockWidgetState();

  void stop() {
    stopped = true;
    stoppedSecondCount = secondCount;
    stoppedMinuteCount = minuteCount;
  }

  void reset() {
    stopped = false;
    secondCount = -1;
    minuteCount = 0;
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          ++secondCount;
          if (secondCount >= 60) {
            secondCount = 0;
            ++minuteCount;
          }
        });
      });
    });
  }

  Widget build(BuildContext context) {
    return stopped
        ? Text(
            stoppedMinuteCount.toString().padLeft(2, "0") +
                ":" +
                stoppedSecondCount.toString().padLeft(2, "0"),
            style: const TextStyle(fontSize: 25, color: Colors.indigoAccent))
        : Text(
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
