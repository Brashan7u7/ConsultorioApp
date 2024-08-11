import 'package:flutter/material.dart';

class AppointmentNoteWidget extends StatelessWidget {
  final TextEditingController noteController;

  const AppointmentNoteWidget({super.key, required this.noteController});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: noteController,
          maxLength: 100,
          decoration: InputDecoration(
            labelText: 'Nota para la cita',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(width: 1, color: Colors.grey),
            ),
            filled: true,
            fillColor: Colors.transparent,
          ),
          maxLines: 3,
        ),
      ],
    );
  }
}
