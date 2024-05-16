import 'package:calendario_manik/pages/calendar_page.dart';
import 'package:flutter/material.dart';
import 'package:calendario_manik/pages/patients_page.dart';
import 'package:intl/intl.dart';
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';
import 'package:calendario_manik/database/database.dart';

class Add extends StatelessWidget {
  final bool isCitaInmediata, isEvento, isPacient, isCitaPro;
  final bool? isCitaselect;

  TextEditingController? fechaController, horaController;

  Add(
      {Key? key,
      required this.isCitaInmediata,
      this.isEvento = false,
      this.isPacient = false,
      this.isCitaPro = false,
      this.isCitaselect = false,
      this.fechaController,
      this.horaController})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isCitaInmediata
            ? "Cita Inmediata"
            : isCitaselect!
                ? "Cita Programada"
                : isEvento
                    ? 'Evento'
                    : isPacient
                        ? "Registrar Paciente"
                        : isCitaPro
                            ? "Cita Programada"
                            : ""),
      ),
      body: isCitaInmediata
          ? _buildCitaRapidaContent(
              context,
            )
          : (isCitaselect ?? false)
              ? _buildCitaselectContent(
                  context, fechaController!, horaController!)
              : isEvento
                  ? _buildEventoContent(context)
                  : isPacient
                      ? _buildPacientContent(context)
                      : isCitaPro
                          ? _buildCitaProgramadaContent(context)
                          : Calendar(),
    );
  }

//Cita rapida cuando se selecciona en el menu
  Widget _buildCitaRapidaContent(BuildContext context) {
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
                              // name: nameController.text,
                              // fecha: fechaController.text,
                              // hora: horaController.text,
                              // duracion: duracionDropdownController.text,
                              // servicio: servicioController.text,
                              // nota: notaController.text,
                              ),
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

//Genera cita Rapida cuando se selecciona
  Widget _buildCitaselectContent(
      BuildContext context,
      TextEditingController fechaController,
      TextEditingController horaController) {
    final _formKey = GlobalKey<FormState>();

    TextEditingController nameController = TextEditingController(text: "");
    TextEditingController servicioController = TextEditingController(text: "");
    TextEditingController notaController = TextEditingController(text: "");

    String hora24 =
        horaController.text; // Obtener la hora en formato de 24 horas

// Convertir la hora de 24 horas a un formato de 12 horas
    DateTime horaDateTime = DateFormat("HH:mm:ss.SSS").parse(hora24);
    String hora12 = DateFormat("HH:mm").format(horaDateTime);

    int? selectedDuration;

    final duracionDropdownController = TextEditingController();

    duracionDropdownController.addListener(() {
      selectedDuration = int.tryParse(duracionDropdownController.text);
    });

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
                              // name: nameController.text,
                              // fecha: fechaController.text,
                              // hora: horaController.text,
                              // duracion: duracionDropdownController.text,
                              // servicio: servicioController.text,
                              // nota: notaController.text,
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
        )
      ],
    );
  }

//Genera cita programada
  Widget _buildCitaProgramadaContent(BuildContext context) {
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

    // Initialize appointmentTime to the selected date and time
    DateTime appointmentTime = DateTime.now();

    // Set the initial appointmentTime to the selected date and time
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
        initialDatePickerMode:
            DatePickerMode.day, // Establecer el modo de selección diaria
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
                          firstDate: DateTime.now()
                              .subtract(const Duration(days: 365)),
                          lastDate:
                              DateTime.now().add(const Duration(days: 365)),
                        );
                        if (pickedDate != null) {
                          String hour =
                              pickedDate.hour.toString().padLeft(2, '0');
                          String minute =
                              pickedDate.minute.toString().padLeft(2, '0');
                          horaController.text = '$hour:$minute';
                        }
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
                          horaController.text = pickedTime.format(context);
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10.0),
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
              TextFormField(
                controller: notaController,
                decoration: const InputDecoration(labelText: 'Nota para cita'),
                maxLines: 3,
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

//Calcula el proximo horario disponible

//Generación del evento
  Widget _buildEventoContent(BuildContext context) {
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
                  Evento evento = Evento(
                    nombre: nameController.text,
                    fecha: fechaController.text,
                    hora: horaController.text,
                    duracion: duracionController.text,
                    servicio: servicioController.text,
                    nota: notaController.text,
                  );
                }
              },
              child: const Text('Guardar Evento'),
            ),
          ],
        ),
      ),
    );
  }

//Registrar Paciente
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

class Evento {
  final String nombre;
  final String fecha;
  final String hora;
  final String duracion;
  final String servicio;
  final String nota;

  Evento({
    required this.nombre,
    required this.fecha,
    required this.hora,
    required this.duracion,
    required this.servicio,
    required this.nota,
  });
}
