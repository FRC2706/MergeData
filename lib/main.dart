import 'package:flutter/material.dart';
import 'package:merge_data/screens/start.dart';

const CURRENT_YEAR = 2024;

void main() {
  runApp(const MergeDataApp());
}

class MergeDataApp extends StatelessWidget {
  const MergeDataApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MergeData',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 102, 51, 153)),
        useMaterial3: true,
      ),
      home: const StartPage(title: 'MergeData', year: CURRENT_YEAR),
    );
  }
}
