import 'package:flutter/material.dart';

class CitasController {
  // Implementa la lógica del controlador si es necesario
}

class Citas extends StatefulWidget {
  const Citas({Key? key}) : super(key: key);

  @override
  State<Citas> createState() => _CitasState();
}

class _CitasState extends State<Citas> {
  final CitasController _citasController = CitasController();

  @override
  Widget build(BuildContext) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pagina de citas de hoy'),
      ),
      body: Center(
        child: Text('Contenido de la pagina '),
      ),
    );
  }
}
