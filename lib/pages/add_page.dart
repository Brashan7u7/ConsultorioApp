import 'package:calendario_manik/pages/calendar_page.dart';
import 'package:flutter/material.dart';
import 'package:calendario_manik/pages/patients_page.dart';

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
          ? _buildCitaRapidaContent(
              context,
            )
          : isEvento
              ? _buildEventoContent(context)
              : isPacient
                  ? _buildPacientContent(context)
                  : isCitaPro
                      ? _buildCitaProgramadaContent(context)
                      : Calendar(),
    );
  }

  Widget _buildCitaRapidaContent(BuildContext context) {
    final _formKey = GlobalKey<FormState>();

    TextEditingController nameController = TextEditingController(text: "");
    TextEditingController fechaController = TextEditingController(
      text: DateTime.now().toIso8601String().split('T')[0],
    );
    TextEditingController horaController = TextEditingController(
      text: TimeOfDay.now().format(context),
    );
    TextEditingController duracionController = TextEditingController(text: "");
    TextEditingController servicioController = TextEditingController(text: "");
    TextEditingController notaController = TextEditingController(text: "");

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'Cita para hoy (${DateTime.now().toIso8601String().split('T')[0]}) a las ${TimeOfDay.now().format(context)}',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
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
                TextFormField(
                  controller: duracionController,
                  keyboardType: TextInputType.number,
                  decoration:
                      const InputDecoration(labelText: 'Duración (min)'),
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
                  decoration:
                      const InputDecoration(labelText: 'Nota para cita'),
                  maxLines: 3,
                ),
                SizedBox(height: 20.0),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Calendar(
                            name: nameController.text,
                            fecha: fechaController.text,
                            hora: horaController.text,
                            duracion: duracionController.text,
                            servicio: servicioController.text,
                            nota: notaController.text,
                          ),
                        ),
                      );
                    }
                  },
                  child: const Text('Guardar Cita Rápida'),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }

  // Método para guardar la cita en la página de calendario

  Widget _buildCitaProgramadaContent(BuildContext context) {
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
                        firstDate:
                            DateTime.now().subtract(const Duration(days: 365)),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Calendar(
                        name: nameController.text,
                        fecha: fechaController.text,
                        hora: horaController.text,
                        duracion: duracionController.text,
                        servicio: servicioController.text,
                        nota: notaController.text,
                      ),
                    ),
                  );
                }
              },
              child: const Text('Guardar Cita Programada'),
            ),
          ],
        ),
      ),
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

  Widget _buildPacientContent(BuildContext context) {
    final _formKey = GlobalKey<FormState>();

    TextEditingController nameController = TextEditingController(text: "");
    TextEditingController lastnameController = TextEditingController(text: "");
    TextEditingController firstnameController = TextEditingController(text: "");
    TextEditingController birthdateController = TextEditingController(text: "");
    TextEditingController sexController = TextEditingController(text: "");
    TextEditingController genderController = TextEditingController(text: "");
    TextEditingController mailController = TextEditingController(text: "");
    TextEditingController phoneController = TextEditingController(text: "");

    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
            TextFormField(
              controller: nameController,
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
                  child: DropdownButtonFormField<String>(
                    value:
                        sexController.text.isEmpty ? null : sexController.text,
                    hint: const Text('Sexo biologico'),
                    items: <DropdownMenuItem<String>>[
                      DropdownMenuItem<String>(
                        value: 'Hombre',
                        child: Text('Hombre'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'Mujer',
                        child: Text('Mujer'),
                      ),
                      // ... Add more service options here
                    ],
                    onChanged: (value) => sexController.text = value!,
                  ),
                ),
                const SizedBox(width: 10.0),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: genderController.text.isEmpty
                        ? null
                        : genderController.text,
                    hint: const Text('Genero'),
                    items: <DropdownMenuItem<String>>[
                      DropdownMenuItem<String>(
                        value: 'Transgenero',
                        child: Text('Transgenero'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'Transexual',
                        child: Text('Transexual'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'Tranvesti',
                        child: Text('Tranvesti'),
                      ),
                      // ... Add more service options here
                    ],
                    onChanged: (value) => genderController.text = value!,
                  ),
                ),
              ],
            ),
            TextFormField(
              controller: firstnameController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Primer Apellido'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'El Primer Apellido es obligatoria';
                }
                return null;
              },
            ),
            TextFormField(
              controller: lastnameController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Segundo Apellido'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'El Segundo Apellido es obligatoria';
                }
                return null;
              },
            ),
            TextFormField(
              controller: birthdateController,
              keyboardType: TextInputType.number,
              decoration:
                  const InputDecoration(labelText: 'Fecha de Nacimiento'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'La Fecha de nacimiento es obligatoria';
                }
                return null;
              },
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now().subtract(const Duration(days: 365)),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (pickedDate != null) {
                  birthdateController.text =
                      pickedDate.toIso8601String().split('T')[0];
                }
              },
            ),
            TextFormField(
              controller: mailController,
              keyboardType: TextInputType.number,
              decoration:
                  const InputDecoration(labelText: 'Correo Electronico'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'El Correo Electronico es obligatoria';
                }
                return null;
              },
            ),
            TextFormField(
              controller: phoneController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Telefono'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'El Telefono es obligatorio';
                }
                return null;
              },
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  // Navigate to calendar_page and pass the appointment object
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Patients(
                        name: nameController.text,
                        sexo: sexController.text,
                        genero: genderController.text,
                        primerPat: firstnameController.text,
                        segundPat: lastnameController.text,
                        fechaNaci: birthdateController.text,
                        correo: mailController.text,
                        telefono: phoneController.text,
                      ),
                    ),
                  );
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
