import 'package:calendario_manik/pages/add_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:calendario_manik/pages/calendar_page.dart';

class CitaProgramadaContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    String? _selectedOption;
    DateTime _selectedDateTime = DateTime.now();
    TextEditingController fechaController = TextEditingController(text: "");
    TextEditingController horaController = TextEditingController(text: "");

    TextEditingController nameController = TextEditingController(text: "");
    TextEditingController duracionController = TextEditingController(text: "");
    TextEditingController servicioController = TextEditingController(text: "");
    TextEditingController notaController = TextEditingController(text: "");

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

    DateTime appointmentTime = DateTime.now();

    fechaController.addListener(() {
      if (fechaController.text.isNotEmpty && horaController.text.isNotEmpty) {
        appointmentTime =
            DateTime.parse('${fechaController.text} ${horaController.text}');
      }
    });

    horaController.addListener(() {
      if (fechaController.text.isNotEmpty && horaController.text.isNotEmpty) {
        appointmentTime =
            DateTime.parse('${fechaController.text} ${horaController.text}');
      }
    });

    Future<void> _selectTime(BuildContext context) async {
      final TimeOfDay? newTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay(hour: 7, minute: 15),
        initialEntryMode: TimePickerEntryMode.input,
      );
    }

    Future<void> _selectDay(BuildContext context) async {
      final DateTime firstDate = DateTime.now();
      final DateTime lastDate = DateTime(DateTime.now().year + 1);

      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: firstDate,
        lastDate: lastDate,
        initialDatePickerMode: DatePickerMode.day,
      );
    }

    return SingleChildScrollView(
      child: Form(
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
              const SizedBox(height: 20.0),
              DropdownButtonFormField<String>(
                value: servicioController.text.isEmpty
                    ? null
                    : servicioController.text,
                hint: const Text('Recomendación de la proxima cita'),
                items: const <DropdownMenuItem<String>>[
                  DropdownMenuItem<String>(
                    value: 'Opción 1',
                    child: Text('Siguiente hora más cercana'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'Opción 2',
                    child: Text('Siguiente día del mes más cercano'),
                  ),
                ],
                onChanged: (value) {
                  servicioController.text = value!;
                  if (value == 'Opción 1') {
                    _selectTime(context);
                  } else if (value == 'Opción 2') {
                    _selectDay(context);
                  }
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
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101),
                        );
                        if (pickedDate != null) {
                          String formattedDate =
                              DateFormat('yyyy-MM-dd').format(pickedDate);
                          fechaController.text = formattedDate;
                        }
                      },
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
                      onTap: () async {
                        TimeOfDay? pickedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (pickedTime != null) {
                          DateTime parsedTime = DateFormat.jm().parse(
                              pickedTime.format(context).toString());
                          String formattedTime =
                              DateFormat('HH:mm:ss').format(parsedTime);
                          horaController.text = formattedTime;
                        }
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'La hora es obligatoria';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20.0),
              TextFormField(
                controller: notaController,
                decoration: const InputDecoration(labelText: 'Nota para cita'),
                maxLines: 3,
              ),
              const SizedBox(height: 20.0),
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
                child: const Text('Guardar Cita Programada'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
