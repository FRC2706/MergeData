import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'dart:async';
import 'send_data.dart';

class MatchScoutingPage extends StatefulWidget {
  const MatchScoutingPage({super.key, required this.title, required this.year});

  final String title;
  final int year;

  @override
  State<MatchScoutingPage> createState() => _MatchScoutingState();
}

class _MatchScoutingState extends State<MatchScoutingPage> {
  Map data = {};
  Map<String, String> textValues = {};
  Map<String, String> radioControllers = {};
  Map<String, bool> boolValues = {};
  Map<String, int> counterValues = {};
  Map<String, bool> fieldErrors = {};
  Map<String, List<Map>> counterTimestamps = {};
  Timer? _timer;
  int _start = 150;

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

  /*
  void addController(String name) {
    if (!textValues.keys.contains(name)) {
      textValues[name] = "";
    }
  }
  */

  void addBoolValue(String name) {
    if (!boolValues.keys.contains(name)) {
      boolValues[name] = false;
    }
  }

  void addCounter(String name) {
    if (!counterValues.keys.contains(name)) {
      counterValues[name] = 0;
    }
    if (!counterTimestamps.keys.contains(name)) {
      counterTimestamps[name] = [];
    }
  }

  void decrementCounter(String name) {
    if ((counterValues[name] ?? 0) > 0) {
      counterValues[name] = counterValues[name]! - 1;
      if (_timer != null) {
        counterTimestamps[name]!.add({
          "action": "decrement",
          "newValue": counterValues[name],
          "timeStamp": _start
        });
      }
    }
  }

  void incrementCounter(String name) {
    if ((counterValues[name] ?? 10000) < 10000) {
      counterValues[name] = counterValues[name]! + 1;
      if (_timer != null) {
        counterTimestamps[name]!.add({
          "action": "increment",
          "newValue": counterValues[name],
          "timeStamp": _start
        });
      }
    }
  }

