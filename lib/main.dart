import 'package:flutter/material.dart';
import 'dart:math';

var rng = new Random();

int firstDice = rng.nextInt(9) + 1;
int secondDice = rng.nextInt(9) + 1;
int thirdDice = rng.nextInt(9) + 1;
int fourthDice = rng.nextInt(9) + 1;

List<int> dices = [firstDice, secondDice, thirdDice, fourthDice];

List<bool> usedDices = [false, false, false, false];
List<String> numUsed = ['_', '_'];
List<int> numUsedIndex = [-1, -1];
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
    return turn >= 1 && numUsedIndex[1] != -1;
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
            new TextButton(
              child: new Text("Continue"),
              onPressed: () {
                if (finalResult == 24) {
                  setState(() {
                    firstDice = rng.nextInt(9) + 1;
                    secondDice = rng.nextInt(9) + 1;
                    thirdDice = rng.nextInt(9) + 1;
                    fourthDice = rng.nextInt(9) + 1;

                    dices = [firstDice, secondDice, thirdDice, fourthDice];
                    usedDices = [false, false, false, false];
                    numUsed = ['_', '_'];
                    numUsedIndex = [-1, -1];

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
                    numUsed = ['_', '_'];
                    numUsedIndex = [-1, -1];
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
          content: Text('Sorry you cannot divide by zero',
              style: TextStyle(color: Colors.white, fontSize: 30),
              textAlign: TextAlign.center),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new TextButton(
                child: new Text("Continue"),
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
                numUsed = ['_', '_'];
                numUsedIndex = [-1, -1];
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
            child: Text(
              "Welcome to 24",
              style: TextStyle(
                color: Colors.white,
              ),
            )),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Dice buttons
            Container(
                height: 150,
                child: GridView.builder(
                    itemCount: dices.length,
                    gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: dices.length,
                    ),
                    itemBuilder: (BuildContext context, int index) {
                      return new Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            ButtonTheme(
                              minWidth: 50.0,
                              height: 50.0,
                              child: ElevatedButton(
                                child: Text(
                                  dices[index].toString(),
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.white,
                                  ),
                                ),
                                // color: usedDices[index] ||
                                //         !expectNum ||
                                //         dices.length == 1
                                //     ? Colors.grey
                                //     : Colors.black,
                                onPressed: () {
                                  if (!usedDices[index] &&
                                      expectNum &&
                                      dices.length != 1) {
                                    setState(() {
                                      numUsed[turn] = dices[index].toString();
                                      numUsedIndex[turn] = index;
                                    });
                                    expectNum = false;
                                    usedDices[index] = true;
                                  }
                                },
                              ),
                            ),
                          ]);
                    })),
            //Operation buttons
            Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
              ButtonTheme(
                  minWidth: 50.0,
                  height: 50.0,
                  child: TextButton(
                    child: Text('+',
                        style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: turn > 0 || expectNum
                                ? Colors.grey
                                : Colors.black)),
                    onPressed: () {
                      if (!expectNum && turn < 1) {
                        setState(() {
                          operationUsed = '+';
                        });
                        expectNum = true;
                        turn++;
                      }
                    },
                  )),
              Text("    "),
              ButtonTheme(
                  minWidth: 50.0,
                  height: 50.0,
                  child: TextButton(
                    child: Text('-',
                        style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: turn > 0 || expectNum
                                ? Colors.grey
                                : Colors.black)),
                    onPressed: () {
                      if (!expectNum && turn < 1) {
                        setState(() {
                          operationUsed = '-';
                        });
                        expectNum = true;
                        turn++;
                      }
                    },
                  )),
              Text("    "),
              ButtonTheme(
                  minWidth: 50.0,
                  height: 50.0,
                  child: TextButton(
                    child: Text('*',
                        style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: turn > 0 || expectNum
                                ? Colors.grey
                                : Colors.black)),
                    onPressed: () {
                      if (!expectNum && turn < 1) {
                        setState(() {
                          operationUsed = '*';
                        });
                        expectNum = true;
                        turn++;
                      }
                    },
                  )),
              Text("    "),
              ButtonTheme(
                  minWidth: 50.0,
                  height: 50.0,
                  child: TextButton(
                    child: Text('/',
                        style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: turn > 0 || expectNum
                                ? Colors.grey
                                : Colors.black)),
                    onPressed: () {
                      if (!expectNum && turn < 1) {
                        setState(() {
                          operationUsed = '/';
                        });
                        expectNum = true;
                        turn++;
                      }
                    },
                  )),
              Text("    "),
              ButtonTheme(
                  minWidth: 50.0,
                  height: 50.0,
                  child: TextButton(
                    child: Text('%',
                        style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: turn > 0 || expectNum
                                ? Colors.grey
                                : Colors.black)),
                    onPressed: () {
                      if (!expectNum && turn < 1) {
                        setState(() {
                          operationUsed = '%';
                        });
                        expectNum = true;
                        turn++;
                      }
                    },
                  )),
            ]),
            Text(
              '\n\n',
            ),
            //Result text
            dices.length == 1
                ? Text(' ')
                : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(numUsed[0] + ' ', style: TextStyle(fontSize: 26)),
                  Text(operationUsed + ' ',
                      style: TextStyle(fontSize: 26)),
                  Text(numUsed[1], style: TextStyle(fontSize: 26))
                ]),
            Text(""),
            ButtonTheme(
              minWidth: 48.0,
              height: 36.0,
              child: ElevatedButton(
                child: Text(
                  'Submit',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
                // color: done() ? Colors.green : Colors.grey,
                onPressed: () {
                  bool divisionError = false;
                  if (done()) {
                    if (operationUsed == '+') {
                      finalResult =
                          int.parse(numUsed[0]) + int.parse(numUsed[1]);
                    } else if (operationUsed == '-') {
                      finalResult =
                          int.parse(numUsed[0]) - int.parse(numUsed[1]);
                    } else if (operationUsed == '*') {
                      finalResult =
                          int.parse(numUsed[0]) * int.parse(numUsed[1]);
                    } else if (operationUsed == '/') {
                      if (int.parse(numUsed[1]) != 0) {
                        finalResult =
                            ((int.parse(numUsed[0]) / int.parse(numUsed[1])) -
                                0.5)
                                .round();
                      } else {
                        _showDivisionErrorMsg();
                        divisionError = true;
                      }
                    }

                    if (!divisionError) {
                      setState(() {
                        List<int> tmp = [];
                        tmp.add(finalResult);
                        for (int i = 0; i < dices.length; i++) {
                          if (i != numUsedIndex[0] && i != numUsedIndex[1])
                            tmp.add(dices[i]);
                        }
                        dices = tmp;

                        usedDices = [];
                        for (int i = 0; i < dices.length; i++) {
                          usedDices.add(false);
                        }

                        expectNum = true;
                        turn = 0;
                        numUsed = ['_', '_'];
                        numUsedIndex = [-1, -1];
                        operationUsed = '_';

                        if (dices.length == 1) {
                          if (finalResult == 24) {
                            DateTime end = DateTime.now();
                            timePassed = end.difference(start).inSeconds;
                          }
//                        Navigator.push(
//                            context,
//                            MaterialPageRoute(
//                                builder: (context) => ViewResult()));

                          _showResultDialog();
                        }
                      });
                    }
                  }
                },
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
            numUsed = ['_', '_'];
            numUsedIndex = [-1, -1];

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
        child: Icon(Icons.arrow_forward),
      ),
    );
  }
}