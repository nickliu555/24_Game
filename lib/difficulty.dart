import 'package:flutter/material.dart';
import 'package:projects/timed_game.dart';

import 'classic_game.dart';
import 'menu.dart';

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
          backgroundColor: Colors.indigoAccent,
          centerTitle: true,
          title: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text("Select Difficulty Level",
                  style: TextStyle(
                    color: Colors.white,
                  ))
            ],
          )),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(
                width: 200.0,
                child: RadioListTile<difficultyLevel>(
                  title: Text(
                    'Easy',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: currDifficultyLevel == difficultyLevel.Easy
                            ? FontWeight.bold
                            : FontWeight.normal),
                  ),
                  value: difficultyLevel.Easy,
                  groupValue: currDifficultyLevel,
                  activeColor: Colors.white,
                  tileColor: Colors.green,
                  onChanged: (difficultyLevel? value) {
                    setState(() {
                      currDifficultyLevel = value;
                    });
                  },
                )),
            const Padding(padding: EdgeInsets.only(bottom: 10.0)),
            SizedBox(
                width: 200.0,
                child: RadioListTile<difficultyLevel>(
                  title: Text(
                    'Medium',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight:
                            currDifficultyLevel == difficultyLevel.Medium
                                ? FontWeight.bold
                                : FontWeight.normal),
                  ),
                  value: difficultyLevel.Medium,
                  groupValue: currDifficultyLevel,
                  activeColor: Colors.white,
                  tileColor: Colors.orange,
                  onChanged: (difficultyLevel? value) {
                    setState(() {
                      currDifficultyLevel = value;
                    });
                  },
                )),
            const Padding(padding: EdgeInsets.only(bottom: 10.0)),
            SizedBox(
                width: 200.0,
                child: RadioListTile<difficultyLevel>(
                  title: Text(
                    'Hard',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: currDifficultyLevel == difficultyLevel.Hard
                            ? FontWeight.bold
                            : FontWeight.normal),
                  ),
                  value: difficultyLevel.Hard,
                  groupValue: currDifficultyLevel,
                  activeColor: Colors.white,
                  tileColor: Colors.red,
                  onChanged: (difficultyLevel? value) {
                    setState(() {
                      currDifficultyLevel = value;
                    });
                  },
                )),
            const Padding(padding: EdgeInsets.only(bottom: 10.0)),
            SizedBox(
                width: 200.0,
                child: RadioListTile<difficultyLevel>(
                  title: Text(
                    'Mixed',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: currDifficultyLevel == difficultyLevel.Mixed
                            ? FontWeight.bold
                            : FontWeight.normal),
                  ),
                  value: difficultyLevel.Mixed,
                  groupValue: currDifficultyLevel,
                  activeColor: Colors.white,
                  tileColor: Colors.purple,
                  onChanged: (difficultyLevel? value) {
                    setState(() {
                      currDifficultyLevel = value;
                    });
                  },
                )),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.indigoAccent,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => currGameType == gameType.Classic
                    ? ClassicGamePage()
                    : TimedGamePage()),
          );
        },
        tooltip: 'Submit',
        child: const Icon(Icons.arrow_forward),
      ),
    );
  }
}
