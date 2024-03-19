import 'package:flutter/material.dart';

class Consultorio {
  final String nombre;
  final String especialidad;
  final String direccion;
  final String telefono;
  final String horario;

  const Consultorio({
    required this.nombre,
    required this.especialidad,
    required this.direccion,
    required this.telefono,
    required this.horario,
  });
}

List<Consultorio> consultorios = []; // Definición de la lista consultorios

class Consulting extends StatefulWidget {
  const Consulting({Key? key}) : super(key: key);

  @override
  State<Consulting> createState() => _ConsultingState();
}

class _ConsultingState extends State<Consulting> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Consultorios'),
      ),
      body: ListView.builder(
        itemCount: consultorios.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(consultorios[index].nombre),
            subtitle: Text(consultorios[index].especialidad),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ConsultorioDetallePage(
                    consultorio: consultorios[index],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ConsultorioNuevoPage(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class ConsultorioDetallePage extends StatefulWidget {
  const ConsultorioDetallePage({Key? key, required this.consultorio})
      : super(key: key);

  final Consultorio consultorio;

  @override
  State<ConsultorioDetallePage> createState() => _ConsultorioDetallePageState();
}

class _ConsultorioDetallePageState extends State<ConsultorioDetallePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.consultorio.nombre),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Especialidad'),
            subtitle: Text(widget.consultorio.especialidad),
          ),
          ListTile(
            title: const Text('Dirección'),
            subtitle: Text(widget.consultorio.direccion),
          ),
          ListTile(
            title: const Text('Teléfono'),
            subtitle: Text(widget.consultorio.telefono),
          ),
          ListTile(
            title: const Text('Horario'),
            subtitle: Text(widget.consultorio.horario),
          ),
          SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              // TODO: Editar consultorio
            },
            icon: Icon(Icons.edit),
            label: Text('Editar'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pop(context); // Regresar a la página anterior
        },
        child: const Icon(Icons.arrow_back),
      ),
    );
  }
}

class ConsultorioNuevoPage extends StatefulWidget {
  const ConsultorioNuevoPage({Key? key}) : super(key: key);

  @override
  State<ConsultorioNuevoPage> createState() => _ConsultorioNuevoPageState();
}

class _ConsultorioNuevoPageState extends State<ConsultorioNuevoPage> {
  final _formKey = GlobalKey<FormState>();

  final _nombreController = TextEditingController();
  final _especialidadController = TextEditingController();
  final _direccionController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _horarioController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuevo Consultorio'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ingresa los datos del nuevo consultorio:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El nombre es obligatorio';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _especialidadController,
                decoration: const InputDecoration(
                  labelText: 'Especialidad',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'La especialidad es obligatoria';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _direccionController,
                decoration: const InputDecoration(
                  labelText: 'Dirección',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'La dirección es obligatoria';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _telefonoController,
                decoration: const InputDecoration(
                  labelText: 'Teléfono',
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El teléfono es obligatorio';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _horarioController,
                decoration: const InputDecoration(
                  labelText: 'Horario',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El horario es obligatorio';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final nuevoConsultorio = Consultorio(
                      nombre: _nombreController.text,
                      especialidad: _especialidadController.text,
                      direccion: _direccionController.text,
                      telefono: _telefonoController.text,
                      horario: _horarioController.text,
                    );
                    // Agregar el nuevo consultorio a la lista
                    setState(() {
                      consultorios.add(nuevoConsultorio);
                    });
                    // Mostrar mensaje de éxito
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Consultorio agregado con éxito'),
                      ),
                    );
                    // Limpiar los campos del formulario
                    _nombreController.clear();
                    _especialidadController.clear();
                    _direccionController.clear();
                    _telefonoController.clear();
                    _horarioController.clear();
                  }
                },
                child: const Text('Guardar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
