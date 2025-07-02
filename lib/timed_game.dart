import 'dart:math';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:fraction/fraction.dart';
import 'package:projects/difficulty.dart';
import 'package:projects/solutions.dart';
import 'package:projects/timer.dart';

import 'problems.dart';

var rng = Random();

List<List<int>> allSolvableProblems = getProblems();
Map<String, String> problemToSolutionMap = getProblemSolutionMap();

List<List<int>> validProblems = [];
List<int> currProblem = [];
String? solution = "";

class GameState {
  late List<double> nums;
  List<bool> isNumIndexVisible;
  int firstNumUsedIndex;
  int secondNumUsedIndex;
  String operationUsed;

  GameState({
    this.isNumIndexVisible = const [false, false, false, false],
    this.firstNumUsedIndex = -1,
    this.secondNumUsedIndex = -1,
    this.operationUsed = '_'
  }) {
    nums = [
      currProblem[0].toDouble(),
      currProblem[1].toDouble(),
      currProblem[2].toDouble(),
      currProblem[3].toDouble()
    ];
  }

  // Copy constructor
  GameState.copy(GameState other)
      : isNumIndexVisible = List.from(other.isNumIndexVisible),
        firstNumUsedIndex = other.firstNumUsedIndex,
        secondNumUsedIndex = other.secondNumUsedIndex,
        operationUsed = other.operationUsed {
    nums = List.from(other.nums);
  }
}

List<GameState> gameStateStack = [];

