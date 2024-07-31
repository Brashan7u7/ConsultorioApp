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
        Padding(
          padding: const EdgeInsets.all(5.0),
          child: Text(
            'Intervalo de Atención (minutos)',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.normal,
              color: Colors.grey[800],
            ),
          ),
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
          decoration: InputDecoration(
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
