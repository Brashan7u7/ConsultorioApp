import 'package:flutter/material.dart';
import 'package:calendario_manik/pages/patients_page.dart';

class Add extends StatelessWidget {
  final bool isCitaRapida, isEvento, isPacient;

  const Add({
    Key? key,
    required this.isCitaRapida,
    this.isEvento = false,
    this.isPacient = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextEditingController _nameController = TextEditingController();
    TextEditingController _lastnameController = TextEditingController();
    TextEditingController _phoneController = TextEditingController();
    TextEditingController _symptomsController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: Text(isCitaRapida
            ? "Cita Rápida"
            : isEvento
                ? 'Evento'
                : isPacient
                    ? "Registrar Paciente"
                    : "Cita Programada"),
      ),
      body: isCitaRapida
          ? _buildCitaRapidaContent()
          : isEvento
              ? _buildEventoContent()
              : isPacient
                  ? _buildPacientContent(
                      context,
                      _nameController,
                      _lastnameController,
                      _phoneController,
                      _symptomsController)
                  : _buildCitaProgramadaContent(),
    );
  }

  Widget _buildCitaRapidaContent() {
    return Center(
      child: Text("Contenido para Cita Rápida"),
    );
  }

  Widget _buildCitaProgramadaContent() {
    return Center(
      child: Text("Contenido para Cita Programada"),
    );
  }

  Widget _buildEventoContent() {
    return Center(
      child: Text("Contenido para Evento"),
    );
  }

  Widget _buildPacientContent(
      BuildContext context,
      TextEditingController nameController,
      TextEditingController lastnameController,
      TextEditingController phoneController,
      TextEditingController symptomsController) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          TextField(
            controller: nameController,
            decoration: InputDecoration(labelText: 'Nombre'),
          ),
          TextField(
            controller: lastnameController,
            decoration: InputDecoration(labelText: 'Apellido'),
          ),
          TextField(
            controller: phoneController,
            decoration: InputDecoration(labelText: 'Teléfono'),
          ),
          TextField(
            controller: symptomsController,
            decoration: InputDecoration(labelText: 'Síntomas'),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              DataPatients newPatient = DataPatients(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                name: nameController.text,
                lastname: lastnameController.text,
                phone: phoneController.text,
                symptoms: symptomsController.text,
              );

              Navigator.pop(context, Patients(newPatient: newPatient));
            },
            child: Text('Guardar Paciente'),
          ),
        ],
      ),
    );
  }
}
