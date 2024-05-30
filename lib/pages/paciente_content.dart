import 'package:flutter/material.dart';

class PacienteContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();

    TextEditingController nameController = TextEditingController(text: "");
    TextEditingController fechaNacimientoController = TextEditingController(text: "");
    TextEditingController telefonoController = TextEditingController(text: "");
    TextEditingController direccionController = TextEditingController(text: "");
    TextEditingController notaController = TextEditingController(text: "");

    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre del paciente',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'El nombre del paciente es obligatorio';
                }
                return null;
              },
            ),
            TextFormField(
              controller: fechaNacimientoController,
              decoration: const InputDecoration(labelText: 'Fecha de nacimiento'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'La fecha de nacimiento es obligatoria';
                }
                return null;
              },
            ),
            TextFormField(
              controller: telefonoController,
              decoration: const InputDecoration(labelText: 'Teléfono'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'El teléfono es obligatorio';
                }
                return null;
              },
            ),
            TextFormField(
              controller: direccionController,
              decoration: const InputDecoration(labelText: 'Dirección'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'La dirección es obligatoria';
                }
                return null;
              },
            ),
            TextFormField(
              controller: notaController,
              decoration: const InputDecoration(labelText: 'Nota'),
              maxLines: 3,
            ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  // Add the patient to the database or do something else
                }
              },
              child: const Text('Guardar Paciente'),
            ),
          ],
        ),
      ),
    );
  }
}
