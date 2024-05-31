import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CitaSelectContent extends StatelessWidget {
  final TextEditingController fechaController;
  final TextEditingController horaController;

  CitaSelectContent({required this.fechaController, required this.horaController});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: fechaController,
          readOnly: true,
          decoration: const InputDecoration(labelText: 'Fecha'),
          onTap: () async {
            DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2101),
            );
            if (pickedDate != null) {
              String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
              fechaController.text = formattedDate;
            }
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'La fecha es obligatoria';
            }
            return null;
          },
        ),
        TextFormField(
          controller: horaController,
          readOnly: true,
          decoration: const InputDecoration(labelText: 'Hora'),
          onTap: () async {
            TimeOfDay? pickedTime = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.now(),
            );
            if (pickedTime != null) {
              DateTime parsedTime = DateFormat.jm().parse(pickedTime.format(context).toString());
              String formattedTime = DateFormat('HH:mm:ss').format(parsedTime);
              horaController.text = formattedTime;
            }
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'La hora es obligatoria';
            }
            return null;
          },
        ),
        const SizedBox(height: 20.0),
        ElevatedButton(
          onPressed: () {
            if (fechaController.text.isNotEmpty && horaController.text.isNotEmpty) {
              // Guardar cita seleccionada o hacer algo más
            }
          },
          child: const Text('Guardar Cita Seleccionada'),
        ),
      ],
    );
  }
}
