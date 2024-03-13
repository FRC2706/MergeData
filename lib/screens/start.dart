import 'package:flutter/material.dart';
import 'package:merge_data/screens/pit_scouting.dart';
import 'package:merge_data/screens/match_scouting.dart';
import 'package:merge_data/screens/scan.dart';
import 'package:merge_data/screens/send_data.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StartPage extends StatefulWidget {
  const StartPage({super.key, required this.title, required this.year});

  final String title;
  final int year;

  @override
  State<StartPage> createState() => _StartState();
}

class _StartState extends State<StartPage> {
  void matchScouting() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            MatchScoutingPage(title: "Match Scouting", year: widget.year),
      ),
    );
  }

  void pitScouting() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            PitScoutingPage(title: "Pit Scouting", year: widget.year),
      ),
    );
  }

  void scanResults() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ScanResultsPage(title: "Scan Results", year: widget.year),
      ),
    );
  }

  void sendData() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            SendData(data: {}, isGame: true, justSend: true),
      ),
    );
  }

  launchIssues() async {
    Uri url = Uri.parse('https://github.com/FRC2706/MergeData/issues');
    if (await launchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> deleteAllGames() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('savedGames');
  }

  Future<void> saveApiKey(String apiKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('apiKey', apiKey);
  }

  Future<void> promptForApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    String apiKey = prefs.getString('apiKey') ?? '';
    bool obscureText = true;

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Enter API Key'),
              content: TextField(
                controller: TextEditingController(text: apiKey),
                obscureText: obscureText,
                onChanged: (value) {
                  apiKey = value;
                },
                decoration: InputDecoration(
                  hintText: "API Key",
                  suffixIcon: IconButton(
                    icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility),
                    onPressed: () {
                      setState(() {
                        obscureText = !obscureText;
                      });
                    },
                  ),
                ),
              ),
              actions: [
                TextButton(
                  child: Text('Save'),
                  onPressed: () {
                    saveApiKey(apiKey);
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('API Key saved.')),
                    );
                  },
                ),
                TextButton(
                  child: Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
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
      floatingActionButton: Stack(
        children: [
          Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(32.0, 8.0, 8.0, 8.0),
              child: FloatingActionButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Delete all local games?'),
                        content: Text('This action cannot be undone!!', style: TextStyle(color: Colors.red)),
                        actions: [
                          TextButton(
                            child: Text('Yes'),
                            onPressed: () {
                              deleteAllGames();
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('All local games deleted.')),
                              );
                            },
                          ),
                          TextButton(
                            child: Text('No'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
                child: Icon(Icons.delete),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  FloatingActionButton(
                    onPressed: launchIssues,
                    tooltip: 'Report an issue',
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: SvgPicture.asset("assets/images/github.svg"),
                    ),
                  ),
                  SizedBox(width: 10),
                  FloatingActionButton(
                    onPressed: promptForApiKey,
                    tooltip: 'Enter API Key',
                    child: Icon(Icons.settings, size: 30.0),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: matchScouting,
              child: const Text("Match Scouting", style: TextStyle(fontSize: 28)),
            ),
            const Padding(padding: EdgeInsets.all(10)),
            ElevatedButton(
              onPressed: pitScouting,
              child: const Text("Pit Scouting", style: TextStyle(fontSize: 28)),
            ),
            const Padding(padding: EdgeInsets.all(10)),
            ElevatedButton(
              onPressed: scanResults,
              child: const Text("Scan Results", style: TextStyle(fontSize: 28)),
            ),
            const Padding(padding: EdgeInsets.all(10)),
            StreamBuilder<List<String>>(
              stream: Stream.periodic(Duration(seconds: 1)).asyncMap((_) => SharedPreferences.getInstance().then((prefs) => prefs.getStringList('savedGames') ?? [])),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return ElevatedButton(
                    onPressed: null,
                    child: Text('Loading...', style: TextStyle(fontSize: 28)),
                  );
                } else {
                  return ElevatedButton(
                    onPressed: sendData,
                    child: Text('Upload Local Saves (${snapshot.data!.length})', style: TextStyle(fontSize: 28)),
                  );
                }
              },
            )
          ],
        ),
      ),
    );
  }
}
