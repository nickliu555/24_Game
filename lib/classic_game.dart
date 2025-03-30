import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:projects/difficulty.dart';
import 'package:projects/solutions.dart';
import 'dart:math';
import 'clock.dart';
import 'problems.dart';
import 'package:fraction/fraction.dart';

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

var difficultyToColor = {
  difficultyLevel.Easy: Colors.green,
  difficultyLevel.Medium: Colors.orange,
  difficultyLevel.Hard: Colors.red,
  difficultyLevel.Mixed: Colors.purple,
};

ClockWidget clockWidget = ClockWidget();

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

class ClassicGamePage extends StatefulWidget {
  ClassicGamePage({Key? key}) : super(key: key);

  @override
  _ClassicGamePageState createState() => _ClassicGamePageState();
}

class _ClassicGamePageState extends State<ClassicGamePage> {
  _ClassicGamePageState() {
    newGame(true);
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
        _showDivisionErrorDialog();
        return;
      }
    }

    setState(() {
      nums[secondNumUsedIndex] = finalResult;
      isNumIndexVisible[firstNumUsedIndex] = false;

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

  void _showResultDialog() {
    if (finalResult == 24) {
      setState(() {
        isNumIndexVisible = [false, false, false, false];
        if (finalResult == 24) {
          clockWidget.stop();
        }
      });
    }
    AwesomeDialog(
            context: context,
            animType: AnimType.rightSlide,
            headerAnimationLoop: false,
            dialogType:
                finalResult == 24 ? DialogType.success : DialogType.error,
            showCloseIcon: false,
            title: finalResult == 24 ? '🎉👏' : '😔',
            desc: finalResult == 24
                ? 'Congrats! You got 24\nYour time was ' +
                    clockWidget.getMinutes().toString().padLeft(2, "0") +
                    ":" +
                    clockWidget.getSeconds().toString().padLeft(2, "0")
                : 'Sorry, you did not get 24.\nYou got ' +
                    Fraction.fromDouble(finalResult).toString() +
                    '\nPlease try again',
            btnOkOnPress: () {
              if (finalResult == 24) {
                setState(() {
                  clockWidget.reset();
                  newGame(false);
                });
              } else {
                setState(() {
                  resetGame();
                });
              }
            },
            btnOkIcon: Icons.check_circle,
            dismissOnTouchOutside: false)
        .show();
  }

  void _showSolutionDialog() {
    setState(() {
      isNumIndexVisible = [false, false, false, false];
      clockWidget.stop();
    });
    AwesomeDialog(
            context: context,
            animType: AnimType.leftSlide,
            headerAnimationLoop: false,
            dialogType: DialogType.info,
            showCloseIcon: false,
            title: '⏭️',
            desc: 'Here is one possible solution to the problem:\n\n' +
                solution.toString(),
            btnOkOnPress: () {
              setState(() {
                clockWidget.reset();
                newGame(false);
              });
            },
            btnOkIcon: Icons.check_circle,
            dismissOnTouchOutside: false)
        .show();
  }

  void _showDivisionErrorDialog() {
    AwesomeDialog(
            context: context,
            animType: AnimType.rightSlide,
            headerAnimationLoop: false,
            dialogType: DialogType.error,
            showCloseIcon: false,
            title: '⚠️',
            desc: 'Sorry you cannot divide by zero',
            btnOkOnPress: () {
              setState(() {
                resetGame();
              });
            },
            btnOkIcon: Icons.check_circle,
            dismissOnTouchOutside: false)
        .show();
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
                Text("Classic Game",
                    style: TextStyle(
                      color: Colors.white,
                    ))
              ],
            )),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              clockWidget,
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
                  _showSolutionDialog();
                },
                child: Icon(Icons.arrow_forward),
                tooltip: 'Next Game',
              )
            ],
          ),
        ));
  }
}
