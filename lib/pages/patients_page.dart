import 'package:flutter/material.dart';
import 'package:calendario_manik/pages/calendar_page.dart';
import 'package:calendario_manik/pages/add_page.dart';

class Patients extends StatefulWidget {
  final String? name,
      sexo,
      genero,
      primerPat,
      segundPat,
      fechaNaci,
      correo,
      telefono;

  Patients({
    Key? key,
    this.name,
    this.sexo,
    this.genero,
    this.primerPat,
    this.segundPat,
    this.fechaNaci,
    this.correo,
    this.telefono,
  }) : super(key: key);

  @override
  State<Patients> createState() => _PatientsState();
}

class _PatientsState extends State<Patients> {
  int currentIndex = 2;
  final List<DataPatients> _allPatients = [
    DataPatients(
      id: "1",
      name: "Manuel",
      sexo: "Masculino",
      genero: "Hombre",
      primerPat: "García",
      segundPat: "",
      fechaNaci: "01/01/1990",
      correo: "manuel@example.com",
      telefono: "+52 951 123 4567",
    ),
    DataPatients(
      id: "2",
      name: "Luisa",
      sexo: "Femenino",
      genero: "Mujer",
      primerPat: "Martínez",
      segundPat: "",
      fechaNaci: "15/05/1985",
      correo: "luisa@example.com",
      telefono: "+52 951 987 6543",
    ),
    DataPatients(
      id: "3",
      name: "Juan",
      sexo: "Masculino",
      genero: "Hombre",
      primerPat: "Gómez",
      segundPat: "",
      fechaNaci: "10/10/1975",
      correo: "juan@example.com",
      telefono: "+52 951 555 1234",
    ),
    DataPatients(
      id: "4",
      name: "María",
      sexo: "Femenino",
      genero: "Mujer",
      primerPat: "López",
      segundPat: "",
      fechaNaci: "25/12/1980",
      correo: "maria@example.com",
      telefono: "+52 951 789 0123",
    ),
    DataPatients(
      id: "5",
      name: "Carlos",
      sexo: "Masculino",
      genero: "Hombre",
      primerPat: "Hernández",
      segundPat: "",
      fechaNaci: "03/07/1995",
      correo: "carlos@example.com",
      telefono: "+52 951 321 9876",
    ),
    DataPatients(
      id: "6",
      name: "Ana",
      sexo: "Femenino",
      genero: "Mujer",
      primerPat: "Sánchez",
      segundPat: "Martínez",
      fechaNaci: "12/08/1992",
      correo: "ana@example.com",
      telefono: "+52 951 456 7890",
    ),
    DataPatients(
      id: "7",
      name: "Pedro",
      sexo: "Masculino",
      genero: "Hombre",
      primerPat: "Díaz",
      segundPat: "García",
      fechaNaci: "05/04/1987",
      correo: "pedro@example.com",
      telefono: "+52 951 888 8888",
    ),
    DataPatients(
      id: "8",
      name: "Laura",
      sexo: "Femenino",
      genero: "Mujer",
      primerPat: "Ramírez",
      segundPat: "López",
      fechaNaci: "20/11/1983",
      correo: "laura@example.com",
      telefono: "+52 951 777 7777",
    ),
    DataPatients(
      id: "9",
      name: "Sofía",
      sexo: "Femenino",
      genero: "Mujer",
      primerPat: "Gutiérrez",
      segundPat: "Hernández",
      fechaNaci: "17/09/1998",
      correo: "sofia@example.com",
      telefono: "+52 951 666 6666",
    ),
    DataPatients(
      id: "10",
      name: "Miguel",
      sexo: "Masculino",
      genero: "Hombre",
      primerPat: "Pérez",
      segundPat: "Gómez",
      fechaNaci: "30/06/1979",
      correo: "miguel@example.com",
      telefono: "+52 951 999 9999",
    ),
    DataPatients(
      id: "11",
      name: "Alejandra",
      sexo: "Femenino",
      genero: "Mujer",
      primerPat: "Flores",
      segundPat: "Castillo",
      fechaNaci: "25/03/1984",
      correo: "alejandra@example.com",
      telefono: "+52 951 000 0000",
    ),
    DataPatients(
      id: "12",
      name: "Fernando",
      sexo: "Masculino",
      genero: "Hombre",
      primerPat: "Cruz",
      segundPat: "González",
      fechaNaci: "10/10/1990",
      correo: "fernando@example.com",
      telefono: "+52 951 111 1111",
    ),
    DataPatients(
      id: "13",
      name: "Paola",
      sexo: "Femenino",
      genero: "Mujer",
      primerPat: "Torres",
      segundPat: "Martínez",
      fechaNaci: "15/07/1995",
      correo: "paola@example.com",
      telefono: "+52 951 222 2222",
    ),
    DataPatients(
      id: "14",
      name: "Eduardo",
      sexo: "Masculino",
      genero: "Hombre",
      primerPat: "Castillo",
      segundPat: "López",
      fechaNaci: "02/12/1988",
      correo: "eduardo@example.com",
      telefono: "+52 951 333 3333",
    ),
    DataPatients(
      id: "15",
      name: "Gabriela",
      sexo: "Femenino",
      genero: "Mujer",
      primerPat: "Luna",
      segundPat: "Sánchez",
      fechaNaci: "20/05/1993",
      correo: "gabriela@example.com",
      telefono: "+52 951 444 4444",
    ),
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
                        "${_filteredPatients[index].name} ${_filteredPatients[index].primerPat}"),
                    subtitle: Text(_filteredPatients[index].telefono),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.arrow_forward_ios),
                          onPressed: () {
                            _viewPatient(context, _filteredPatients[index]);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            _deletePatient(_filteredPatients[index]);
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });

          if (index == 1) {
            _showRegistrarModal();
          }
          if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Calendar(),
              ),
            );
          }
          if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Patients(),
              ),
            );
          }
        },
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Calendario',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Registrar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Pacientes',
          ),
        ],
        selectedItemColor: Colors.green,
      ),
    );
  }

  void _showRegistrarModal() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (BuildContext builder) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
          ),
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(Icons.person_add),
                title: Text('Registrar Paciente'),
                onTap: () {
                  Navigator.pop(context);
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
                },
              ),
            ],
          ),
        );
      },
    );
  }

  _onSearchTextChanged(String text) {
    setState(() {
      _filteredPatients.clear();
      if (text.isEmpty) {
        _filteredPatients.addAll(_allPatients);
      } else {
        _filteredPatients.addAll(_allPatients.where((patient) =>
            patient.name.toLowerCase().contains(text.toLowerCase()) ||
            patient.primerPat.toLowerCase().contains(text.toLowerCase())));
      }
    });
  }

  _viewPatient(context, patient) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Datos de ${patient.name}"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Nombre: ${patient.name}"),
              Text("Sexo: ${patient.sexo}"),
              Text("Género: ${patient.genero}"),
              Text("Primer apellido: ${patient.primerPat}"),
              Text("Segundo apellido: ${patient.segundPat}"),
              Text("Fecha de nacimiento: ${patient.fechaNaci}"),
              Text("Correo: ${patient.correo}"),
              Text("Teléfono: ${patient.telefono}"),
            ],
          ),
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
              "¿Estás seguro de que quieres eliminar a ${patient.name} ${patient.primerPat}?"),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _allPatients.remove(patient);
                  _filteredPatients.remove(patient);
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
  String sexo;
  String genero;
  String primerPat;
  String segundPat;
  String fechaNaci;
  String correo;
  String telefono;

  DataPatients({
    required this.id,
    required this.name,
    required this.sexo,
    required this.genero,
    required this.primerPat,
    required this.segundPat,
    required this.fechaNaci,
    required this.correo,
    required this.telefono,
  });
}
