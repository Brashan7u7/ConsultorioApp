import 'package:calendario_manik/database/database.dart';
import 'package:calendario_manik/models/tarea.dart';
import 'package:calendario_manik/widgets/AddPatientForm.dart';
import 'package:calendario_manik/widgets/AppointmentNoteWidget.dart';
import 'package:flutter/material.dart';
import 'package:calendario_manik/pages/add_page.dart';
import 'package:calendario_manik/pages/calendar_page.dart';
import 'package:intl/intl.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:calendario_manik/variab.dart';
import 'package:calendario_manik/models/doctor.dart';
import 'package:calendario_manik/pages/lista_espera.dart';

class CitaProgramadaContent extends StatefulWidget {
  final int? consultorioId;

  CitaProgramadaContent({Key? key, this.consultorioId}) : super(key: key);

  @override
  _CitaProgramadaContentState createState() => _CitaProgramadaContentState();
}

class _CitaProgramadaContentState extends State<CitaProgramadaContent> {
  final _formKey = GlobalKey<FormState>();
  int selectedInterval = 60;
  String valor = "Consulta";
  TextEditingController nameController = TextEditingController(text: "");
  final TextEditingController doctorController = TextEditingController();

  List<Map<String, dynamic>> suggestedPatients = [];
  bool isPatientRegistered =
      true; // Variable para controlar si el paciente está registrado
  List<Map<String, dynamic>> _recommendedAppointments = [];
  String? _selectedAppointment;

  List<Doctor> doctores = [];
  int doctorId = 0;
  Doctor? selectedDoctor;

  int pacienteId = 0;
  String nombres = 'paciente';

  @override
  void initState() {
    super.initState();
    nameController.addListener(searchPatients);
    if (usuario_cuenta_id == 3 && usuario_rol != 'MED') _fetchDoctores();
    if (usuario_rol == 'MED') doctorId = usuario_id;
  }

  @override
  void dispose() {
    nameController.removeListener(searchPatients);
    super.dispose();
  }

  void searchPatients() async {
    String query = nameController.text.trim();
    if (query.isNotEmpty) {
      List<Map<String, dynamic>> patients =
          await DatabaseManager.searchPatients(query, widget.consultorioId!);
      setState(() {
        suggestedPatients = patients;
        isPatientRegistered = patients.isNotEmpty;
      });
    } else {
      setState(() {
        suggestedPatients = [];
        isPatientRegistered = true; // Restablecer a true cuando no hay consulta
      });
    }
  }

  Future<void> _getRecommendedDateTime(String option) async {
    List<Map<String, dynamic>> recommendations = [];
    if (option == 'Opción 1') {
      recommendations = await DatabaseManager.getRecomeDiaria();
    } else if (option == 'Opción 2') {
      recommendations = await DatabaseManager.getRecomeSema();
    } else if (option == 'Opción 3') {
      recommendations = await DatabaseManager.getRecomeMen();
    }

    setState(() {
      _recommendedAppointments = recommendations;
      _selectedAppointment = recommendations.isNotEmpty
          ? recommendations[0]['fecha'] + ' ' + recommendations[0]['hora']
          : null;
    });
  }

  Future<void> _fetchDoctores() async {
    try {
      List<Map<String, dynamic>> doctoresData =
          await DatabaseManager.getDoctores(grupo_id);

      List<Doctor> doctoresList = doctoresData.map((data) {
        return Doctor(
          id: data['id'],
          nombre: data['nombre'],
          apellidos: data['apellidos'],
        );
      }).toList();

      setState(() {
        doctores = doctoresList;
      });
    } catch (e) {
      print('Error fetching doctores: $e');
    }
  }

  bool status = false;
  bool espera = false;

