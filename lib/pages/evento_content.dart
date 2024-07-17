import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:calendario_manik/models/evento.dart';
import 'package:calendario_manik/database/database.dart';
import 'package:calendario_manik/pages/calendar_page.dart';

class EventoContent extends StatefulWidget {
  final int? consultorioId;

  const EventoContent({super.key, this.consultorioId});

  @override
  _EventoContentState createState() => _EventoContentState();
}

class _EventoContentState extends State<EventoContent> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController nameController = TextEditingController(text: "");
  TextEditingController fechaController = TextEditingController(text: "");
  TextEditingController horaController = TextEditingController(text: "");
  TextEditingController duracionController = TextEditingController(text: "");
  TextEditingController servicioController = TextEditingController(text: "");
  TextEditingController notaController = TextEditingController(text: "");

  int selectedInterval = 60;

  Future<void> _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (pickedDate != null) {
      setState(() {
        fechaController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  Future<void> _pickTime() async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null) {
      setState(() {
        // Convertir a formato de 24 horas
        final now = DateTime.now();
        final formattedTime = DateTime(
            now.year, now.month, now.day, pickedTime.hour, pickedTime.minute);
        horaController.text = DateFormat('HH:mm').format(formattedTime);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
              const SizedBox(height: 10.0),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: fechaController,
                      readOnly: true,
                      decoration: const InputDecoration(labelText: 'Fecha'),
                      onTap: _pickDate,
                    ),
                  ),
                  const SizedBox(width: 10.0),
                  Expanded(
                    child: TextFormField(
                      controller: horaController,
                      readOnly: true,
                      decoration: const InputDecoration(labelText: 'Hora'),
                      onTap: _pickTime,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10.0),
              DropdownButtonFormField<String>(
                items: const [
                  DropdownMenuItem<String>(
                    value: '60',
                    child: Text('60 minutos'),
                  ),
                  DropdownMenuItem<String>(
                    value: '30',
                    child: Text('30 minutos'),
                  ),
                  DropdownMenuItem<String>(
                    value: '20',
                    child: Text('20 minutos'),
                  ),
                  DropdownMenuItem<String>(
                    value: '15',
                    child: Text('15 minutos'),
                  ),
                ],
                value: selectedInterval.toString(),
                onChanged: (value) {
                  setState(() {
                    selectedInterval = int.parse(value!);
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Intervalo de Atención (minutos)',
                ),
              ),
              const SizedBox(height: 10.0),
              DropdownButtonFormField<String>(
                value: servicioController.text.isEmpty
                    ? null
                    : servicioController.text,
                hint: const Text('Servicio de atención'),
                items: const <DropdownMenuItem<String>>[
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
                onChanged: (value) => setState(() {
                  servicioController.text = value!;
                }),
              ),
              const SizedBox(height: 10.0),
              TextFormField(
                controller: notaController,
                decoration: const InputDecoration(labelText: 'Nota para cita'),
                maxLines: 3,
              ),
              const SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    Evento evento = Evento(
                      nombre: nameController.text,
                      fecha: fechaController.text,
                      hora: horaController.text,
                      duracion: selectedInterval.toString(),
                      servicio: servicioController.text,
                      nota: notaController.text,
                    );

                    DatabaseManager.insertEvento(widget.consultorioId!, evento)
                        .then((_) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Evento guardado correctamente')),
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Calendar(),
                        ),
                      );
                    }).catchError((error) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content:
                                Text('Error al guardar el evento: $error')),
                      );
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
