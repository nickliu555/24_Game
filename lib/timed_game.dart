import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:fraction/fraction.dart';
import 'package:projects/difficulty.dart';
import 'package:projects/solutions.dart';
import 'package:projects/timer.dart';

import 'problems.dart';

var rng = Random();

List<List<int>> allSolvableProblems = getProblems();
Map<String, String> problemToSolutionMap = getProblemSolutionMap();
Set<int> problemIndexSeen = {};
List<int> shuffledProblem = [];
String? solution = "";

int firstNum = -1;
int secondNum = -1;
int thirdNum = -1;
int fourthNum = -1;

List<double> nums = [
  firstNum.toDouble(),
  secondNum.toDouble(),
  thirdNum.toDouble(),
  fourthNum.toDouble()
];

List<bool> isNumIndexVisible = [false, false, false, false];
int firstNumUsedIndex = -1;
int secondNumUsedIndex = -1;
String operationUsed = '_';

bool expectNum = true;
int turn = 0;

double finalResult = 0;
int numProblemsCompleted = 0;
GlobalKey<TimerWidgetState> keyTimeWidget = GlobalKey();
final GlobalKey<State> _resultDialog = GlobalKey();
final GlobalKey<State> _divisionErrorDialog = GlobalKey();

var difficultyToColor = {
  difficultyLevel.Easy: Colors.green,
  difficultyLevel.Medium: Colors.orange,
  difficultyLevel.Hard: Colors.red,
  difficultyLevel.Mixed: Colors.purple,
};

List<int> shuffleList<T>(List<int> list) {
  List<int> shuffledList = List<int>.from(list);
  for (var i = shuffledList.length - 1; i > 0; --i) {
    final j = rng.nextInt(i + 1);
    final temp = shuffledList[i];
    shuffledList[i] = shuffledList[j];
    shuffledList[j] = temp;
  }
  return shuffledList;
}

class TimedGamePage extends StatefulWidget {
  TimedGamePage({Key? key}) : super(key: key);

  @override
  _TimedGamePageState createState() => _TimedGamePageState();
}

