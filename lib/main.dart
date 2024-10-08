import 'package:calendario_manik/pages/start_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:calendario_manik/database/database.dart';
import 'package:intl/intl.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'dart:async';

void main() async {
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation(
      'America/Mexico_City')); // Set the local time zone to 'America/Mexico_City'
  await DatabaseManager.connectAndExecuteQuery();
  WidgetsFlutterBinding.ensureInitialized();
  Intl.defaultLocale = 'es_ES'; // Establece el idioma predeterminado en español
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 5), (Timer t) async {
      await DatabaseManager.verificarYMoverCitasEnEspera();
    });
    //print(_timer);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primaryColor: Colors.blue, fontFamily: 'Roboto'),
      debugShowCheckedModeBanner: false,
      home: const StartPage(),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es', ''), // Soporte para español
      ],
    );
  }
}
