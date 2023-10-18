import 'package:flutter/material.dart';

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
              child: const Text("Difficulty Level",
                  style: TextStyle(
                    color: Colors.white,
                  )))),
      body: Center(
        child: Column(
          children: <Widget>[
            Container(
                width: 200.0,
                child: ListTile(
                  title: const Text('Easy'),
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
        Container(
          width: 200.0,
          child: ListTile(
              title: const Text('Medium'),
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
        Container(
          width: 200.0,
          child: ListTile(
              title: const Text('Hard'),
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
        Container(
          width: 200.0,
          child: ListTile(
              title: const Text('Mixed'),
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
          Navigator.pop(context);
        },
        tooltip: 'Submit',
        child: const Icon(Icons.arrow_forward),
      ),
    );
  }
}
