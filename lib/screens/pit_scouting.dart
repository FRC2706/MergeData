import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PitScoutingPage extends StatefulWidget {
  PitScoutingPage({Key? key, required this.title, required this.year}) : super(key: key);

  final String title;
  final int year;

  @override
  _PitScoutingState createState() => _PitScoutingState();
}

class _PitScoutingState extends State<PitScoutingPage> {
  Map<String, String> radioValues = {};
  Map<String, dynamic> formFields = {};
  Map<String, bool> fieldErrors = {};

  @override
  void initState() {
    super.initState();
    loadJson();
  }

  Future<void> loadJson() async {
    final String response = await rootBundle.loadString("assets/pit/${widget.year}.json");
    final data = await jsonDecode(response);
    setState(() {
      formFields = data;
    });
  }

  bool validateRequiredFields() {
    bool allFieldsValid = true;
    for (var field in formFields['Pit']) {
      if (field['required']) {
        if (field['type'] == 'radio' && (radioValues[field['name']] == null || radioValues[field['name']]!.isEmpty)) {
          fieldErrors[field['name']] = true;
          allFieldsValid = false;
        } else {
          fieldErrors[field['name']] = false;
        }
        // Add checks for other field types as needed
      }
    }
    return allFieldsValid;
  }

  void saveAndSend() {
    if (!validateRequiredFields()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill out all required fields before saving.')),
      );
      setState(() {}); // Trigger a rebuild to show error messages
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmation'),
          content: Text('Are you sure you want to send the data?'),
          actions: <Widget>[
            TextButton(
              child: Text('Send away!'),
              onPressed: () {
                // Placeholder for saving data
                // TODO: Implement save data functionality
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('No, not yet'),
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
        title: Text(widget.title),
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
                    setState(() {});
                  },
                ),
              ],
            );
          } else if (field['type'] == 'text') {
            return Column(
              children: [
                TextFormField(
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
                showError ? Text('This field is required', style: TextStyle(color: Colors.red)) : SizedBox.shrink(),
              ],
            );
          } else {
            return SizedBox.shrink(); // Return an empty widget for unsupported field types
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