import 'package:calendario_manik/models/paciente.dart';
import 'package:calendario_manik/pages/cita_programada_content.dart';
import 'package:calendario_manik/pages/cita_rapida_content.dart';
import 'package:calendario_manik/pages/cita_select_content.dart';
import 'package:calendario_manik/pages/evento_content.dart';
import 'package:calendario_manik/pages/paciente_content.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:calendario_manik/pages/calendar_page.dart';
import 'package:calendario_manik/models/datapatients.dart';

class Add extends StatelessWidget {
  final bool isCitaInmediata,
      isEvento,
      isPacient,
      isCitaPro,
      isCitaselect,
      isEditingPacient;
  final int? consultorioId;
  final DataPatients? pacient;

  TextEditingController? fechaController, horaController, duracionController;

  Add({
    Key? key,
    required this.isCitaInmediata,
    this.isEvento = false,
    this.isPacient = false,
    this.isCitaPro = false,
    this.isCitaselect = false,
    this.isEditingPacient = false,
    this.fechaController,
    this.horaController,
    this.duracionController,
    this.consultorioId,
    this.pacient,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isCitaInmediata
            ? "Cita Inmediata"
            : isCitaselect
                ? "Cita Programada"
                : isEvento
                    ? 'Evento'
                    : isEditingPacient
                        ? "Editar Paciente"
                        : isPacient
                            ? "Registrar Paciente"
                            : isCitaPro
                                ? "Cita Programada"
                                : ""),
      ),
      body: isCitaInmediata
          ? CitaRapidaContent()
          : (isCitaselect)
              ? CitaSelectContent(
                  fechaController: fechaController!,
                  horaController: horaController!,
                  consultorioId: consultorioId,
                )
              : isEvento
                  ? EventoContent(
                      consultorioId: consultorioId,
                    )
                  : isPacient
                      ? PacienteContent(
                          patient: pacient, consultorioId: consultorioId!)
                      : isCitaPro
                          ? CitaProgramadaContent(
                              consultorioId: consultorioId,
                            )
                          : Calendar(),
    );
  }
}
