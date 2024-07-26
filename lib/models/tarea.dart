class Tarea {
  final String nombre;
  final String fecha;
  final String hora;
  final String duracion;
  final String servicio;
  final String nota;
  final int? asignado_id;
  final int? paciente_id;

  Tarea({
    required this.nombre,
    required this.fecha,
    required this.hora,
    required this.duracion,
    required this.servicio,
    required this.nota,
    this.asignado_id,
    this.paciente_id,
  });
}
