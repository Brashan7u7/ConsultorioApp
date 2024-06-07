import 'package:calendario_manik/pages/add_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CitaSelectContent extends StatelessWidget {
  final TextEditingController fechaController;
  final TextEditingController horaController;
 
  TextEditingController nameController = TextEditingController(text: "");

  CitaSelectContent(
      {required this.fechaController, required this.horaController});

  @override
  Widget build(BuildContext context) {
    void _openAddPatientPage() {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Add(
            isCitaInmediata: false,
            isEvento: false,
            isPacient: true,
            isCitaPro: false,
          ),
        ),
      );
    }

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Escriba el nombre del paciente',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El nombre del paciente es obligatorio';
                  }
                  return null;
                },
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: _openAddPatientPage,
              tooltip: 'Agregar paciente',
            ),
          ],
        ),
        TextFormField(
          controller: fechaController,
          readOnly: true,
          decoration: const InputDecoration(labelText: 'Fecha'),
        ),
        TextFormField(
          controller: horaController,
          readOnly: true,
          decoration: const InputDecoration(labelText: 'Hora'),
        ),
        TextFormField(
          
          readOnly: true,
          decoration: const InputDecoration(labelText: 'Duracion'),
        ),
        const SizedBox(height: 20.0),
        ElevatedButton(
          onPressed: () {
            if (fechaController.text.isNotEmpty &&
                horaController.text.isNotEmpty) {
              // Guardar cita seleccionada o hacer algo más
            }
          },
          child: const Text('Guardar Cita Seleccionada'),
        ),
      ],
    );
  }
}
