import 'package:flutter/material.dart';
import 'dart:math';

var rng = new Random();

int firstDice = rng.nextInt(9) + 1;
int secondDice = rng.nextInt(9) + 1;
int thirdDice = rng.nextInt(9) + 1;
int fourthDice = rng.nextInt(9) + 1;

List<int> dices = [firstDice, secondDice, thirdDice, fourthDice];

List<bool> usedDices = [false, false, false, false];
List<int> diceUsedIndex = [-1, -1];
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
  Colors.black,
];
int randomColorIndex = rng.nextInt(6);

DateTime start = DateTime.now();
int timePassed = 0;

void main() {
  start = DateTime.now();
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
    return turn >= 1 && diceUsedIndex[1] != -1;
  }

  void _showResultDialog() {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          backgroundColor: finalResult == 24 ? Colors.green : Colors.red,
          content: finalResult == 24
              ? Text(
                  'Congrats! You got 24!\nYour time was ' +
                      timePassed.toString() +
                      's',
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
                  setState(() {
                    firstDice = rng.nextInt(9) + 1;
                    secondDice = rng.nextInt(9) + 1;
                    thirdDice = rng.nextInt(9) + 1;
                    fourthDice = rng.nextInt(9) + 1;

                    dices = [firstDice, secondDice, thirdDice, fourthDice];
                    usedDices = [false, false, false, false];
                    diceUsedIndex = [-1, -1];

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

                    start = DateTime.now();
                  });
                } else {
                  setState(() {
                    dices = [firstDice, secondDice, thirdDice, fourthDice];
                    diceUsedIndex = [-1, -1];
                    usedDices = [false, false, false, false];

                    operationUsed = '_';

                    expectNum = true;
                    turn = 0;

                    finalResult = 0;
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
                setState(() {
                  dices = [firstDice, secondDice, thirdDice, fourthDice];
                  diceUsedIndex = [-1, -1];
                  usedDices = [false, false, false, false];

                  operationUsed = '_';

                  expectNum = true;
                  turn = 0;

                  finalResult = 0;
                });
              },
              tooltip: "Restart",
            )
          ],
          title: Center(
              child: const Text("Welcome to 24",
                  style: TextStyle(
                    color: Colors.white,
                  )))),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Dice buttons
            Container(
                height: 150,
                child: GridView.builder(
                    itemCount: dices.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: dices.length,
                    ),
                    itemBuilder: (BuildContext context, int index) {
                      return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            ButtonTheme(
                              minWidth: 50.0,
                              height: 50.0,
                              child: Visibility(
                                  visible: dices[index]==-1 ? false : true,
                                  child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    primary: Colors.black),
                                onPressed: usedDices[index] ||
                                        !expectNum ||
                                        dices.length == 1
                                    ? null
                                    : () {
                                        if (!usedDices[index] &&
                                            expectNum &&
                                            dices.length != 1) {
                                          setState(() {
                                            diceUsedIndex[turn] = index;
                                          });
                                          expectNum = false;
                                          usedDices[index] = true;
                                        }
                                      },
                                child: Text(
                                  dices[index].toString(),
                                  style: const TextStyle(
                                    fontSize: 20,
                                    color: Colors.white,
                                  ),
                                ),
                              ))
                            ),
                          ]);
                    })),
            //Operation buttons
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
              const Text("    "),
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
              const Text("    "),
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
              const Text("    "),
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
              const Text("    "),
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
                                  : Colors.black)))),
            ]),
            const Text(
              '\n\n',
            ),
            //Result text
            dices.length == 1
                ? Text(' ')
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                        Text(
                            diceUsedIndex[0] == -1
                                ? "_  "
                                : dices[diceUsedIndex[0]].toString() + "  ",
                            style: TextStyle(fontSize: 26)),
                        Text(operationUsed + "  ",
                            style: TextStyle(fontSize: 26)),
                        Text(
                            diceUsedIndex[1] == -1
                                ? "_"
                                : dices[diceUsedIndex[1]].toString(),
                            style: TextStyle(fontSize: 26))
                      ]),
            const Text(""),
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
                              dices[diceUsedIndex[0]] + dices[diceUsedIndex[1]];
                        } else if (operationUsed == '-') {
                          finalResult =
                              dices[diceUsedIndex[0]] - dices[diceUsedIndex[1]];
                        } else if (operationUsed == '×') {
                          finalResult =
                              dices[diceUsedIndex[0]] * dices[diceUsedIndex[1]];
                        } else if (operationUsed == '÷') {
                          if (dices[diceUsedIndex[1]] != 0) {
                            finalResult = (dices[diceUsedIndex[0]] /
                                    dices[diceUsedIndex[1]])
                                .toInt();
                          } else {
                            _showDivisionErrorMsg();
                            divisionError = true;
                          }
                        } else if (operationUsed == '%') {
                          finalResult =
                              dices[diceUsedIndex[0]] % dices[diceUsedIndex[1]];
                        }

                        if (!divisionError) {
                          setState(() {
                            dices[diceUsedIndex[0]] = finalResult;
                            dices[diceUsedIndex[1]] = -1;

                            usedDices = [];
                            for (int i = 0; i < dices.length; i++) {
                              usedDices.add(false);
                            }

                            expectNum = true;
                            turn = 0;
                            diceUsedIndex = [-1, -1];
                            operationUsed = '_';

                            int numDiceLeft = 4;
                            for (int die in dices) {
                              if (die == -1) {
                                --numDiceLeft;
                              }
                            }
                            if (numDiceLeft <= 1) {
                              if (finalResult == 24) {
                                DateTime end = DateTime.now();
                                timePassed = end.difference(start).inSeconds;
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
          setState(() {
            firstDice = rng.nextInt(9) + 1;
            secondDice = rng.nextInt(9) + 1;
            thirdDice = rng.nextInt(9) + 1;
            fourthDice = rng.nextInt(9) + 1;

            dices = [firstDice, secondDice, thirdDice, fourthDice];
            usedDices = [false, false, false, false];
            diceUsedIndex = [-1, -1];

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

            start = DateTime.now();
          });
        },
        tooltip: 'Next Game',
        child: const Icon(Icons.arrow_forward),
      ),
    );
  }
}
