import 'package:calendario_manik/pages/start_page.dart';
import 'package:flutter/material.dart';
import 'package:calendario_manik/database/database.dart';

void main() async {
  await DatabaseManager.connectAndExecuteQuery();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: StartPage(),
    );
  }
}
