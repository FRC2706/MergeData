import 'package:flutter/material.dart';

class MatchScoutingPage extends StatefulWidget {
  const MatchScoutingPage({super.key, required this.title});

  final String title;

  @override
  State<MatchScoutingPage> createState() => _MatchScoutingState();
}

class _MatchScoutingState extends State<MatchScoutingPage> {
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
            children: <Widget>[const Text("Shep is cool")],
          ),
        ) // This trailing comma makes auto-formatting nicer for build methods.
        );
  }
}