  @override
  Widget build(BuildContext context) {
    DateTime selectedDateTime = DateTime.now();
    TextEditingController fechaController = TextEditingController(text: "");
    TextEditingController horaController = TextEditingController(text: "");
    TextEditingController duracionController = TextEditingController(text: "");
    TextEditingController servicioController = TextEditingController(text: "");
    TextEditingController notaController = TextEditingController(text: "");
    TextEditingController motivoConsultaController =
        TextEditingController(text: "");
    TextEditingController tipoCitaController = TextEditingController(text: "");

    void openAddPatientPage() {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Add(
            isCitaInmediata: false,
            isEvento: false,
            isPacient: true,
            isCitaPro: false,
            consultorioId: widget.consultorioId,
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
      //print(fechaController);
    });

    horaController.addListener(() {
      if (fechaController.text.isNotEmpty && horaController.text.isNotEmpty) {
        appointmentTime =
            DateTime.parse('${fechaController.text} ${horaController.text}');
      }
      //print(horaController);
    });

    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AddPatientForm(
                onPatientAdded: (Map<String, dynamic> patient) {
                  setState(() {
                    nameController.text = patient['nombre'];
                    pacienteId = patient['id'];
                  });
                },
                consultorioId: widget.consultorioId!,
                nombres: nombres,
              ),
              const SizedBox(height: 20.0),
              if (usuario_cuenta_id == 3 && usuario_rol != 'MED')
                Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<Doctor>(
                            isExpanded: true,
                            items: doctores.map((doctor) {
                              return DropdownMenuItem<Doctor>(
                                value: doctor,
                                child: Text(
                                    '${doctor.nombre} ${doctor.apellidos}'),
                              );
                            }).toList(),
                            value: selectedDoctor,
                            onChanged: (value) {
                              setState(() {
                                selectedDoctor = value;
                                if (selectedDoctor != null) {
                                  doctorId = selectedDoctor!.id!;
                                }
                              });
                            },
                            decoration: InputDecoration(
                              labelText:
                                  'Seleccione el médico que atenderá la cita',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                    width: 1, color: Colors.grey),
                              ),
                              filled: true,
                              fillColor: Colors.transparent,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
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
                    selectedInterval = int.parse(value!);
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Intervalo de Atención (minutos)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(width: 1, color: Colors.grey),
                  ),
                  filled: true,
                  fillColor: Colors.transparent,
                ),
              ),
              if (espera) ...[
                const SizedBox(height: 20.0),
                TextFormField(
                  controller: fechaController,
                  //readOnly: !espera,
                  decoration: InputDecoration(
                    labelText: 'Fecha',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          const BorderSide(width: 1, color: Colors.grey),
                    ),
                    filled: true,
                    fillColor: Colors.transparent,
                  ),
                  onTap: () async {
                    if (espera) {
                      DateTime? selectedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate:
                            DateTime.now().subtract(const Duration(days: 365)),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (selectedDate != null) {
                        fechaController.text =
                            DateFormat('yyyy-MM-dd').format(selectedDate);
                      }
                    }
                  },
                ),
                const SizedBox(height: 20.0),
                TextFormField(
                  controller: horaController,
                  //readOnly: !espera,
                  decoration: InputDecoration(
                    labelText: 'Hora',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          const BorderSide(width: 1, color: Colors.grey),
                    ),
                    filled: true,
                    fillColor: Colors.transparent,
                  ),
                  onTap: () async {
                    if (espera) {
                      TimeOfDay? selectedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (selectedTime != null) {
                        String formattedTime =
                            "${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}";

                        horaController.text = formattedTime;
                      }
                    }
                  },
                ),
              ] else ...[
                const SizedBox(height: 20.0),
                DropdownButtonFormField<String>(
                  value: servicioController.text.isEmpty
                      ? null
                      : servicioController.text,
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
                  onChanged: (value) async {
                    servicioController.text = value!;
                    await _getRecommendedDateTime(value);
                  },
                  decoration: InputDecoration(
                    labelText: 'Recomendación de la próxima cita',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          const BorderSide(width: 1, color: Colors.grey),
                    ),
                    filled: true,
                    fillColor: Colors.transparent,
                  ),
                ),
              ],
              const SizedBox(height: 20.0),
              if (_recommendedAppointments.isNotEmpty)
                DropdownButtonFormField<String>(
                  value: _selectedAppointment,
                  hint: const Text('Seleccione una cita recomendada'),
                  items: _recommendedAppointments.map((appointment) {
                    DateTime fecha = DateTime.parse(appointment['fecha']);
                    String formattedDate =
                        DateFormat('dd/MM/yyyy').format(fecha);
                    String hora = appointment['hora'];
                    return DropdownMenuItem<String>(
                      value: appointment['fecha'] + ' ' + hora,
                      child: Text('$formattedDate a las $hora'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedAppointment = value!;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Seleccione una fecha y hora recomendada',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          const BorderSide(width: 1, color: Colors.grey),
                    ),
                    filled: true,
                    fillColor: Colors.transparent,
                  ),
                ),
              const SizedBox(height: 5.0),
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: Text(
                  'Motivo de consulta',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                      color: Colors.grey[800]),
                ),
              ),
              const SizedBox(height: 5.0),
              if (sis) ...[
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        isExpanded: true,
                        items: const [
                          DropdownMenuItem<String>(
                            value: 'Servicio 1',
                            child: Text('Servicio 1'),
                          ),
                          DropdownMenuItem<String>(
                            value: 'Servicio 2',
                            child: Text('Servicio 2'),
                          ),
                          // Agrega más servicios aquí
                        ],
                        // value: tipoServicio,
                        onChanged: (value) {
                          setState(() {
                            //tipoServicio = value!;
                          });
                        },
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                                const BorderSide(width: 1, color: Colors.grey),
                          ),
                          filled: true,
                          fillColor: Colors.transparent,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10.0),
                    Expanded(
                      child: FlutterSwitch(
                        activeText: "Subsecuente",
                        inactiveText: "Primera vez",
                        value: status,
                        valueFontSize: 11.0,
                        width: 150,
                        height: 52,
                        borderRadius: 5.0,
                        showOnOff: true,
                        onToggle: (val) {
                          setState(() {
                            status = val;
                            tipoCitaController.text =
                                val ? "Subsecuente" : "Primera vez";
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 20.0),
                    Expanded(
                      child: FlutterSwitch(
                        activeText: "En espera",
                        inactiveText: "Sin espera",
                        value: espera,
                        valueFontSize: 11.0,
                        width: 150,
                        height: 52,
                        borderRadius: 5.0,
                        showOnOff: true,
                        onToggle: (val) {
                          setState(() {
                            espera = val;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ] else ...[
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        isExpanded: true,
                        items: const [
                          DropdownMenuItem<String>(
                              value: 'Consulta', child: Text('Consulta')),
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
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                                const BorderSide(width: 1, color: Colors.grey),
                          ),
                          filled: true,
                          fillColor: Colors.transparent,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10.0),
                    Expanded(
                      child: FlutterSwitch(
                        activeText: "Subsecuente",
                        inactiveText: "Primera vez",
                        value: status,
                        valueFontSize: 11.0,
                        width: 150,
                        height: 52,
                        borderRadius: 5.0,
                        showOnOff: true,
                        onToggle: (val) {
                          setState(() {
                            status = val;
                            tipoCitaController.text =
                                val ? "Subsecuente" : "Primera vez";
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 20.0),
                    Expanded(
                      child: FlutterSwitch(
                        activeText: "En espera",
                        inactiveText: "Sin espera",
                        value: espera,
                        valueFontSize: 11.0,
                        width: 150,
                        height: 52,
                        borderRadius: 5.0,
                        showOnOff: true,
                        onToggle: (val) {
                          setState(() {
                            espera = val;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 20.0),
              AppointmentNoteWidget(noteController: notaController),
              const SizedBox(height: 20.0),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, // Color de fondo del botón
                  foregroundColor: Colors.white, // Color del texto del botón
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        10), // Radio de esquinas redondeadas
                    side: const BorderSide(
                        width: 1, color: Colors.grey), // Borde del botón
                  ),
                ),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    // Recolectar datos del formulario
                    String nombre = nameController.text;
                    String? fecha = _selectedAppointment != null
                        ? _selectedAppointment?.split(' ')[0]
                        : fechaController.text;
                    String? hora = _selectedAppointment != null
                        ? _selectedAppointment?.split(' ')[1]
                        : horaController.text;
                    String duracion = selectedInterval.toString();
                    String servicio = servicioController.text;
                    String nota = notaController.text;
                    String motivoConsulta =
                        valor; // Assign the value from the DropdownButton
                    String tipoCita = status ? "Subsecuente" : "Primera vez";

                    // Crear el objeto Evento
                    Tarea tarea = Tarea(
                        nombre: nombre,
                        fecha: fecha!,
                        hora: hora!,
                        duracion: duracion,
                        servicio: servicio,
                        nota: nota,
                        asignado_id: doctorId,
                        paciente_id: pacienteId,
                        motivoConsulta: motivoConsulta,
                        tipoCita: tipoCita);

                    if (espera) {
                      // Guarda el evento en la base de datos
                      await DatabaseManager.insertarListaEspera(
                          widget.consultorioId!, tarea);

                      await Future.delayed(const Duration(milliseconds: 1500));
                      // Redirige a la página de lista de espera si la opción está activada
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ListaEspera(),
                        ),
                      );
                    } else {
                      // Guarda el evento en la base de datos
                      await DatabaseManager.insertarTareaProgramada(
                          widget.consultorioId!, tarea);

                      await Future.delayed(const Duration(milliseconds: 1500));
                      // Redirige a la página de calendario después de guardar el evento
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Calendar(),
                        ),
                      );
                    }

                    // Mostrar mensaje de éxito o redireccionar a otra pantalla si es necesario
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content:
                              Text('Cita programada agregada correctamente')),
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
