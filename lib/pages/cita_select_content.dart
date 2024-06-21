import 'package:calendario_manik/pages/add_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CitaSelectContent extends StatefulWidget {
  final TextEditingController fechaController;
  final TextEditingController horaController;

  const CitaSelectContent(
      {Key? key, required this.fechaController, required this.horaController})
      : super(key: key);

  @override
  State<CitaSelectContent> createState() => _CitaSelectContentState();
}

class _CitaSelectContentState extends State<CitaSelectContent> {
  TextEditingController nameController = TextEditingController(text: "");
  int selectedInterval = 60;

  @override
  Widget build(BuildContext context) {
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

    return Column(
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
        TextFormField(
          controller: widget.fechaController,
          readOnly: true,
          decoration: const InputDecoration(labelText: 'Fecha'),
        ),
        TextFormField(
          controller: widget.horaController,
          readOnly: true,
          decoration: const InputDecoration(labelText: 'Hora'),
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
        const SizedBox(height: 20.0),
        ElevatedButton(
          onPressed: () {
            if (widget.fechaController.text.isNotEmpty &&
                widget.horaController.text.isNotEmpty) {
              // Guardar cita seleccionada o hacer algo más
            }
          },
          child: const Text('Guardar Cita Seleccionada'),
        ),
      ],
    );
  }
}