  void startTimer() {
    if (_timer != null) {
      _timer!.cancel();
    }
    _timer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
      if (_start == 0) {
        setState(() {
          timer.cancel();
          if (_timer != null) {
            _timer!.cancel();
            _timer = null;
          }
        });
      } else {
        setState(() {
          _start--;
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    readJson();
  }

  bool validateRequiredFields() {
    bool allFieldsValid = true;

    for (var section in data.entries) {
      for (var item in section.value) {
        if (item.containsKey("required")) {
          if (item['required']) {
            if ((item['type'] == 'text' || item['type'] == 'number') &&
                (textValues[item['name']] == null ||
                    (textValues[item['name']] != null &&
                        textValues[item['name']]!.trim().isEmpty))) {
              fieldErrors[item['name']] = true;
              allFieldsValid = false;
            } else {
              fieldErrors[item['name']] = false;
            }
          }
        }
      }
    }

    return allFieldsValid;
  }

  Map<String, String> getBunchValues() {
    Map<String, String> bunchValues = {};

    for (var section in data.entries) {
      for (var item in section.value) {
        if (item['type'] == "text" || item['type'] == "number") {
          bunchValues[item['name']] = textValues[item['name']] ?? '';
        } else if (item['type'] == "radio") {
          bunchValues[item['name']] = radioControllers[item['name']] ?? '';
        } else if (item['type'] == "bool") {
          bunchValues[item['name']] =
              (boolValues[item['name']] ?? false) ? "Current value: Yes" : "Current value: No";
        } else if (item['type'] == "counter") {
          bunchValues[item['name']] =
              (counterValues[item['name']] ?? 0).toString();
        }
      }
    }
    bunchValues["Counter Timestamps"] = jsonEncode(counterTimestamps);
    return bunchValues;
  }

  void saveAndSend() {
    if (!validateRequiredFields()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Please fill out all the required fields before sending.')),
      );
      setState(
          () {}); // Trigger a rebuild to show error messages, feel free to refactor if there is a better way
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation'),
          content: const Text('Are you sure you want to send the data?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Prepare to send!'),
              onPressed: () {
                Navigator.of(context).pop();
                // redirect to `send_data.dart` and pass the data
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SendData(
                            data: getBunchValues(),
                            isGame: true,
                          )),
                );
              },
            ),
            TextButton(
              child: const Text('No, not yet'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      title: Text(widget.title, style: const TextStyle(color: Colors.black)),
    ),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: saveAndSend,
      label: const Text('Save & Send'),
      icon: const Icon(Icons.send),
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
            itemCount: data.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return Column(children: [
                  const Padding(padding: EdgeInsets.all(5)),
                  const Text(
                    "Match Timer",
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Padding(padding: EdgeInsets.all(2)),
                  if (_start >= 60) ...[
                    Text(
                        "${(_start / 60).floor()}:${(_start % 60).toString().padLeft(2, '0')}",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18)),
                  ],
                  if (_start <= 59) ...[
                    Text("$_start",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18)),
                  ],
                  const Padding(padding: EdgeInsets.all(2)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      if (_timer == null) ...[
                        ElevatedButton(
                          onPressed: () {
                            startTimer();
                          },
                          child: const Text("Start"),
                        ),
                        const Padding(padding: EdgeInsets.all(5)),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _start = 150;
                            });
                          },
                          child: const Text("Reset"),
                        ),
                      ] else ...[
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              if (_timer != null) {
                                _timer!.cancel();
                                _timer = null;
                              }
                            });
                          },
                          child: const Text("Pause"),
                        ),
                        const Padding(padding: EdgeInsets.all(5)),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              if (_timer != null) {
                                _start = 150;
                                _timer!.cancel();
                                _timer = null;
                              }
                            });
                          },
                          child: const Text("Reset"),
                        ),
                      ]
                    ],
                  ),
                  const Padding(padding: EdgeInsets.all(5)),
                ]);
              }
              return ExpansionTile(
                title: Text(
                  data.keys.toList()[index - 1].toString(),
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
                        itemCount: data.values.toList()[index - 1].length,
                        itemBuilder: (context2, index2) {
                          bool showError = fieldErrors[data.values
                                  .toList()[index - 1][index2]["name"]] ??
                              false;
                          if (data.values.toList()[index - 1][index2]
                                  ["type"] ==
                              "text") {
                            //addController(data.values.toList()[index - 1][index2]["name"]);
                            String placeholderText = "";
                            if (data.values
                                .toList()[index - 1][index2]
                                .keys
                                .contains("defaultValue")) {
                              placeholderText =
                                  data.values.toList()[index - 1][index2]
                                      ["defaultValue"];
                            }
                            return Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                      padding: const EdgeInsets.all(5),
                                      child: Text(
                                        data.values.toList()[index - 1]
                                            [index2]["name"],
                                        style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                      )),
                                  Container(
                                      padding: const EdgeInsets.all(5),
                                      child: TextFormField(
                                        decoration: InputDecoration(
                                          border:
                                              const OutlineInputBorder(),
                                          hintText: placeholderText,
                                          errorText: showError
                                              ? 'This field is required'
                                              : null,
                                        ),
                                        initialValue: textValues[data
                                                .values
                                                .toList()[index - 1]
                                            [index2]["name"]],
                                        onChanged: (newString) {
                                          if (data.values
                                                      .toList()[index - 1]
                                                  [index2]['required'] &&
                                              (newString == null ||
                                                  newString.isEmpty)) {
                                            fieldErrors[data.values
                                                    .toList()[index - 1]
                                                [index2]['name']] = true;
                                          } else {
                                            fieldErrors[data.values
                                                    .toList()[index - 1]
                                                [index2]['name']] = false;
                                          }
                                          setState(() {
                                            textValues[
                                                data.values.toList()[
                                                        index - 1][index2]
                                                    ["name"]] = newString;
                                          });
                                        },
                                      )),
                                  const Padding(
                                      padding: EdgeInsets.all(10))
                                ]);
                          } else if (data.values.toList()[index - 1]
                                  [index2]["type"] ==
                              "radio") {
                            addRadioController(
                                data.values.toList()[index - 1][index2]
                                    ["name"],
                                data.values.toList()[index - 1][index2]
                                    ["choices"][0]);
                            return ListView.builder(
                              shrinkWrap: true,
                              physics:
                                  const NeverScrollableScrollPhysics(),
                              itemCount: data.values
                                      .toList()[index - 1][index2]
                                          ["choices"]
                                      .length +
                                  2,
                              itemBuilder: (content3, index3) {
                                if (index3 == 0) {
                                  return Padding(
                                      padding: const EdgeInsets.all(5),
                                      child: Text(
                                          data.values.toList()[index - 1]
                                              [index2]["name"],
                                          style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight:
                                                  FontWeight.bold)));
                                } else if (index3 > 0 &&
                                    index3 <
                                        data.values
                                                .toList()[index - 1]
                                                    [index2]["choices"]
                                                .length +
                                            1) {
                                  return RadioListTile<String>(
                                    title: Text(data.values
                                            .toList()[index - 1][index2]
                                        ["choices"][index3 - 1]),
                                    value: data.values.toList()[index - 1]
                                        [index2]["choices"][index3 - 1],
                                    groupValue: radioControllers[
                                        data.values.toList()[index - 1]
                                            [index2]["name"]],
                                    onChanged: (String? value) {
                                      setState(() {
                                        if (value != null) {
                                          radioControllers[data.values
                                                  .toList()[index - 1]
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
                          } else if (data.values.toList()[index - 1]
                                  [index2]["type"] ==
                              "number") {
                            //(data.values.toList()[index - 1][index2]["name"]);
                            String placeholderText = "";
                            if (data.values
                                .toList()[index - 1][index2]
                                .keys
                                .contains("defaultValue")) {
                              placeholderText =
                                  data.values.toList()[index - 1][index2]
                                      ["defaultValue"];
                            }
                            return Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                      padding: const EdgeInsets.all(5),
                                      child: Text(
                                        data.values.toList()[index - 1]
                                            [index2]["name"],
                                        style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                      )),
                                  Container(
                                      padding: const EdgeInsets.all(5),
                                      child: TextFormField(
                                        decoration: InputDecoration(
                                          border:
                                              const OutlineInputBorder(),
                                          hintText: placeholderText,
                                          errorText: showError
                                              ? 'This field is required'
                                              : null,
                                        ),
                                        keyboardType:
                                            TextInputType.number,
                                        inputFormatters: [
                                          FilteringTextInputFormatter
                                              .digitsOnly
                                        ],
                                        initialValue: textValues[data
                                                .values
                                                .toList()[index - 1]
                                            [index2]["name"]],
                                        onChanged: (newString) {
                                          if (data.values
                                                      .toList()[index - 1]
                                                  [index2]['required'] &&
                                              (newString == null ||
                                                  newString.isEmpty)) {
                                            fieldErrors[data.values
                                                    .toList()[index - 1]
                                                [index2]['name']] = true;
                                          } else {
                                            fieldErrors[data.values
                                                    .toList()[index - 1]
                                                [index2]['name']] = false;
                                          }
                                          setState(() {
                                            textValues[
                                                data.values.toList()[
                                                        index - 1][index2]
                                                    ["name"]] = newString;
                                          });
                                        },
                                      )),
                                  const Padding(
                                      padding: EdgeInsets.all(10))
                                ]);
                          } else if (data.values.toList()[index - 1]
                                  [index2]["type"] ==
                              "bool") {
                            addBoolValue(data.values.toList()[index - 1]
                                [index2]["name"]);
                            return Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: <Widget>[
                                Container(
                                    padding: const EdgeInsets.all(5),
                                    child: Text(
                                      data.values.toList()[index - 1]
                                          [index2]["name"],
                                      style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    )),
                                Row(children: <Widget>[
                                  Checkbox(
                                    value: boolValues[
                                        data.values.toList()[index - 1]
                                            [index2]["name"]],
                                    onChanged: (bool? value) {
                                      setState(() {
                                        if (value != null) {
                                          boolValues[data.values
                                                  .toList()[index - 1]
                                              [index2]["name"]] = value;
                                        }
                                      });
                                    },
                                  ),
                                  const Padding(
                                      padding: EdgeInsets.all(5)),
                                  Text(
                                    boolValues[data.values
                                                    .toList()[index - 1]
                                                [index2]["name"]] ??
                                            false
                                        ? "Current value: Yes"
                                        : "Current value: No",
                                    style: const TextStyle(
                                      fontSize: 18,
                                    ),
                                  )
                                ]),
                                const Padding(padding: EdgeInsets.all(10))
                              ],
                            );
                          } else if (data.values.toList()[index - 1]
                                  [index2]["type"] ==
                              "counter") {
                            addCounter(data.values.toList()[index - 1]
                                [index2]["name"]);
                            return Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: <Widget>[
                                  Padding(
                                      padding: const EdgeInsets.all(5),
                                      child: Text(
                                        data.values.toList()[index - 1]
                                            [index2]["name"],
                                        style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                      )),
                                  Row(
                                    mainAxisAlignment: MediaQuery.of(context).size.width > 700 
                                      ? MainAxisAlignment.start 
                                      : MainAxisAlignment.center,
                                    children: <Widget>[
                                      ElevatedButton(
                                        onPressed: () {
                                          setState(() {
                                            decrementCounter(data.values
                                                    .toList()[index - 1]
                                                [index2]["name"]);
                                          });
                                        },
                                        style: ElevatedButton.styleFrom(
                                          shape: const CircleBorder(),
                                        ),
                                        child: const Text("-",
                                            style: TextStyle(
                                                fontWeight:
                                                    FontWeight.bold,
                                                fontSize: 24)),
                                      ),
                                      const Padding(
                                          padding: EdgeInsets.all(5)),
                                      Text(
                                          counterValues[data.values
                                                      .toList()[index - 1]
                                                  [index2]["name"]]
                                              .toString(),
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 24)),
                                      const Padding(
                                          padding: EdgeInsets.all(5)),
                                      ElevatedButton(
                                        onPressed: () {
                                          setState(() {
                                            incrementCounter(data.values
                                                    .toList()[index - 1]
                                                [index2]["name"]);
                                          });
                                        },
                                        style: ElevatedButton.styleFrom(
                                          shape: const CircleBorder(),
                                        ),
                                        child: const Text("+",
                                            style: TextStyle(
                                                fontWeight:
                                                    FontWeight.bold,
                                                fontSize: 24)),
                                      ),
                                    ],
                                  ),
                                  const Padding(
                                      padding: EdgeInsets.all(10))
                                ]);
                          }
                          return const Text("Failed to create widget");
                        }
                      ),
                  )
                ]
              );
            },
          ),
    );
  }
}