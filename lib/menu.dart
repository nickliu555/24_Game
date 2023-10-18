import 'package:flutter/material.dart';
import 'package:projects/rules.dart';
import 'game.dart';
import 'difficulty.dart';

enum difficultyLevel { Easy, Medium, Hard, Mixed }

difficultyLevel? currDifficultyLevel = difficultyLevel.Mixed;

class MenuPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Menu Page',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyMenuPage(),
    );
  }
}

class MyMenuPage extends StatefulWidget {
  MyMenuPage({Key? key}) : super(key: key);

  @override
  _MyMenuPageState createState() => _MyMenuPageState();
}

class _MyMenuPageState extends State<MyMenuPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Center(
              child: const Text("Menu Page",
                  style: TextStyle(
                    color: Colors.white,
                  )))),
      body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ButtonTheme(
                minWidth: 1000.0,
                height: 50.0,
                child: Center(
                  child: ElevatedButton(
                    child: const Text('Play'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => GamePage()),
                      );
                    },
                  ),
                )),
            ButtonTheme(
                minWidth: 1000.0,
                height: 50.0,
                child: Center(
                  child: ElevatedButton(
                    child: const Text('How to Play'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => RulesPage()),
                      );
                    },
                  ),
                )),
            ButtonTheme(
                minWidth: 1000.0,
                height: 50.0,
                child: Center(
                  child: ElevatedButton(
                    child: const Text('Difficulty'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => DifficultyPage()),
                      );
                    },
                  ),
                )),
            ButtonTheme(
                minWidth: 1000.0,
                height: 50.0,
                child: Center(
                  child: ElevatedButton(
                    child: const Text('Settings'),
                    onPressed: () {},
                  ),
                ))
          ]),
    );
  }
}