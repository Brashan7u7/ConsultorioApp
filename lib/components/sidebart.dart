import 'package:flutter/material.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({Key? key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // logo
          DrawerHeader(
            child: Image.asset('lib/images/usuario.png'),
            padding: EdgeInsets.symmetric(horizontal: 80),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 50.0),
            child: Divider(
              color: Colors.red,
            ),
          ),

          const Padding(
            padding: EdgeInsets.only(left: 25.0),
            child: ListTile(
              leading: Icon(
                Icons.announcement,
              ),
              title: Text(
                'Pacientes esperando',
              ),
            ),
          ),

          // Opción de horario que navega a la página de consultorios
          ListTile(
            contentPadding: EdgeInsets.only(left: 25.0),
            leading: Icon(
              Icons.access_alarm,
            ),
            title: Text(
              'Horario',
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ConsultorioPage(), // Nueva página de consultorios
                ),
              );
            },
          ),
          const Spacer(),
          const Padding(
            padding: EdgeInsets.only(left: 25.0, bottom: 25),
            child: ListTile(
              leading: Icon(
                Icons.logout,
              ),
              title: Text(
                'Cerrar Sesión',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Nueva página para agregar consultorios
class ConsultorioPage extends StatelessWidget {
  const ConsultorioPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Agregar Consultorio'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ConsultorioForm(),
      ),
    );
  }
}

// Formulario para agregar consultorios
class ConsultorioForm extends StatefulWidget {
  const ConsultorioForm({Key? key}) : super(key: key);

  @override
  _ConsultorioFormState createState() => _ConsultorioFormState();
}

class _ConsultorioFormState extends State<ConsultorioForm> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            decoration: InputDecoration(labelText: 'Nombre del Consultorio'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingrese el nombre del consultorio';
              }
              return null;
            },
          ),
          TextFormField(
            decoration: InputDecoration(labelText: 'Teléfono'),
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingrese el teléfono';
              }
              return null;
            },
          ),
          TextFormField(
            decoration: InputDecoration(labelText: 'Calle y Número'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingrese la calle y número';
              }
              return null;
            },
          ),
          TextFormField(
            decoration: InputDecoration(labelText: 'Tipo de Personal'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingrese el tipo de personal';
              }
              return null;
            },
          ),
          TextFormField(
            decoration: InputDecoration(labelText: 'Código Postal'),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingrese el código postal';
              }
              return null;
            },
          ),
          TextFormField(
            decoration: InputDecoration(labelText: 'Intervalo de Atención'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingrese el intervalo de atención';
              }
              return null;
            },
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                // Procesar los datos del formulario
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Consultorio agregado')),
                );
              }
            },
            child: Text('Agregar Consultorio'),
          ),
        ],
      ),
    );
  }
}
