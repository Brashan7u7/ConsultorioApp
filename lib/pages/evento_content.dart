import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:calendario_manik/models/evento.dart';
import 'package:calendario_manik/database/database.dart';
import 'package:calendario_manik/pages/calendar_page.dart';

class EventoContent extends StatelessWidget {
  final int? consultorioId;

  EventoContent({
    Key? key,
    this.consultorioId,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();

    TextEditingController nameController = TextEditingController(text: "");
    TextEditingController fechaController = TextEditingController(text: "");
    TextEditingController horaController = TextEditingController(text: "");
    TextEditingController duracionController = TextEditingController(text: "");
    TextEditingController servicioController = TextEditingController(text: "");
    TextEditingController notaController = TextEditingController(text: "");

    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
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
              SizedBox(height: 10.0),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: fechaController,
                      readOnly: true,
                      decoration: const InputDecoration(labelText: 'Fecha'),
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now()
                              .subtract(const Duration(days: 365)),
                          lastDate:
                              DateTime.now().add(const Duration(days: 365)),
                        );
                        if (pickedDate != null) {
                          fechaController.text =
                              pickedDate.toIso8601String().split('T')[0];
                        }
                      },
                    ),
                  ),
                  SizedBox(width: 10.0),
                  Expanded(
                    child: TextFormField(
                      controller: horaController,
                      readOnly: true,
                      decoration: const InputDecoration(labelText: 'Hora'),
                      onTap: () async {
                        // Handle time selection using a time picker
                        TimeOfDay? pickedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (pickedTime != null) {
                          horaController.text = pickedTime.format(context);
                        }
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.0),
              TextFormField(
                controller: duracionController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Duración (min)'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'La duración es obligatoria';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10.0),
              DropdownButtonFormField<String>(
                value: servicioController.text.isEmpty
                    ? null
                    : servicioController.text,
                hint: const Text('Servicio de atención'),
                items: <DropdownMenuItem<String>>[
                  DropdownMenuItem<String>(
                    value: 'Subsecuente',
                    child: Text('Subsecuente'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'Videoconsulta',
                    child: Text('Videoconsulta'),
                  ),
                  // ... Add more service options here
                ],
                onChanged: (value) => servicioController.text = value!,
              ),
              SizedBox(height: 10.0),
              TextFormField(
                controller: notaController,
                decoration: const InputDecoration(labelText: 'Nota para cita'),
                maxLines: 3,
              ),
              SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    Evento evento = Evento(
                      nombre: nameController.text,
                      fecha: fechaController.text,
                      hora: horaController.text,
                      duracion: duracionController.text,
                      servicio: servicioController.text,
                      nota: notaController.text,
                    );
                    DatabaseManager.insertEvento(consultorioId!, evento)
                        .then((_) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Calendar(),
                        ),
                      );
                    }).catchError((error) {
                      // Manejar el error, como mostrar un mensaje al usuario
                      print('Error al guardar el evento: $error');
                    });
                  }
                },
                child: const Text('Guardar Evento'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
