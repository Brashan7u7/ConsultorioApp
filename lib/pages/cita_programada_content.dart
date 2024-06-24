import 'package:calendario_manik/database/database.dart';
import 'package:calendario_manik/models/evento.dart';
import 'package:flutter/material.dart';
import 'package:calendario_manik/pages/add_page.dart';
import 'package:calendario_manik/pages/calendar_page.dart';
import 'package:intl/intl.dart';
import 'package:flutter_switch/flutter_switch.dart';

class CitaProgramadaContent extends StatefulWidget {
  final int? usuario_id, consultorioId;

  CitaProgramadaContent({Key? key, this.usuario_id, this.consultorioId})
      : super(key: key);

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
  String? _recommendedDate, fechaRecomenGuar;
  String? _recommendedTime;

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

  Future<void> _getRecommendedDateTime() async {
    List<Map<String, dynamic>> recommendations =
        await DatabaseManager.getRecomeDiaria();
    if (recommendations.isNotEmpty) {
      DateTime fecha = DateTime.parse(recommendations[0]['fecha']);
      String hora = recommendations[0]['hora'];
      setState(() {
        _recommendedDate = DateFormat('dd/MM/yyyy').format(fecha);
        fechaRecomenGuar = DateFormat('yyyy-MM-dd').format(fecha);
        _recommendedTime = hora; // No need to parse, just assign the value
      });
    }
  }

  Future<void> _getRecommendedDateTimeSemanal() async {
    List<Map<String, dynamic>> recommendations =
        await DatabaseManager.getRecomeSema();
    if (recommendations.isNotEmpty) {
      DateTime fecha = DateTime.parse(recommendations[0]['fecha']);
      String hora = recommendations[0]['hora'];
      setState(() {
        _recommendedDate = DateFormat('dd/MM/yyyy').format(fecha);
        fechaRecomenGuar = DateFormat('yyyy-MM-dd').format(fecha);
        _recommendedTime = hora; // No need to parse, just assign the value
      });
    }
  }

  Future<void> _getRecommendedDateTimeMen() async {
    List<Map<String, dynamic>> recommendations =
        await DatabaseManager.getRecomeMen();
    if (recommendations.isNotEmpty) {
      DateTime fecha = DateTime.parse(recommendations[0]['fecha']);
      String hora = recommendations[0]['hora'];
      setState(() {
        _recommendedDate = DateFormat('dd/MM/yyyy').format(fecha);
        fechaRecomenGuar = DateFormat('yyyy-MM-dd').format(fecha);
        _recommendedTime = hora; // No need to parse, just assign the value
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
                    selectedInterval = int.parse(value!);
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
                onChanged: (value) async {
                  servicioController.text = value!;
                  if (value == 'Opción 1') {
                    await _getRecommendedDateTime();
                  } else if (value == 'Opción 2') {
                    await _getRecommendedDateTimeSemanal();
                  } else if (value == 'Opción 3') {
                    await _getRecommendedDateTimeMen();
                  }
                },
              ),
              SizedBox(height: 20.0),
              Text(
                'Fecha y hora por registrar:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Fecha: ${_recommendedDate ?? ''}'),
                  Text('Hora: ${_recommendedTime ?? ''}'),
                ],
              ),
              SizedBox(height: 20.0),
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
                    String? fecha = fechaRecomenGuar;
                    String? hora = _recommendedTime;
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
                      SnackBar(
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
