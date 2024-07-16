import 'package:calendario_manik/database/database.dart';
import 'package:calendario_manik/models/evento.dart';
import 'package:calendario_manik/widgets/AddPatientForm.dart';
import 'package:flutter/material.dart';
import 'package:calendario_manik/pages/add_page.dart';
import 'package:calendario_manik/pages/calendar_page.dart';
import 'package:intl/intl.dart';
import 'package:flutter_switch/flutter_switch.dart';

class CitaProgramadaContent extends StatefulWidget {
  final int? usuario_id, consultorioId;

  const CitaProgramadaContent({super.key, this.usuario_id, this.consultorioId});

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
  List<Map<String, dynamic>> _recommendedAppointments = [];
  String? _selectedAppointment;

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

  bool status = false;

  @override
  Widget build(BuildContext context) {
    DateTime selectedDateTime = DateTime.now();
    TextEditingController fechaController = TextEditingController(text: "");
    TextEditingController horaController = TextEditingController(text: "");
    TextEditingController duracionController = TextEditingController(text: "");
    TextEditingController servicioController = TextEditingController(text: "");
    TextEditingController notaController = TextEditingController(text: "");

    void openAddPatientPage() {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Add(
            isCitaInmediata: false,
            isEvento: false,
            isPacient: true,
            isCitaPro: false,
            usuario_id: widget.usuario_id,
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
      print(fechaController);
    });

    horaController.addListener(() {
      if (fechaController.text.isNotEmpty && horaController.text.isNotEmpty) {
        appointmentTime =
            DateTime.parse('${fechaController.text} ${horaController.text}');
      }
      print(horaController);
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
                onPatientAdded: (String patientName) {
                  setState(() {
                    nameController.text = patientName;
                  });
                },
              ),
              const SizedBox(height: 30.0),
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: Text(
                  'Intervalo de Atención (minutos)',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                      color: Colors.grey[800]),
                ),
              ),
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
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(width: 1, color: Colors.grey),
                  ),
                  filled: true,
                  fillColor: Colors.transparent,
                ),
              ),
              const SizedBox(height: 20.0),
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: Text(
                  'Recomendación de la próxima cita',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                      color: Colors.grey[800]),
                ),
              ),
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
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(width: 1, color: Colors.grey),
                  ),
                  filled: true,
                  fillColor: Colors.transparent,
                ),
              ),
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
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      isExpanded: true,
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
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(width: 1, color: Colors.grey),
                        ),
                        filled: true,
                        fillColor: Colors.transparent,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20.0),
                  Expanded(
                    child: FlutterSwitch(
                      activeText: "Subsecuente",
                      inactiveText: "Primera vez",
                      value: status,
                      valueFontSize: 15.0,
                      width: 180,
                      height: 52,
                      borderRadius: 5.0,
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
              const SizedBox(height: 25.0),
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: Text(
                  'Nota para la cita',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                      color: Colors.grey[800]),
                ),
              ),
              TextFormField(
                controller: notaController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(width: 1, color: Colors.grey),
                  ),
                  filled: true,
                  fillColor: Colors.transparent,
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 70.0),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, // Color de fondo del botón
                  foregroundColor: Colors.white, // Color del texto del botón
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        10), // Radio de esquinas redondeadas
                    side: BorderSide(
                        width: 1, color: Colors.grey), // Borde del botón
                  ),
                ),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    // Recolectar datos del formulario
                    String nombre = nameController.text;
                    String? fecha = _selectedAppointment?.split(' ')[0];
                    String? hora = _selectedAppointment?.split(' ')[1];
                    String duracion = selectedInterval.toString();
                    String servicio = servicioController.text;
                    String nota = notaController.text;

                    // Crear el objeto Evento
                    Evento evento = Evento(
                      nombre: nombre,
                      fecha: fecha!,
                      hora: hora!,
                      duracion: duracion,
                      servicio: servicio,
                      nota: nota,
                    );

                    // Insertar el evento en la base de datos
                    await DatabaseManager.insertEvento(
                        widget.consultorioId!, evento);

                    // Mostrar mensaje de éxito o redireccionar a otra pantalla si es necesario
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content:
                              Text('Cita programada agregada correctamente')),
                    );

                    // Opcional: Redirigir a la página de calendario u otra página relevante
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Calendar(
                                usuario_id: widget.usuario_id,
                              )),
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
