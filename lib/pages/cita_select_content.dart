import 'package:calendario_manik/database/database.dart';
import 'package:calendario_manik/models/tarea.dart';
import 'package:calendario_manik/pages/add_page.dart';
import 'package:calendario_manik/pages/calendar_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:intl/intl.dart';
import 'package:calendario_manik/variab.dart';
import 'package:calendario_manik/widgets/AddPatientForm.dart';
import 'package:calendario_manik/models/doctor.dart';
import 'package:calendario_manik/pages/lista_espera.dart';
import 'package:calendario_manik/models/paciente.dart';

class CitaSelectContent extends StatefulWidget {
  final TextEditingController fechaController;
  final TextEditingController horaController;
  final int? consultorioId;

  CitaSelectContent({
    required this.fechaController,
    required this.horaController,
    this.consultorioId,
  });

  @override
  _CitaSelectContentState createState() => _CitaSelectContentState();
}

class _CitaSelectContentState extends State<CitaSelectContent> {
  int selectedInterval = 60;
  TextEditingController nameController = TextEditingController(text: "");
  String valor = "Consulta";
  TextEditingController notaController = TextEditingController(text: "");
  bool status = false;
  bool espera = false;

  final _formKey = GlobalKey<FormState>();

  List<Doctor> doctores = [];
  int doctorId = 0;
  Doctor? selectedDoctor;
  Paciente? selectedPaciente;

  @override
  void initState() {
    super.initState();
    if (usuario_cuenta_id == 3 && usuario_rol != 'MED') _fetchDoctores();
  }

  Future<void> _fetchDoctores() async {
    try {
      List<Map<String, dynamic>> doctoresData =
          await DatabaseManager.getDoctores(usuario_id);

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
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Form(
            key: _formKey,
            child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AddPatientForm(
                      onPatientAdded: (String patientName) {
                        setState(() {
                          nameController.text = patientName;
                        });
                      },
                      consultorioId: widget.consultorioId!,
                    ),
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
                    TextFormField(
                      controller: widget.fechaController,
                      readOnly: true,
                      decoration: const InputDecoration(labelText: 'Fecha'),
                    ),
                    TextFormField(
                      controller: widget.horaController,
                      readOnly: true,
                      decoration: const InputDecoration(labelText: 'Hora'),
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
                      decoration: const InputDecoration(
                        labelText: 'Intervalo de Atención (minutos)',
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
                              decoration: InputDecoration(
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
                              width: 150,
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
                                      BorderSide(width: 1, color: Colors.grey),
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
                                  print(espera);
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                    //const SizedBox(height: 20.0),
                    TextFormField(
                      controller: notaController,
                      decoration:
                          const InputDecoration(labelText: 'Nota para cita'),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 50.0),
                    ElevatedButton(
                      onPressed: () async {
                        if (widget.fechaController.text.isNotEmpty &&
                            widget.horaController.text.isNotEmpty &&
                            _formKey.currentState!.validate()) {
                          // Recolectar datos del formulario
                          String nombre = nameController.text;
                          String fecha = widget.fechaController.text;
                          String hora = widget.horaController.text;
                          String duracion = selectedInterval.toString();
                          String servicio = valor; // Usar el valor seleccionado
                          String nota = notaController.text;

                          // Crear el objeto Evento
                          Tarea tarea = Tarea(
                            nombre: nombre,
                            fecha: fecha,
                            hora: hora,
                            duracion: duracion,
                            servicio: servicio,
                            nota: nota,
                            asignado_id: doctorId,
                            paciente_id: 1,
                          );

                          if (espera) {
                            // Redirige a la página de lista de espera si la opción está activada
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ListaEspera(tarea: tarea),
                              ),
                            );
                          } else {
                            // Insertar el evento en la base de datos
                            await DatabaseManager.insertTareaSeleccionada(
                                widget.consultorioId!, tarea);

                            await Future.delayed(
                                const Duration(milliseconds: 1500));
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
                              content: Text(
                                  'Cita programada agregada correctamente'),
                            ),
                          );
                        }
                      },
                      child: const Text('Guardar Cita Seleccionada'),
                    ),
                  ],
                ))));
  }
}
