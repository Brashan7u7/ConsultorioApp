import 'package:calendario_manik/pages/home_page.dart';
import 'package:calendario_manik/pages/calendar_page.dart';
import 'package:calendario_manik/pages/login_page.dart';
import 'package:calendario_manik/pages/patients_page.dart';
import 'package:calendario_manik/pages/add_page.dart';
import 'package:flutter/material.dart';
import 'package:calendario_manik/pages/createAccount_page.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: HomePage(),
        routes: {
          '/calendary': (context) => Calendar(),
          '/patients': (context) => Patients(),
          '/add': (context) => Add(),
          '/login': (context) => Login(),
          '/createaccount': (context) => CreateP()
        });
  }
}
