import 'package:flutter/material.dart';
import 'package:calendario_manik/pages/patients_page.dart';
import 'package:flutter/widgets.dart';

class Add extends StatelessWidget {
  final bool isCitaRapida, isEvento, isPacient;

  const Add({
    Key? key,
    required this.isCitaRapida,
    this.isEvento = false,
    this.isPacient = false,
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
                    : "Cita Programada"),
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
                  : _buildCitaProgramadaContent(),
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
                  // Form is valid, process appointment data
                  // ... Handle appointment creation logic here
                }
              },
              child: const Text('Guardar Cita Rápida'),
            ),
          ],
        ),
      ),
    );
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
      TextEditingController symptomsController) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          TextField(
            controller: nameController,
            decoration: InputDecoration(labelText: 'Nombre'),
          ),
          TextField(
            controller: lastnameController,
            decoration: InputDecoration(labelText: 'Apellido'),
          ),
          TextField(
            controller: phoneController,
            decoration: InputDecoration(labelText: 'Teléfono'),
          ),
          TextField(
            controller: symptomsController,
            decoration: InputDecoration(labelText: 'Síntomas'),
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
    );
  }
}
