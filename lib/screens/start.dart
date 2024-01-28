import 'package:flutter/material.dart';
import 'package:merge_data/screens/pit_scouting.dart';
import 'package:merge_data/screens/match_scouting.dart';

class StartPage extends StatefulWidget {
  const StartPage({super.key, required this.title});

  final String title;

  @override
  State<StartPage> createState() => _StartState();
}

class _StartState extends State<StartPage> {
  void pitScouting() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PitScoutingPage(title: "Pit Scouting"),
      ),
    );
  }

  void matchScouting() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MatchScoutingPage(title: "Match Scouting"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title:
              Text(widget.title, style: const TextStyle(color: Colors.black)),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
                  onPressed: pitScouting,
                  child: const Text("Pit Scouting",
                      style: TextStyle(fontSize: 28))),
              const Padding(padding: EdgeInsets.all(10)),
              ElevatedButton(
                  onPressed: matchScouting,
                  child: const Text("Match Scouting",
                      style: TextStyle(fontSize: 28))),
            ],
          ),
        ) // This trailing comma makes auto-formatting nicer for build methods.
        );
  }
}
