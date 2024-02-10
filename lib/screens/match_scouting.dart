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
  List<TextEditingController> controllers = [];
  List<String> controllerNames = [];
  Map<String, String> radioControllers = {};

  void addRadioController(String name, String initValue) {
    if (!radioControllers.keys.contains(name)) {
      radioControllers[name] = initValue;
    }
  }

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
                                    String placeholderText = "";
                                    if (data.values
                                        .toList()[index][index2]
                                        .keys
                                        .contains("defaultValue")) {
                                      placeholderText =
                                          data.values.toList()[index][index2]
                                              ["defaultValue"];
                                    }
                                    return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                              padding: const EdgeInsets.all(5),
                                              child: Text(
                                                data.values.toList()[index]
                                                    [index2]["name"],
                                                style: const TextStyle(
                                                    fontSize: 18,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              )),
                                          Container(
                                              padding: const EdgeInsets.all(5),
                                              child: TextField(
                                                  decoration: InputDecoration(
                                                      border:
                                                          const OutlineInputBorder(),
                                                      hintText:
                                                          placeholderText),
                                                  controller:
                                                      controllers[controlNum])),
                                          const Padding(
                                              padding: EdgeInsets.all(10))
                                        ]);
                                  } else if (data.values.toList()[index][index2]
                                          ["type"] ==
                                      "radio") {
                                    addRadioController(
                                        data.values.toList()[index][index2]
                                            ["name"],
                                        data.values.toList()[index][index2]
                                            ["choices"][0]);
                                    return ListView.builder(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount: data.values
                                              .toList()[index][index2]
                                                  ["choices"]
                                              .length +
                                          2,
                                      itemBuilder: (content3, index3) {
                                        if (index3 == 0) {
                                          return Padding(
                                              padding: const EdgeInsets.all(5),
                                              child: Text(
                                                  data.values.toList()[index]
                                                      [index2]["name"],
                                                  style: const TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold)));
                                        } else if (index3 > 0 &&
                                            index3 <
                                                data.values
                                                        .toList()[index][index2]
                                                            ["choices"]
                                                        .length +
                                                    1) {
                                          return RadioListTile<String>(
                                            title: Text(data.values
                                                    .toList()[index][index2]
                                                ["choices"][index3 - 1]),
                                            value: data.values.toList()[index]
                                                [index2]["choices"][index3 - 1],
                                            groupValue: radioControllers[
                                                data.values.toList()[index]
                                                    [index2]["name"]],
                                            onChanged: (String? value) {
                                              setState(() {
                                                if (value != null) {
                                                  radioControllers[data.values
                                                          .toList()[index]
                                                      [index2]["name"]] = value;
                                                }
                                              });
                                            },
                                          );
                                        } else {
                                          return const Padding(
                                            padding: EdgeInsets.all(10),
                                          );
                                        }
                                      },
                                    );
                                  }
                                }),
                          )
                        ])));
  }
}
