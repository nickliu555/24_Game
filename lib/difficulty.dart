import 'package:flutter/material.dart';

import 'game.dart';

enum difficultyLevel { Easy, Medium, Hard, Mixed }

difficultyLevel? currDifficultyLevel = difficultyLevel.Mixed;

getDifficulty() {
  return currDifficultyLevel;
}

class DifficultyPage extends StatefulWidget {
  DifficultyPage({Key? key}) : super(key: key);

  @override
  _MyDifficultyPageState createState() => _MyDifficultyPageState();
}

class _MyDifficultyPageState extends State<DifficultyPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Center(
              child: const Text("Select Difficulty Level",
                  style: TextStyle(
                    color: Colors.white,
                  )))),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
                width: 200.0,
                child: ListTile(
                  title: const Text('Easy'),
                  textColor: Colors.white,
                  tileColor: Colors.green,
                  leading: Radio<difficultyLevel>(
                    value: difficultyLevel.Easy,
                    groupValue: currDifficultyLevel,
                    onChanged: (difficultyLevel? value) {
                      setState(() {
                        currDifficultyLevel = value;
                      });
                    },
                  ),
                )),
            Padding(padding: EdgeInsets.only(bottom: 10.0)),
            Container(
                width: 200.0,
                child: ListTile(
                  title: const Text('Medium'),
                  textColor: Colors.white,
                  tileColor: Colors.orange,
                  leading: Radio<difficultyLevel>(
                    value: difficultyLevel.Medium,
                    groupValue: currDifficultyLevel,
                    onChanged: (difficultyLevel? value) {
                      setState(() {
                        currDifficultyLevel = value;
                      });
                    },
                  ),
                )),
            Padding(padding: EdgeInsets.only(bottom: 10.0)),
            Container(
                width: 200.0,
                child: ListTile(
                  title: const Text('Hard'),
                  textColor: Colors.white,
                  tileColor: Colors.red,
                  leading: Radio<difficultyLevel>(
                    value: difficultyLevel.Hard,
                    groupValue: currDifficultyLevel,
                    onChanged: (difficultyLevel? value) {
                      setState(() {
                        currDifficultyLevel = value;
                      });
                    },
                  ),
                )),
            Padding(padding: EdgeInsets.only(bottom: 10.0)),
            Container(
                width: 200.0,
                child: ListTile(
                  title: const Text('Mixed'),
                  textColor: Colors.white,
                  tileColor: Colors.purple,
                  leading: Radio<difficultyLevel>(
                    value: difficultyLevel.Mixed,
                    groupValue: currDifficultyLevel,
                    onChanged: (difficultyLevel? value) {
                      setState(() {
                        currDifficultyLevel = value;
                      });
                    },
                  ),
                )),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => GamePage()),
          );
        },
        tooltip: 'Submit',
        child: const Icon(Icons.arrow_forward),
      ),
    );
  }
}
