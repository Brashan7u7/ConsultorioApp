import 'package:flutter/material.dart';
import 'package:calendario_manik/pages/calendar_page.dart';
import 'package:calendario_manik/pages/add_page.dart';
import 'package:calendario_manik/database/database.dart';

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
  List<DataPatients> _allPatients = [];
  List<DataPatients> _filteredPatients = [];
  final TextEditingController _searchController = TextEditingController();


  // @override
  // void initState() {
  //   super.initState();
  //   _fetchPatients(); // Llama a la función para obtener los pacientes desde la base de datos
  // }

  // Future<void> _fetchPatients() async {
  //   try {
  //     // Obtener los datos desde la base de datos
  //     List<Map<String, dynamic>> patientsData = await getPatients();

      
  //     List<DataPatients> patients = patientsData.map((data) {
  //       return DataPatients(
  //         id: data['id'].toString(),
  //         name: data['nombre'],
  //         sexo: data['sexo'] == 'M' ? 'Masculino' : 'Femenino',
  //         genero: data['sexo'] == 'M' ? 'Hombre' : 'Mujer',
  //         primerPat: data['apPaterno'],
  //         segundPat: data['apMaterno'],
  //         fechaNaci: data['fechaNacimiento'].toString(),
  //         correo: data['correo'],
  //         telefono: data['telefonoMovil'] ?? data['telefonoFijo'],
  //       );
  //     }).toList();

  //     // Actualizar las listas de pacientes
  //     setState(() {
  //       _allPatients = patients;
  //       _filteredPatients = patients;
  //     });
  //   } catch (e) {
  //     print('Error fetching patients: $e');
  //   }
  // }


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
                        "${_filteredPatients[index].name} ${_filteredPatients[index].primerPat} ${_filteredPatients[index].segundPat}"),
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
