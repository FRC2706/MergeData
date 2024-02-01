import 'package:flutter/material.dart';

class PitScoutingPage extends StatefulWidget {
  const PitScoutingPage({super.key, required this.title, required this.year});

  final String title;
  final int year;

  @override
  State<PitScoutingPage> createState() => _PitScoutingState();
}

class _PitScoutingState extends State<PitScoutingPage> {
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
        ));
  }
}
