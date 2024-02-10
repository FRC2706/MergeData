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
  List<TextEditingController> controllers = [];
  List<String> controllerNames = [];

  Future<void> readJson() async {
    final String response =
        await rootBundle.loadString("assets/games/${widget.year}.json");
    final decodedData = await json.decode(response);
    setState(() {
      data = decodedData;
    });
  }

  int addController(String name) {
    TextEditingController newController = TextEditingController();
    int controllerCount = controllers.length;
    controllers.add(newController);
    controllerNames.add(name);
    return controllerCount;
  }

  @override
  void initState() {
    super.initState();
    readJson();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title:
              Text(widget.title, style: const TextStyle(color: Colors.black)),
        ),
        body: data.isEmpty
            ? Center(
                child: Column(
                children: <Widget>[
                  Image.asset("assets/images/shep-loading.gif"),
                  const Padding(
                    padding: EdgeInsets.all(5),
                  ),
                  const Text(
                      "Shep didn't find anything so he started dancing...",
                      style: TextStyle(fontSize: 18))
                ],
              ))
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
                                itemBuilder: (context2, index2) {
                                  if (data.values.toList()[index][index2]
                                          ["type"] ==
                                      "text") {
                                    int controlNum = addController(data.values
                                        .toList()[index][index2]["name"]);
                                    return Container(
                                        padding: const EdgeInsets.all(5),
                                        child: textWidget(
                                            data.values.toList()[index][index2]
                                                ["name"],
                                            controllers[controlNum]));
                                  }
                                }),
                          )
                        ])));
  }
}
