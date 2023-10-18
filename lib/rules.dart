import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class RulesPage extends StatefulWidget {
  RulesPage({Key? key}) : super(key: key);

  @override
  _MyRulesPageState createState() => _MyRulesPageState();
}

class _MyRulesPageState extends State<RulesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: const Center(
                child: const Text("How to Play",
                    style: TextStyle(
                      color: Colors.white,
                    )))),
        body: Center(
            child: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        "Object of the game: Make the number 24 from the four numbers shown. You can add, subtract, multiply and divide. Use all four numbers on the card, but use each number only once. You do not have to use all four operations.",
                        style: TextStyle(
                            fontSize: 25,
                            color: Colors.black,
                            fontWeight: FontWeight.w700,
                            shadows: [
                              Shadow(
                                  color: Colors.brown,
                                  offset: Offset(2, 1),
                                  blurRadius: 10)
                            ]),
                      ),
                      Padding(padding: EdgeInsets.only(bottom: 50.0)),
                      InkWell(
                          child: Text(
                            "Video",
                            style: TextStyle(
                                fontSize: 25,
                                color: Colors.blue,
                                shadows: [
                                  Shadow(
                                      color: Colors.brown,
                                      offset: Offset(2, 1),
                                      blurRadius: 10)
                                ]),
                          ),
                          onTap: () =>
                              launchUrl(Uri.parse('https://www.youtube.com/')))
                    ]))));
  }
}
