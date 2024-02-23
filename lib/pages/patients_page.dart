import 'package:flutter/material.dart';

class Patients extends StatefulWidget {
  const Patients({Key? key}) : super(key: key);

  @override
  State<Patients> createState() => _PatientsState();
}

class _PatientsState extends State<Patients> {
  List<DataPatients> _patients = [
    DataPatients(
        id: "1",
        name: "Manuel",
        lastname: "Perez",
        phone: "+52 951 440 6462",
        symptoms: "Diabetes"),
    DataPatients(
        id: "2",
        name: "Vidal",
        lastname: "Jarquin",
        phone: "+52 951 983 2881",
        symptoms: "Mucha alergia"),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.symmetric(horizontal: 25),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Buscar Paciente'),
                Icon(Icons.search),
              ],
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 25),
              child: ListView.builder(
                itemCount: _patients.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    onTap: () {
                      _viewPatient(context, _patients[index]);
                    },
                    title: Text(
                        "${_patients[index].name} ${_patients[index].lastname}"),
                    subtitle: Text(_patients[index].phone),
                    leading: CircleAvatar(
                      child: Text(_patients[index].name.substring(0, 2)),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  _viewPatient(context, patient) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Datos de ${patient.name}"),
          content: Text("${patient.id} ${patient.name} ${patient.symptoms}"),
        );
      },
    );
  }
}

class DataPatients {
  String id;
  String name;
  String lastname;
  String phone;
  String symptoms;

  DataPatients(
      {required this.id,
      required this.name,
      required this.lastname,
      required this.phone,
      required this.symptoms});
}
