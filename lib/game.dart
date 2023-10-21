import 'package:flutter/material.dart';
import 'package:projects/difficulty.dart';
import 'dart:math';
import 'data.dart';

var rng = Random();

List<List<int>> allSolvableProblems = getProblems();
Set<int> problemIndexSeen = {};
List<int> shuffledProblem = [];

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

List<bool> isNumUsedIndexes = [false, false, false, false];
List<int> currentlyUsedNumIndexes = [-1, -1];
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
  for (var i = list.length - 1; i > 0; i--) {
    final j = rng.nextInt(i + 1);
    final temp = list[i];
    list[i] = list[j];
    list[j] = temp;
  }
  return list;
}

class GamePage extends StatefulWidget {
  GamePage({Key? key}) : super(key: key);

  @override
  _MyGamePageState createState() => _MyGamePageState();
}

class _MyGamePageState extends State<GamePage> {
  _MyGamePageState() {
    startTime = DateTime.now();
    newGame(true);
  }

  bool done() {
    return turn >= 1 && currentlyUsedNumIndexes[1] != -1;
  }

  void resetGame() {
    nums = [
      firstNum.toDouble(),
      secondNum.toDouble(),
      thirdNum.toDouble(),
      fourthNum.toDouble()
    ];
    currentlyUsedNumIndexes = [-1, -1];
    isNumUsedIndexes = [false, false, false, false];

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
    print(randomProblemIndex);
    if (firstGame) {
      problemIndexSeen = {};
    }
    // make sure new problem is not seen before
    while (problemIndexSeen.contains(randomProblemIndex)) {
      randomProblemIndex = rng.nextInt(allSolvableProblems.length);
    }
    problemIndexSeen.add(randomProblemIndex);
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
    isNumUsedIndexes = [false, false, false, false];
    currentlyUsedNumIndexes = [-1, -1];

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
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          backgroundColor: finalResult == 24 ? Colors.green : Colors.red,
          content: finalResult == 24
              ? Text(
                  '🎉👏\nCongrats! You got 24.\nYour time was ' +
                      timePassedMinutes.toString().padLeft(2, "0") +
                      ":" +
                      timePassedSeconds.toString().padLeft(2, "0"),
                  style: TextStyle(color: Colors.white, fontSize: 30),
                  textAlign: TextAlign.center)
              : finalResult == finalResult.roundToDouble()
                  ? Text(
                      '😔\nSorry, you did not get 24.\nYou got ' +
                          finalResult.toInt().toString() + "\nPlease try again",
                      style: TextStyle(color: Colors.white, fontSize: 30),
                      textAlign: TextAlign.center)
                  : Text(
                      '😔\nSorry, you did not get 24.\nYou got ' +
                          finalResult.toStringAsFixed(2) + "\nPlease try again",
                      style: TextStyle(color: Colors.white, fontSize: 30),
                      textAlign: TextAlign.center),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            TextButton(
              child: Text("Continue"),
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
                child: Text("Continue"),
                onPressed: () {
                  Navigator.of(context).pop();
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
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.refresh),
              color: Colors.white,
              onPressed: () {
                setState(() {
                  resetGame();
                });
              },
              tooltip: "Restart",
            )
          ],
          title: Center(
              child: const Text("24 Game",
                  style: TextStyle(
                    color: Colors.white,
                  )))),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // NUM BUTTONS
            Container(
                height: 100,
                child: GridView.builder(
                    itemCount: nums.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: nums.length,
                    ),
                    itemBuilder: (BuildContext context, int index) {
                      return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            ButtonTheme(
                                minWidth: 50.0,
                                height: 50.0,
                                child: Visibility(
                                    visible: nums[index] == -1 ? false : true,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(32.0)),
                                          minimumSize: Size(70, 70),
                                          primary: difficultyToColor[
                                              getDifficulty()]),
                                      onPressed: isNumUsedIndexes[index] ||
                                              !expectNum
                                          ? null
                                          : () {
                                              setState(() {
                                                currentlyUsedNumIndexes[turn] =
                                                    index;
                                              });
                                              expectNum = false;
                                              isNumUsedIndexes[index] = true;
                                            },
                                      child: Text(
                                        nums[index] ==
                                                nums[index].roundToDouble()
                                            ? nums[index].toInt().toString()
                                            : nums[index].toStringAsFixed(2),
                                        style: const TextStyle(
                                          fontSize: 20,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ))),
                          ]);
                    })),
            Padding(padding: EdgeInsets.only(bottom: 20.0)),
            // OPERATION BUTTONS
            Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
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
                              turn++;
                            },
                      child: Text('+',
                          style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                              color: turn > 0 || expectNum
                                  ? Colors.grey
                                  : difficultyToColor[getDifficulty()])))),
              Padding(padding: EdgeInsets.only(right: 30.0)),
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
                              turn++;
                            },
                      child: Text('-',
                          style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                              color: turn > 0 || expectNum
                                  ? Colors.grey
                                  : difficultyToColor[getDifficulty()])))),
              Padding(padding: EdgeInsets.only(right: 30.0)),
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
                              turn++;
                            },
                      child: Text('×',
                          style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                              color: turn > 0 || expectNum
                                  ? Colors.grey
                                  : difficultyToColor[getDifficulty()])))),
              Padding(padding: EdgeInsets.only(right: 35.0)),
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
                              turn++;
                            },
                      child: Text('÷',
                          style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                              color: turn > 0 || expectNum
                                  ? Colors.grey
                                  : difficultyToColor[getDifficulty()])))),
            ]),
            Padding(padding: EdgeInsets.only(bottom: 50.0)),
            // RESULT TEXT
            nums.length == 1
                ? Text(' ')
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                        Padding(
                            padding: EdgeInsets.only(right: 10.0, bottom: 30.0),
                            child: Text(
                                currentlyUsedNumIndexes[0] == -1
                                    ? "_"
                                    : nums[currentlyUsedNumIndexes[0]] ==
                                            nums[currentlyUsedNumIndexes[0]]
                                                .roundToDouble()
                                        ? nums[currentlyUsedNumIndexes[0]]
                                            .toInt()
                                            .toString()
                                        : nums[currentlyUsedNumIndexes[0]]
                                            .toStringAsFixed(2),
                                style: TextStyle(fontSize: 26))),
                        Padding(
                            padding: EdgeInsets.only(
                                left: 10.0, right: 10.0, bottom: 30.0),
                            child: Text(operationUsed,
                                style: TextStyle(fontSize: 26))),
                        Padding(
                            padding: EdgeInsets.only(left: 10.0, bottom: 30.0),
                            child: Text(
                                currentlyUsedNumIndexes[1] == -1
                                    ? "_"
                                    : nums[currentlyUsedNumIndexes[1]] ==
                                            nums[currentlyUsedNumIndexes[1]]
                                                .roundToDouble()
                                        ? nums[currentlyUsedNumIndexes[1]]
                                            .toInt()
                                            .toString()
                                        : nums[currentlyUsedNumIndexes[1]]
                                            .toStringAsFixed(2),
                                style: TextStyle(fontSize: 26)))
                      ]),
            ButtonTheme(
              minWidth: 48.0,
              height: 36.0,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    primary: Colors.green // Background color
                    ),
                onPressed: !done()
                    ? null
                    : () {
                        bool divisionError = false;
                        if (operationUsed == '+') {
                          finalResult = nums[currentlyUsedNumIndexes[0]] +
                              nums[currentlyUsedNumIndexes[1]].toDouble();
                        } else if (operationUsed == '-') {
                          finalResult = nums[currentlyUsedNumIndexes[0]] -
                              nums[currentlyUsedNumIndexes[1]].toDouble();
                        } else if (operationUsed == '×') {
                          finalResult = nums[currentlyUsedNumIndexes[0]] *
                              nums[currentlyUsedNumIndexes[1]].toDouble();
                        } else if (operationUsed == '÷') {
                          if (nums[currentlyUsedNumIndexes[1]] != 0) {
                            finalResult = (nums[currentlyUsedNumIndexes[0]] /
                                nums[currentlyUsedNumIndexes[1]]);
                          } else {
                            _showDivisionErrorMsg();
                            divisionError = true;
                          }
                        }

                        if (!divisionError) {
                          setState(() {
                            nums[currentlyUsedNumIndexes[0]] = finalResult;
                            nums[currentlyUsedNumIndexes[1]] = -1;

                            isNumUsedIndexes = [];
                            for (int i = 0; i < nums.length; i++) {
                              isNumUsedIndexes.add(false);
                            }

                            expectNum = true;
                            turn = 0;
                            currentlyUsedNumIndexes = [-1, -1];
                            operationUsed = '_';

                            int numDiceLeft = 4;
                            for (double die in nums) {
                              if (die == -1) {
                                --numDiceLeft;
                              }
                            }
                            if (numDiceLeft <= 1) {
                              if (finalResult == 24) {
                                DateTime end = DateTime.now();
                                timePassedSeconds =
                                    end.difference(startTime).inSeconds;

                                timePassedMinutes =
                                    (timePassedSeconds / 60).truncate();
                                timePassedSeconds = timePassedSeconds % 60;
                              }
                              _showResultDialog();
                            }
                          });
                        }
                      },
                child: const Text(
                  'Submit',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: difficultyToColor[getDifficulty()],
        onPressed: () {
          setState(() {
            newGame(false);
          });
        },
        tooltip: 'Next Game',
        child: const Icon(Icons.arrow_forward),
      ),
    );
  }
}
