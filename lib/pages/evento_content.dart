import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:calendario_manik/models/evento.dart';
import 'package:calendario_manik/database/database.dart';

class EventoContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();

    TextEditingController nameController = TextEditingController();
    TextEditingController fechaController = TextEditingController();
    TextEditingController horaController = TextEditingController();
    TextEditingController duracionController = TextEditingController();
    TextEditingController servicioController = TextEditingController();
    TextEditingController notaController = TextEditingController();

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
                labelText: 'Nombre del evento',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'El nombre del evento es obligatorio';
                }
                return null;
              },
            ),
            TextFormField(
              controller: fechaController,
              decoration: const InputDecoration(labelText: 'Fecha'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'La fecha es obligatoria';
                }
                return null;
              },
            ),
            TextFormField(
              controller: horaController,
              decoration: const InputDecoration(labelText: 'Hora'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'La hora es obligatoria';
                }
                return null;
              },
            ),
            TextFormField(
              controller: duracionController,
              decoration: const InputDecoration(labelText: 'Duración'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'La duración es obligatoria';
                }
                return null;
              },
            ),
            TextFormField(
              controller: servicioController,
              decoration: const InputDecoration(labelText: 'Servicio'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'El servicio es obligatorio';
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
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  try {
                    DateTime fechaHora = DateFormat("dd/MM/yyyy HH:mm").parse("${fechaController.text} ${horaController.text}");
                    
                    Evento nuevoEvento = Evento(
                      id: 0,
                      nombre: nameController.text,
                      fecha: DateFormat("yyyy-MM-dd").format(fechaHora),
                      hora: DateFormat("HH:mm").format(fechaHora),
                      duracion: duracionController.text,
                      servicio: servicioController.text,
                      nota: notaController.text,
                    );

                    await DatabaseManager.insertEvento(nuevoEvento);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Evento guardado con éxito')),
                    );

                    nameController.clear();
                    fechaController.clear();
                    horaController.clear();
                    duracionController.clear();
                    servicioController.clear();
                    notaController.clear();
                  } catch (e) {
                    print('Error al insertar el evento: $e');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error al guardar el evento')),
                    );
                  }
                }
              },
              child: const Text('Guardar Evento'),
            ),
          ],
        ),
      ),
    );
  }
}
