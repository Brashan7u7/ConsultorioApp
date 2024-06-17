import 'package:calendario_manik/database/database.dart';
import 'package:calendario_manik/models/evento.dart';
import 'package:calendario_manik/pages/calendar_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Importa el paquete intl para formateo de fechas

class CitaRapidaContent extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController notaController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();

    void _saveCitaInmediata(BuildContext context) async {
      if (_formKey.currentState!.validate()) {
        // Aquí se realiza la lógica para guardar la cita inmediata
        String nombre = nameController.text;
        String nota = notaController.text;

        // Suponiendo que tienes el consultorioId y el paciente adecuados
        int consultorioId = 1; // Ajusta el consultorioId según tu lógica

        // Obtener la fecha y hora actual
        DateTime now = DateTime.now();
        String fechaActual = DateFormat('yyyy-MM-dd').format(now);
        String horaActual = DateFormat('HH:mm').format(now);

        // Crear el objeto evento con la fecha y hora actuales
        Evento evento = Evento(
          nombre: nombre,
          fecha: fechaActual,
          hora: horaActual,
          duracion: "", // Puedes ajustar la duración si es necesario
          servicio: "", // Ajusta el servicio si es necesario
          nota: nota,
        );

        // Insertar la cita inmediata en la base de datos
        int citaId = await DatabaseManager.insertCitaInmediata(
          consultorioId,
          evento,
          nota,
        );

        if (citaId != -1) {
          // Éxito al guardar la cita
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Cita guardada correctamente')),
          );

          // Navegar a la página del calendario
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => Calendar(),
            ),
          );
        } else {
          // Error al guardar la cita
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al guardar la cita')),
          );
        }
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration:
                      InputDecoration(labelText: 'Nombre del paciente'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'El nombre del paciente es obligatorio';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: notaController,
                  decoration: InputDecoration(labelText: 'Nota para la cita'),
                  maxLines: 3,
                ),
                SizedBox(height: 20.0),
                Text(
                  'Fecha y hora por registrar:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Fecha: ${DateFormat('dd/MM/yyyy').format(DateTime.now())}'),
                    Text('Hora: ${DateFormat('HH:mm').format(DateTime.now())}'),
                  ],
                ),
                SizedBox(height: 20.0),
                ElevatedButton(
                  onPressed: () => _saveCitaInmediata(context),
                  child: Text('Guardar Cita Inmediata'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
