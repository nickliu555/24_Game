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
            backgroundColor: Colors.indigoAccent,
            centerTitle: true,
            title: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text("How to Play",
                    style: TextStyle(
                      color: Colors.white,
                    ))
              ],
            )),
        body: Center(
            child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Text(
                        "Object of the game: Make the number 24 from the four numbers shown. You can add (+), subtract (-), multiply (×) and divide (÷). You must use all four numbers exactly once. However you do not have to use all four operations.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 20.0,
                            fontFamily: "Caveat",
                            fontWeight: FontWeight.w400),
                      ),
                      const Padding(padding: EdgeInsets.only(bottom: 50.0)),
                      InkWell(
                          child: const Text(
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
                          onTap: () => launchUrl(Uri.parse(
                              'https://www.youtube.com/watch?v=LR6O3QdUWtk')))
                    ]))));
  }
}
