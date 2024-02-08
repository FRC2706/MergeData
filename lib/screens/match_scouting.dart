import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:merge_data/widgets/text_widget.dart';

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
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: data.values.toList()[index].length,
                                itemBuilder: (context2, index2) => Container(
                                    padding: const EdgeInsets.all(5),
                                    child: textWidget(
                                        "ahh", TextEditingController()))),
                          )
                        ])));
  }
}
