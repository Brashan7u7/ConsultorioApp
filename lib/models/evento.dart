class Evento {
  final String nombre;
  final String fecha;
  final String hora;
  final String duracion;
  final String servicio;
  final bool allDay;
  final String nota;
  final int usuarioId;

  Evento({
    required this.nombre,
    required this.fecha,
    required this.hora,
    required this.duracion,
    required this.servicio,
    required this.allDay,
    required this.nota,
    required this.usuarioId,
  });
}
