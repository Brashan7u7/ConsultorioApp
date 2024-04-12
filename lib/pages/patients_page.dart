import 'package:flutter/material.dart';

class Patients extends StatefulWidget {
  final DataPatients? newPatient;

  Patients({Key? key, this.newPatient}) : super(key: key);

  @override
  State<Patients> createState() => _PatientsState();
}

class _PatientsState extends State<Patients> {
  List<DataPatients> _allPatients = [
    DataPatients(
        id: "1",
        name: "Manuel",
        lastname: "García",
        phone: "+52 951 123 4567",
        symptoms: "Dolor de cabeza"),
    DataPatients(
        id: "2",
        name: "Luisa",
        lastname: "Martínez",
        phone: "+52 951 987 6543",
        symptoms: "Fiebre alta"),
    DataPatients(
        id: "3",
        name: "Juan",
        lastname: "Gómez",
        phone: "+52 951 555 1234",
        symptoms: "Dolor de garganta"),
    DataPatients(
        id: "4",
        name: "María",
        lastname: "López",
        phone: "+52 951 789 0123",
        symptoms: "Dolor abdominal"),
    DataPatients(
        id: "5",
        name: "Carlos",
        lastname: "Hernández",
        phone: "+52 951 321 9876",
        symptoms: "Tos persistente"),
    DataPatients(
        id: "6",
        name: "Ana",
        lastname: "Sánchez",
        phone: "+52 951 456 7890",
        symptoms: "Fatiga extrema"),
    DataPatients(
        id: "7",
        name: "Pedro",
        lastname: "Díaz",
        phone: "+52 951 888 8888",
        symptoms: "Congestión nasal"),
    DataPatients(
        id: "8",
        name: "Laura",
        lastname: "Ramírez",
        phone: "+52 951 777 7777",
        symptoms: "Dificultad para respirar"),
    DataPatients(
        id: "9",
        name: "Sofía",
        lastname: "Gutiérrez",
        phone: "+52 951 666 6666",
        symptoms: "Dolor en el pecho"),
    DataPatients(
        id: "10",
        name: "Miguel",
        lastname: "Pérez",
        phone: "+52 951 999 9999",
        symptoms: "Escalofríos"),
    DataPatients(
        id: "11",
        name: "Alejandra",
        lastname: "Flores",
        phone: "+52 951 000 0000",
        symptoms: "Náuseas y vómitos"),
    DataPatients(
        id: "12",
        name: "Fernando",
        lastname: "Cruz",
        phone: "+52 951 111 1111",
        symptoms: "Dolor articular"),
    DataPatients(
        id: "13",
        name: "Paola",
        lastname: "Torres",
        phone: "+52 951 222 2222",
        symptoms: "Malestar general"),
    DataPatients(
        id: "14",
        name: "Eduardo",
        lastname: "Castillo",
        phone: "+52 951 333 3333",
        symptoms: "Urticaria"),
    DataPatients(
        id: "15",
        name: "Gabriela",
        lastname: "Luna",
        phone: "+52 951 444 4444",
        symptoms: "Dolor lumbar")
  ];
  late ScrollController _scrollController;
  List<DataPatients> _displayedPatients = [];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_scrollListener);
    _loadInitialPatients();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _loadMorePatients();
    }
  }

  _loadInitialPatients() {
    setState(() {
      _displayedPatients.addAll(_allPatients.take(10));
    });
  }

  _loadMorePatients() {
    setState(() {
      _displayedPatients.addAll(_allPatients.skip(_displayedPatients.length).take(10));
    });
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
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _displayedPatients.length + 1,
              itemBuilder: (context, index) {
                if (index == _displayedPatients.length) {
                  return _buildLoadMoreIndicator();
                } else {
                  return _buildPatientTile(_displayedPatients[index]);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadMoreIndicator() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildPatientTile(DataPatients patient) {
    return ListTile(
      onTap: () {
        _viewPatient(context, patient);
      },
      title: Text("${patient.name} ${patient.lastname}"),
      subtitle: Text(patient.phone),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(Icons.arrow_forward_ios),
            onPressed: () {
              _viewPatient(context, patient);
            },
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              _deletePatient(patient);
            },
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

  _deletePatient(DataPatients patient) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Eliminar Paciente"),
          content: Text(
              "¿Estás seguro de que quieres eliminar a ${patient.name} ${patient.lastname}?"),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _allPatients.remove(patient);
                  _displayedPatients.remove(patient);
                });
                Navigator.pop(context);
              },
              child: const Text('Sí'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('No'),
            ),
          ],
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
