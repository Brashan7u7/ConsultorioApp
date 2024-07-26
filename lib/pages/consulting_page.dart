import 'package:calendario_manik/database/database.dart';
import 'package:calendario_manik/pages/calendar_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:calendario_manik/variab.dart';

class Consulting extends StatefulWidget {
  const Consulting({
    super.key,
  });

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

  Map<String, List<int>> occupiedButtonsByDay = {};
  Map<String, List<int>> freeButtonsByDay = {};

  bool camposvacios = false;

  List<Map<String, dynamic>> consultoriosData = [];

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
    _loadHorarios();
  }

  Future<void> _loadHorarios() async {
    Map<String, List<String>> horariosString =
        await DatabaseManager.getHorarios();

    Map<String, List<String>> horariosLibresPorDia = {};
    Map<String, List<String>> horariosOcupadosPorDia = {};

    setState(() {
      selectedButtonsByDay.clear();
      occupiedButtonsByDay.clear();
      freeButtonsByDay.clear();

      for (String day in daysOfWeek) {
        List<String> horariosOcupados = horariosString[day] ?? [];
        List<int> occupiedIndexes = [];
        List<int> freeIndexes = [];

        for (String horario in horariosOcupados) {
          int startHour = int.parse(horario.split('-')[0].split(':')[0]);
          int startMinute = int.parse(horario.split('-')[0].split(':')[1]);
          int startMinutes = startHour * 60 + startMinute;

          int buttonIndex = startMinutes ~/ selectedInterval;
          occupiedIndexes.add(buttonIndex);
        }

        List<int> allIndexes = List.generate((20 - 8) * 60 ~/ selectedInterval,
            (index) => index + 8 * 60 ~/ selectedInterval);
        freeIndexes = allIndexes
            .where((index) => !occupiedIndexes.contains(index))
            .toList();

        selectedButtonsByDay[day] = freeIndexes;
        occupiedButtonsByDay[day] = occupiedIndexes;

        List<String> freeTimes = freeIndexes.map((index) {
          int startMinute = index * selectedInterval;
          int endMinute = (index + 1) * selectedInterval - 1;
          String startTime =
              '${(startMinute ~/ 60).toString().padLeft(2, '0')}:${(startMinute % 60).toString().padLeft(2, '0')}';
          String endTime =
              '${(endMinute ~/ 60).toString().padLeft(2, '0')}:${(endMinute % 60).toString().padLeft(2, '0')}';
          return '$startTime-$endTime';
        }).toList();

        List<String> occupiedTimes = occupiedIndexes.map((index) {
          int startMinute = index * selectedInterval;
          int endMinute = (index + 1) * selectedInterval - 1;
          String startTime =
              '${(startMinute ~/ 60).toString().padLeft(2, '0')}:${(startMinute % 60).toString().padLeft(2, '0')}';
          String endTime =
              '${(endMinute ~/ 60).toString().padLeft(2, '0')}:${(endMinute % 60).toString().padLeft(2, '0')}';
          return '$startTime-$endTime';
        }).toList();

        horariosLibresPorDia[day] = freeTimes;
        horariosOcupadosPorDia[day] = occupiedTimes;
      }
    });
  }

  Future<void> _loadConsultorios() async {
    List<Consultorio> consultoriosList = [];
    if (usuario_rol == 'MED') {
      consultoriosData = await DatabaseManager.getConsultoriosData(usuario_id);
    }
    if (usuario_rol == 'ASI' || usuario_rol == 'ENF') {
      consultoriosData =
          await DatabaseManager.getConsultoriosData_id(usuario_id);
    }
    if (usuario_cuenta_id == 3) {
      consultoriosList = consultoriosData
          .map((data) => Consultorio(
                grupo_nombre: data['grupo_nombre'],
                id: data['id'],
                nombre: data['nombre'],
              ))
          .toList();
    } else {
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
    }
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
      occupiedButtonsByDay.clear();
      freeButtonsByDay.clear();
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
    await DatabaseManager.deleteConsultorio(consultorioId);

    // Limpia los campos del formulario
    _limpiarFormulario();
    showDeleteButton = false;
  }

  _showConfirmationDialog(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar consultorio'),
        content: const Text('¿Estás seguro de eliminar este consultorio?'),
        actions: [
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            child: const Text('Eliminar'),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Mis Consultorios'),
        leading: IconButton(
          icon: const Icon(Icons.close), // Icono de X
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const Calendar()),
            );
          },
        ),
        actions: [
          if (showDeleteButton)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
                bool confirmDelete = await _showConfirmationDialog(context);
                if (confirmDelete) {
                  _eliminarConsultorio(selectedConsultorio!.id!);

                  await Future.delayed(const Duration(milliseconds: 1500));

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const Calendar()),
                  );
                }
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
                    hint:
                        const Text('Seleccione un consultorio para modificar'),
                    items: consultorios.map((consultorio) {
                      return DropdownMenuItem<Consultorio>(
                        value: consultorio,
                        child: Text(consultorio.nombre!),
                      );
                    }).toList(),
                    onChanged: (value) async {
                      setState(() {
                        selectedConsultorio = value;
                        showDeleteButton = true;
                        if (selectedConsultorio != null) {
                          _nombreController.text = selectedConsultorio!.nombre!;
                          _telefonoController.text =
                              selectedConsultorio!.telefono!;
                          _calleController.text =
                              selectedConsultorio!.direccion!;
                          _codigoPostalController.text =
                              selectedConsultorio!.codigoPostal.toString();
                          selectedInterval =
                              selectedConsultorio!.intervaloAtencion!;
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
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Por favor ingresa el nombre del consultorio';
                    }
                    return null; // retorna null si la validación es exitosa
                  },
                ),
                TextFormField(
                  controller: _telefonoController,
                  decoration: const InputDecoration(
                    labelText: 'Teléfono Fijo',
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly
                  ], // solo acepta numeros
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Por favor ingresa el teléfono';
                    } else if (value.length < 7) {
                      return 'El teléfono debe tener al menos 7 dígitos';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _calleController,
                  decoration: const InputDecoration(
                    labelText: 'Calle y Número',
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Por favor ingresa la calle y número';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _codigoPostalController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Código Postal',
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly
                  ], // solo acepta numeros
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Por favor ingresa el código postal';
                    } else {
                      // Validación específica para asegurarse de que el código postal tenga la longitud adecuada
                      if (value.length != 5) {
                        return 'El código postal debe tener 5 dígitos';
                      }
                    }
                    return null;
                  },
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
                const Text('Selecciona un día de la semana:'),
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
                const Text('Horarios de atención'),
                _buildTimeIntervals(), // Llama al método para generar los intervalos de tiempo
                if (hasConsultorios) const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () async {
                    _guardarConsultorio();

                    if (camposvacios != true) {
                      await Future.delayed(const Duration(milliseconds: 1500));

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const Calendar()),
                      );
                    }
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

            bool isOccupied =
                occupiedButtonsByDay[selectedDay]?.contains(index) ?? false;
            bool isSelected =
                selectedButtonsByDay[selectedDay]?.contains(index) ?? false;

            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: isOccupied
                      ? null // Deshabilita el botón si está ocupado
                      : () {
                          setState(() {
                            if (isSelected) {
                              selectedButtonsByDay[selectedDay]!.remove(index);
                            } else {
                              selectedButtonsByDay[selectedDay]!.add(index);
                            }
                          });
                        },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.resolveWith<Color?>(
                      (Set<MaterialState> states) {
                        if (isOccupied) {
                          return Colors.grey[200];
                        } else if (isSelected) {
                          return Colors.lightBlue[100];
                        } else {
                          return Colors.grey[350];
                        }
                      },
                    ),
                    foregroundColor:
                        MaterialStateProperty.all<Color>(Colors.black),
                  ),
                  child: Text(timeInterval),
                ),
                const SizedBox(width: 8.0), // Espacio entre los botones
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
    selectedDay = daysOfWeek[0];
    _loadHorarios();
  }

  void _guardarConsultorio() async {
    if (_formKey.currentState!.validate()) {
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
                if (selectedButtonsByDay.containsKey(day) &&
                    day == selectedDay) {
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
        bool existeConsultorio = consultorios.any(
            (consultorio) => consultorio.nombre == nuevoConsultorio.nombre);

        if (!existeConsultorio) {
          int consultorioId = await DatabaseManager.insertConsultorio(
              nuevoConsultorio, usuario_id);

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
                  content:
                      Text('Ya existe un consultorio con el mismo nombre.'),
                ),
              );
            });
          }
        }
      }
    } else {
      camposvacios = true;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, complete todos los campos.'),
        ),
      );
    }
  }
}

class Consultorio {
  int? id;
  String? nombre;
  String? telefono;
  String? direccion;
  int? codigoPostal;
  int? intervaloAtencion;
  String? grupo_nombre;

  Consultorio({
    this.id,
    this.nombre,
    this.telefono,
    this.direccion,
    this.codigoPostal,
    this.intervaloAtencion,
    this.grupo_nombre,
  });
}
