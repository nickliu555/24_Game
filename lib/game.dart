import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:projects/difficulty.dart';
import 'package:projects/solutions.dart';
import 'dart:math';
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

List<bool> isIndexVisible = [true, true, true, true];
List<int> currentStepUsedNumIndex = [-1, -1];
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

DateTime startTime = DateTime.now();
int timePassedSeconds = 0;
int timePassedMinutes = 0;

List<int> shuffleList<T>(List<int> list) {
  List<int> newList = list;
  for (var i = newList.length - 1; i > 0; --i) {
    final j = rng.nextInt(i + 1);
    final temp = newList[i];
    newList[i] = newList[j];
    newList[j] = temp;
  }
  return newList;
}

class GamePage extends StatefulWidget {
  GamePage({Key? key}) : super(key: key);

  @override
  _MyGamePageState createState() => _MyGamePageState();
}

class _MyGamePageState extends State<GamePage> {
  _MyGamePageState() {
    newGame(true);
  }

  bool readyToCreateNewNumber() {
    return turn >= 1 && currentStepUsedNumIndex[1] != -1;
  }

  void handleCreateNewNum() {
    if (operationUsed == '+') {
      finalResult = nums[currentStepUsedNumIndex[0]] +
          nums[currentStepUsedNumIndex[1]].toDouble();
    } else if (operationUsed == '-') {
      finalResult = nums[currentStepUsedNumIndex[0]] -
          nums[currentStepUsedNumIndex[1]].toDouble();
    } else if (operationUsed == '×') {
      finalResult = nums[currentStepUsedNumIndex[0]] *
          nums[currentStepUsedNumIndex[1]].toDouble();
    } else if (operationUsed == '÷') {
      if (nums[currentStepUsedNumIndex[1]] != 0) {
        finalResult =
            (nums[currentStepUsedNumIndex[0]] / nums[currentStepUsedNumIndex[1]]);
      } else {
        _showDivisionErrorMsg();
        return;
      }
    }

    setState(() {
      nums[currentStepUsedNumIndex[0]] = finalResult;
      isIndexVisible[currentStepUsedNumIndex[1]] = false;

      expectNum = true;
      turn = 0;
      currentStepUsedNumIndex = [-1, -1];
      operationUsed = '_';

      int numLeftToUse = 4;
      for (int i=0; i<4; ++i) {
        if (!isIndexVisible[i]) {
          --numLeftToUse;
        }
      }
      // have used all numbers
      if (numLeftToUse <= 1) {
        if (finalResult == 24) {
          DateTime end = DateTime.now();
          timePassedSeconds = end.difference(startTime).inSeconds;
          timePassedMinutes = (timePassedSeconds / 60).truncate();
          timePassedSeconds = timePassedSeconds % 60;
        }
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

    isIndexVisible = [true, true, true, true];
    currentStepUsedNumIndex = [-1, -1];
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

    isIndexVisible = [true, true, true, true];
    currentStepUsedNumIndex = [-1, -1];
    operationUsed = '_';

    expectNum = true;
    turn = 0;

    finalResult = 0;
    startTime = DateTime.now();
  }

  void _showResultDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        final confettiController = ConfettiController();
        if (finalResult == 24) {
          confettiController.play();
        }
        return Stack(
          alignment: Alignment.topCenter,
          children: [
            AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              backgroundColor: finalResult == 24 ? Colors.green : Colors.red,
              content: finalResult == 24
                  ? Text(
                      '🎉👏\nCongrats! You got 24\nYour time was ' +
                          timePassedMinutes.toString().padLeft(2, "0") +
                          ":" +
                          timePassedSeconds.toString().padLeft(2, "0"),
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
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.blue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          content: Text(
              'Here is one possible solution to the problem:\n\n' +
                  solution.toString(),
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
          backgroundColor: Colors.red,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          content: const Text('Sorry you cannot divide by zero',
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
                Text("24 Game",
                    style: TextStyle(
                      color: Colors.white,
                    ))
              ],
            )),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // NUM BUTTONS
              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Visibility(
                        visible: isIndexVisible[0],
                        maintainSize: true,
                        maintainAnimation: true,
                        maintainState: true,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(32.0)),
                              minimumSize: const Size(100, 80),
                              primary: difficultyToColor[getDifficulty()]),
                          onPressed: currentStepUsedNumIndex[0] == 0 ||
                                  currentStepUsedNumIndex[1] == 0 ||
                                  !expectNum
                              ? null
                              : () {
                                  setState(() {
                                    currentStepUsedNumIndex[turn] = 0;
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
                        )),
                    const Padding(padding: EdgeInsets.only(right: 30.0)),
                    Visibility(
                        visible: isIndexVisible[1],
                        maintainSize: true,
                        maintainAnimation: true,
                        maintainState: true,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(32.0)),
                              minimumSize: const Size(100, 80),
                              primary: difficultyToColor[getDifficulty()]),
                          onPressed: currentStepUsedNumIndex[0] == 1 ||
                                  currentStepUsedNumIndex[1] == 1 ||
                                  !expectNum
                              ? null
                              : () {
                                  setState(() {
                                    currentStepUsedNumIndex[turn] = 1;
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
                        )),
                  ]),
              const Padding(padding: EdgeInsets.only(bottom: 30.0)),
              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Visibility(
                        visible: isIndexVisible[2],
                        maintainSize: true,
                        maintainAnimation: true,
                        maintainState: true,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(32.0)),
                              minimumSize: const Size(100, 80),
                              primary: difficultyToColor[getDifficulty()]),
                          onPressed: currentStepUsedNumIndex[0] == 2 ||
                                  currentStepUsedNumIndex[1] == 2 ||
                                  !expectNum
                              ? null
                              : () {
                                  setState(() {
                                    currentStepUsedNumIndex[turn] = 2;
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
                        )),
                    const Padding(padding: EdgeInsets.only(right: 30.0)),
                    Visibility(
                        visible: isIndexVisible[3],
                        maintainSize: true,
                        maintainAnimation: true,
                        maintainState: true,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(32.0)),
                              minimumSize: const Size(100, 80),
                              primary: difficultyToColor[getDifficulty()]),
                          onPressed: currentStepUsedNumIndex[0] == 3 ||
                                  currentStepUsedNumIndex[1] == 3 ||
                                  !expectNum
                              ? null
                              : () {
                                  setState(() {
                                    currentStepUsedNumIndex[turn] = 3;
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
                        )),
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
                            currentStepUsedNumIndex[0] == -1
                                ? "_"
                                : Fraction.fromDouble(
                                        nums[currentStepUsedNumIndex[0]])
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
                            currentStepUsedNumIndex[1] == -1
                                ? "_"
                                : Fraction.fromDouble(
                                        nums[currentStepUsedNumIndex[1]])
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
