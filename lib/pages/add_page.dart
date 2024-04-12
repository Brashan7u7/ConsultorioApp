import 'package:calendario_manik/pages/calendar_page.dart';
import 'package:flutter/material.dart';
import 'package:calendario_manik/pages/patients_page.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart'; // Import the Add page

class Add extends StatelessWidget {
  final bool isCitaRapida, isEvento, isPacient, isCitaPro;

  const Add({
    Key? key,
    required this.isCitaRapida,
    this.isEvento = false,
    this.isPacient = false,
    this.isCitaPro = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextEditingController _idController = TextEditingController();
    TextEditingController _nameController = TextEditingController();
    TextEditingController _lastnameController = TextEditingController();
    TextEditingController _phoneController = TextEditingController();
    TextEditingController _symptomsController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: Text(isCitaRapida
            ? "Cita Rápida"
            : isEvento
                ? 'Evento'
                : isPacient
                    ? "Registrar Paciente"
                    : isCitaPro
                        ? "Cita Programada"
                        : ""),
      ),
      body: isCitaRapida
          ? _buildCitaRapidaContent(context)
          : isEvento
              ? _buildEventoContent(context)
              : isPacient
                  ? _buildPacientContent(
                      context,
                      _idController,
                      _nameController,
                      _lastnameController,
                      _phoneController,
                      _symptomsController)
                  : isCitaPro
                      ? _buildCitaProgramadaContent()
                      : Calendar(),
    );
  }

  Widget _buildCitaRapidaContent(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    final _nameController = TextEditingController();
    final _fechaController = TextEditingController();
    final _horaController = TextEditingController();
    final _duracionController = TextEditingController();
    final _servicioController = TextEditingController();
    final _notaController = TextEditingController();

    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                  labelText: 'Escriba el nombre del paciente'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'El nombre del paciente es obligatorio';
                }
                return null;
              },
            ),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _fechaController,
                    readOnly: true, // Prevent user from editing date directly
                    decoration: const InputDecoration(labelText: 'Fecha'),
                    onTap: () async {
                      // Handle date selection using a date picker
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now().subtract(
                            const Duration(days: 365)), // Allow past year dates
                        lastDate: DateTime.now().add(const Duration(
                            days: 365)), // Allow future dates for next year
                      );
                      if (pickedDate != null) {
                        _fechaController.text = pickedDate.toIso8601String();
                      }
                    },
                  ),
                ),
                const SizedBox(width: 10.0),
                Expanded(
                  child: TextFormField(
                    controller: _horaController,
                    readOnly: true, // Prevent user from editing time directly
                    decoration: const InputDecoration(labelText: 'Hora'),
                    onTap: () async {
                      // Handle time selection using a time picker
                      TimeOfDay? pickedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (pickedTime != null) {
                        _horaController.text = pickedTime.format(context);
                      }
                    },
                  ),
                ),
              ],
            ),
            TextFormField(
              controller: _duracionController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Duración (min)'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'La duración es obligatoria';
                }
                return null;
              },
            ),
            DropdownButtonFormField<String>(
              value: _servicioController.text.isEmpty
                  ? null
                  : _servicioController.text,
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
              onChanged: (value) => _servicioController.text = value!,
            ),
            TextFormField(
              controller: _notaController,
              decoration: const InputDecoration(labelText: 'Nota para cita'),
              maxLines: 3,
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  // Form is valid, process quick appointment data
                  saveQuickAppointment(
                    context,
                    _nameController.text,
                    _fechaController.text,
                    _horaController.text,
                    _duracionController.text,
                    _servicioController.text,
                    _notaController.text,
                  );
                }
              },
              child: const Text('Guardar Cita Rápida'),
            ),
          ],
        ),
      ),
    );
  }

  // Método para guardar la cita en la página de calendario
  void saveQuickAppointment(
    BuildContext context,
    String name,
    String fecha,
    String hora,
    String duracion,
    String servicio,
    String nota,
  ) {
    // Combine date and time into a proper format
    String dateTimeString = '$fecha $hora:00'; // Add seconds to HH:MM:SS format

    // Correct the format of the date and time string
    DateTime startTime = DateTime.parse(dateTimeString.replaceAll('T', ' '));
    int duration = int.tryParse(duracion) ?? 0;
    DateTime endTime = startTime.add(Duration(minutes: duration));

    Appointment newAppointment = Appointment(
      startTime: startTime,
      endTime: endTime,
      subject: name,
      notes: nota,
    );

    // Return the new appointment to the Calendar page
    Navigator.pop(context, newAppointment);
  }

  Widget _buildCitaProgramadaContent() {
    return Center(
      child: Text("Contenido para Cita Programada"),
    );
  }

  Widget _buildEventoContent(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    final _nombreController = TextEditingController();
    final _fechaController = TextEditingController();
    final _horaController = TextEditingController();
    final _duracionController = TextEditingController();
    final _notaController = TextEditingController();

    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
            TextFormField(
              controller: _nombreController,
              decoration: const InputDecoration(labelText: 'Nombre del Evento'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'El nombre del evento es obligatorio';
                }
                return null;
              },
            ),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _fechaController,
                    readOnly: true, // Prevent user from editing date directly
                    decoration: const InputDecoration(labelText: 'Fecha'),
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate:
                            DateTime.now().subtract(const Duration(days: 365)),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (pickedDate != null) {
                        _fechaController.text = pickedDate.toIso8601String();
                      }
                    },
                  ),
                ),
                const SizedBox(width: 10.0),
                Expanded(
                  child: TextFormField(
                    controller: _horaController,
                    readOnly: true, // Prevent user from editing time directly
                    decoration: const InputDecoration(labelText: 'Hora'),
                    onTap: () async {
                      TimeOfDay? pickedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (pickedTime != null) {
                        _horaController.text = pickedTime.format(context);
                      }
                    },
                  ),
                ),
              ],
            ),
            TextFormField(
              controller: _duracionController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Duración (min)'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'La duración es obligatoria';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _notaController,
              decoration:
                  const InputDecoration(labelText: 'Nota para el evento'),
              maxLines: 3,
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  // Form is valid, process event data
                  // ... Handle event creation logic here
                }
              },
              child: const Text('Guardar Evento'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPacientContent(
    BuildContext context,
    TextEditingController idController,
    TextEditingController nameController,
    TextEditingController lastnameController,
    TextEditingController phoneController,
    TextEditingController symptomsController,
  ) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: SingleChildScrollView(
  child: Column(
    children: [
      TextField(
        controller: idController,
        decoration: InputDecoration(labelText: 'Identificador'),
        maxLength: 16,
      ),
      TextField(
        controller: nameController,
        decoration: InputDecoration(labelText: 'Nombre'),
        maxLength: 32,
      ),
      TextField(
        controller: lastnameController,
        decoration: InputDecoration(labelText: 'Apellido paterno'),
        maxLength: 64,
      ),
      TextField(
        controller: TextEditingController(), // Campo para Apellido materno
        decoration: InputDecoration(labelText: 'Apellido materno'),
        maxLength: 64,
      ),
      TextField(
        controller: TextEditingController(), // Campo para Fecha de nacimiento
        decoration: InputDecoration(labelText: 'Fecha de nacimiento'),
        keyboardType: TextInputType.datetime,
      ),
      TextField(
        controller: TextEditingController(), // Campo para Teléfono móvil
        decoration: InputDecoration(labelText: 'Teléfono móvil'),
        keyboardType: TextInputType.phone,
      ),
      TextField(
        controller: TextEditingController(), // Campo para Correo electrónico
        decoration: InputDecoration(labelText: 'Correo electrónico'),
        keyboardType: TextInputType.emailAddress,
      ),
      TextField(
        controller: TextEditingController(), // Campo para Teléfono fijo
        decoration: InputDecoration(labelText: 'Teléfono fijo'),
        keyboardType: TextInputType.phone,
      ),
      SizedBox(height: 20),
      ElevatedButton(
        onPressed: () {
          DataPatients newPatient = DataPatients(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            name: nameController.text,
            lastname: lastnameController.text,
            phone: phoneController.text,
            symptoms: symptomsController.text,
          );

          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => Patients(newPatient: newPatient)));
        },
        child: Text('Guardar Paciente'),
      ),
    ],
  ),
),

    );
  }
}