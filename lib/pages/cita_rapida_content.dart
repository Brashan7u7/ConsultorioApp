import 'package:calendario_manik/database/database.dart';
import 'package:calendario_manik/models/evento.dart';
import 'package:calendario_manik/models/tarea.dart';
import 'package:calendario_manik/models/doctor.dart';
import 'package:calendario_manik/pages/add_page.dart';
import 'package:calendario_manik/pages/calendar_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Importa el paquete intl para formateo de fechas
import 'package:flutter_switch/flutter_switch.dart';
import 'package:calendario_manik/variab.dart';
import 'package:calendario_manik/widgets/AddPatientForm.dart';

class CitaRapidaContent extends StatefulWidget {
  final int? consultorioId;
  const CitaRapidaContent({
    super.key,
    this.consultorioId,
  });
  @override
  _CitaRapidaContentState createState() => _CitaRapidaContentState();
}

class _CitaRapidaContentState extends State<CitaRapidaContent> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController notaController = TextEditingController();
  final TextEditingController doctorController = TextEditingController();
  final TextEditingController tipoCitaController = TextEditingController();
  bool status = false;
  bool espera = false;
  String valor = "Consulta";
  final _formKey = GlobalKey<FormState>();
  List<String> suggestedPatients = [];

  // Lista de consultorios
  List<Doctor> doctores = [];
  int doctorId = 0;
  Doctor? selectedDoctor;

  int pacienteId = 0;

  void _saveCitaInmediata(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      // Aquí se realiza la lógica para guardar la cita inmediata
      String nombre = nameController.text;
      String nota = notaController.text;
      TextEditingController motivoConsultaController =
          TextEditingController(text: "");
      TextEditingController tipoCitaController =
          TextEditingController(text: "");

      // Suponiendo que tienes el consultorioId y el paciente adecuados
      // Obtener la fecha y hora actual
      DateTime now = DateTime.now();
      String fechaActual = DateFormat('yyyy-MM-dd').format(now);
      // Redondear la hora actual a la hora cerrada más cercana
      int minute = now.minute;
      int roundedHour = now.hour;
      if (minute >= 30) {
        roundedHour = now.hour + 1;
      }
      DateTime roundedTime = now.copyWith(hour: roundedHour, minute: 0);

      String horaActual = DateFormat('HH:mm').format(roundedTime);

      // Crear el objeto evento con la fecha y hora actuales
      String motivoConsulta = valor; // Assign the value from the DropdownButton
      String tipoCita = status ? "Subsecuente" : "Primera vez";
      Tarea tarea = Tarea(
        nombre: nombre,
        fecha: fechaActual,
        hora: DateFormat('HH:mm').format(roundedTime),
        duracion: "", // Puedes ajustar la duración si es necesario
        servicio: "", // Ajusta el servicio si es necesario
        nota: nota,
        asignado_id: doctorId,
        paciente_id: pacienteId,
        motivoConsulta: motivoConsulta,
        tipoCita: tipoCita,
      );
      print('Hora redondeada: ${DateFormat('HH:mm').format(roundedTime)}');

      // Insertar la cita inmediata en la base de datos
      int citaId = await DatabaseManager.insertarTareaInmediata(
          widget.consultorioId!, tarea, nota);

      if (citaId != -1) {
        // Éxito al guardar la cita
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cita guardada correctamente')),
        );

        // Navegar a la página del calendario
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const Calendar(),
          ),
        );
      } else {
        // Error al guardar la cita
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al guardar la cita')),
        );
      }
    }
  }

  void _openAddPatientPage() {
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

  @override
  void initState() {
    super.initState();
    if (usuario_cuenta_id == 3 && usuario_rol != 'MED') _fetchDoctores();
    if (usuario_rol == 'MED') doctorId = usuario_id;
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

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
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
                  const SizedBox(height: 20.0),
                  if (usuario_cuenta_id == 3 && usuario_rol != 'MED')
                    Container(
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: DropdownButton<Doctor>(
                                  isExpanded: true,
                                  hint: const Text(
                                      'Seleccione el médico que atenderá la cita'),
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
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  const Text(
                    'Fecha y hora por registrar:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10.0),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                          'Fecha: ${DateFormat('dd/MM/yyyy').format(DateTime.now())}'),
                      Text(
                          'Hora: ${DateFormat('HH:mm').format(DateTime.now())}'),
                    ],
                  ),
                  const SizedBox(height: 20.0),
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
                            decoration: const InputDecoration(
                              labelText: 'Tipo de servicio',
                            ),
                          ),
                        ),
                        const SizedBox(width: 20.0),
                        Expanded(
                          child: FlutterSwitch(
                            activeText: "Subsecuente",
                            inactiveText: "Primera vez",
                            value: status,
                            valueFontSize: 11.0,
                            width: 110,
                            height: 30,
                            borderRadius: 30.0,
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
                              labelText: 'Motivo de consulta',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    BorderSide(width: 1, color: Colors.grey),
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
                            valueFontSize: 11.0,
                            width: 110,
                            height: 30,
                            borderRadius: 30.0,
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
                  TextFormField(
                    controller: notaController,
                    decoration:
                        const InputDecoration(labelText: 'Nota para la cita'),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 20.0),
                  ElevatedButton(
                    onPressed: () => _saveCitaInmediata(context),
                    child: const Text('Guardar Cita Inmediata'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
