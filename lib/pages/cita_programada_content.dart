import 'package:calendario_manik/database/database.dart';
import 'package:calendario_manik/models/evento.dart';
import 'package:flutter/material.dart';
import 'package:calendario_manik/pages/add_page.dart';
import 'package:calendario_manik/pages/calendar_page.dart';
import 'package:intl/intl.dart';
import 'package:flutter_switch/flutter_switch.dart';

class CitaProgramadaContent extends StatefulWidget {
  final int? usuario_id;

  CitaProgramadaContent({Key? key, this.usuario_id}) : super(key: key);

  @override
  _CitaProgramadaContentState createState() => _CitaProgramadaContentState();
}

class _CitaProgramadaContentState extends State<CitaProgramadaContent> {
  final _formKey = GlobalKey<FormState>();
  int selectedInterval = 60;
  String valor = "Consulta";
  TextEditingController nameController = TextEditingController(text: "");
  List<String> suggestedPatients = [];
  bool isPatientRegistered =
      true; // Variable para controlar si el paciente está registrado

  @override
  void initState() {
    super.initState();
    nameController.addListener(searchPatients);
  }

  @override
  void dispose() {
    nameController.removeListener(searchPatients);
    super.dispose();
  }

  void searchPatients() async {
    String query = nameController.text.trim();
    if (query.isNotEmpty) {
      List<String> patients = await DatabaseManager.searchPatients(query);
      setState(() {
        suggestedPatients = patients;
        // Verificar si el paciente está registrado
        isPatientRegistered = patients.isNotEmpty;
      });
    } else {
      setState(() {
        suggestedPatients = [];
        isPatientRegistered = true; // Restablecer a true cuando no hay consulta
      });
    }
  }

  bool status = false;
  @override
  Widget build(BuildContext context) {
    DateTime _selectedDateTime = DateTime.now();
    TextEditingController fechaController = TextEditingController(text: "");
    TextEditingController horaController = TextEditingController(text: "");
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
              // Lista de sugerencias de pacientes
              if (suggestedPatients.isNotEmpty)
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: suggestedPatients.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(suggestedPatients[index]),
                      onTap: () {
                        // Actualizar el campo de texto con el paciente seleccionado
                        nameController.text = suggestedPatients[index];
                        // Limpiar la lista de sugerencias
                        setState(() {
                          suggestedPatients = [];
                        });
                      },
                    );
                  },
                ),
              const SizedBox(height: 20.0),
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
                    selectedInterval = int.parse(value!); //no es
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
                hint: const Text('Recomendación de la próxima cita'),
                items: const <DropdownMenuItem<String>>[
                  DropdownMenuItem<String>(
                    value: 'Opción 1',
                    child: Text('Próximo día disponible'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'Opción 2',
                    child: Text('Próxima semana disponible'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'Opción 3',
                    child: Text('Próximo mes disponible'),
                  ),
                ],
                onChanged: (value) {
                  servicioController.text = value!; //No es
                  if (value == 'Opción 1') {
                    // Lógica para la opción 1
                  } else if (value == 'Opción 2') {
                    // Lógica para la opción 2
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
                          String formattedTime = DateFormat('HH:mm:ss').format(
                              DateTime(
                                  0, 1, 1, pickedTime.hour, pickedTime.minute));

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
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      items: const [
                        DropdownMenuItem<String>(
                          value: 'Consulta',
                          child: Text('Consulta'),
                        ),
                        DropdownMenuItem<String>(
                          value: 'Valoración',
                          child: Text('Valoración'),
                        ),
                        DropdownMenuItem<String>(
                          value: 'Estudios',
                          child: Text('Estudios'),
                        ),
                        DropdownMenuItem<String>(
                          value: 'Vacunas',
                          child: Text('Vacunas'),
                        ),
                        DropdownMenuItem<String>(
                          value: 'Nota de evolución',
                          child: Text('Nota de evolución'),
                        ),
                        DropdownMenuItem<String>(
                          value: 'interconsulta',
                          child: Text('Nota de interconsulta'),
                        ),
                        DropdownMenuItem<String>(
                          value: 'Rehabilitación',
                          child: Text('Rehabilitación'),
                        ),
                      ],
                      value: valor,
                      onChanged: (value) {
                        setState(() {
                          valor = value!;
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: 'Motivo de consulta',
                      ),
                    ),
                  ),
                  const SizedBox(width: 20.0),
                  Expanded(
                    child: FlutterSwitch(
                      activeText: "Subsecuente",
                      inactiveText: "Primera ves",
                      value: status,
                      valueFontSize: 11.0,
                      width: 110,
                      height: 30,
                      borderRadius: 30.0,
                      showOnOff: true,
                      onToggle: (val) {
                        setState(() {
                          status = val;
                        });
                      },
                    ),
                  ),
                ],
              ),

              TextFormField(
                controller: notaController,
                decoration: const InputDecoration(labelText: 'Nota para cita'),
                maxLines: 3,
              ),
              const SizedBox(height: 50.0),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    // Recolectar datos del formulario
                    String nombre = nameController.text;
                    String fecha = fechaController.text;
                    String hora = horaController.text;
                    String duracion = selectedInterval.toString();
                    String servicio = servicioController.text;
                    String nota = notaController.text;

                    // Obtener el ID del consultorio de alguna manera (supongamos que está disponible en una variable)
                    int consultorioId =
                        1; // Por ejemplo, asumiendo que el ID del consultorio está disponible aquí

                    // Crear el objeto Evento
                    Evento evento = Evento(
                      nombre: nombre,
                      fecha: fecha,
                      hora: hora,
                      duracion: duracion,
                      servicio: servicio,
                      nota: nota,
                    );

                    // Insertar el evento en la base de datos
                    await DatabaseManager.insertEvento(consultorioId, evento);

                    // Mostrar mensaje de éxito o redireccionar a otra pantalla si es necesario
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content:
                              Text('Cita programada agregada correctamente')),
                    );

                    // Opcional: Redirigir a la página de calendario u otra página relevante
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              Calendar(usuario_id: widget.usuario_id)),
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