class _TimedGamePageState extends State<TimedGamePage> {
  _TimedGamePageState() {
    newGame(true);
    numProblemsCompleted = 0;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        isNumIndexVisible = [true, true, true, true];
      });
    });
  }

  bool readyToCreateNewNumber() {
    return turn >= 1 && secondNumUsedIndex != -1;
  }

  void handleCreateNewNum() {
    if (operationUsed == '+') {
      finalResult =
          nums[firstNumUsedIndex] + nums[secondNumUsedIndex].toDouble();
    } else if (operationUsed == '-') {
      finalResult =
          nums[firstNumUsedIndex] - nums[secondNumUsedIndex].toDouble();
    } else if (operationUsed == '×') {
      finalResult =
          nums[firstNumUsedIndex] * nums[secondNumUsedIndex].toDouble();
    } else if (operationUsed == '÷') {
      if (nums[secondNumUsedIndex] != 0) {
        finalResult = (nums[firstNumUsedIndex] / nums[secondNumUsedIndex]);
      } else {
        _showDivisionErrorMsg();
        return;
      }
    }

    setState(() {
      nums[firstNumUsedIndex] = finalResult;
      isNumIndexVisible[secondNumUsedIndex] = false;

      expectNum = true;
      turn = 0;
      firstNumUsedIndex = -1;
      secondNumUsedIndex = -1;
      operationUsed = '_';

      int numLeftToUse = 4;
      for (int i = 0; i < 4; ++i) {
        if (!isNumIndexVisible[i]) {
          --numLeftToUse;
        }
      }
      // have used all numbers
      if (numLeftToUse <= 1) {
        if (finalResult == 24) keyTimeWidget.currentState?.stopStartTime();
        _showResultDialog();
      }
    });
  }

  void resetGame() {
    nums = [
      firstNum.toDouble(),
      secondNum.toDouble(),
      thirdNum.toDouble(),
      fourthNum.toDouble()
    ];

    isNumIndexVisible = [true, true, true, true];
    firstNumUsedIndex = -1;
    secondNumUsedIndex = -1;
    operationUsed = '_';

    expectNum = true;
    turn = 0;

    finalResult = 0;
  }

  void newGame(bool firstGame) {
    int firstThirdCuttoff = (allSolvableProblems.length / 3).toInt();
    int secondThirdCutoff = firstThirdCuttoff * 2;
    var currDifficulty = getDifficulty();
    int start = 0;
    int end = allSolvableProblems.length;
    if (difficultyLevel.Easy == currDifficulty) {
      end = firstThirdCuttoff;
    } else if (difficultyLevel.Medium == currDifficulty) {
      start = firstThirdCuttoff;
      end = secondThirdCutoff;
    } else if (difficultyLevel.Hard == currDifficulty) {
      start = secondThirdCutoff;
    }

    int randomProblemIndex = start + rng.nextInt(end - start);

    // if its first game or we have already completed all problems
    if (firstGame || problemIndexSeen.length == (end - start + 1)) {
      problemIndexSeen = {};
    }
    // make sure new problem is not seen before
    while (problemIndexSeen.contains(randomProblemIndex)) {
      randomProblemIndex = rng.nextInt(allSolvableProblems.length);
    }
    problemIndexSeen.add(randomProblemIndex);
    print('randomProblemIndex = ' + randomProblemIndex.toString());

    String problemString = "";
    for (int num in allSolvableProblems[randomProblemIndex]) {
      problemString += (num.toString() + " ");
    }
    problemString = problemString.substring(
        0, problemString.length - 1); // remove last space
    print('problemString = ' + problemString);
    solution = problemToSolutionMap[problemString];
    print('solution = ' + solution.toString());
    shuffledProblem = shuffleList(allSolvableProblems[randomProblemIndex]);

    firstNum = shuffledProblem[0];
    secondNum = shuffledProblem[1];
    thirdNum = shuffledProblem[2];
    fourthNum = shuffledProblem[3];

    nums = [
      firstNum.toDouble(),
      secondNum.toDouble(),
      thirdNum.toDouble(),
      fourthNum.toDouble()
    ];

    isNumIndexVisible = [true, true, true, true];
    if (firstGame) {
      isNumIndexVisible = [false, false, false, false];
    }
    firstNumUsedIndex = -1;
    secondNumUsedIndex = -1;
    operationUsed = '_';

    expectNum = true;
    turn = 0;

    finalResult = 0;
  }

  bool isAlertDialogShowing(BuildContext context) {
    return Navigator.of(context, rootNavigator: true).canPop();
  }

  void _showGameEndDialog() {
    setState(() {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            backgroundColor: Colors.indigoAccent,
            content: numProblemsCompleted == 1
                ? Text('⌛\nTimes up!!\n\nYou have completed 1 problem',
                    style: const TextStyle(color: Colors.white, fontSize: 30),
                    textAlign: TextAlign.center)
                : Text(
                    '⌛\nTimes up!!\n\nYou have completed ' +
                        numProblemsCompleted.toString() +
                        ' problems',
                    style: const TextStyle(color: Colors.white, fontSize: 30),
                    textAlign: TextAlign.center),
            actions: <Widget>[
              // usually buttons at the bottom of the dialog
              TextButton(
                style: ButtonStyle(
                    shape: MaterialStateProperty.all(RoundedRectangleBorder(
                        side: const BorderSide(
                          color: Colors.white, // your color here
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(50)))),
                child: const Text("Continue",
                    style: TextStyle(color: Colors.white)),
                onPressed: () {
                  Navigator.of(context).pop();
                  if (_resultDialog.currentContext != null) {
                    Navigator.of(_resultDialog.currentContext!).pop();
                  }
                  if (_divisionErrorDialog.currentContext != null) {
                    Navigator.of(_divisionErrorDialog.currentContext!).pop();
                  }
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    });
  }

  void _showResultDialog() {
    if (finalResult == 24) {
      setState(() {
        isNumIndexVisible = [false, false, false, false];
      });
    }
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        final confettiController = ConfettiController();
        if (finalResult == 24) {
          ++numProblemsCompleted;
          confettiController.play();
        }
        return Stack(
          alignment: Alignment.topCenter,
          children: [
            AlertDialog(
              key: _resultDialog,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              backgroundColor: finalResult == 24 ? Colors.green : Colors.red,
              content: finalResult == 24
                  ? Text('🎉👏\nCongrats! You got 24',
                      style: TextStyle(color: Colors.white, fontSize: 30),
                      textAlign: TextAlign.center)
                  : Text(
                      '😔\nSorry, you did not get 24.\nYou got ' +
                          Fraction.fromDouble(finalResult).toString() +
                          "\nPlease try again",
                      style: TextStyle(color: Colors.white, fontSize: 30),
                      textAlign: TextAlign.center),
              actions: <Widget>[
                // usually buttons at the bottom of the dialog
                TextButton(
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(
                          side: const BorderSide(
                            color: Colors.white, // your color here
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(50)))),
                  child: const Text("Continue",
                      style: TextStyle(color: Colors.white)),
                  onPressed: () {
                    if (finalResult == 24) {
                      keyTimeWidget.currentState?.stopStartTime();
                      setState(() {
                        newGame(false);
                      });
                    } else {
                      setState(() {
                        resetGame();
                      });
                    }
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
            ConfettiWidget(
              confettiController: confettiController,
              shouldLoop: true,
              blastDirectionality: BlastDirectionality.explosive,
              emissionFrequency: 0.05,
            ),
          ],
        );
      },
    );
  }

  void _showSolutionMsg() {
    setState(() {
      isNumIndexVisible = [false, false, false, false];
    });
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.indigoAccent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          content: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              children: <TextSpan>[
                TextSpan(
                    text: 'Penalty of ',
                    style: const TextStyle(color: Colors.white, fontSize: 30)),
                TextSpan(
                    text: '-20s',
                    style: const TextStyle(color: Colors.red, fontSize: 30)),
                TextSpan(
                    text:
                        '\n\nHere is one possible solution to the problem:\n\n' +
                            solution.toString(),
                    style: const TextStyle(color: Colors.white, fontSize: 30))
              ],
            ),
          ),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            TextButton(
                style: ButtonStyle(
                    shape: MaterialStateProperty.all(RoundedRectangleBorder(
                        side: const BorderSide(
                          color: Colors.white, // your color here
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(50)))),
                child: const Text("Continue",
                    style: TextStyle(color: Colors.white)),
                onPressed: () {
                  Navigator.of(context).pop();
                  keyTimeWidget.currentState?.stopStartTime();
                  setState(() {
                    newGame(false);
                  });
                }),
          ],
        );
      },
    );
  }

  void _showDivisionErrorMsg() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          key: _divisionErrorDialog,
          backgroundColor: Colors.red,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          content: const Text('⚠️\nSorry you cannot divide by zero',
              style: TextStyle(color: Colors.white, fontSize: 30),
              textAlign: TextAlign.center),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            TextButton(
                style: ButtonStyle(
                    shape: MaterialStateProperty.all(RoundedRectangleBorder(
                        side: const BorderSide(
                          color: Colors.white, // your color here
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(50)))),
                child: const Text("Continue",
                    style: TextStyle(color: Colors.white)),
                onPressed: () {
                  Navigator.of(context).pop();
                  setState(() {
                    resetGame();
                  });
                }),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            backgroundColor: difficultyToColor[getDifficulty()],
            centerTitle: true,
            title: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text("Timed Game",
                    style: TextStyle(
                      color: Colors.white,
                    ))
              ],
            )),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TimerWidget(keyTimeWidget, () => _showGameEndDialog()),
              const Padding(padding: EdgeInsets.only(bottom: 30.0)),
              // NUM BUTTONS
              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    IgnorePointer(
                        ignoring: !isNumIndexVisible[0],
                        child: AnimatedOpacity(
                            opacity: isNumIndexVisible[0] ? 1.0 : 0.0,
                            duration: const Duration(milliseconds: 750),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  shadowColor: Colors.black,
                                  elevation: 10.0,
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(32.0)),
                                  minimumSize: const Size(100, 80),
                                  primary: difficultyToColor[getDifficulty()]),
                              onPressed: firstNumUsedIndex == 0 ||
                                      secondNumUsedIndex == 0 ||
                                      !expectNum
                                  ? null
                                  : () {
                                      setState(() {
                                        if (turn == 0) {
                                          firstNumUsedIndex = 0;
                                        } else {
                                          secondNumUsedIndex = 0;
                                        }
                                        expectNum = false;
                                      });

                                      if (readyToCreateNewNumber()) {
                                        handleCreateNewNum();
                                      }
                                    },
                              child: Text(
                                Fraction.fromDouble(nums[0]).toString(),
                                style: const TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                ),
                              ),
                            ))),
                    const Padding(padding: EdgeInsets.only(right: 30.0)),
                    IgnorePointer(
                        ignoring: !isNumIndexVisible[1],
                        child: AnimatedOpacity(
                            opacity: isNumIndexVisible[1] ? 1.0 : 0.0,
                            duration: const Duration(milliseconds: 750),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  shadowColor: Colors.black,
                                  elevation: 10.0,
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(32.0)),
                                  minimumSize: const Size(100, 80),
                                  primary: difficultyToColor[getDifficulty()]),
                              onPressed: firstNumUsedIndex == 1 ||
                                      secondNumUsedIndex == 1 ||
                                      !expectNum
                                  ? null
                                  : () {
                                      setState(() {
                                        if (turn == 0) {
                                          firstNumUsedIndex = 1;
                                        } else {
                                          secondNumUsedIndex = 1;
                                        }
                                        expectNum = false;
                                      });

                                      if (readyToCreateNewNumber()) {
                                        handleCreateNewNum();
                                      }
                                    },
                              child: Text(
                                Fraction.fromDouble(nums[1]).toString(),
                                style: const TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                ),
                              ),
                            ))),
                  ]),
              const Padding(padding: EdgeInsets.only(bottom: 30.0)),
              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    IgnorePointer(
                        ignoring: !isNumIndexVisible[2],
                        child: AnimatedOpacity(
                            opacity: isNumIndexVisible[2] ? 1.0 : 0.0,
                            duration: const Duration(milliseconds: 750),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  shadowColor: Colors.black,
                                  elevation: 10.0,
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(32.0)),
                                  minimumSize: const Size(100, 80),
                                  primary: difficultyToColor[getDifficulty()]),
                              onPressed: firstNumUsedIndex == 2 ||
                                      secondNumUsedIndex == 2 ||
                                      !expectNum
                                  ? null
                                  : () {
                                      setState(() {
                                        if (turn == 0) {
                                          firstNumUsedIndex = 2;
                                        } else {
                                          secondNumUsedIndex = 2;
                                        }
                                        expectNum = false;
                                      });

                                      if (readyToCreateNewNumber()) {
                                        handleCreateNewNum();
                                      }
                                    },
                              child: Text(
                                Fraction.fromDouble(nums[2]).toString(),
                                style: const TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                ),
                              ),
                            ))),
                    const Padding(padding: EdgeInsets.only(right: 30.0)),
                    IgnorePointer(
                        ignoring: !isNumIndexVisible[3],
                        child: AnimatedOpacity(
                            opacity: isNumIndexVisible[3] ? 1.0 : 0.0,
                            duration: const Duration(milliseconds: 750),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  shadowColor: Colors.black,
                                  elevation: 10.0,
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(32.0)),
                                  minimumSize: const Size(100, 80),
                                  primary: difficultyToColor[getDifficulty()]),
                              onPressed: firstNumUsedIndex == 3 ||
                                      secondNumUsedIndex == 3 ||
                                      !expectNum
                                  ? null
                                  : () {
                                      setState(() {
                                        if (turn == 0) {
                                          firstNumUsedIndex = 3;
                                        } else {
                                          secondNumUsedIndex = 3;
                                        }
                                        expectNum = false;
                                      });

                                      if (readyToCreateNewNumber()) {
                                        handleCreateNewNum();
                                      }
                                    },
                              child: Text(
                                Fraction.fromDouble(nums[3]).toString(),
                                style: const TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                ),
                              ),
                            ))),
                  ]),
              const Padding(padding: EdgeInsets.only(bottom: 50.0)),
              // OPERATION BUTTONS
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    ButtonTheme(
                        minWidth: 50.0,
                        height: 50.0,
                        child: OutlinedButton(
                            onPressed: turn > 0 || expectNum
                                ? null
                                : () {
                                    setState(() {
                                      operationUsed = '+';
                                    });
                                    expectNum = true;
                                    ++turn;
                                  },
                            child: Text('+',
                                style: TextStyle(
                                    fontSize: 25,
                                    fontWeight: FontWeight.bold,
                                    color: turn > 0 || expectNum
                                        ? Colors.grey
                                        : difficultyToColor[
                                            getDifficulty()])))),
                    ButtonTheme(
                        minWidth: 50.0,
                        height: 50.0,
                        child: OutlinedButton(
                            onPressed: turn > 0 || expectNum
                                ? null
                                : () {
                                    setState(() {
                                      operationUsed = '-';
                                    });
                                    expectNum = true;
                                    ++turn;
                                  },
                            child: Text('-',
                                style: TextStyle(
                                    fontSize: 25,
                                    fontWeight: FontWeight.bold,
                                    color: turn > 0 || expectNum
                                        ? Colors.grey
                                        : difficultyToColor[
                                            getDifficulty()])))),
                    ButtonTheme(
                        minWidth: 50.0,
                        height: 50.0,
                        child: OutlinedButton(
                            onPressed: turn > 0 || expectNum
                                ? null
                                : () {
                                    setState(() {
                                      operationUsed = '×';
                                    });
                                    expectNum = true;
                                    ++turn;
                                  },
                            child: Text('×',
                                style: TextStyle(
                                    fontSize: 25,
                                    fontWeight: FontWeight.bold,
                                    color: turn > 0 || expectNum
                                        ? Colors.grey
                                        : difficultyToColor[
                                            getDifficulty()])))),
                    ButtonTheme(
                        minWidth: 50.0,
                        height: 50.0,
                        child: OutlinedButton(
                            onPressed: turn > 0 || expectNum
                                ? null
                                : () {
                                    setState(() {
                                      operationUsed = '÷';
                                    });
                                    expectNum = true;
                                    ++turn;
                                  },
                            child: Text('÷',
                                style: TextStyle(
                                    fontSize: 25,
                                    fontWeight: FontWeight.bold,
                                    color: turn > 0 || expectNum
                                        ? Colors.grey
                                        : difficultyToColor[
                                            getDifficulty()])))),
                  ]),
              const Padding(padding: EdgeInsets.only(bottom: 50.0)),
              // RESULT TEXT
              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                        padding:
                            const EdgeInsets.only(right: 10.0, bottom: 30.0),
                        child: Text(
                            firstNumUsedIndex == -1
                                ? "_"
                                : Fraction.fromDouble(nums[firstNumUsedIndex])
                                    .toString(),
                            style: const TextStyle(fontSize: 26))),
                    Padding(
                        padding: const EdgeInsets.only(
                            left: 10.0, right: 10.0, bottom: 30.0),
                        child: Text(operationUsed,
                            style: const TextStyle(fontSize: 26))),
                    Padding(
                        padding:
                            const EdgeInsets.only(left: 10.0, bottom: 30.0),
                        child: Text(
                            secondNumUsedIndex == -1
                                ? "_"
                                : Fraction.fromDouble(nums[secondNumUsedIndex])
                                    .toString(),
                            style: const TextStyle(fontSize: 26)))
                  ]),
            ],
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              FloatingActionButton(
                heroTag: "refresh_button",
                backgroundColor: Colors.indigoAccent,
                onPressed: () {
                  setState(() {
                    resetGame();
                  });
                },
                child: Icon(Icons.refresh),
                tooltip: 'Reset Game',
              ),
              FloatingActionButton(
                heroTag: "next_game_button",
                backgroundColor: Colors.indigoAccent,
                onPressed: () {
                  keyTimeWidget.currentState?.reduceTime();
                  keyTimeWidget.currentState?.stopStartTime();
                  _showSolutionMsg();
                },
                child: Icon(Icons.arrow_forward),
                tooltip: 'Next Game',
              )
            ],
          ),
        ));
  }
}
