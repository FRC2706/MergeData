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
  Map<String, TextEditingController> controllers = {};
  Map<String, String> radioControllers = {};
  Map<String, bool> boolValues = {};
  Map<String, int> counterValues = {};

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
    controllers[name] = newController;
    return controllerCount;
  }

  void addBoolValue(String name) {
    if (!boolValues.keys.contains(name)) {
      boolValues[name] = false;
    }
  }

  void addCounter(String name) {
    if (!counterValues.keys.contains(name)) {
      counterValues[name] = 0;
    }
  }

  void decrementCounter(String name) {
    if ((counterValues[name] ?? 0) > 0) {
      counterValues[name] = counterValues[name]! - 1;
    }
  }

  void incrementCounter(String name) {
    if ((counterValues[name] ?? 10000) < 10000) {
      counterValues[name] = counterValues[name]! + 1;
    }
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
                                  } else if (data.values.toList()[index][index2]
                                          ["type"] ==
                                      "number") {
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
                                                    hintText: placeholderText),
                                                controller: controllers[
                                                    data.values.toList()[index]
                                                        [index2]["name"]],
                                                keyboardType:
                                                    TextInputType.number,
                                                inputFormatters: [
                                                  FilteringTextInputFormatter
                                                      .digitsOnly
                                                ],
                                              )),
                                          const Padding(
                                              padding: EdgeInsets.all(10))
                                        ]);
                                  } else if (data.values.toList()[index][index2]
                                          ["type"] ==
                                      "bool") {
                                    addBoolValue(data.values.toList()[index]
                                        [index2]["name"]);
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Container(
                                            padding: const EdgeInsets.all(5),
                                            child: Text(
                                              data.values.toList()[index]
                                                  [index2]["name"],
                                              style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold),
                                            )),
                                        Row(children: <Widget>[
                                          Checkbox(
                                            value: boolValues[
                                                data.values.toList()[index]
                                                    [index2]["name"]],
                                            onChanged: (bool? value) {
                                              setState(() {
                                                if (value != null) {
                                                  boolValues[data.values
                                                          .toList()[index]
                                                      [index2]["name"]] = value;
                                                }
                                              });
                                            },
                                          ),
                                          const Padding(
                                              padding: EdgeInsets.all(5)),
                                          Text(
                                            boolValues[data.values
                                                            .toList()[index]
                                                        [index2]["name"]] ??
                                                    false
                                                ? "Yes"
                                                : "No",
                                            style: const TextStyle(
                                              fontSize: 18,
                                            ),
                                          )
                                        ]),
                                        const Padding(
                                            padding: EdgeInsets.all(10))
                                      ],
                                    );
                                  } else if (data.values.toList()[index][index2]
                                          ["type"] ==
                                      "counter") {
                                    addCounter(data.values.toList()[index]
                                        [index2]["name"]);
                                    return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
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
                                          Row(
                                            children: <Widget>[
                                              ElevatedButton(
                                                onPressed: () {
                                                  setState(() {
                                                    decrementCounter(data.values
                                                            .toList()[index]
                                                        [index2]["name"]);
                                                  });
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  shape: CircleBorder(),
                                                ),
                                                child: const Text("-",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 18)),
                                              ),
                                              const Padding(
                                                  padding: EdgeInsets.all(5)),
                                              Text(
                                                  counterValues[data.values
                                                              .toList()[index]
                                                          [index2]["name"]]
                                                      .toString(),
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 18)),
                                              const Padding(
                                                  padding: EdgeInsets.all(5)),
                                              ElevatedButton(
                                                onPressed: () {
                                                  setState(() {
                                                    incrementCounter(data.values
                                                            .toList()[index]
                                                        [index2]["name"]);
                                                  });
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  shape: CircleBorder(),
                                                ),
                                                child: const Text("+",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 18)),
                                              ),
                                            ],
                                          ),
                                          const Padding(
                                              padding: EdgeInsets.all(10))
                                        ]);
                                  }
                                }),
                          )
                        ])));
  }
}
