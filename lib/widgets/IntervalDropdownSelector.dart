import 'package:flutter/material.dart';

class IntervalDropdownSelector extends StatefulWidget {
  const IntervalDropdownSelector({super.key});

  @override
  State<IntervalDropdownSelector> createState() =>
      _IntervalDropdownSelectorState();
}

class _IntervalDropdownSelectorState extends State<IntervalDropdownSelector> {
  int selectedInterval = 60; // Valor predeterminado

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20.0),
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
          decoration: InputDecoration(
            labelText: 'Intervalo de Atención (minutos)',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(width: 1, color: Colors.grey),
            ),
            filled: true,
            fillColor: Colors.transparent,
          ),
        ),
      ],
    );
  }
}
