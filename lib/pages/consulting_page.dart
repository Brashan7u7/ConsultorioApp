import 'package:calendario_manik/database/database.dart';
import 'package:calendario_manik/pages/calendar_page.dart';
import 'package:flutter/material.dart';

class Consulting extends StatefulWidget {
  const Consulting({Key? key}) : super(key: key);

  @override
  State<Consulting> createState() => _ConsultingState();
}

class _ConsultingState extends State<Consulting> {
  final _formKey = GlobalKey<FormState>();

  final _nombreController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _calleController = TextEditingController();
  final _codigoPostalController = TextEditingController();

  int selectedInterval = 60;
  String? selectedDay;
  Map<String, List<int>> selectedButtonsByDay =
      {}; // Mapa para almacenar los botones seleccionados por día
  Consultorio? selectedConsultorio; // Consultorio seleccionado

  List<String> daysOfWeek = [
    'Lunes',
    'Martes',
    'Miércoles',
    'Jueves',
    'Viernes',
    'Sábado',
    'Domingo',
  ];

  bool hasConsultorios =
      false; // Variable para controlar si hay consultorios registrados
  List<Consultorio> consultorios = []; // Lista de consultorios

  @override
  void initState() {
    super.initState();
    _loadConsultorios();
    for (String day in daysOfWeek) {
      selectedButtonsByDay[day] = [];
      if (day != 'Domingo') {
        selectedButtonsByDay[day] = List.generate(
            (20 - 8) * 60 ~/ selectedInterval,
            (index) => index + 8 * 60 ~/ selectedInterval);
      }
    }
    selectedDay = daysOfWeek[0];
  }

  Future<void> _loadConsultorios() async {
    List<Consultorio> consultoriosList = [];
    List<Map<String, dynamic>> consultoriosData =
        await DatabaseManager.getConsultoriosData();
    consultoriosList = consultoriosData
        .map((data) => Consultorio(
              id: data['id'],
              nombre: data['nombre'].toString(),
              telefono: data['telefono'].toString(),
              direccion: data['direccion'].toString(),
              codigoPostal: int.parse(data['colonia_id'].toString()),
              intervaloAtencion: int.parse(data['intervalo'].toString()),
            ))
        .toList();
    setState(() {
      hasConsultorios = consultoriosList.isNotEmpty;
      consultorios = consultoriosList;
    });
  }

  Future<void> _loadHorariosConsultorios(id) async {
    Map<String, List<String>> horariosString =
        await DatabaseManager.getHorarioConsultorio(id);

    setState(() {
      // Limpiamos los botones seleccionados por día para actualizarlos
      selectedButtonsByDay.clear();
      // Recorremos los horarios obtenidos
      for (String day in horariosString.keys) {
        List<String> horarios = horariosString[day] ?? [];
        List<int> selectedIndexes = [];

        // Mapeamos cada horario a su índice de botón correspondiente
        for (String horario in horarios) {
          int startHour = int.parse(horario.split('-')[0].split(':')[0]);
          int startMinute = int.parse(horario.split('-')[0].split(':')[1]);
          int startMinutes = startHour * 60 + startMinute;

          // Calculamos el índice del botón
          int buttonIndex = startMinutes ~/ selectedInterval;
          selectedIndexes.add(buttonIndex);
        }

        // Asignamos los índices al mapa de botones seleccionados por día
        selectedButtonsByDay[day] = selectedIndexes;
      }
    });
  }

  bool showDeleteButton = false;

