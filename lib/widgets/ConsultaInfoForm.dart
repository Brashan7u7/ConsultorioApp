import 'package:calendario_manik/widgets/AppointmentNoteWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';

class ConsultaInfoForm extends StatefulWidget {
  final TextEditingController notaController;
  const ConsultaInfoForm({super.key, required this.notaController});

  @override
  _ConsultaInfoFormState createState() => _ConsultaInfoFormState();
}

class _ConsultaInfoFormState extends State<ConsultaInfoForm> {
  String valor = 'Consulta';
  bool status = false;
  bool espera = false;
  final TextEditingController tipoCitaController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 5.0),
        const Padding(
          padding: EdgeInsets.all(5.0),
          child: Text(
            'Motivo de consulta',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.normal,
              color: Colors.grey,
            ),
          ),
        ),
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
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(width: 1, color: Colors.grey),
                  ),
                  filled: true,
                  fillColor: Colors.transparent,
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
                width: 150,
                height: 52,
                borderRadius: 5.0,
                showOnOff: true,
                onToggle: (val) {
                  setState(() {
                    status = val;
                    tipoCitaController.text =
                        val ? "Subsecuente" : "Primera vez";
                  });
                },
              ),
            ),
            const SizedBox(width: 20.0),
            Expanded(
              child: FlutterSwitch(
                activeText: "En espera",
                inactiveText: "Sin espera",
                value: espera,
                valueFontSize: 11.0,
                width: 150,
                height: 52,
                borderRadius: 5.0,
                showOnOff: true,
                onToggle: (val) {
                  setState(() {
                    espera = val;
                    print(espera);
                  });
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 25.0),
        AppointmentNoteWidget(noteController: widget.notaController),
      ],
    );
  }
}
