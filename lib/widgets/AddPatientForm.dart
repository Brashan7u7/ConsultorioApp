import 'package:calendario_manik/pages/add_page.dart';
import 'package:calendario_manik/variab.dart';
import 'package:flutter/material.dart';
import 'package:calendario_manik/database/database.dart';

class AddPatientForm extends StatefulWidget {
  final Function(Map<String, dynamic>) onPatientAdded;
  final int consultorioId;
  final String nombres;

  const AddPatientForm(
      {super.key,
      required this.onPatientAdded,
      required this.consultorioId,
      required this.nombres});

  @override
  _AddPatientFormState createState() => _AddPatientFormState();
}

class _AddPatientFormState extends State<AddPatientForm> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  List<Map<String, dynamic>> suggestedPatients = [];

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
      List<Map<String, dynamic>> patients =
          await DatabaseManager.searchPatients(query, widget.consultorioId);
      setState(() {
        suggestedPatients = patients;
      });
    } else {
      setState(() {
        suggestedPatients = [];
      });
    }
  }

  void _addPatient() {
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
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(1.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: TextFormField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Ingrese el nombre del ${widget.nombres}',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'El nombre del paciente es obligatorio';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                if (crearPacientes)
                  IconButton(
                    onPressed: _addPatient,
                    icon: const Icon(Icons.group_add),
                    tooltip: 'Agregar paciente',
                  ),
              ],
            ),
            if (suggestedPatients.isNotEmpty)
              ListView.builder(
                shrinkWrap: true,
                itemCount: suggestedPatients.length,
                itemBuilder: (context, index) {
                  var patient = suggestedPatients[index];
                  return ListTile(
                    title: Text(patient['nombre']),
                    onTap: () {
                      nameController.text = patient['nombre'];
                      widget.onPatientAdded(patient);
                      setState(() {
                        suggestedPatients = [];
                      });
                    },
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
