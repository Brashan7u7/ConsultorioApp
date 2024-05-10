import 'package:flutter/material.dart';

class CustomScaffold extends StatelessWidget {
  const CustomScaffold({super.key, this.child});
  final Widget? child;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
      ),
      extendBodyBehindAppBar: true,
      backgroundColor: Color.fromARGB(255, 11, 66, 105),
      body: Stack(
        children: [
          Image.asset(
            'lib/images/disesup.png',
            fit: BoxFit.cover,
            width: double.infinity,
            height: 290,
          ),
          SafeArea(child: child!)
        ],
      ),
    );
  }
}