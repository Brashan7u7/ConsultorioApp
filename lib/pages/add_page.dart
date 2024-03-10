import 'package:flutter/material.dart';

class Add extends StatelessWidget {
  final bool isCitaRapida;

  const Add({Key? key, required this.isCitaRapida}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isCitaRapida ? "Cita Rápida" : "Cita Programada"),
      ),
      body: isCitaRapida
          ? _buildCitaRapidaContent()
          : _buildCitaProgramadaContent(),
    );
  }

  Widget _buildCitaRapidaContent() {
    // Agrega aquí el contenido específico para Cita Rápida
    return Center(
      child: Text("Contenido para Cita Rápida"),
    );
  }

  Widget _buildCitaProgramadaContent() {
    // Agrega aquí el contenido específico para Cita Programada
    return Center(
      child: Text("Contenido para Cita Programada"),
    );
  }
}
