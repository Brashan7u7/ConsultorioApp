import 'package:calendario_manik/pages/cita_programada_content.dart';
import 'package:calendario_manik/pages/cita_rapida_content.dart';
import 'package:calendario_manik/pages/cita_select_content.dart';
import 'package:calendario_manik/pages/evento_content.dart';
import 'package:calendario_manik/pages/paciente_content.dart';
import 'package:flutter/material.dart';
import 'package:calendario_manik/pages/calendar_page.dart';
import 'package:calendario_manik/pages/patients_page.dart';

class Add extends StatelessWidget {
  final bool isCitaInmediata, isEvento, isPacient, isCitaPro;
  final bool? isCitaselect;
  final int? consultorioId;
  final int? usuario_id;

  TextEditingController? fechaController, horaController, duracionController;

  Add(
      {super.key,
      required this.isCitaInmediata,
      this.isEvento = false,
      this.isPacient = false,
      this.isCitaPro = false,
      this.isCitaselect = false,
      this.fechaController,
      this.horaController,
      this.duracionController,
      this.consultorioId,
      this.usuario_id});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isCitaInmediata
            ? "Cita Inmediata"
            : isCitaselect!
                ? "Cita Programada"
                : isEvento
                    ? 'Evento'
                    : isPacient
                        ? "Registrar Paciente"
                        : isCitaPro
                            ? "Cita Programada"
                            : ""),
      ),
      body: isCitaInmediata
          ? CitaRapidaContent(usuario_id: usuario_id)
          : (isCitaselect ?? false)
              ? CitaSelectContent(
                  fechaController: fechaController!,
                  horaController: horaController!,
                  consultorioId: consultorioId,
                  usuario_id: usuario_id)
              : isEvento
                  ? EventoContent(
                      consultorioId: consultorioId, usuario_id: usuario_id)
                  : isPacient
                      ? PacienteContent(usuario_id: usuario_id)
                      : isCitaPro
                          ? CitaProgramadaContent(
                              usuario_id: usuario_id,
                              consultorioId: consultorioId,
                            )
                          : Calendar(usuario_id: usuario_id),
    );
  }
}
