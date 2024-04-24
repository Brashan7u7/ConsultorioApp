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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Consultorios'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _limpiarFormulario(); // Limpia el formulario al presionar el botón de agregar
              setState(() {
                selectedButtonsByDay
                    .clear(); // Borra todas las selecciones al presionar "+"
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
                    onChanged: (value) {
                      setState(() {
                        selectedConsultorio = value;
                        _nombreController.text = value!.nombre;
                        _telefonoController.text = value.telefono;
                        _calleController.text = value.direccion;
                        _codigoPostalController.text = value.codigoPostal;
                        selectedInterval = value.intervaloAtencion;
                        selectedDay = value.diaAtencion;
                        // Actualiza los botones seleccionados para el día del consultorio seleccionado
                        selectedButtonsByDay[selectedDay!] =
                            value.botonesSeleccionados;
                      });
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
                  decoration: const InputDecoration(
                    labelText: 'Código Postal',
                  ),
                ),
                DropdownButtonFormField<int>(
                  items: const [
                    DropdownMenuItem<int>(
                      value: 60,
                      child: Text('60 minutos'),
                    ),
                    DropdownMenuItem<int>(
                      value: 30,
                      child: Text('30 minutos'),
                    ),
                    DropdownMenuItem<int>(
                      value: 20,
                      child: Text('20 minutos'),
                    ),
                    DropdownMenuItem<int>(
                      value: 15,
                      child: Text('15 minutos'),
                    ),
                  ],
                  value: selectedInterval,
                  onChanged: (value) {
                    setState(() {
                      selectedInterval = value!;
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
                Text('Días y horarios de atención'),
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
            String timeInterval = '$startTime - $endTime';
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
                        // Cambia el color del botón según el estado
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
    selectedButtonsByDay
        .clear(); // Borra todos los botones seleccionados por día
  }

  void _guardarConsultorio() {
    if (selectedConsultorio != null) {
      // Si hay un consultorio seleccionado, se actualiza en lugar de agregar uno nuevo
      setState(() {
        selectedConsultorio!.nombre = _nombreController.text;
        selectedConsultorio!.telefono = _telefonoController.text;
        selectedConsultorio!.direccion = _calleController.text;
        selectedConsultorio!.codigoPostal = _codigoPostalController.text;
        selectedConsultorio!.intervaloAtencion = selectedInterval;
        selectedConsultorio!.diaAtencion = selectedDay!;
        selectedConsultorio!.botonesSeleccionados =
            selectedButtonsByDay[selectedDay!] ?? [];
      });
    } else {
      // Si no hay un consultorio seleccionado, se agrega uno nuevo
      final nuevoConsultorio = Consultorio(
        nombre: _nombreController.text,
        telefono: _telefonoController.text,
        direccion: _calleController.text,
        codigoPostal: _codigoPostalController.text,
        intervaloAtencion: selectedInterval,
        diaAtencion: selectedDay!,
        botonesSeleccionados: selectedButtonsByDay[selectedDay!] ?? [],
      );

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
        consultorios.add(nuevoConsultorio);
        setState(() {
          hasConsultorios = true;
        });
      }
    }
  }
}

class Consultorio {
  String nombre;
  String telefono;
  String direccion;
  String codigoPostal;
  int intervaloAtencion;
  String diaAtencion;
  List<int> botonesSeleccionados; // Índices de botones seleccionados

  Consultorio({
    required this.nombre,
    required this.telefono,
    required this.direccion,
    required this.codigoPostal,
    required this.intervaloAtencion,
    required this.diaAtencion,
    required this.botonesSeleccionados,
  });
}
