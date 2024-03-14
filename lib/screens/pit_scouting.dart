import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'send_data.dart';

class PitScoutingPage extends StatefulWidget {
  PitScoutingPage(
      {Key? key, required this.title, required this.year, required this.api})
      : super(key: key);

  final String title;
  final int year;
  final String api;

  @override
  _PitScoutingState createState() => _PitScoutingState();
}

class _PitScoutingState extends State<PitScoutingPage> {
  Map<String, String> radioValues = {};
  Map<String, dynamic> formFields = {};
  Map<String, bool> fieldErrors = {};
  Map<String, String> textValues = {};
  Map<String, String> numberValues = {};

  @override
  void initState() {
    super.initState();
    loadJson();
  }

  Future<void> loadJson() async {
    final String response =
        await rootBundle.loadString("assets/pit/${widget.year}.json");
    final data = await jsonDecode(response);
    setState(() {
      formFields = data;
    });
  }

  bool validateRequiredFields() {
    bool allFieldsValid = true;
    for (var field in formFields['Pit']) {
      if (field['required']) {
        if (field['type'] == 'radio' &&
            (radioValues[field['name']] == null ||
                radioValues[field['name']]!.isEmpty)) {
          fieldErrors[field['name']] = true;
          allFieldsValid = false;
        } else if ((field['type'] == 'text' || field['type'] == 'number') &&
            (textValues[field['name']] == null ||
                textValues[field['name']]!.trim().isEmpty)) {
          fieldErrors[field['name']] = true;
          allFieldsValid = false;
        } else {
          fieldErrors[field['name']] = false;
        }
      }
    }
    return allFieldsValid;
  }

  void saveAndSend() {
    if (!validateRequiredFields()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Please fill out all required fields before saving.')),
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
                          isGame: false,
                          api: widget.api)),
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

  Map<String, String> getBunchValues() {
    Map<String, String> bunchValues = {};

    for (var item in formFields['Pit']) {
      if (item['type'] == "text" || item['type'] == "number") {
        bunchValues[item['name']] = textValues[item['name']] ?? '';
      } else if (item['type'] == "radio") {
        bunchValues[item['name']] = radioValues[item['name']] ?? '';
      }
    }

    return bunchValues;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title, style: const TextStyle(color: Colors.black)),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: formFields['Pit']?.length ?? 0,
        itemBuilder: (BuildContext context, int index) {
          var field = formFields['Pit'][index];
          bool showError = fieldErrors[field['name']] ?? false;
          if (field['type'] == 'number') {
            return Column(
              children: [
                TextFormField(
                  keyboardType: TextInputType.number,
                  initialValue:
                      textValues[field['name']] ?? '', // Use the stored value
                  decoration: InputDecoration(
                    labelText: field['name'],
                    errorText: showError ? 'This field is required' : null,
                  ),
                  onChanged: (value) {
                    if (field['required'] && (value == null || value.isEmpty)) {
                      fieldErrors[field['name']] = true;
                    } else {
                      fieldErrors[field['name']] = false;
                    }
                    textValues[field['name']] = value; // Update textValues
                    setState(() {});
                  },
                ),
              ],
            );
          } else if (field['type'] == 'text') {
            return Column(
              children: [
                TextFormField(
                  initialValue:
                      textValues[field['name']] ?? '', // Use the stored value
                  decoration: InputDecoration(
                    labelText: field['name'],
                    errorText: showError ? 'This field is required' : null,
                  ),
                  onChanged: (value) {
                    if (field['required'] && (value == null || value.isEmpty)) {
                      fieldErrors[field['name']] = true;
                    } else {
                      fieldErrors[field['name']] = false;
                    }
                    textValues[field['name']] = value; // Update textValues
                    setState(() {});
                  },
                ),
              ],
            );
          } else if (field['type'] == 'radio') {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  field['name'],
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                ...field['choices'].map<Widget>((choice) {
                  return ListTile(
                    title: Text(choice),
                    leading: Radio<String>(
                      value: choice,
                      groupValue: radioValues[field['name']],
                      onChanged: (String? value) {
                        if (value != null) {
                          setState(() {
                            radioValues[field['name']] = value;
                            fieldErrors[field['name']] = false;
                          });
                        }
                      },
                    ),
                  );
                }).toList(),
                showError
                    ? Text('This field is required',
                        style: TextStyle(color: Colors.red))
                    : SizedBox.shrink(),
              ],
            );
          } else {
            return SizedBox
                .shrink(); // Return an empty widget for unsupported field types
          }
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: saveAndSend,
        label: Text('Save & Send'),
        icon: Icon(Icons.send),
      ),
    );
  }
}
