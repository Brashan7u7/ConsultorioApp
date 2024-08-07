import 'package:calendario_manik/variab.dart';
import 'package:flutter/material.dart';
import 'package:calendario_manik/pages/calendar_page.dart';
import 'package:calendario_manik/pages/add_page.dart';
import 'package:calendario_manik/database/database.dart';
import 'package:intl/intl.dart';

import 'package:calendario_manik/models/datapatients.dart';

class Patients extends StatefulWidget {
  final int consultorioId;
  const Patients({
    Key? key,
    required this.consultorioId,
  }) : super(key: key);

  @override
  State<Patients> createState() => _PatientsState();
}

class _PatientsState extends State<Patients> {
  int currentIndex = 0;
  final List<DataPatients> _allPatients = [];

  List<DataPatients> _filteredPatients = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false; // Indica si los pacientes están siendo cargados
  int _patientsToLoad = 8; // Número de pacientes a cargar en cada solicitud
  int _currentOffset = 0;

  @override
  void initState() {
    _filteredPatients.addAll(_allPatients);
    super.initState();
    _loaderPacientes();
    if (crearPacientes) {
      currentIndex = 2;
    } else {
      currentIndex = 1;
    }
  }

  Future<void> _loaderPacientes({int offset = 0}) async {
    if (_isLoading) return; // Previene llamadas concurrentes
    setState(() {
      _isLoading = true;
    });
    List<Map<String, dynamic>> pacientesData =
        await DatabaseManager.getPacientes(
            widget.consultorioId, offset, _patientsToLoad);

    List<DataPatients> pacientesList = pacientesData.map((data) {
      return DataPatients(
        id: data['id'],
        name: data['nombre'] ?? '',
        sexo: data['sexo'] ?? '',
        curp: data['curp'] ?? '',
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
        codigoPostal: data['codigo_postal'] ?? 0,
      );
    }).toList();

    setState(() {
      _isLoading = false;
      if (pacientesList.isNotEmpty) {
        _allPatients.addAll(pacientesList);
        _filteredPatients = _allPatients
            .where((patient) =>
                patient.name
                    .toLowerCase()
                    .contains(_searchController.text.toLowerCase()) ||
                patient.primerPat
                    .toLowerCase()
                    .contains(_searchController.text.toLowerCase()))
            .toList();
        _currentOffset += _patientsToLoad;
      }
    });
  }

  void _loadMorePatients() {
    if (!_isLoading) {
      _loaderPacientes(offset: _currentOffset);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pacientes"),
        automaticallyImplyLeading: false,
      ),
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
              child: Stack(
                children: [
                  NotificationListener<ScrollNotification>(
                    onNotification: (scrollInfo) {
                      if (!scrollInfo.metrics.outOfRange &&
                          scrollInfo.metrics.pixels ==
                              scrollInfo.metrics.maxScrollExtent) {
                        _loadMorePatients();
                        return true;
                      }
                      return false;
                    },
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
                                icon: const Icon(Icons.arrow_forward_ios),
                                onPressed: () {
                                  _viewPatient(
                                      context, _filteredPatients[index]);
                                },
                              ),
                              if (eliminarPacientes)
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () {
                                    print(_filteredPatients[index].id);
                                    _deletePatient(_filteredPatients[index]);
                                  },
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  if (_isLoading)
                    Center(
                      child: Container(
                        color: Colors.white.withOpacity(0.8),
                        child: const CircularProgressIndicator(),
                      ),
                    ),
                ],
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

          if (index == 1 && crearPacientes) {
            _showRegistrarModal();
          }
          if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const Calendar(),
              ),
            );
          }
          if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    Patients(consultorioId: widget.consultorioId),
              ),
            );
          }
        },
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Calendario',
          ),
          if (crearPacientes)
            const BottomNavigationBarItem(
              icon: Icon(Icons.add),
              label: 'Registrar',
            ),
          const BottomNavigationBarItem(
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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (BuildContext builder) {
        return Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
          ),
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.person_add),
                title: const Text('Registrar Paciente'),
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
                          consultorioId: widget.consultorioId),
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
              Text("Curp: ${patient.curp}"),
              Text("Correo: ${patient.correo}"),
              Text("Teléfono Movil: ${patient.telefonomov}"),
              Text("Teléfono Fijo: ${patient.telefonofij}"),
              Text("Direccion: ${patient.direccion}"),
              Text("Código Postal: ${patient.codigoPostal}"),
            ],
          ),
          actions: [
            if (editarPacientes)
              TextButton(
                child: const Text('Editar Paciente'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Add(
                        isCitaInmediata: false,
                        isEvento: false,
                        isPacient: true,
                        isCitaPro: false,
                        isEditingPacient: true,
                        pacient: patient,
                        consultorioId: widget.consultorioId,
                      ),
                    ),
                  );
                },
              ),
            TextButton(
              child: const Text('Cerrar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  _deletePatient(DataPatients patient) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Eliminar Paciente"),
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
              child: const Text('Eliminar Paciente'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }
}
