import 'package:flutter/material.dart';

class CitasController {
  // Implementa la lógica del controlador si es necesario
}

class Citas extends StatefulWidget {
  const Citas({super.key});

  @override
  State<Citas> createState() => _CitasState();
}

class _CitasState extends State<Citas> {
  final CitasController _citasController = CitasController();

  @override
  Widget build(BuildContext) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Pagina de citas de hoy'),
      ),
      body: Center(
        child: const Text('Contenido de la pagina '),
      ),
    );
  }
}
