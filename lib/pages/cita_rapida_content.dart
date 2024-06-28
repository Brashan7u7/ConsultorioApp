import 'package:calendario_manik/database/database.dart';
import 'package:calendario_manik/models/evento.dart';
import 'package:calendario_manik/pages/add_page.dart';
import 'package:calendario_manik/pages/calendar_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Importa el paquete intl para formateo de fechas
import 'package:flutter_switch/flutter_switch.dart';

class CitaRapidaContent extends StatefulWidget {
  final int? usuario_id;

  CitaRapidaContent({Key? key, this.usuario_id}) : super(key: key);
  @override
  _CitaRapidaContentState createState() => _CitaRapidaContentState();
}

class _CitaRapidaContentState extends State<CitaRapidaContent> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController notaController = TextEditingController();
  bool status = false;
  String valor = "Consulta";
  final _formKey = GlobalKey<FormState>();
  List<String> suggestedPatients = [];

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
            builder: (context) => Calendar(usuario_id: widget.usuario_id),
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

  void _openAddPatientPage() {
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
  }

  @override
  Widget build(BuildContext context) {
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
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Escriba el nombre del paciente',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'El nombre del paciente es obligatorio';
                          }
                          return null;
                        },
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: _openAddPatientPage,
                      tooltip: 'Agregar paciente',
                    ),
                  ],
                ),
                // Lista de sugerencias de pacientes
                if (suggestedPatients.isNotEmpty)
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: suggestedPatients.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(suggestedPatients[index]),
                        onTap: () {
                          // Actualizar el campo de texto con el paciente seleccionado
                          nameController.text = suggestedPatients[index];
                          // Limpiar la lista de sugerencias
                          setState(() {
                            suggestedPatients = [];
                          });
                        },
                      );
                    },
                  ),
                SizedBox(height: 20.0),
                Text(
                  'Fecha y hora por registrar:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10.0),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                        'Fecha: ${DateFormat('dd/MM/yyyy').format(DateTime.now())}'),
                    Text('Hora: ${DateFormat('HH:mm').format(DateTime.now())}'),
                  ],
                ),
                SizedBox(height: 20.0),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        isExpanded: true,
                        items: const [
                          DropdownMenuItem<String>(
                            value: 'Consulta',
                            child: Text('Consulta'),
                          ),
                          DropdownMenuItem<String>(
                            value: 'Valoración',
                            child: Text('Valoración'),
                          ),
                          DropdownMenuItem<String>(
                            value: 'Estudios',
                            child: Text('Estudios'),
                          ),
                          DropdownMenuItem<String>(
                            value: 'Vacunas',
                            child: Text('Vacunas'),
                          ),
                          DropdownMenuItem<String>(
                            value: 'Nota de evolución',
                            child: Text('Nota de evolución'),
                          ),
                          DropdownMenuItem<String>(
                            value: 'interconsulta',
                            child: Text('Nota de interconsulta'),
                          ),
                          DropdownMenuItem<String>(
                            value: 'Rehabilitación',
                            child: Text('Rehabilitación'),
                          ),
                        ],
                        value: valor,
                        onChanged: (value) {
                          setState(() {
                            valor = value!;
                          });
                        },
                        decoration: const InputDecoration(
                          labelText: 'Motivo de consulta',
                        ),
                      ),
                    ),
                    const SizedBox(width: 20.0),
                    Expanded(
                      child: FlutterSwitch(
                        activeText: "Subsecuente",
                        inactiveText: "Primera vez",
                        value: status,
                        valueFontSize: 11.0,
                        width: 110,
                        height: 30,
                        borderRadius: 30.0,
                        showOnOff: true,
                        onToggle: (val) {
                          setState(() {
                            status = val;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.0),
                TextFormField(
                  controller: notaController,
                  decoration: InputDecoration(labelText: 'Nota para la cita'),
                  maxLines: 3,
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