  void _eliminarConsultorio(int consultorioId) async {
    if (consultorioId != null) {
      await DatabaseManager.deleteConsultorio(consultorioId);

      // Limpia los campos del formulario
      _limpiarFormulario();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Mis Consultorios'),
        leading: IconButton(
          icon: Icon(Icons.close), // Icono de X
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => Calendar()),
            );
          },
        ),
        actions: [
          if (showDeleteButton)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                // Lógica para eliminar el consultorio seleccionado
              },
            ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _limpiarFormulario();
              setState(() {
                for (String day in daysOfWeek) {
                  selectedButtonsByDay[day] = [];
                  if (day != 'Domingo') {
                    selectedButtonsByDay[day] = List.generate(
                        (20 - 8) * 60 ~/ selectedInterval,
                        (index) => index + 8 * 60 ~/ selectedInterval);
                  }
                }
                selectedDay = daysOfWeek[0];
              });

              // Ocultar el botón de eliminar al hacer clic en el botón de agregar
              setState(() {
                showDeleteButton = false;
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (!hasConsultorios)
                  const Text('No hay consultorios registrados'),
                if (hasConsultorios)
                  DropdownButtonFormField<Consultorio>(
                    items: consultorios.map((consultorio) {
                      return DropdownMenuItem<Consultorio>(
                        value: consultorio,
                        child: Text(consultorio.nombre),
                      );
                    }).toList(),
                    onChanged: (value) async {
                      setState(() {
                        selectedConsultorio = value;
                        showDeleteButton = true;
                        if (selectedConsultorio != null) {
                          _nombreController.text = selectedConsultorio!.nombre;
                          _telefonoController.text =
                              selectedConsultorio!.telefono;
                          _calleController.text =
                              selectedConsultorio!.direccion;
                          _codigoPostalController.text =
                              selectedConsultorio!.codigoPostal.toString();
                          selectedInterval =
                              selectedConsultorio!.intervaloAtencion;
                        }
                        selectedDay = daysOfWeek[0];
                      });

                      if (value != null) {
                        await _loadHorariosConsultorios(
                            selectedConsultorio!.id);
                      }
                    },
                  ),
                TextFormField(
                  controller: _nombreController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre del Consultorio',
                  ),
                ),
                TextFormField(
                  controller: _telefonoController,
                  decoration: const InputDecoration(
                    labelText: 'Teléfono Fijo',
                  ),
                ),
                TextFormField(
                  controller: _calleController,
                  decoration: const InputDecoration(
                    labelText: 'Calle y Número',
                  ),
                ),
                TextFormField(
                  controller: _codigoPostalController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Código Postal',
                  ),
                ),
                DropdownButtonFormField<String>(
                  items: const [
                    DropdownMenuItem<String>(
                      value: '60',
                      child: Text('60 minutos'),
                    ),
                    DropdownMenuItem<String>(
                      value: '30',
                      child: Text('30 minutos'),
                    ),
                    DropdownMenuItem<String>(
                      value: '20',
                      child: Text('20 minutos'),
                    ),
                    DropdownMenuItem<String>(
                      value: '15',
                      child: Text('15 minutos'),
                    ),
                  ],
                  value: selectedInterval.toString(),
                  onChanged: (value) {
                    setState(() {
                      selectedInterval = int.parse(value!);
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: 'Intervalo de Atención (minutos)',
                  ),
                ),
                const SizedBox(height: 16.0),
                Text('Selecciona un día de la semana:'),
                DropdownButtonFormField<String>(
                  items: daysOfWeek.map((day) {
                    return DropdownMenuItem<String>(
                      value: day,
                      child: Text(day),
                    );
                  }).toList(),
                  value: selectedDay,
                  onChanged: (value) {
                    setState(() {
                      selectedDay = value;
                    });
                  },
                ),
                const SizedBox(height: 16.0),
                Text('Horarios de atención'),
                _buildTimeIntervals(), // Llama al método para generar los intervalos de tiempo
                if (hasConsultorios) const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () async {
                    _guardarConsultorio();

                    await Future.delayed(Duration(milliseconds: 1500));

                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => Calendar()),
                    );
                  },
                  child: const Text('Guardar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeIntervals() {
    return SizedBox(
      height: 300, // Altura fija para el contenedor de los botones
      child: GridView.count(
        crossAxisCount: 2, // Dos botones por fila
        childAspectRatio: 2.5, // Relación de aspecto para los botones
        children: List.generate(
          24 * 60 ~/ selectedInterval,
          (index) {
            int startMinute = index * selectedInterval;
            int endMinute = (index + 1) * selectedInterval - 1;
            String startTime =
                '${(startMinute ~/ 60).toString().padLeft(2, '0')}:${(startMinute % 60).toString().padLeft(2, '0')}';
            String endTime =
                '${(endMinute ~/ 60).toString().padLeft(2, '0')}:${(endMinute % 60).toString().padLeft(2, '0')}';
            String timeInterval = '$startTime-$endTime';

            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      if (selectedButtonsByDay.containsKey(selectedDay)) {
                        if (selectedButtonsByDay[selectedDay]!
                            .contains(index)) {
                          selectedButtonsByDay[selectedDay]!.remove(index);
                        } else {
                          selectedButtonsByDay[selectedDay]!.add(index);
                        }
                      } else {
                        selectedButtonsByDay[selectedDay!] = [index];
                      }
                    });
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.resolveWith<Color?>(
                      (Set<MaterialState> states) {
                        return selectedButtonsByDay.containsKey(selectedDay) &&
                                selectedButtonsByDay[selectedDay]!
                                    .contains(index)
                            ? Colors.lightGreenAccent
                            : Colors.grey[300];
                      },
                    ),
                    foregroundColor:
                        MaterialStateProperty.all<Color>(Colors.black),
                  ),
                  child: Text(timeInterval),
                ),
                SizedBox(width: 8.0), // Espacio entre los botones
              ],
            );
          },
        ),
      ),
    );
  }

  void _limpiarFormulario() {
    _nombreController.clear();
    _telefonoController.clear();
    _calleController.clear();
    _codigoPostalController.clear();
    selectedInterval = 60;
    selectedDay = null;
    selectedConsultorio = null;
  }

  void _guardarConsultorio() async {
    if (selectedConsultorio != null) {
      if (mounted) {
        setState(() {
          // Si hay un consultorio seleccionado, se actualiza en lugar de agregar uno nuevo
          setState(() {
            selectedConsultorio!.nombre = _nombreController.text;
            selectedConsultorio!.telefono = _telefonoController.text;
            selectedConsultorio!.direccion = _calleController.text;
            selectedConsultorio!.codigoPostal =
                int.tryParse(_codigoPostalController.text) ?? 0;
            selectedConsultorio!.intervaloAtencion = selectedInterval;

            DatabaseManager.updateConsultorio(selectedConsultorio!);

            Map<String, String> horariosSeleccionados = {};
            for (String day in daysOfWeek) {
              if (selectedButtonsByDay.containsKey(day) && day == selectedDay) {
                List<int> buttonsPressed = selectedButtonsByDay[day]!;
                String horariosStr = buttonsPressed.map((index) {
                  int startMinute = index * selectedInterval;
                  int endMinute = (index + 1) * selectedInterval - 1;
                  String startTime =
                      '${(startMinute ~/ 60).toString().padLeft(2, '0')}:${(startMinute % 60).toString().padLeft(2, '0')}';
                  String endTime =
                      '${(endMinute ~/ 60).toString().padLeft(2, '0')}:${(endMinute % 60).toString().padLeft(2, '0')}';
                  return '$startTime-$endTime';
                }).join(',');
                horariosSeleccionados[day] = horariosStr;
              } else if (selectedButtonsByDay.containsKey(day)) {
                List<int> buttonsPressed = selectedButtonsByDay[day]!;
                String horariosStr = buttonsPressed.map((index) {
                  int startMinute = index * selectedInterval;
                  int endMinute = (index + 1) * selectedInterval - 1;
                  String startTime =
                      '${(startMinute ~/ 60).toString().padLeft(2, '0')}:${(startMinute % 60).toString().padLeft(2, '0')}';
                  String endTime =
                      '${(endMinute ~/ 60).toString().padLeft(2, '0')}:${(endMinute % 60).toString().padLeft(2, '0')}';
                  return '$startTime-$endTime';
                }).join(',');
                horariosSeleccionados[day] = horariosStr;
              }
            }

            DatabaseManager.updateHorarioConsultorio(
              selectedConsultorio!.id!,
              horariosSeleccionados['Lunes'] ?? "",
              horariosSeleccionados['Martes'] ?? "",
              horariosSeleccionados['Miércoles'] ?? "",
              horariosSeleccionados['Jueves'] ?? "",
              horariosSeleccionados['Viernes'] ?? "",
              horariosSeleccionados['Sábado'] ?? "",
              horariosSeleccionados['Domingo'] ?? "",
            );
          });
        });
      }
    } else {
      final nuevoConsultorio = Consultorio(
        nombre: _nombreController.text,
        telefono: _telefonoController.text,
        direccion: _calleController.text,
        codigoPostal: int.tryParse(_codigoPostalController.text) ?? 0,
        intervaloAtencion: selectedInterval,
      );

      if (mounted) {
        setState(() {
          // Clear the form fields
          _nombreController.clear();
          _telefonoController.clear();
          _calleController.clear();
          _codigoPostalController.clear();
          selectedInterval = 60;
          selectedDay = null;
          selectedConsultorio = null;
        });
      }
      bool existeConsultorio = consultorios
          .any((consultorio) => consultorio.nombre == nuevoConsultorio.nombre);

      if (!existeConsultorio) {
        int consultorioId =
            await DatabaseManager.insertConsultorio(nuevoConsultorio);

        Map<String, String> horariosSeleccionados = {};
        for (String day in daysOfWeek) {
          if (selectedButtonsByDay.containsKey(day)) {
            List<int> buttonsPressed = selectedButtonsByDay[day]!;
            String horariosStr = buttonsPressed.map((index) {
              int startMinute = index * selectedInterval;
              int endMinute = (index + 1) * selectedInterval - 1;
              String startTime =
                  '${(startMinute ~/ 60).toString().padLeft(2, '0')}:${(startMinute % 60).toString().padLeft(2, '0')}';
              String endTime =
                  '${(endMinute ~/ 60).toString().padLeft(2, '0')}:${(endMinute % 60).toString().padLeft(2, '0')}';
              return '$startTime-$endTime';
            }).join(',');
            horariosSeleccionados[day] = horariosStr;
          }
        }

        DatabaseManager.insertHorarioConsultorio(
          consultorioId,
          horariosSeleccionados['Lunes'] ?? '',
          horariosSeleccionados['Martes'] ?? '',
          horariosSeleccionados['Miércoles'] ?? '',
          horariosSeleccionados['Jueves'] ?? '',
          horariosSeleccionados['Viernes'] ?? '',
          horariosSeleccionados['Sábado'] ?? '',
          horariosSeleccionados['Domingo'] ?? '',
        );

        if (mounted) {
          setState(() {
            // Add the new consultorio to the list
            consultorios.add(nuevoConsultorio);
            hasConsultorios = true;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            // Show an error message
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Ya existe un consultorio con el mismo nombre.'),
              ),
            );
          });
        }
      }
    }
  }
}

class Consultorio {
  int? id;
  String nombre;
  String telefono;
  String direccion;
  int codigoPostal;
  int intervaloAtencion;

  Consultorio({
    this.id,
    required this.nombre,
    required this.telefono,
    required this.direccion,
    required this.codigoPostal,
    required this.intervaloAtencion,
  });
}
