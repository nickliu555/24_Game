import 'package:flutter/material.dart';
import 'dart:math';

var rng = new Random();

int firstNum = rng.nextInt(9) + 1;
int secondNum = rng.nextInt(9) + 1;
int thirdNum = rng.nextInt(9) + 1;
int fourthNum = rng.nextInt(9) + 1;

List<int> nums = [firstNum, secondNum, thirdNum, fourthNum];

List<bool> isNumUsedIndexes = [false, false, false, false];
List<int> numCurrentlyUsedIndexes = [-1, -1];
String operationUsed = '_';

bool expectNum = true;
int turn = 0;

int finalResult = 0;

List colors = [
  Colors.red,
  Colors.orange,
  Colors.green,
  Colors.blue,
  Colors.purple,
  Colors.brown
];
int randomColorIndex = rng.nextInt(6);

DateTime startTime = DateTime.now();
int timePassedSeconds = 0;
int timePassedMinutes = 0;

void main() {
  startTime = DateTime.now();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool done() {
    return turn >= 1 && numCurrentlyUsedIndexes[1] != -1;
  }

  void _refreshSetState() {
    setState(() {
      nums = [firstNum, secondNum, thirdNum, fourthNum];
      numCurrentlyUsedIndexes = [-1, -1];
      isNumUsedIndexes = [false, false, false, false];

      operationUsed = '_';

      expectNum = true;
      turn = 0;

      finalResult = 0;
    });
  }

  void _nextGameSetState() {
    setState(() {
      firstNum = rng.nextInt(9) + 1;
      secondNum = rng.nextInt(9) + 1;
      thirdNum = rng.nextInt(9) + 1;
      fourthNum = rng.nextInt(9) + 1;

      nums = [firstNum, secondNum, thirdNum, fourthNum];
      isNumUsedIndexes = [false, false, false, false];
      numCurrentlyUsedIndexes = [-1, -1];

      operationUsed = '_';

      expectNum = true;
      turn = 0;

      finalResult = 0;

      int prevColorIndex = randomColorIndex;
      int colorIndex = rng.nextInt(6);
      // makes sure next random color is diff than previous one
      while (colorIndex == prevColorIndex) {
        colorIndex = rng.nextInt(6);
      }
      randomColorIndex = colorIndex;

      startTime = DateTime.now();
    });
  }

  void _showResultDialog() {
    // flutter defined function
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          backgroundColor: finalResult == 24 ? Colors.green : Colors.red,
          content: finalResult == 24
              ? Text(
                  'Congrats! You got 24!\nYour time was ' +
                      timePassedMinutes.toString().padLeft(2, "0") +
                      ":" +
                      timePassedSeconds.toString().padLeft(2, "0"),
                  style: TextStyle(color: Colors.white, fontSize: 30),
                  textAlign: TextAlign.center)
              : Text(
                  'Sorry, you did not get 24.\nYou got ' +
                      finalResult.toString() +
                      '.',
                  style: TextStyle(color: Colors.white, fontSize: 30),
                  textAlign: TextAlign.center),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            TextButton(
              child: Text("Continue"),
              onPressed: () {
                if (finalResult == 24) {
                  _nextGameSetState();
                } else {
                  _refreshSetState();
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
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          backgroundColor: Colors.red,
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
          backgroundColor: colors[randomColorIndex],
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.refresh),
              color: Colors.white,
              onPressed: () {
                _refreshSetState();
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
            // DICE BUTTONS
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
                                          primary: Colors.black),
                                      onPressed: isNumUsedIndexes[index] ||
                                              !expectNum ||
                                              nums.length == 1
                                          ? null
                                          : () {
                                              if (!isNumUsedIndexes[index] &&
                                                  expectNum &&
                                                  nums.length != 1) {
                                                setState(() {
                                                  numCurrentlyUsedIndexes[turn] = index;
                                                });
                                                expectNum = false;
                                                isNumUsedIndexes[index] = true;
                                              }
                                            },
                                      child: Text(
                                        nums[index].toString(),
                                        style: const TextStyle(
                                          fontSize: 20,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ))),
                          ]);
                    })),
            // OPERATION BUTTONS
            Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
              ButtonTheme(
                  minWidth: 50.0,
                  height: 50.0,
                  child: OutlinedButton(
                      onPressed: turn > 0 || expectNum
                          ? null
                          : () {
                              if (!expectNum && turn < 1) {
                                setState(() {
                                  operationUsed = '+';
                                });
                                expectNum = true;
                                turn++;
                              }
                            },
                      child: Text('+',
                          style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                              color: turn > 0 || expectNum
                                  ? Colors.grey
                                  : Colors.black)))),
              Padding(padding: EdgeInsets.only(right: 15.0)),
              ButtonTheme(
                  minWidth: 50.0,
                  height: 50.0,
                  child: OutlinedButton(
                      onPressed: turn > 0 || expectNum
                          ? null
                          : () {
                              if (!expectNum && turn < 1) {
                                setState(() {
                                  operationUsed = '-';
                                });
                                expectNum = true;
                                turn++;
                              }
                            },
                      child: Text('-',
                          style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                              color: turn > 0 || expectNum
                                  ? Colors.grey
                                  : Colors.black)))),
              Padding(padding: EdgeInsets.only(right: 15.0)),
              ButtonTheme(
                  minWidth: 50.0,
                  height: 50.0,
                  child: OutlinedButton(
                      onPressed: turn > 0 || expectNum
                          ? null
                          : () {
                              if (!expectNum && turn < 1) {
                                setState(() {
                                  operationUsed = '×';
                                });
                                expectNum = true;
                                turn++;
                              }
                            },
                      child: Text('×',
                          style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                              color: turn > 0 || expectNum
                                  ? Colors.grey
                                  : Colors.black)))),
              Padding(padding: EdgeInsets.only(right: 15.0)),
              ButtonTheme(
                  minWidth: 50.0,
                  height: 50.0,
                  child: OutlinedButton(
                      onPressed: turn > 0 || expectNum
                          ? null
                          : () {
                              if (!expectNum && turn < 1) {
                                setState(() {
                                  operationUsed = '÷';
                                });
                                expectNum = true;
                                turn++;
                              }
                            },
                      child: Text('÷',
                          style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                              color: turn > 0 || expectNum
                                  ? Colors.grey
                                  : Colors.black)))),
              Padding(padding: EdgeInsets.only(right: 15.0)),
              ButtonTheme(
                  minWidth: 50.0,
                  height: 50.0,
                  child: OutlinedButton(
                      onPressed: turn > 0 || expectNum
                          ? null
                          : () {
                              if (!expectNum && turn < 1) {
                                setState(() {
                                  operationUsed = '%';
                                });
                                expectNum = true;
                                turn++;
                              }
                            },
                      child: Text('%',
                          style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                              color: turn > 0 || expectNum
                                  ? Colors.grey
                                  : Colors.black))))
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
                                numCurrentlyUsedIndexes[0] == -1
                                    ? "_"
                                    : nums[numCurrentlyUsedIndexes[0]].toString(),
                                style: TextStyle(fontSize: 26))),
                        Padding(
                            padding: EdgeInsets.only(
                                left: 10.0, right: 10.0, bottom: 30.0),
                            child: Text(operationUsed,
                                style: TextStyle(fontSize: 26))),
                        Padding(
                            padding: EdgeInsets.only(left: 10.0, bottom: 30.0),
                            child: Text(
                                numCurrentlyUsedIndexes[1] == -1
                                    ? "_"
                                    : nums[numCurrentlyUsedIndexes[1]].toString(),
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
                          finalResult =
                              nums[numCurrentlyUsedIndexes[0]] + nums[numCurrentlyUsedIndexes[1]];
                        } else if (operationUsed == '-') {
                          finalResult =
                              nums[numCurrentlyUsedIndexes[0]] - nums[numCurrentlyUsedIndexes[1]];
                        } else if (operationUsed == '×') {
                          finalResult =
                              nums[numCurrentlyUsedIndexes[0]] * nums[numCurrentlyUsedIndexes[1]];
                        } else if (operationUsed == '÷') {
                          if (nums[numCurrentlyUsedIndexes[1]] != 0) {
                            finalResult = (nums[numCurrentlyUsedIndexes[0]] /
                                    nums[numCurrentlyUsedIndexes[1]])
                                .truncate();
                          } else {
                            _showDivisionErrorMsg();
                            divisionError = true;
                          }
                        } else if (operationUsed == '%') {
                          finalResult =
                              nums[numCurrentlyUsedIndexes[0]] % nums[numCurrentlyUsedIndexes[1]];
                        }

                        if (!divisionError) {
                          setState(() {
                            nums[numCurrentlyUsedIndexes[0]] = finalResult;
                            nums[numCurrentlyUsedIndexes[1]] = -1;

                            isNumUsedIndexes = [];
                            for (int i = 0; i < nums.length; i++) {
                              isNumUsedIndexes.add(false);
                            }

                            expectNum = true;
                            turn = 0;
                            numCurrentlyUsedIndexes = [-1, -1];
                            operationUsed = '_';

                            int numDiceLeft = 4;
                            for (int die in nums) {
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
        backgroundColor: colors[randomColorIndex],
        onPressed: () {
          _nextGameSetState();
        },
        tooltip: 'Next Game',
        child: const Icon(Icons.arrow_forward),
      ),
    );
  }
}
