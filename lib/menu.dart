import 'package:flutter/material.dart';
import 'package:projects/rules.dart';
import 'difficulty.dart';

enum gameType { Classic, Timed }

gameType? currGameType = gameType.Classic;

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
          backgroundColor: Colors.indigoAccent,
          title: const Center(
              child: const Text("Menu",
                  style: TextStyle(
                    color: Colors.white,
                  )))),
      body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image(
                image: NetworkImage(
                    'https://www.24game.com/skins/24game/images/24game-logo.png')),
            Padding(padding: EdgeInsets.only(bottom: 30.0)),
            ButtonTheme(
                minWidth: 50.0,
                height: 50.0,
                child: Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        minimumSize: Size(150, 40),
                        primary: Colors.indigoAccent),
                    child: const Text('▶️ Play Classic'),
                    onPressed: () {
                      currGameType = gameType.Classic;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => DifficultyPage()),
                      );
                    },
                  ),
                )),
            ButtonTheme(
                minWidth: 50.0,
                height: 50.0,
                child: Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        minimumSize: Size(150, 40),
                        primary: Colors.indigoAccent),
                    child: const Text('🕗 Play Timed'),
                    onPressed: () {
                      currGameType = gameType.Timed;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => DifficultyPage()),
                      );
                    },
                  ),
                )),
            ButtonTheme(
                minWidth: 50.0,
                height: 50.0,
                child: Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        minimumSize: Size(150, 40),
                        primary: Colors.indigoAccent),
                    child: const Text('❔ How to Play'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => RulesPage()),
                      );
                    },
                  ),
                )),
            ButtonTheme(
                minWidth: 50.0,
                height: 50.0,
                child: Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        minimumSize: Size(150, 40),
                        primary: Colors.indigoAccent),
                    child: const Text('⚙️ Settings'),
                    onPressed: () {},
                  ),
                ))
          ]),
    );
  }
}
