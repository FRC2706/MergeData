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
          if (field['type'] == 'number') {
            return TextFormField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: field['name'],
              ),
              validator: (value) {
                if (field['required'] && (value == null || value.isEmpty)) {
                  return 'Please enter a value';
                }
                return null;
              },
            );
          } else if (field['type'] == 'text') {
            return TextFormField(
              decoration: InputDecoration(
                labelText: field['name'],
              ),
              validator: (value) {
                if (field['required'] && (value == null || value.isEmpty)) {
                  return 'Please enter a value';
                }
                return null;
              },
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
                          });
                        }
                      },
                    ),
                  );
                }).toList(),
              ],
            );
          } else {
            return SizedBox.shrink(); // Return an empty widget for unsupported field types
          }
        },
      ),
    );
  }
}