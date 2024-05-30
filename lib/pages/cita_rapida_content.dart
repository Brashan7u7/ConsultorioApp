import 'package:calendario_manik/pages/add_page.dart';
import 'package:flutter/material.dart';
import 'package:calendario_manik/pages/calendar_page.dart';

class CitaRapidaContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();

    TextEditingController nameController = TextEditingController(text: "");
    TextEditingController fechaController = TextEditingController(
      text: DateTime.now().toIso8601String().split('T')[0],
    );
    TextEditingController horaController = TextEditingController(
      text: TimeOfDay.now().format(context),
    );
    TextEditingController servicioController = TextEditingController(text: "");
    TextEditingController notaController = TextEditingController(text: "");

    int? selectedDuration;
    final duracionDropdownController = TextEditingController();

    duracionDropdownController.addListener(() {
      selectedDuration = int.tryParse(duracionDropdownController.text);
    });

    void _openAddPatientPage() {
      Navigator.pop(context); // Cierra la ventana actual
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
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
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
                  controller: notaController,
                  decoration: const InputDecoration(labelText: 'Nota para cita'),
                  maxLines: 3,
                ),
                SizedBox(height: 20.0),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Calendar(),
                        ),
                      );
                    }
                  },
                  child: const Text('Guardar Cita Inmediata'),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}
