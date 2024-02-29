import 'package:flutter/material.dart';

class Patients extends StatefulWidget {
  const Patients({Key? key}) : super(key: key);

  @override
  State<Patients> createState() => _PatientsState();
}

class _PatientsState extends State<Patients> {
  final List<DataPatients> _allPatients = [
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
    // Add more patients as needed
  ];

  List<DataPatients> _filteredPatients = [];

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    _filteredPatients.addAll(_allPatients);
    super.initState();
  }

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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearchTextChanged,
                    decoration: const InputDecoration(
                      hintText: 'Buscar Paciente',
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const Icon(Icons.search),
              ],
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 25),
              child: ListView.builder(
                itemCount: _filteredPatients.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    onTap: () {
                      _viewPatient(context, _filteredPatients[index]);
                    },
                    title: Text(
                        "${_filteredPatients[index].name} ${_filteredPatients[index].lastname}"),
                    subtitle: Text(_filteredPatients[index].phone),
                    leading: CircleAvatar(
                      child:
                          Text(_filteredPatients[index].name.substring(0, 2)),
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

  _onSearchTextChanged(String text) {
    _filteredPatients.clear();
    if (text.isEmpty) {
      _filteredPatients.addAll(_allPatients);
    } else {
      _filteredPatients.addAll(_allPatients.where((patient) =>
          patient.name.toLowerCase().contains(text.toLowerCase()) ||
          patient.lastname.toLowerCase().contains(text.toLowerCase())));
    }
    setState(() {});
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

  DataPatients({
    required this.id,
    required this.name,
    required this.lastname,
    required this.phone,
    required this.symptoms,
  });
}
