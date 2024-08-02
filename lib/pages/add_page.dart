import 'package:calendario_manik/models/paciente.dart';
import 'package:calendario_manik/pages/cita_programada_content.dart';
import 'package:calendario_manik/pages/cita_rapida_content.dart';
import 'package:calendario_manik/pages/cita_select_content.dart';
import 'package:calendario_manik/pages/editingCita_page.dart';
import 'package:calendario_manik/pages/evento_content.dart';
import 'package:calendario_manik/pages/paciente_content.dart';
import 'package:flutter/material.dart';
import 'package:calendario_manik/pages/calendar_page.dart';
import 'package:calendario_manik/models/datapatients.dart';

class Add extends StatelessWidget {
  final bool isCitaInmediata,
      isEvento,
      isPacient,
      isCitaPro,
      isCitaselect,
      isEditingPacient,
      isEditingCita;
  final int? consultorioId;
  final DataPatients? pacient;

  TextEditingController? fechaController, horaController, duracionController;

  Add({
    super.key,
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
    this.isEditingCita = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditingCita
            ? "Editar Cita"
            : isCitaInmediata
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
          ? CitaRapidaContent(consultorioId: consultorioId)
          : isCitaselect
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
                          : isEditingCita
                              ? EditingCita()
                              : Calendar(),
    );
  }
}
