import 'package:calendario_manik/database/database.dart';
import 'package:calendario_manik/models/tarea.dart';
import 'package:calendario_manik/pages/add_page.dart';
import 'package:calendario_manik/pages/calendar_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:intl/intl.dart';

import 'package:calendario_manik/variab.dart';

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

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
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
                        if (crearPacientes)
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: _openAddPatientPage,
                            tooltip: 'Agregar paciente',
                          ),
                      ],
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
                    const SizedBox(height: 20.0),
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
                          );

                          // Insertar el evento en la base de datos
                          await DatabaseManager.insertTareaSeleccionada(
                              widget.consultorioId!, tarea);

                          // Mostrar mensaje de éxito o redireccionar a otra pantalla si es necesario
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Cita programada agregada correctamente'),
                            ),
                          );

                          // Opcional: Redirigir a la página de calendario u otra página relevante
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => Calendar()),
                          );
                        }
                      },
                      child: const Text('Guardar Cita Seleccionada'),
                    ),
                  ],
                ))));
  }
}
