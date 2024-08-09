import 'package:calendario_manik/variab.dart';
import 'package:flutter/material.dart';
import 'package:calendario_manik/database/database.dart';
import 'package:calendario_manik/models/doctor.dart';

class EditingCita extends StatefulWidget {
  const EditingCita({super.key});

  @override
  _EditingCitaState createState() => _EditingCitaState();
}

class _EditingCitaState extends State<EditingCita> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController doctorController = TextEditingController();

  List<Doctor> doctores = [];
  int doctorId = 0;
  Doctor? selectedDoctor;

  @override
  void initState() {
    super.initState();
    if (usuario_cuenta_id == 3 && usuario_rol != 'MED') _fetchDoctores();
  }

  @override
  void dispose() {
    super.dispose();
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
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
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
              const SizedBox(height: 20.0),
            ])),
      ),
    );
  }
}
