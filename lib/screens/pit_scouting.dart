import 'package:flutter/material.dart';

class PitScoutingPage extends StatefulWidget {
  const PitScoutingPage({Key? key, required this.title, required this.year})
      : super(key: key);

  final String title;
  final int year;

  @override
  State<PitScoutingPage> createState() => _PitScoutingState();
}

class _PitScoutingState extends State<PitScoutingPage> {
  TextEditingController _textEditingController = TextEditingController();

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title, style: const TextStyle(color: Colors.black)),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text("Shep is cool"),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _textEditingController,
                decoration: InputDecoration(
                  labelText: 'Enter a value',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}