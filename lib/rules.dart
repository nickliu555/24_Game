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
            child: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                margin: const EdgeInsets.only(top: 150.0, bottom: 150.0),
                padding: const EdgeInsets.all(3.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.indigo.shade100,
                  border: Border.all(
                    color: Colors.indigo.shade100,
                    width: 2,
                  ),
                ),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Text(
                        "Object of the game:",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.indigoAccent,
                            fontSize: 24.0,
                            fontFamily: "Caveat",
                            fontWeight: FontWeight.bold),
                      ),
                      const Text(
                        "Make the number 24 from the four numbers shown. You can add (+), subtract (-), multiply (×) and divide (÷). You must use all four numbers exactly once. However you do not have to use all four operations.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.indigoAccent,
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
                                decoration: TextDecoration.underline,
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
