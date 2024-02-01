import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

class MatchScoutingPage extends StatefulWidget {
  const MatchScoutingPage({super.key, required this.title, required this.year});

  final String title;
  final int year;

  @override
  State<MatchScoutingPage> createState() => _MatchScoutingState();
}

class _MatchScoutingState extends State<MatchScoutingPage> {
  Map data = {};

  Future<void> readJson() async {
    final String response =
        await rootBundle.loadString("assets/games/${widget.year}.json");
    final decodedData = await json.decode(response);
    setState(() {
      data = decodedData;
    });
  }

  @override
  Widget build(BuildContext context) {
    readJson();
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title:
              Text(widget.title, style: const TextStyle(color: Colors.black)),
        ),
        body: data.isEmpty
            ? const Text("Shep did not find anything")
            : ListView.builder(
                itemCount: data.length,
                itemBuilder: (context, index) => ExpansionTile(
                        title: Text(
                          data.keys.toList()[index].toString(),
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        children: <Widget>[
                          const Text('ahh'),
                          const Padding(
                            padding: EdgeInsets.all(10),
                          )
                        ])));
  }
}