int numProblemsCompleted = 0;
GlobalKey<TimerWidgetState> keyTimeWidget = GlobalKey();
var divisionErrorDialog = null;
var resultDialog = null;

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
        gameStateStack.last.isNumIndexVisible = [true, true, true, true];
      });
    });
  }

  bool readyToCreateNewNumber() {
    return gameStateStack.last.secondNumUsedIndex != -1;
  }

  bool expectNum() {
    if (gameStateStack.last.firstNumUsedIndex == -1 ||
        (gameStateStack.last.operationUsed != '_' && gameStateStack.last.secondNumUsedIndex == -1)) {
      return true;
    }
    return false;
  }

  void handleCreateNewNum() {
    double finalResult = 0;
    if (gameStateStack.last.operationUsed == '+') {
      finalResult =
          gameStateStack.last.nums[gameStateStack.last.firstNumUsedIndex]
              + gameStateStack.last.nums[gameStateStack.last.secondNumUsedIndex].toDouble();
    } else if (gameStateStack.last.operationUsed == '-') {
      finalResult =
          gameStateStack.last.nums[gameStateStack.last.firstNumUsedIndex]
              - gameStateStack.last.nums[gameStateStack.last.secondNumUsedIndex].toDouble();
    } else if (gameStateStack.last.operationUsed == '×') {
      finalResult =
          gameStateStack.last.nums[gameStateStack.last.firstNumUsedIndex]
              * gameStateStack.last.nums[gameStateStack.last.secondNumUsedIndex].toDouble();
    } else if (gameStateStack.last.operationUsed == '÷') {
      if (gameStateStack.last.nums[gameStateStack.last.secondNumUsedIndex] != 0) {
        finalResult = (gameStateStack.last.nums[gameStateStack.last.firstNumUsedIndex]
            / gameStateStack.last.nums[gameStateStack.last.secondNumUsedIndex]);
      } else {
        _showDivisionErrorDialog();
        return;
      }
    }

    setState(() {
      gameStateStack.last.nums[gameStateStack.last.secondNumUsedIndex] = finalResult;
      gameStateStack.last.isNumIndexVisible[gameStateStack.last.firstNumUsedIndex] = false;

      gameStateStack.last.firstNumUsedIndex = -1;
      gameStateStack.last.secondNumUsedIndex = -1;
      gameStateStack.last.operationUsed = '_';

      int numLeftToUse = 4;
      for (int i = 0; i < 4; ++i) {
        if (!gameStateStack.last.isNumIndexVisible[i]) {
          --numLeftToUse;
        }
      }
      // have used all numbers
      if (numLeftToUse <= 1) {
        _showResultDialog(finalResult);
      }
    });
  }

  void resetGame() {
    gameStateStack.last.nums = [
      currProblem[0].toDouble(),
      currProblem[1].toDouble(),
      currProblem[2].toDouble(),
      currProblem[3].toDouble()
    ];

    gameStateStack.last.isNumIndexVisible = [true, true, true, true];
    gameStateStack.last.firstNumUsedIndex = -1;
    gameStateStack.last.secondNumUsedIndex = -1;
    gameStateStack.last.operationUsed = '_';
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

    // if this is the first game, get all of the valid problems for this difficulty level
    // and shuffle all of the problems in random order.
    // Note: we treat the first problem of validProblems as the current problem
    if (firstGame) {
      validProblems = allSolvableProblems.sublist(start, end);
      validProblems.shuffle();
    }

    String problemString = "";
    for (int num in validProblems.first) {
      problemString += (num.toString() + " ");
    }
    problemString = problemString.substring(0, problemString.length - 1); // remove last space
    print('problemString = ' + problemString);
    solution = problemToSolutionMap[problemString];
    print('solution = ' + solution.toString());
    currProblem = shuffleList(validProblems.first); // reorder the numbers in the problem randomly
    validProblems.removeAt(0); // remove this problem from the list

    gameStateStack.clear();
    gameStateStack.add(GameState());

    gameStateStack.last.nums = [
      currProblem[0].toDouble(),
      currProblem[1].toDouble(),
      currProblem[2].toDouble(),
      currProblem[3].toDouble()
    ];

    gameStateStack.last.isNumIndexVisible = [true, true, true, true];
    if (firstGame) {
      gameStateStack.last.isNumIndexVisible = [false, false, false, false];
    }
    gameStateStack.last.firstNumUsedIndex = -1;
    gameStateStack.last.secondNumUsedIndex = -1;
    gameStateStack.last.operationUsed = '_';
  }

  bool isAlertDialogShowing(BuildContext context) {
    return Navigator.of(context, rootNavigator: true).canPop();
  }

  void _showGameEndDialog() {
    AwesomeDialog(
            context: context,
            animType: AnimType.leftSlide,
            headerAnimationLoop: false,
            dialogType: DialogType.info,
            showCloseIcon: false,
            title: '⌛',
            desc: numProblemsCompleted == 1
                ? 'Times up!!\n\nYou have completed 1 problem'
                : 'Times up!!\n\nYou have completed ' +
                    numProblemsCompleted.toString() +
                    ' problems',
            btnOkOnPress: () {
              if (divisionErrorDialog != null) {
                divisionErrorDialog.dismiss();
              }
              if (resultDialog != null) {
                resultDialog.dismiss();
              }
              Navigator.of(context).pop();
            },
            btnOkIcon: Icons.check_circle,
            dismissOnTouchOutside: false)
        .show();
  }

  void _showResultDialog(double finalResult) {
    setState(() {
      gameStateStack.last.isNumIndexVisible = [false, false, false, false];
      if (finalResult == 24) {
        ++numProblemsCompleted;
      }
    });
    resultDialog = AwesomeDialog(
        context: context,
        animType: AnimType.rightSlide,
        headerAnimationLoop: false,
        dialogType: finalResult == 24 ? DialogType.success : DialogType.error,
        showCloseIcon: false,
        title: finalResult == 24 ? '🎉👏' : '😔',
        desc: finalResult == 24
            ? 'Congrats! You got 24'
            : 'Sorry, you did not get 24.\nYou got ' +
                Fraction.fromDouble(finalResult).toString() +
                '\nPlease try again',
        btnOkOnPress: () {
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
          resultDialog = null;
        },
        btnOkIcon: Icons.check_circle,
        dismissOnTouchOutside: false);
    resultDialog.show();
  }

  void _showSolutionDialog() {
    setState(() {
      gameStateStack.last.isNumIndexVisible = [false, false, false, false];
    });
    AwesomeDialog(
            context: context,
            animType: AnimType.leftSlide,
            headerAnimationLoop: false,
            dialogType: DialogType.info,
            showCloseIcon: false,
            title: 'Penalty of -20s',
            desc: 'Here is one possible solution to the problem:\n\n' +
                solution.toString(),
            btnOkOnPress: () {
              keyTimeWidget.currentState?.stopStartTime();
              setState(() {
                newGame(false);
              });
            },
            btnOkIcon: Icons.check_circle,
            dismissOnTouchOutside: false)
        .show();
  }

  void _showDivisionErrorDialog() {
    divisionErrorDialog = AwesomeDialog(
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
            divisionErrorDialog = null;
          });
        },
        btnOkIcon: Icons.check_circle,
        dismissOnTouchOutside: false);
    divisionErrorDialog.show();
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
                        ignoring: !gameStateStack.last.isNumIndexVisible[0],
                        child: AnimatedOpacity(
                            opacity: gameStateStack.last.isNumIndexVisible[0] ? 1.0 : 0.0,
                            duration: gameStateStack.last.isNumIndexVisible[0] ? const Duration(milliseconds: 1500) : const Duration(milliseconds: 0),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  shadowColor: Colors.black,
                                  elevation: 10.0,
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(32.0)),
                                  minimumSize: const Size(100, 80),
                                  primary: difficultyToColor[getDifficulty()]),
                              onPressed: gameStateStack.last.firstNumUsedIndex == 0 ||
                                  gameStateStack.last.secondNumUsedIndex == 0 ||
                                      !expectNum()
                                  ? null
                                  : () {
                                      setState(() {
                                        // create new GameState
                                        gameStateStack.add(GameState.copy(gameStateStack.last));
                                        if (gameStateStack.last.firstNumUsedIndex == -1) {
                                          gameStateStack.last.firstNumUsedIndex = 0;
                                        } else {
                                          gameStateStack.last.secondNumUsedIndex = 0;
                                        }
                                      });

                                      if (readyToCreateNewNumber()) {
                                        handleCreateNewNum();
                                      }
                                    },
                              child: Text(
                                Fraction.fromDouble(gameStateStack.last.nums[0]).toString(),
                                style: const TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                ),
                              ),
                            ))),
                    const Padding(padding: EdgeInsets.only(right: 30.0)),
                    IgnorePointer(
                        ignoring: !gameStateStack.last.isNumIndexVisible[1],
                        child: AnimatedOpacity(
                            opacity: gameStateStack.last.isNumIndexVisible[1] ? 1.0 : 0.0,
                            duration: gameStateStack.last.isNumIndexVisible[1] ? const Duration(milliseconds: 1500) : const Duration(milliseconds: 0),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  shadowColor: Colors.black,
                                  elevation: 10.0,
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(32.0)),
                                  minimumSize: const Size(100, 80),
                                  primary: difficultyToColor[getDifficulty()]),
                              onPressed: gameStateStack.last.firstNumUsedIndex == 1 ||
                                  gameStateStack.last.secondNumUsedIndex == 1 ||
                                      !expectNum()
                                  ? null
                                  : () {
                                      setState(() {
                                        // create new GameState
                                        gameStateStack.add(GameState.copy(gameStateStack.last));
                                        if (gameStateStack.last.firstNumUsedIndex == -1) {
                                          gameStateStack.last.firstNumUsedIndex = 1;
                                        } else {
                                          gameStateStack.last.secondNumUsedIndex = 1;
                                        }
                                      });

                                      if (readyToCreateNewNumber()) {
                                        handleCreateNewNum();
                                      }
                                    },
                              child: Text(
                                Fraction.fromDouble(gameStateStack.last.nums[1]).toString(),
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
                        ignoring: !gameStateStack.last.isNumIndexVisible[2],
                        child: AnimatedOpacity(
                            opacity: gameStateStack.last.isNumIndexVisible[2] ? 1.0 : 0.0,
                            duration: gameStateStack.last.isNumIndexVisible[2] ? const Duration(milliseconds: 1500) : const Duration(milliseconds: 0),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  shadowColor: Colors.black,
                                  elevation: 10.0,
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(32.0)),
                                  minimumSize: const Size(100, 80),
                                  primary: difficultyToColor[getDifficulty()]),
                              onPressed: gameStateStack.last.firstNumUsedIndex == 2 ||
                                  gameStateStack.last.secondNumUsedIndex == 2 ||
                                      !expectNum()
                                  ? null
                                  : () {
                                      setState(() {
                                        // create new GameState
                                        gameStateStack.add(GameState.copy(gameStateStack.last));
                                        if (gameStateStack.last.firstNumUsedIndex == -1) {
                                          gameStateStack.last.firstNumUsedIndex = 2;
                                        } else {
                                          gameStateStack.last.secondNumUsedIndex = 2;
                                        }
                                      });

                                      if (readyToCreateNewNumber()) {
                                        handleCreateNewNum();
                                      }
                                    },
                              child: Text(
                                Fraction.fromDouble(gameStateStack.last.nums[2]).toString(),
                                style: const TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                ),
                              ),
                            ))),
                    const Padding(padding: EdgeInsets.only(right: 30.0)),
                    IgnorePointer(
                        ignoring: !gameStateStack.last.isNumIndexVisible[3],
                        child: AnimatedOpacity(
                            opacity: gameStateStack.last.isNumIndexVisible[3] ? 1.0 : 0.0,
                            duration: gameStateStack.last.isNumIndexVisible[3] ? const Duration(milliseconds: 1500) : const Duration(milliseconds: 0),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  shadowColor: Colors.black,
                                  elevation: 10.0,
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(32.0)),
                                  minimumSize: const Size(100, 80),
                                  primary: difficultyToColor[getDifficulty()]),
                              onPressed: gameStateStack.last.firstNumUsedIndex == 3 ||
                                  gameStateStack.last.secondNumUsedIndex == 3 ||
                                      !expectNum()
                                  ? null
                                  : () {
                                      setState(() {
                                        // create new GameState
                                        gameStateStack.add(GameState.copy(gameStateStack.last));
                                        if (gameStateStack.last.firstNumUsedIndex == -1) {
                                          gameStateStack.last.firstNumUsedIndex = 3;
                                        } else {
                                          gameStateStack.last.secondNumUsedIndex = 3;
                                        }
                                      });

                                      if (readyToCreateNewNumber()) {
                                        handleCreateNewNum();
                                      }
                                    },
                              child: Text(
                                Fraction.fromDouble(gameStateStack.last.nums[3]).toString(),
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
                            onPressed: expectNum()
                                ? null
                                : () {
                                    setState(() {
                                      // create new GameState
                                      gameStateStack.add(GameState.copy(gameStateStack.last));
                                      gameStateStack.last.operationUsed = '+';
                                    });
                                  },
                            child: Text('+',
                                style: TextStyle(
                                    fontSize: 25,
                                    fontWeight: FontWeight.bold,
                                    color: expectNum()
                                        ? Colors.grey
                                        : difficultyToColor[
                                            getDifficulty()])))),
                    ButtonTheme(
                        minWidth: 50.0,
                        height: 50.0,
                        child: OutlinedButton(
                            onPressed: expectNum()
                                ? null
                                : () {
                                    setState(() {
                                      // create new GameState
                                      gameStateStack.add(GameState.copy(gameStateStack.last));
                                      gameStateStack.last.operationUsed = '-';
                                    });
                                  },
                            child: Text('-',
                                style: TextStyle(
                                    fontSize: 25,
                                    fontWeight: FontWeight.bold,
                                    color: expectNum()
                                        ? Colors.grey
                                        : difficultyToColor[
                                            getDifficulty()])))),
                    ButtonTheme(
                        minWidth: 50.0,
                        height: 50.0,
                        child: OutlinedButton(
                            onPressed: expectNum()
                                ? null
                                : () {
                                    setState(() {
                                      // create new GameState
                                      gameStateStack.add(GameState.copy(gameStateStack.last));
                                      gameStateStack.last.operationUsed = '×';
                                    });
                                  },
                            child: Text('×',
                                style: TextStyle(
                                    fontSize: 25,
                                    fontWeight: FontWeight.bold,
                                    color: expectNum()
                                        ? Colors.grey
                                        : difficultyToColor[
                                            getDifficulty()])))),
                    ButtonTheme(
                        minWidth: 50.0,
                        height: 50.0,
                        child: OutlinedButton(
                            onPressed: expectNum()
                                ? null
                                : () {
                                    setState(() {
                                      // create new GameState
                                      gameStateStack.add(GameState.copy(gameStateStack.last));
                                      gameStateStack.last.operationUsed = '÷';
                                    });
                                  },
                            child: Text('÷',
                                style: TextStyle(
                                    fontSize: 25,
                                    fontWeight: FontWeight.bold,
                                    color: expectNum()
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
                            gameStateStack.last.firstNumUsedIndex == -1
                                ? "_"
                                : Fraction.fromDouble(gameStateStack.last.nums[gameStateStack.last.firstNumUsedIndex])
                                    .toString(),
                            style: const TextStyle(fontSize: 26))),
                    Padding(
                        padding: const EdgeInsets.only(
                            left: 10.0, right: 10.0, bottom: 30.0),
                        child: Text(gameStateStack.last.operationUsed,
                            style: const TextStyle(fontSize: 26))),
                    Padding(
                        padding:
                            const EdgeInsets.only(left: 10.0, bottom: 30.0),
                        child: Text(
                            gameStateStack.last.secondNumUsedIndex == -1
                                ? "_"
                                : Fraction.fromDouble(gameStateStack.last.nums[gameStateStack.last.secondNumUsedIndex])
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
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SizedBox(
                width: 130,
                height: 56,
                child: Stack(
                  children: [
                    Positioned(
                      left: 0,
                      child: FloatingActionButton(
                        heroTag: "reset_button",
                        backgroundColor: Colors.indigoAccent,
                        onPressed: () {
                          setState(() {
                            gameStateStack.last.isNumIndexVisible = [false, false, false, false];
                          });
                          Future.delayed(Duration(milliseconds: 30), () {
                            setState(() {
                              resetGame();
                            });
                          });
                        },
                        child: Icon(Icons.skip_previous),
                        tooltip: 'Reset Game',
                      ),
                    ),
                    Positioned(
                      left: 70,
                      child: FloatingActionButton(
                        heroTag: "undo_button",
                        backgroundColor: (gameStateStack.length > 1) ? Colors.indigoAccent : Colors.grey,
                        onPressed: () {
                          if (gameStateStack.length > 1) {
                            setState(() {
                              gameStateStack.removeLast();
                            });
                          }
                        },
                        child: Icon(Icons.refresh),
                        tooltip: 'Undo Button',
                      ),
                    ),
                  ],
                ),
              ),

              // Right side button
              FloatingActionButton(
                heroTag: "next_game_button",
                backgroundColor: Colors.indigoAccent,
                onPressed: () {
                  keyTimeWidget.currentState?.reduceTime();
                  keyTimeWidget.currentState?.stopStartTime();
                  _showSolutionDialog();
                },
                child: Icon(Icons.navigate_next),
                tooltip: 'Next Game',
              ),
            ],
          ),
        ));
  }
}
