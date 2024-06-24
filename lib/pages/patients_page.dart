import 'package:flutter/material.dart';
import 'package:calendario_manik/pages/calendar_page.dart';
import 'package:calendario_manik/pages/add_page.dart';
import 'package:calendario_manik/database/database.dart';
import 'package:intl/intl.dart';

class Patients extends StatefulWidget {
  final int? usuario_id;
  Patients({
    Key? key,
    this.usuario_id,
  }) : super(key: key);

  @override
  State<Patients> createState() => _PatientsState();
}

class _PatientsState extends State<Patients> {
  int currentIndex = 2;
  final List<DataPatients> _allPatients = [];

  List<DataPatients> _filteredPatients = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    _filteredPatients.addAll(_allPatients);
    super.initState();
    _loaderPacientes();
  }

  Future<void> _loaderPacientes() async {
    List<Map<String, dynamic>> pacientesData =
        await DatabaseManager.getPacientes();

    List<DataPatients> pacientesList = pacientesData.map((data) {
      return DataPatients(
        id: data['id'],
        name: data['nombre'] ?? '',
        sexo: data['sexo'] ?? '',
        primerPat: data['ap_paterno'] ?? '',
        segundPat: data['ap_materno'] ?? '',
        fechaNaci: data['fecha_nacimiento'] != null
            ? DateFormat('dd-MM-yyyy')
                .format(data['fecha_nacimiento'] as DateTime)
            : '',
        correo: data['correo'] ?? '',
        telefonomov: data['telefono_movil'] ?? '',
        telefonofij: data['telefono_fijo'] ?? '',
        direccion: data['direccion'] ?? '',
        identificador: data['identificador'] ?? '',
      );
    }).toList();

    setState(() {
      _allPatients.addAll(pacientesList);
      _filteredPatients = _allPatients;
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
                    subtitle: Text(_filteredPatients[index].telefonomov),
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
                builder: (context) => Calendar(usuario_id: widget.usuario_id),
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
              Text("Primer apellido: ${patient.primerPat}"),
              Text("Segundo apellido: ${patient.segundPat}"),
              Text("Fecha de nacimiento: ${patient.fechaNaci}"),
              Text("Correo: ${patient.correo}"),
              Text("Teléfono Movil: ${patient.telefonomov}"),
              Text("Teléfono Fijo: ${patient.telefonofij}"),
              Text("Direccion: ${patient.direccion}"),
              Text("Identificador: ${patient.identificador}"),
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
              onPressed: () async {
                await DatabaseManager.deletePaciente(patient.id);
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
  int id;
  String name;
  String sexo;
  String primerPat;
  String segundPat;
  String fechaNaci;
  String correo;
  String telefonomov;
  String telefonofij;
  String direccion;
  String identificador;

  DataPatients({
    required this.id,
    required this.name,
    required this.sexo,
    required this.primerPat,
    required this.segundPat,
    required this.fechaNaci,
    required this.correo,
    required this.telefonomov,
    required this.telefonofij,
    required this.direccion,
    required this.identificador,
  });
}
