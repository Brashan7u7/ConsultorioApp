import 'package:flutter/material.dart';
import 'package:calendario_manik/components/bottom_nav_bar.dart';

class HomePage extends StatelessWidget {
  final int? usuario_id;
  
  const HomePage({super.key, this.usuario_id});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavBar(usuario_id: usuario_id),
    );
  }
}
