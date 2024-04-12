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
  int? selectedButtonIndex; // Índice del botón seleccionado

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
                        _nombreController.text = value!.nombre;
                        _telefonoController.text = value.telefono;
                        _calleController.text = value.direccion;
                        _codigoPostalController.text = value.codigoPostal;
                        selectedInterval = value.intervaloAtencion;
                        selectedDay = value.diaAtencion;
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
                      selectedButtonIndex =
                          index; // Actualiza el índice del botón seleccionado
                    });
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.resolveWith<Color?>(
                      (Set<MaterialState> states) {
                        // Cambia el color del botón según el estado
                        if (states.contains(MaterialState.pressed)) {
                          return Colors.green; // Color cuando se presiona
                        }
                        return selectedButtonIndex == index
                            ? Colors.green
                            : Colors.grey.withOpacity(0.6);
                        ; // Color por defecto
                      },
                    ),
                  ),
                  child: Text(
                    timeInterval,
                    style: TextStyle(
                      fontSize: 16.0, // Tamaño de fuente del texto
                      fontWeight: FontWeight.bold, // Fuente en negrita
                      color: Colors.white, // Color del texto
                    ),
                  ),
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
    selectedButtonIndex = null;
  }

  void _guardarConsultorio() {
    final nuevoConsultorio = Consultorio(
      nombre: _nombreController.text,
      telefono: _telefonoController.text,
      direccion: _calleController.text,
      codigoPostal: _codigoPostalController.text,
      intervaloAtencion: selectedInterval,
      diaAtencion: selectedDay!,
    );
    if (consultorios != null) {
      consultorios.add(nuevoConsultorio);
      setState(() {
        hasConsultorios = true;
      });
    }
  }
}

class Consultorio {
  final String nombre;
  final String telefono;
  final String direccion;
  final String codigoPostal;
  final int intervaloAtencion;
  final String diaAtencion;

  Consultorio({
    required this.nombre,
    required this.telefono,
    required this.direccion,
    required this.codigoPostal,
    required this.intervaloAtencion,
    required this.diaAtencion,
  });
}
