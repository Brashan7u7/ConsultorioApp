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
    _loadHorariosConsultorios();
    for (String day in daysOfWeek) {
      selectedButtonsByDay[day] = [];
    }
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

  Future<void> _loadHorariosConsultorios() async {
    if (selectedConsultorio != null && selectedConsultorio!.id != null) {
      Map<String, List<int>> horarios =
          await DatabaseManager.getHorarioConsultorio(selectedConsultorio!.id!);
      setState(() {
        // selectedButtonsByDay = horarios; // Esto debería ser eliminado
        for (String day in horarios.keys) {
          selectedButtonsByDay[day] = horarios[day] ?? [];
        }
      });
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
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _limpiarFormulario(); // Limpia el formulario al presionar el botón de agregar
              setState(() {
                selectedButtonsByDay.clear();
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

                        // selectedDay = value.diaAtencion;
                        // selectedButtonsByDay[selectedDay!] =
                        //     value.selectedButtonsByDay[selectedDay!] ?? [];
                      });

                      if (selectedConsultorio != null) {
                        Map<String, List<int>> horarios =
                            await DatabaseManager.getHorarioConsultorio(
                                selectedConsultorio!.id!);
                        setState(() {
                          selectedButtonsByDay = horarios;
                        });
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
                  onPressed: () {
                    _guardarConsultorio();
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
                            ? Colors.green
                            : Colors.grey; // Color por defecto
                      },
                    ),
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
      // Si hay un consultorio seleccionado, se actualiza en lugar de agregar uno nuevo

      setState(() {
        selectedConsultorio!.nombre = _nombreController.text;
        selectedConsultorio!.telefono = _telefonoController.text;
        selectedConsultorio!.direccion = _calleController.text;
        selectedConsultorio!.codigoPostal =
            int.tryParse(_codigoPostalController.text) ?? 0;
        selectedConsultorio!.intervaloAtencion = selectedInterval;

        DatabaseManager.updateConsultorio(selectedConsultorio!);

        Map<String, List<int>> horariosSeleccionados = {};
        for (String day in daysOfWeek) {
          if (selectedButtonsByDay.containsKey(day)) {
            horariosSeleccionados[day] = selectedButtonsByDay[day]!;
          }
        }

        // Map<String, String> horariosSeleccionados = {};
        // if (selectedDay != null &&
        //     selectedButtonsByDay.containsKey(selectedDay)) {
        //   List<int> buttonsPressed = selectedButtonsByDay[selectedDay]!;
        //   String horariosStr = buttonsPressed.map((index) {
        //     int startMinute = index * selectedInterval;
        //     int endMinute = (index + 1) * selectedInterval - 1;
        //     String startTime =
        //         '${(startMinute ~/ 60).toString().padLeft(2, '0')}:${(startMinute % 60).toString().padLeft(2, '0')}';
        //     String endTime =
        //         '${(endMinute ~/ 60).toString().padLeft(2, '0')}:${(endMinute % 60).toString().padLeft(2, '0')}';
        //     return '$startTime-$endTime';
        //   }).join(',');
        //   horariosSeleccionados[selectedDay!] = horariosStr;
        // }

        DatabaseManager.updateHorarioConsultorio(
          selectedConsultorio!.id!,
          horariosSeleccionados['Lunes'] ?? [],
          horariosSeleccionados['Martes'] ?? [],
          horariosSeleccionados['Miércoles'] ?? [],
          horariosSeleccionados['Jueves'] ?? [],
          horariosSeleccionados['Viernes'] ?? [],
          horariosSeleccionados['Sábado'] ?? [],
          horariosSeleccionados['Domingo'] ?? [],
        );
      });
    } else {
      // Si no hay un consultorio seleccionado, se agrega uno nuevo
      final nuevoConsultorio = Consultorio(
        nombre: _nombreController.text,
        telefono: _telefonoController.text,
        direccion: _calleController.text,
        codigoPostal: int.tryParse(_codigoPostalController.text) ?? 0,
        intervaloAtencion: selectedInterval,
        //diaAtencion: selectedDay!,
        // selectedButtonsByDay: {
        //   selectedDay!: selectedButtonsByDay[selectedDay!] ?? []
        // }, // Asocia el día seleccionado con los botones seleccionados
      );

      Map<String, List<int>> horariosSeleccionados = {};
      for (String day in daysOfWeek) {
        if (selectedButtonsByDay.containsKey(day)) {
          horariosSeleccionados[day] = selectedButtonsByDay[day]!;
        }
      }

      // Verifica si ya existe un consultorio con el mismo nombre
      bool existeConsultorio = consultorios
          .any((consultorio) => consultorio.nombre == nuevoConsultorio.nombre);

      if (existeConsultorio) {
        // Si ya existe un consultorio con el mismo nombre, muestra un mensaje o realiza otra acción
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ya existe un consultorio con el mismo nombre.'),
          ),
        );
      } else {
        // Si no existe un consultorio con el mismo nombre, agrega el nuevo consultorio a la lista
        int consultorioId =
            await DatabaseManager.insertConsultorio(nuevoConsultorio);
        setState(() {
          hasConsultorios = true;
        });

        DatabaseManager.insertHorarioConsultorio(
          consultorioId,
          horariosSeleccionados['Lunes'] ?? [],
          horariosSeleccionados['Martes'] ?? [],
          horariosSeleccionados['Miércoles'] ?? [],
          horariosSeleccionados['Jueves'] ?? [],
          horariosSeleccionados['Viernes'] ?? [],
          horariosSeleccionados['Sábado'] ?? [],
          horariosSeleccionados['Domingo'] ?? [],
        );
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
