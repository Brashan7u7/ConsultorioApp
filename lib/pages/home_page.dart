import 'package:flutter/material.dart';
import 'package:calendario_manik/components/bottom_nav_bar.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Home page")),
      bottomNavigationBar: BottomNavBar(),
    );
  }
}
