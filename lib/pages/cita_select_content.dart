import 'package:calendario_manik/database/database.dart';
import 'package:calendario_manik/models/tarea.dart';
import 'package:calendario_manik/pages/add_page.dart';
import 'package:calendario_manik/pages/calendar_page.dart';
import 'package:calendario_manik/widgets/ConsultaInfoForm.dart';
import 'package:calendario_manik/widgets/IntervalDropdownSelector.dart';
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

  const CitaSelectContent(
      {super.key,
      required this.fechaController,
      required this.horaController,
      this.consultorioId});

  @override
  _CitaSelectContentState createState() => _CitaSelectContentState();
}

class _CitaSelectContentState extends State<CitaSelectContent> {
  int selectedInterval = 60;
  final TextEditingController nameController = TextEditingController();
  String valor = "Consulta";
  TextEditingController notaController = TextEditingController(text: "");
  bool status = false;

  bool espera = false;

  final _formKey = GlobalKey<FormState>();

  List<Doctor> doctores = [];
  int doctorId = 0;
  Doctor? selectedDoctor;
  Paciente? selectedPaciente;

  int pacienteId = 0;
  String nombres = 'paciente';

  String _fechaGuardada = '';
  String _horaGuardada = '';

  @override
  void initState() {
    super.initState();
    if (usuario_cuenta_id == 3 && usuario_rol != 'MED') _fetchDoctores();
    if (usuario_rol == 'MED') doctorId = usuario_id;
    _fechaGuardada = widget.fechaController.text;
    _horaGuardada = widget.horaController.text;
  }

  void _handleEsperaChanged(bool newValue) {
    setState(() {
      espera = newValue;

      if (espera) {
        // Guarda los valores actuales
        _fechaGuardada = widget.fechaController.text;
        _horaGuardada = widget.horaController.text;

        // Limpia los campos de fecha y hora
        widget.fechaController.clear();
        widget.horaController.clear();
      } else {
        // Restaura los valores guardados
        widget.fechaController.text = _fechaGuardada;
        widget.horaController.text = _horaGuardada;
      }
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

  TextEditingController motivoConsultaController =
      TextEditingController(text: "");
  TextEditingController tipoCitaController = TextEditingController(text: "");

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
                      Container(
                        child: Column(
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
                      ),
                    const SizedBox(height: 20.0),
                    TextFormField(
                      controller: widget.fechaController,
                      readOnly: !espera,
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
                            firstDate: DateTime.now()
                                .subtract(const Duration(days: 365)),
                            lastDate:
                                DateTime.now().add(const Duration(days: 365)),
                          );
                          if (selectedDate != null) {
                            widget.fechaController.text =
                                DateFormat('yyyy-MM-dd').format(selectedDate);
                          }
                        }
                      },
                    ),
                    const SizedBox(height: 20.0),
                    TextFormField(
                      controller: widget.horaController,
                      readOnly: !espera,
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
                            widget.horaController.text = formattedTime;
                          }
                        }
                      },
                    ),
                    const IntervalDropdownSelector(),
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
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      ConsultaInfoForm(
                        notaController: notaController,
                        onEsperaChanged: _handleEsperaChanged,
                      ),
                    ],
                    const SizedBox(height: 20.0),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Colors.blue, // Color de fondo del botón
                        foregroundColor:
                            Colors.white, // Color del texto del botón
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              10), // Radio de esquinas redondeadas
                          side: BorderSide(
                              width: 1, color: Colors.grey), // Borde del botón
                        ),
                      ),
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
                          String motivoConsulta =
                              valor; // Assign the value from the DropdownButton
                          String tipoCita =
                              status ? "Subsecuente" : "Primera vez";

                          // Crear el objeto Evento
                          Tarea tarea = Tarea(
                            nombre: nombre,
                            fecha: fecha,
                            hora: hora,
                            duracion: duracion,
                            servicio: servicio,
                            nota: nota,
                            asignado_id: doctorId,
                            paciente_id: pacienteId,
                            motivoConsulta: motivoConsulta,
                            tipoCita: tipoCita,
                          );

                          if (espera) {
                            print(espera);
                            // Redirige a la página de lista de espera si la opción está activada
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ListaEspera(),
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
