import 'package:calendario_manik/widgets/AppointmentNoteWidget.dart';
import 'package:calendario_manik/widgets/IntervalDropdownSelector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:intl/intl.dart';
import 'package:calendario_manik/models/evento.dart';
import 'package:calendario_manik/database/database.dart';
import 'package:calendario_manik/pages/calendar_page.dart';
import 'package:flutter_switch/flutter_switch.dart';

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
  TextEditingController servicioController = TextEditingController(text: "Subsecuente");
  ValueNotifier<bool> allDay = ValueNotifier<bool>(false);
  TextEditingController notaController = TextEditingController(text: "");

  bool isAllDay = false;

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

  Future<bool> _hasEventsOrTasksOnDate(String date) async {
    final events =
        await DatabaseManager.getEventosByFecha(widget.consultorioId!, date);
    final tasks =
        await DatabaseManager.getTareasByFecha(widget.consultorioId!, date);
    return events.isNotEmpty || tasks.isNotEmpty;
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
                  labelText: 'Escriba el nombre del evento',
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
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'La fecha es obligatoria';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 10.0),
                  Expanded(
                    child: TextFormField(
                      controller: horaController,
                      readOnly: true,
                      decoration: const InputDecoration(labelText: 'Hora'),
                      onTap: _pickTime,
                  if (!isAllDay) ...[
                    Expanded(
                      child: TextFormField(
                        controller: horaController,
                        readOnly: isAllDay,
                        decoration: const InputDecoration(labelText: 'Hora'),
                        onTap: isAllDay ? null : _pickTime,
                      ),
                    ),
                  ),
                  ],
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
              if (!isAllDay) ...[const IntervalDropdownSelector()],
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
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: Text(
                  'Día completo',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                      color: Colors.grey[800]),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: FlutterSwitch(
                      value: isAllDay,
                      onToggle: (value) {
                      onToggle: (value) async {
                        if (value) {
                          bool hasEventsOrTasks = await _hasEventsOrTasksOnDate(
                              fechaController.text);
                          if (hasEventsOrTasks) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'No se puede poner todo el día porque ya hay eventos o tareas.')),
                            );
                            return;
                          }
                        }
                        setState(() {
                          isAllDay = value;
                          allDay.value = isAllDay;
                          if (isAllDay) {
                            horaController.text = '';
                            fechaController.text = '';
                            duracionController.text = '';
                          }
                        });
                      },
                    ),
                  ),
                ],
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
                    side: const BorderSide(width: 1, color: Colors.grey),
                  ),
                ),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    if (fechaController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Por favor seleccione una fecha.'),
                        ),
                      );
                      return;
                    }

                    // Verificar solo si isAllDay es false
                    if (!isAllDay) {
                      bool hasAllDayEvent =
                          await DatabaseManager.hasAllDayEventOnDate(
                        widget.consultorioId!,
                        fechaController.text,
                      );

                      if (hasAllDayEvent) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Ya hay un evento todo el día en esta fecha.'),
                          ),
                        );
                        return; // No guardar el evento
                      }
                    }

                    Evento evento = Evento(
                      nombre: nameController.text,
                      fecha: fechaController.text,
                      hora: horaController.text,
                      duracion: selectedInterval.toString(),
                      hora: isAllDay ? '' : horaController.text,
                      duracion: isAllDay ? '' : selectedInterval.toString(),
                      servicio: servicioController.text,
                      nota: notaController.text,
                      allDay: isAllDay,
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
                          builder: (context) => Calendar(),
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
