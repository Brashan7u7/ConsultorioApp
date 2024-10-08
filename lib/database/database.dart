import 'package:calendario_manik/models/consultorio.dart';
import 'package:calendario_manik/models/tarea.dart';
import 'package:calendario_manik/pages/consulting_page.dart';
import 'package:postgres/postgres.dart';
import 'package:calendario_manik/models/evento.dart';
import 'package:calendario_manik/models/paciente.dart';
import 'package:calendario_manik/variab.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:intl/intl.dart';

class DatabaseManager {
  static Future<Connection> _connect() async {
    tz.setLocalLocation(tz.getLocation('America/Mexico_City'));
    return await Connection.open(
      Endpoint(
        host: '192.168.1.181',
        port: 5432,
        database: 'medicalmanik',
        username: 'postgres',
        password: '123',
      ),
      settings: const ConnectionSettings(sslMode: SslMode.disable),
    );
  }

  static Future<void> connectAndExecuteQuery() async {
    try {
      final conn = await _connect();
      print('Conexion a base de datos exitosa!');

      await conn.close();
    } catch (e) {
      print('No se ha conectado a la base de datos!!!!: $e');
    }
  }

  //! Cita Seleccionada
  static Future<void> insertTareaSeleccionada(
      int consultorioId, Tarea tarea) async {
    try {
      final conn = await _connect();
      final result = await conn.execute("SELECT MAX(id) FROM tarea");
      int lastId = (result.first.first as int?) ?? 0;
      int newId = lastId + 1;

      DateTime startDate = DateTime.parse("${tarea.fecha} ${tarea.hora}");
      int duration = int.parse(tarea.duracion);
      DateTime endDate = startDate.add(Duration(minutes: duration));

      await conn.execute(
        Sql.named(
            "INSERT INTO tarea(id, token, nombre, descripcion, fecha_inicio, fecha_fin, calendario_id, asignado_id, paciente_id, color, motivo_consulta, tipo_cita) VALUES (@id, @token, @nombre,@descripcion, @fecha_inicio, @fecha_fin, @calendario_id, @asignado_id, @paciente_id, @color, @motivo_consulta, @tipo_cita)"),
        parameters: {
          "id": newId,
          "token": 2,
          "nombre": tarea.nombre,
          "descripcion": tarea.nota,
          "fecha_inicio": startDate.toIso8601String(),
          "fecha_fin": endDate.toIso8601String(),
          "calendario_id": consultorioId,
          "asignado_id": tarea.asignado_id,
          "paciente_id": tarea.paciente_id,
          "color": "#9A2EE5",
          "motivo_consulta": tarea.motivoConsulta,
          "tipo_cita": tarea.tipoCita,
        },
      );

      await conn.close();
    } catch (e) {
      print('Error al insertar la tarea de cita seleccionada: $e');
    }
  }

  //! Cita Inmediata
  static Future<int> insertarTareaInmediata(
      int consultorioId, Tarea tarea, String nota) async {
    try {
      final conn = await _connect();
      DateTime now = DateTime.now();
      int minute = now.minute;
      int roundedHour = now.hour;
      if (minute >= 30) {
        roundedHour = now.hour + 1;
      }
      DateTime roundedTime =
          now.copyWith(hour: roundedHour, minute: 0, microsecond: 0);

      String fechaInicioString =
          DateFormat('yyyy-MM-dd HH:mm:ss+00').format(roundedTime);

      // Calcula la fecha fin sumando 1 hora a la fecha inicio
      DateTime fechaFin = roundedTime.add(Duration(hours: 1));
      String fechaFinString =
          DateFormat('yyyy-MM-dd HH:mm:00+00').format(fechaFin);

      final result = await conn.execute("SELECT MAX(id) FROM tarea");
      int lastId = (result.first.first as int?) ?? 0;

      int newId = lastId + 1;

      await conn.execute(
        Sql.named(
          "INSERT INTO tarea(id, token, nombre, descripcion, fecha_inicio, fecha_fin,  calendario_id,asignado_id, paciente_id, color, motivo_consulta, tipo_cita) VALUES (@id, @token, @nombre, @descripcion, @fecha_inicio, @fecha_fin,  @calendario_id, @asignado_id, @paciente_id, @color, @motivo_consulta, @tipo_cita)",
        ),
        parameters: {
          "id": newId,
          "token": 2, // Asegúrate de obtener el token correcto
          "nombre": tarea.nombre, // Puedes cambiar esto según tus requisitos
          "descripcion": tarea.nota,
          "fecha_inicio": fechaInicioString,
          "fecha_fin": fechaFinString, // Utiliza la fecha y hora fin calculadas

          "calendario_id": consultorioId,
          "asignado_id": tarea.asignado_id,
          "paciente_id": tarea.paciente_id,
          "color": "#EB8015",
          "motivo_consulta": tarea.motivoConsulta,
          "tipo_cita": tarea.tipoCita,
        },
      );

      await conn.close();

      return newId;
    } catch (e) {
      print('Error al insertar la cita inmediata: $e');
      return -1;
    }
  }

  //! Cita Programada
  static Future<void> insertarTareaProgramada(
      int consultorioId, Tarea tarea) async {
    try {
      final conn = await _connect();

      final result = await conn.execute("SELECT MAX(id) FROM tarea");
      int lastId = (result.first.first as int?) ?? 0;

      int newId = lastId + 1;
      print("${tarea.fecha} ${tarea.hora}");
      DateTime startDate = DateTime.parse("${tarea.fecha} ${tarea.hora}");
      int duration = int.parse(tarea.duracion);
      DateTime endDate = startDate.add(Duration(minutes: duration));

      await conn.execute(
        Sql.named(
            "INSERT INTO tarea(id, token, nombre, descripcion, fecha_inicio, fecha_fin,calendario_id, color, asignado_id, paciente_id, motivo_consulta, tipo_cita) VALUES (@id, @token, @nombre,@descripcion, @fecha_inicio, @fecha_fin, @calendario_id, @color, @asignado_id, @paciente_id, @motivo_consulta, @tipo_cita)"),
        parameters: {
          "id": newId,
          "token": 2,
          "nombre": tarea.nombre,
          "descripcion": tarea.nota,
          "fecha_inicio": startDate.toIso8601String(),
          "fecha_fin": endDate.toIso8601String(),
          "calendario_id": consultorioId,
          "color": '#0EEED6',
          "asignado_id": tarea.asignado_id,
          "paciente_id": tarea.paciente_id,
          "motivo_consulta": tarea.motivoConsulta,
          "tipo_cita": tarea.tipoCita,
        },
      );

      await conn.close();
    } catch (e) {
      print('Error al insertar la cita programada: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> getRecomeDiariaDesdeFecha(
      DateTime fechaHoraInicio) async {
    List<Map<String, dynamic>> recomeDiaria = [];
    try {
      final conn = await _connect();
      //final nuevaFechaHoraInicio = fechaHoraInicio.subtract(Duration(hours: 6));

      // Formatear la nueva fecha y hora
      final formattedFechaHoraInicio =
          DateFormat('yyyy-MM-dd HH:mm:ss').format(fechaHoraInicio);

      final result = await conn.execute("""
      WITH fechas AS (
          SELECT 
              DATE '$formattedFechaHoraInicio' + s.i AS recomendacion_semanal,
              lower(translate(to_char((DATE '$formattedFechaHoraInicio' + s.i)::timestamp with time zone, 'TMDay'::text), 'ÁÉÍÓÚáéíóú'::text, 'AEIOUaeiou'::text)) AS dia_de_la_semana,
              to_char(TIMESTAMP '$formattedFechaHoraInicio' AT TIME ZONE 'America/Mexico_City', 'HH24:MI'::text) AS hora_actual,
              to_char(TIMESTAMP '$formattedFechaHoraInicio' AT TIME ZONE 'America/Mexico_City', 'YYYY-MM-DD HH24:MI:SS TZ') AS fecha_hora_zona,
              'America/Mexico_City' AS zona_horaria
          FROM generate_series(0, 6) s(i)
      ), horario AS (
          SELECT horario_consultorio.id,
              'lunes'::text AS dia_de_la_semana,
              unnest(string_to_array(horario_consultorio.lunes::text, ','::text)) AS hora
          FROM horario_consultorio
          UNION ALL
          SELECT horario_consultorio.id,
              'martes'::text AS dia_de_la_semana,
              unnest(string_to_array(horario_consultorio.martes::text, ','::text)) AS hora
          FROM horario_consultorio
          UNION ALL
          SELECT horario_consultorio.id,
              'miercoles'::text AS dia_de_la_semana,
              unnest(string_to_array(horario_consultorio.miercoles::text, ','::text)) AS hora
          FROM horario_consultorio
          UNION ALL
          SELECT horario_consultorio.id,
              'jueves'::text AS dia_de_la_semana,
              unnest(string_to_array(horario_consultorio.jueves::text, ','::text)) AS hora
          FROM horario_consultorio
          UNION ALL
          SELECT horario_consultorio.id,
              'viernes'::text AS dia_de_la_semana,
              unnest(string_to_array(horario_consultorio.viernes::text, ','::text)) AS hora
          FROM horario_consultorio
          UNION ALL
          SELECT horario_consultorio.id,
              'sabado'::text AS dia_de_la_semana,
              unnest(string_to_array(horario_consultorio.sabado::text, ','::text)) AS hora
          FROM horario_consultorio
          UNION ALL
          SELECT horario_consultorio.id,
              'domingo'::text AS dia_de_la_semana,
              unnest(string_to_array(horario_consultorio.domingo::text, ','::text)) AS hora
          FROM horario_consultorio
      ), eventos AS (
          SELECT DISTINCT date(evento.fecha_inicio) AS fecha_evento,
              to_char(evento.fecha_inicio, 'HH24:MI'::text) AS hora_inicio,
              to_char(evento.fecha_fin, 'HH24:MI'::text) AS hora_fin
          FROM evento
      ), tareas AS (
          SELECT DISTINCT date(tarea.fecha_inicio) AS fecha_tarea,
              to_char(tarea.fecha_inicio, 'HH24:MI'::text) AS hora_inicio_tarea,
              to_char(tarea.fecha_fin, 'HH24:MI'::text) AS hora_fin_tarea
          FROM tarea
      ), horas_libres AS (
          SELECT f.recomendacion_semanal,
              f.dia_de_la_semana,
              substr(h.hora, 1, 5) AS hora_disponible,
              f.fecha_hora_zona,
              f.zona_horaria
          FROM fechas f
          JOIN horario h ON f.dia_de_la_semana = h.dia_de_la_semana
          WHERE NOT EXISTS (
              SELECT 1
              FROM eventos e
              WHERE f.recomendacion_semanal = e.fecha_evento
              AND (
                  (substr(h.hora, 1, 5) >= e.hora_inicio AND substr(h.hora, 1, 5) < e.hora_fin) OR 
                  (substr(h.hora, 1, 5) < e.hora_inicio AND substr(h.hora, 1, 5) >= e.hora_fin)
              )
          )
          AND NOT EXISTS (
              SELECT 1
              FROM tareas t
              WHERE f.recomendacion_semanal = t.fecha_tarea
              AND (
                  (substr(h.hora, 1, 5) >= t.hora_inicio_tarea AND substr(h.hora, 1, 5) < t.hora_fin_tarea) OR 
                  (substr(h.hora, 1, 5) < t.hora_inicio_tarea AND substr(h.hora, 1, 5) >= t.hora_fin_tarea)
              )
          )
          AND (
              f.recomendacion_semanal > DATE '$formattedFechaHoraInicio' OR
              (f.recomendacion_semanal = DATE '$formattedFechaHoraInicio' AND substr(h.hora, 1, 5) >= f.hora_actual)
          )
          ORDER BY f.recomendacion_semanal, h.hora
      )
      SELECT DISTINCT to_char(recomendacion_semanal::timestamp with time zone, 'YYYY-MM-DD'::text) AS recomendacion_semanal,
          dia_de_la_semana,
          hora_disponible,
          fecha_hora_zona
      FROM horas_libres
      LIMIT 100;
    """);

      for (var row in result) {
        recomeDiaria.add({
          'fecha': row[0],
          'dia': row[1],
          'hora': row[2],
        });
      }
      await conn.close();
    } catch (e) {
      print('Error: $e');
    }
    return recomeDiaria;
  }

  static Future<List<Map<String, dynamic>>> getRecomeDiaria(
      int consultorioId) async {
    List<Map<String, dynamic>> recomeDiaria = [];
    try {
      final conn = await _connect();
      final result = await conn.execute(Sql.named("""
WITH fechas AS (
    SELECT
        CURRENT_DATE + s.i AS recomendacion_semanal,
        lower(translate(to_char((CURRENT_DATE + s.i)::timestamp with time zone, 'TMDay'::text), 'ÁÉÍÓÚáéíóú'::text, 'AEIOUaeiou'::text)) AS dia_de_la_semana,
        to_char(CURRENT_TIMESTAMP AT TIME ZONE 'America/Mexico_City', 'HH24:MI'::text) AS hora_actual,
        to_char(CURRENT_TIMESTAMP AT TIME ZONE 'America/Mexico_City', 'YYYY-MM-DD HH24:MI:SS TZ') AS fecha_hora_zona,
        'America/Mexico_City' AS zona_horaria
    FROM generate_series(0, 6) s(i)
), horario AS (
    SELECT horario_consultorio.id,
        'lunes'::text AS dia_de_la_semana,
        unnest(string_to_array(horario_consultorio.lunes::text, ','::text)) AS hora
    FROM horario_consultorio where id = @consultorioId
    UNION ALL
    SELECT horario_consultorio.id,
        'martes'::text AS dia_de_la_semana,
        unnest(string_to_array(horario_consultorio.martes::text, ','::text)) AS hora
    FROM horario_consultorio where id = @consultorioId
    UNION ALL
    SELECT horario_consultorio.id,
        'miercoles'::text AS dia_de_la_semana,
        unnest(string_to_array(horario_consultorio.miercoles::text, ','::text)) AS hora
    FROM horario_consultorio where id = @consultorioId
    UNION ALL
    SELECT horario_consultorio.id,
        'jueves'::text AS dia_de_la_semana,
        unnest(string_to_array(horario_consultorio.jueves::text, ','::text)) AS hora
    FROM horario_consultorio where id = @consultorioId
    UNION ALL
    SELECT horario_consultorio.id,
        'viernes'::text AS dia_de_la_semana,
        unnest(string_to_array(horario_consultorio.viernes::text, ','::text)) AS hora
    FROM horario_consultorio where id = @consultorioId
    UNION ALL
    SELECT horario_consultorio.id,
        'sabado'::text AS dia_de_la_semana,
        unnest(string_to_array(horario_consultorio.sabado::text, ','::text)) AS hora
    FROM horario_consultorio where id = @consultorioId
    UNION ALL
    SELECT horario_consultorio.id,
        'domingo'::text AS dia_de_la_semana,
        unnest(string_to_array(horario_consultorio.domingo::text, ','::text)) AS hora
    FROM horario_consultorio where id = @consultorioId
), eventos AS (
    SELECT DISTINCT date(evento.fecha_inicio) AS fecha_evento,
        to_char(evento.fecha_inicio, 'HH24:MI'::text) AS hora_inicio,
        to_char(evento.fecha_fin, 'HH24:MI'::text) AS hora_fin
    FROM evento where calendario_id = @consultorioId
), tareas AS (
    SELECT DISTINCT date(tarea.fecha_inicio) AS fecha_tarea,
        to_char(tarea.fecha_inicio, 'HH24:MI'::text) AS hora_inicio_tarea,
        to_char(tarea.fecha_fin, 'HH24:MI'::text) AS hora_fin_tarea
    FROM tarea where calendario_id = @consultorioId
), horas_libres AS (
    SELECT f.recomendacion_semanal,
        f.dia_de_la_semana,
        substr(h.hora, 1, 5) AS hora_disponible,
        f.fecha_hora_zona,
        f.zona_horaria
    FROM fechas f
    JOIN horario h ON f.dia_de_la_semana = h.dia_de_la_semana
    WHERE NOT EXISTS (
        SELECT 1
        FROM eventos e
        WHERE f.recomendacion_semanal = e.fecha_evento
        AND (
            (substr(h.hora, 1, 5) >= e.hora_inicio AND substr(h.hora, 1, 5) < e.hora_fin) OR
            (substr(h.hora, 1, 5) < e.hora_inicio AND substr(h.hora, 1, 5) >= e.hora_fin)
        )
    )
    AND NOT EXISTS (
        SELECT 1
        FROM tareas t
        WHERE f.recomendacion_semanal = t.fecha_tarea
        AND (
            (substr(h.hora, 1, 5) >= t.hora_inicio_tarea AND substr(h.hora, 1, 5) < t.hora_fin_tarea) OR
            (substr(h.hora, 1, 5) < t.hora_inicio_tarea AND substr(h.hora, 1, 5) >= t.hora_fin_tarea)
        )
    )
    AND (
        f.recomendacion_semanal > CURRENT_DATE OR
        (f.recomendacion_semanal = CURRENT_DATE AND substr(h.hora, 1, 5) >= f.hora_actual)
    )
    ORDER BY f.recomendacion_semanal, h.hora
)
SELECT DISTINCT to_char(recomendacion_semanal::timestamp with time zone, 'YYYY-MM-DD'::text) AS recomendacion_semanal,
    dia_de_la_semana,
    hora_disponible,
    fecha_hora_zona
FROM horas_libres
LIMIT 100 ;
    """), parameters: {"consultorioId": consultorioId});

      for (var row in result) {
        recomeDiaria.add({
          'fecha': row[0],
          'dia': row[1],
          'hora': row[2],
        });
      }
      await conn.close();
    } catch (e) {
      print('Error: $e');
    }
    return recomeDiaria;
  }

  static Future<List<Map<String, dynamic>>> getRecomeSema(
      int consultorioId) async {
    List<Map<String, dynamic>> recomeSema = [];
    try {
      final conn = await _connect();
      final result = await conn.execute(Sql.named("""
     
WITH fechas AS (
    SELECT 
        CURRENT_DATE + s.i AS recomendacion_semanal,
        lower(translate(to_char((CURRENT_DATE + s.i)::timestamp with time zone, 'TMDay'::text), 'ÁÉÍÓÚáéíóú'::text, 'AEIOUaeiou'::text)) AS dia_de_la_semana,
        to_char(CURRENT_TIMESTAMP AT TIME ZONE 'America/Mexico_City', 'HH24:MI'::text) AS hora_actual,
        to_char(CURRENT_TIMESTAMP AT TIME ZONE 'America/Mexico_City', 'YYYY-MM-DD HH24:MI:SS TZ') AS fecha_hora_zona,
        'America/Mexico_City' AS zona_horaria
    FROM generate_series(7, 30) s(i)
), horario AS (
    SELECT horario_consultorio.id,
        'lunes'::text AS dia_de_la_semana,
        unnest(string_to_array(horario_consultorio.lunes::text, ','::text)) AS hora
    FROM horario_consultorio WHERE id = @consultorioId
    UNION ALL
    SELECT horario_consultorio.id,
        'martes'::text AS dia_de_la_semana,
        unnest(string_to_array(horario_consultorio.martes::text, ','::text)) AS hora
    FROM horario_consultorio WHERE id = @consultorioId
    UNION ALL
    SELECT horario_consultorio.id,
        'miercoles'::text AS dia_de_la_semana,
        unnest(string_to_array(horario_consultorio.miercoles::text, ','::text)) AS hora
    FROM horario_consultorio WHERE id = @consultorioId
    UNION ALL
    SELECT horario_consultorio.id,
        'jueves'::text AS dia_de_la_semana,
        unnest(string_to_array(horario_consultorio.jueves::text, ','::text)) AS hora
    FROM horario_consultorio WHERE id = @consultorioId
    UNION ALL
    SELECT horario_consultorio.id,
        'viernes'::text AS dia_de_la_semana,
        unnest(string_to_array(horario_consultorio.viernes::text, ','::text)) AS hora
    FROM horario_consultorio WHERE id = @consultorioId
    UNION ALL
    SELECT horario_consultorio.id,
        'sabado'::text AS dia_de_la_semana,
        unnest(string_to_array(horario_consultorio.sabado::text, ','::text)) AS hora
    FROM horario_consultorio WHERE id = @consultorioId
    UNION ALL
    SELECT horario_consultorio.id,
        'domingo'::text AS dia_de_la_semana,
        unnest(string_to_array(horario_consultorio.domingo::text, ','::text)) AS hora
    FROM horario_consultorio WHERE id = @consultorioId
), eventos AS (
    SELECT DISTINCT date(evento.fecha_inicio) AS fecha_evento,
        to_char(evento.fecha_inicio, 'HH24:MI'::text) AS hora_inicio,
        to_char(evento.fecha_fin, 'HH24:MI'::text) AS hora_fin
    FROM evento WHERE calendario_id = @consultorioId
), tareas AS (
    SELECT DISTINCT date(tarea.fecha_inicio) AS fecha_tarea,
        to_char(tarea.fecha_inicio, 'HH24:MI'::text) AS hora_inicio_tarea,
        to_char(tarea.fecha_fin, 'HH24:MI'::text) AS hora_fin_tarea
    FROM tarea WHERE calendario_id = @consultorioId
), horas_libres AS (
    SELECT f.recomendacion_semanal,
        f.dia_de_la_semana,
        substr(h.hora, 1, 5) AS hora_disponible,
        f.fecha_hora_zona,
        f.zona_horaria
    FROM fechas f
    JOIN horario h ON f.dia_de_la_semana = h.dia_de_la_semana
    WHERE NOT EXISTS (
        SELECT 1
        FROM eventos e
        WHERE f.recomendacion_semanal = e.fecha_evento
        AND (
            (substr(h.hora, 1, 5) >= e.hora_inicio AND substr(h.hora, 1, 5) < e.hora_fin) OR 
            (substr(h.hora, 1, 5) < e.hora_inicio AND substr(h.hora, 1, 5) >= e.hora_fin)
        )
    )
    AND NOT EXISTS (
        SELECT 1
        FROM tareas t
        WHERE f.recomendacion_semanal = t.fecha_tarea
        AND (
            (substr(h.hora, 1, 5) >= t.hora_inicio_tarea AND substr(h.hora, 1, 5) < t.hora_fin_tarea) OR 
            (substr(h.hora, 1, 5) < t.hora_inicio_tarea AND substr(h.hora, 1, 5) >= t.hora_fin_tarea)
        )
    )
    AND (
        f.recomendacion_semanal > CURRENT_DATE OR
        (f.recomendacion_semanal = CURRENT_DATE AND substr(h.hora, 1, 5) >= f.hora_actual)
    )
    ORDER BY f.recomendacion_semanal, h.hora
)
SELECT DISTINCT to_char(recomendacion_semanal::timestamp with time zone, 'YYYY-MM-DD'::text) AS recomendacion_semanal,
    dia_de_la_semana,
    hora_disponible,
    fecha_hora_zona
FROM horas_libres
LIMIT 100;
    """), parameters: {"consultorioId": consultorioId});
      for (var row in result) {
        recomeSema.add({
          'fecha': row[0],
          'dia': row[1],
          'hora': row[2],
        });
      }
      await conn.close();
    } catch (e) {
      print('Error: $e');
    }
    return recomeSema;
  }

  static Future<List<Map<String, dynamic>>> getRecomeMen(
      int consultorioId) async {
    List<Map<String, dynamic>> recomeMen = [];
    try {
      final conn = await _connect();
      final result = await conn.execute(Sql.named("""
   
WITH fechas AS (
    SELECT 
        CURRENT_DATE + s.i AS recomendacion_semanal,
        lower(translate(to_char((CURRENT_DATE + s.i)::timestamp with time zone, 'TMDay'::text), 'ÁÉÍÓÚáéíóú'::text, 'AEIOUaeiou'::text)) AS dia_de_la_semana,
        to_char(CURRENT_TIMESTAMP AT TIME ZONE 'America/Mexico_City', 'HH24:MI'::text) AS hora_actual,
        to_char(CURRENT_TIMESTAMP AT TIME ZONE 'America/Mexico_City', 'YYYY-MM-DD HH24:MI:SS TZ') AS fecha_hora_zona,
        'America/Mexico_City' AS zona_horaria
    FROM generate_series(31, 90) s(i)
), horario AS (
    SELECT horario_consultorio.id,
        'lunes'::text AS dia_de_la_semana,
        unnest(string_to_array(horario_consultorio.lunes::text, ','::text)) AS hora
    FROM horario_consultorio WHERE id = @consultorioId
    UNION ALL
    SELECT horario_consultorio.id,
        'martes'::text AS dia_de_la_semana,
        unnest(string_to_array(horario_consultorio.martes::text, ','::text)) AS hora
    FROM horario_consultorio WHERE id = @consultorioId
    UNION ALL
    SELECT horario_consultorio.id,
        'miercoles'::text AS dia_de_la_semana,
        unnest(string_to_array(horario_consultorio.miercoles::text, ','::text)) AS hora
    FROM horario_consultorio WHERE id = @consultorioId
    UNION ALL
    SELECT horario_consultorio.id,
        'jueves'::text AS dia_de_la_semana,
        unnest(string_to_array(horario_consultorio.jueves::text, ','::text)) AS hora
    FROM horario_consultorio WHERE id = @consultorioId
    UNION ALL
    SELECT horario_consultorio.id,
        'viernes'::text AS dia_de_la_semana,
        unnest(string_to_array(horario_consultorio.viernes::text, ','::text)) AS hora
    FROM horario_consultorio WHERE id = @consultorioId
    UNION ALL
    SELECT horario_consultorio.id,
        'sabado'::text AS dia_de_la_semana,
        unnest(string_to_array(horario_consultorio.sabado::text, ','::text)) AS hora
    FROM horario_consultorio WHERE id = @consultorioId
    UNION ALL
    SELECT horario_consultorio.id,
        'domingo'::text AS dia_de_la_semana,
        unnest(string_to_array(horario_consultorio.domingo::text, ','::text)) AS hora
    FROM horario_consultorio WHERE id = @consultorioId
), eventos AS (
    SELECT DISTINCT date(evento.fecha_inicio) AS fecha_evento,
        to_char(evento.fecha_inicio, 'HH24:MI'::text) AS hora_inicio,
        to_char(evento.fecha_fin, 'HH24:MI'::text) AS hora_fin
    FROM evento WHERE calendario_id = @consultorioId
), tareas AS (
    SELECT DISTINCT date(tarea.fecha_inicio) AS fecha_tarea,
        to_char(tarea.fecha_inicio, 'HH24:MI'::text) AS hora_inicio_tarea,
        to_char(tarea.fecha_fin, 'HH24:MI'::text) AS hora_fin_tarea
    FROM tarea WHERE calendario_id = @consultorioId
), horas_libres AS (
    SELECT f.recomendacion_semanal,
        f.dia_de_la_semana,
        substr(h.hora, 1, 5) AS hora_disponible,
        f.fecha_hora_zona,
        f.zona_horaria
    FROM fechas f
    JOIN horario h ON f.dia_de_la_semana = h.dia_de_la_semana
    WHERE NOT EXISTS (
        SELECT 1
        FROM eventos e
        WHERE f.recomendacion_semanal = e.fecha_evento
        AND (
            (substr(h.hora, 1, 5) >= e.hora_inicio AND substr(h.hora, 1, 5) < e.hora_fin) OR 
            (substr(h.hora, 1, 5) < e.hora_inicio AND substr(h.hora, 1, 5) >= e.hora_fin)
        )
    )
    AND NOT EXISTS (
        SELECT 1
        FROM tareas t
        WHERE f.recomendacion_semanal = t.fecha_tarea
        AND (
            (substr(h.hora, 1, 5) >= t.hora_inicio_tarea AND substr(h.hora, 1, 5) < t.hora_fin_tarea) OR 
            (substr(h.hora, 1, 5) < t.hora_inicio_tarea AND substr(h.hora, 1, 5) >= t.hora_fin_tarea)
        )
    )
    AND (
        f.recomendacion_semanal > CURRENT_DATE OR
        (f.recomendacion_semanal = CURRENT_DATE AND substr(h.hora, 1, 5) >= f.hora_actual)
    )
    ORDER BY f.recomendacion_semanal, h.hora
)
SELECT DISTINCT to_char(recomendacion_semanal::timestamp with time zone, 'YYYY-MM-DD'::text) AS recomendacion_semanal,
    dia_de_la_semana,
    hora_disponible,
    fecha_hora_zona
FROM horas_libres
LIMIT 100;

    """), parameters: {"consultorioId": consultorioId});
      for (var row in result) {
        recomeMen.add({
          'fecha': row[0],
          'dia': row[1],
          'hora': row[2],
        });
      }
      await conn.close();
    } catch (e) {
      print('Error: $e');
    }
    return recomeMen;
  }

  //! Cita Seleccionada
  //?Esta tarea se esta ocupando para seleccionar las tareas
  static Future<List<Map<String, dynamic>>> getTareaSeleccionadaData(
      int consultorioId) async {
    List<Map<String, dynamic>> tareas = [];
    try {
      final conn = await _connect();

      final result = await conn.execute(Sql.named("""SELECT
  t.id,
  t.nombre AS tarea_nombre,
  TO_CHAR(t.fecha_inicio, 'yyyy-MM-dd HH24:MI:SS') AS fecha_inicio,
  TO_CHAR(t.fecha_fin, 'yyyy-MM-dd HH24:MI:SS') AS fecha_fin,
  t.color,
  m.nombre || ' ' || m.apellidos AS medico_nombre_completo,
  p.nombre || ' ' || p.ap_paterno AS paciente_nombre_completo,
  t.motivo_consulta,
  t.asignado_id as doctorid
FROM
  tarea t
  LEFT JOIN usuario m ON t.asignado_id = m.id AND m.rol = 'MED'
  LEFT JOIN paciente p ON t.paciente_id = p.id
WHERE
  t.calendario_id = @id"""), parameters: {"id": consultorioId});

      for (final row in result) {
        tareas.add({
          'id': row[0],
          'nombre': row[1],
          'fecha_inicio': row[2],
          'fecha_fin': row[3],
          'color': row[4],
          'asignado_id': row[5],
          'paciente_id': row[6],
          'motivo_consulta': row[7],
          'doctorid': row[8],
        });
      }

      await conn.close();
    } catch (e) {
      print('Error: $e');
    }
    return tareas;
  }

  //! Evento
  static Future<void> insertEvento(int consultorioId, Evento evento) async {
    try {
      final conn = await _connect();

      final result = await conn.execute("SELECT MAX(id) FROM evento");
      int lastId = (result.first.first as int?) ?? 0;

      int newId = lastId + 1;

      DateTime startDate;
      DateTime endDate;

      if (evento.allDay) {
        // Asumiendo que evento.servicio indica si es de todo el día
        // Para eventos de todo el día
        startDate = DateTime.parse("${evento.fecha} 00:00:00");
        endDate = DateTime.parse("${evento.fecha} 23:59:59");
      } else {
        // Para eventos no de todo el día
        startDate = DateTime.parse("${evento.fecha} ${evento.hora}");
        int duration = int.parse(evento.duracion);
        endDate = startDate.add(Duration(minutes: duration));
      }

      await conn.execute(
        Sql.named(
            "INSERT INTO evento(id, token, nombre, descripcion, fecha_inicio, fecha_fin, all_day, usuario_id, calendario_id, tipo_evento) VALUES (@id, @token, @nombre,@descripcion, @fecha_inicio, @fecha_fin, @all_day, @usuario_id, @calendario_id, @tipo_evento)"),
        parameters: {
          "id": newId,
          "token": 2,
          "nombre": evento.nombre,
          "descripcion": evento.nota,
          "fecha_inicio": startDate.toIso8601String(),
          "fecha_fin": endDate.toIso8601String(),
          "all_day": evento.allDay,
          "usuario_id": evento.usuarioId,
          "calendario_id": consultorioId,
          "tipo_evento": evento.servicio,
        },
      );

      await conn.close();
    } catch (e) {
      print('Error al insertar el evento: $e');
    }
  }

  static Future<void> deleteEvento(int eventoId) async {
    try {
      final conn = await _connect();

      await conn
          .execute(Sql.named("DELETE FROM evento WHERE id = @id"), parameters: {
        "id": eventoId,
      });

      await conn.close();
    } catch (e) {
      print('Error: $e');
    }
  }

  static Future<void> deleteTarea(int tareaId) async {
    try {
      final conn = await _connect();

      await conn
          .execute(Sql.named("DELETE FROM tarea WHERE id = @id"), parameters: {
        "id": tareaId,
      });

      await conn.close();
    } catch (e) {
      print('Error: $e');
    }
  }

  //?Este evento se esta ocupando para seleccionar los eventos
  static Future<List<Map<String, dynamic>>> getEventosData(
      int consultorioId) async {
    List<Map<String, dynamic>> eventos = [];
    try {
      final conn = await _connect();

      final result = await conn.execute(
          Sql.named(
              "select id, nombre,TO_CHAR(fecha_inicio,'yyyy-MM-dd HH24:MI:SS') fecha_inicio,  TO_CHAR(fecha_fin,'yyyy-MM-dd HH24:MI:SS')fecha_fin, all_day from evento WHERE calendario_id=@id"),
          parameters: {
            "id": consultorioId,
          });
      for (final row in result) {
        eventos.add({
          'id': row[0],
          'nombre': row[1],
          'fecha_inicio': row[2],
          'fecha_fin': row[3],
          'all_day': row[4],
        });
      }

      await conn.close();
    } catch (e) {
      print('Error: $e');
    }
    return eventos;
  }

  //*Paciente
  static Future<List<Map<String, dynamic>>> searchPatients(
      String query, int consultorioId) async {
    List<Map<String, dynamic>> patients = [];
    try {
      final conn = await _connect();
      final result = await conn.execute(
        Sql.named(
            "SELECT id, nombre FROM paciente WHERE nombre LIKE @query AND consultorio_id = @consultorioId"),
        parameters: {"query": '%$query%', "consultorioId": consultorioId},
      );

      for (var row in result) {
        patients.add({'id': row[0], 'nombre': row[1]});
      }

      await conn.close();
    } catch (e) {
      print('Error al buscar pacientes: $e');
    }
    return patients;
  }

  static Future<int> insertOrUpdatePaciente(
      Paciente? paciente, int? pacienteId) async {
    try {
      final conn = await _connect();
      int newId = 0;
      if (paciente != null && pacienteId == null) {
        final result = await conn.execute("SELECT MAX(id) FROM paciente");
        int lastId = (result.first.first as int?) ?? 0;

        int newId = lastId + 1;

        await conn.execute(
          Sql.named(
              "INSERT INTO paciente(id, nombre, ap_paterno, ap_materno, fecha_nacimiento, sexo, telefono_movil, telefono_fijo, correo, fecha_registro, direccion, curp, codigo_postal, consultorio_id) VALUES (@id, @nombre, @ap_paterno, @ap_materno, @fechaNacimiento, @sexo, @telefonoMovil, @telefonoFijo, @correo, @fechaRegistro, @direccion, @curp, @codigoPostal, @consultorioId)"),
          parameters: {
            "id": newId,
            "nombre": paciente.nombre,
            "ap_paterno": paciente.apPaterno,
            "ap_materno": paciente.apMaterno,
            "fechaNacimiento": paciente.fechaNacimiento,
            "sexo": paciente.sexo,
            "telefonoMovil": paciente.telefonoMovil,
            "telefonoFijo": paciente.telefonoFijo,
            "correo": paciente.correo,
            //"avatar": paciente.avatar,
            "fechaRegistro": paciente.fechaRegistro.toIso8601String(),
            "direccion": paciente.direccion,
            //"identificador": paciente.identificador,
            "curp": paciente.curp,
            "codigoPostal": paciente.codigoPostal,
            // "municipioId": paciente.municipioId,
            // "estadoId": paciente.estadoId,
            // "pais": paciente.pais,
            // "paisId": paciente.paisId,
            // "entidadNacimientoId": paciente.entidadNacimientoId,
            // "generoId": paciente.generoId,
            "consultorioId": paciente.consultorioId,
          },
        );
      }
      if (pacienteId != null && paciente != null) {
        await conn.execute(
          Sql.named(
              "UPDATE paciente SET nombre = @nombre, ap_paterno = @ap_paterno, ap_materno = @ap_materno, fecha_nacimiento = @fechaNacimiento, sexo = @sexo, telefono_movil = @telefonoMovil, telefono_fijo = @telefonoFijo, correo = @correo, fecha_registro = @fechaRegistro, direccion = @direccion, curp = @curp, codigo_postal = @codigoPostal WHERE id = @id"),
          parameters: {
            "id": pacienteId,
            "nombre": paciente.nombre,
            "ap_paterno": paciente.apPaterno,
            "ap_materno": paciente.apMaterno,
            "fechaNacimiento": paciente.fechaNacimiento,
            "sexo": paciente.sexo,
            "telefonoMovil": paciente.telefonoMovil,
            "telefonoFijo": paciente.telefonoFijo,
            "correo": paciente.correo,
            "fechaRegistro": paciente.fechaRegistro.toIso8601String(),
            "direccion": paciente.direccion,
            "curp": paciente.curp,
            "codigoPostal": paciente.codigoPostal,
          },
        );
      }

      await conn.close();

      return newId;
    } catch (e) {
      print('Error al insertar el paciente: $e');
      return -1;
    }
  }

  static Future<List<Map<String, dynamic>>> getPacientes(
      int consultorioId, int? offset, int? limit) async {
    List<Map<String, dynamic>> pacientes = [];
    try {
      final conn = await _connect();
      String query;

      if (usuario_cuenta_id == 3) {
        // Consulta SQL para el caso de usuario con ID 3
        query = """
        SELECT * 
        FROM paciente 
        WHERE consultorio_id = @id
        LIMIT @limit OFFSET @offset;
      """;
        final result = await conn.execute(Sql.named(query), parameters: {
          "id": consultorioId,
          "limit": limit,
          "offset": offset
        });
        for (var row in result) {
          pacientes.add({
            'id': row[0],
            'nombre': row[1],
            'ap_paterno': row[2],
            'ap_materno': row[3],
            'fecha_nacimiento': row[4],
            'sexo': row[5],
            'telefono_movil': row[7],
            'telefono_fijo': row[8],
            'correo': row[9],
            'direccion': row[12],
            'curp': row[14],
            'codigo_postal': row[15],
          });
        }
      } else {
        // Consulta SQL para otros usuarios
        query = """
        SELECT * 
        FROM paciente 
        WHERE consultorio_id = @id
        LIMIT @limit OFFSET @offset;
      """;
        final result = await conn.execute(Sql.named(query), parameters: {
          "id": consultorioId,
          "limit": limit,
          "offset": offset
        });
        for (var row in result) {
          pacientes.add({
            'id': row[0],
            'nombre': row[1],
            'ap_paterno': row[2],
            'ap_materno': row[3],
            'fecha_nacimiento': row[4],
            'sexo': row[5],
            'telefono_movil': row[7],
            'telefono_fijo': row[8],
            'correo': row[9],
            'direccion': row[12],
            'curp': row[14],
            'codigo_postal': row[15],
          });
        }
      }
      await conn.close();
    } catch (e) {
      print('Error: $e');
    }
    return pacientes;
  }

  static Future<bool> hasAllDayEventOnDate(
      int consultorioId, String date) async {
    try {
      final conn = await _connect();

      final result = await conn.execute(
          Sql.named(
              "SELECT COUNT(*) FROM evento WHERE calendario_id=@id AND all_day=true AND DATE(fecha_inicio) = DATE(@date)"),
          parameters: {
            "id": consultorioId,
            "date": date,
          });

      await conn.close();

      final count =
          result.isNotEmpty && result[0][0] != null ? result[0][0] as int : 0;

      return count > 0;
    } catch (e) {
      print('Error in hasAllDayEventOnDate: $e');
      return false;
    }
  }

  static Future<void> deletePaciente(int id) async {
    try {
      final conn = await _connect();
      if (usuario_cuenta_id == 3) {
        await conn.execute(
          Sql.named("DELETE FROM grupo_paciente WHERE paciente_id = @id"),
          parameters: {"id": id},
        );
        await conn.execute(
          Sql.named("DELETE FROM paciente WHERE id = @id "),
          parameters: {"id": id},
        );
      } else {
        await conn.execute(
          Sql.named("DELETE FROM paciente WHERE id = @id "),
          parameters: {"id": id},
        );
      }
      await conn.close();
    } catch (e) {
      print('Error al eliminar el paciente: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> getConsultoriosData(id) async {
    List<Map<String, dynamic>> consultoriosData = [];
    try {
      final conn = await _connect();
      if (usuario_cuenta_id == 3) {
        final result = await conn.execute(Sql.named("""
      SELECT c.id,c.nombre, c.intervalo
FROM consultorio c
JOIN grupo_consultorio gc ON c.id = gc.consultorio_id
WHERE gc.grupo_id = $grupo_id;
"""));
        for (var row in result) {
          consultoriosData.add({
            'id': row[0],
            'nombre': row[1],
            'intervalo': row[2],
          });
        }
      } else {
        final result = await conn.execute(
            Sql.named("SELECT * FROM consultorio WHERE usuario_id=@id"),
            parameters: {"id": id});
        //final result = await conn.execute("SELECT * FROM consultorio");
        for (var row in result) {
          consultoriosData.add({
            'id': row[0],
            'nombre': row[1],
            'direccion': row[2],
            'colonia_id': row[3],
            'telefono': row[5],
            'intervalo': row[8],
          });
        }
      }
      await conn.close();
    } catch (e) {
      print('Error: $e');
    }
    return consultoriosData;
  }

  static Future<void> updateConsultorio(Consultorio consultorio) async {
    try {
      final conn = await _connect();
      await conn.execute(
        Sql.named(
            "UPDATE consultorio SET nombre = @nombre, direccion = @direccion, colonia_id = @colonia_id, telefono = @telefono, intervalo = @intervalo  WHERE id = @id"),
        parameters: {
          "id": consultorio.id,
          "nombre": consultorio.nombre,
          "direccion": consultorio.direccion,
          "colonia_id": consultorio.codigoPostal,
          "telefono": consultorio.telefono,
          "intervalo": consultorio.intervaloAtencion,
        },
      );
      await conn.close();
    } catch (e) {
      print('Error al actualizar el consultorio: $e');
    }
  }

  static Future<void> deleteConsultorio(int id) async {
    try {
      final conn = await _connect();
      await conn.execute(
        Sql.named("DELETE FROM consultorio WHERE id = @id"),
        parameters: {"id": id},
      );
      await conn.close();
    } catch (e) {
      print('Error al eliminar el consultorio: $e');
    }
  }

  static Future<int> insertConsultorio(
      Consultorio consultorio, int usuario_id) async {
    try {
      final conn = await _connect();
      final result = await conn.execute("SELECT MAX(id) FROM consultorio");
      int lastId = (result.first.first as int?) ?? 0;
      int newId = lastId + 1;
      await conn.execute(
        Sql.named(
            "INSERT INTO consultorio(id, nombre, direccion, colonia_id, telefono, intervalo, usuario_id) VALUES (@id, @nombre, @direccion, @colonia_id, @telefono, @intervalo, @usuario_id)"),
        parameters: {
          "id": newId,
          "nombre": consultorio.nombre,
          "direccion": consultorio.direccion,
          "colonia_id": consultorio.codigoPostal,
          "telefono": consultorio.telefono,
          "intervalo": consultorio.intervaloAtencion,
          "usuario_id": usuario_id,
        },
      );
      await conn.close();
      return newId;
    } catch (e) {
      print('Error al insertar el consultorio: $e');
      return -1;
    }
  }

  static Future<void> insertHorarioConsultorio(
    int consultorioId,
    String lunes,
    String martes,
    String miercoles,
    String jueves,
    String viernes,
    String sabado,
    String domingo,
  ) async {
    try {
      final conn = await _connect();

      await conn.execute(
        Sql.named(
            "INSERT INTO horario_consultorio(id, lunes, martes, miercoles, jueves, viernes, sabado, domingo) VALUES (@id,  @lunes, @martes, @miercoles, @jueves, @viernes, @sabado, @domingo)"),
        parameters: {
          "id": consultorioId,
          "lunes": lunes,
          "martes": martes,
          "miercoles": miercoles,
          "jueves": jueves,
          "viernes": viernes,
          "sabado": sabado,
          "domingo": domingo,
        },
      );

      await conn.close();
    } catch (e) {
      print('Error al insertar los horarios: $e');
    }
  }

  static Future<Map<String, List<String>>> getHorarioConsultorio(
      int consultorioId) async {
    Map<String, List<String>> horarios = {};

    try {
      final conn = await _connect();

      final result = await conn.execute(
        Sql.named("SELECT * FROM horario_consultorio WHERE id = @id"),
        parameters: {"id": consultorioId},
      );

      for (var row in result) {
        // Procesar los horarios recuperados y actualizar el mapa
        // Acceder directamente a las columnas por su nombre
        List<String> lunesHorarios = parseHorarios(row[1] as String);
        List<String> martesHorarios = parseHorarios(row[2] as String);
        List<String> miercolesHorarios = parseHorarios(row[3] as String);
        List<String> juevesHorarios = parseHorarios(row[4] as String);
        List<String> viernesHorarios = parseHorarios(row[5] as String);
        List<String> sabadoHorarios = parseHorarios(row[6] as String);
        List<String> domingoHorarios = parseHorarios(row[7] as String);

        // Actualiza el mapa de horarios
        horarios['Lunes'] = lunesHorarios;
        horarios['Martes'] = martesHorarios;
        horarios['Miércoles'] = miercolesHorarios;
        horarios['Jueves'] = juevesHorarios;
        horarios['Viernes'] = viernesHorarios;
        horarios['Sábado'] = sabadoHorarios;
        horarios['Domingo'] = domingoHorarios;
      }

      await conn.close();
    } catch (e) {
      print('Error al convertir horarios: $e');
    }

    return horarios;
  }

  static List<String> parseHorarios(String horarios) {
    if (horarios.isEmpty) return [];
    return horarios.split(',');
  }

  static Future<Map<String, List<String>>> getHorarios() async {
    Map<String, List<String>> horarios = {
      'Lunes': [],
      'Martes': [],
      'Miércoles': [],
      'Jueves': [],
      'Viernes': [],
      'Sábado': [],
      'Domingo': [],
    };

    try {
      final conn = await _connect();

      final result = await conn.execute("SELECT * FROM horario_consultorio");

      for (var row in result) {
        // Procesar los horarios recuperados y actualizar el mapa
        // Acceder directamente a las columnas por su nombre
        List<String> lunesHorarios = parseHorarios(row[1] as String);
        List<String> martesHorarios = parseHorarios(row[2] as String);
        List<String> miercolesHorarios = parseHorarios(row[3] as String);
        List<String> juevesHorarios = parseHorarios(row[4] as String);
        List<String> viernesHorarios = parseHorarios(row[5] as String);
        List<String> sabadoHorarios = parseHorarios(row[6] as String);
        List<String> domingoHorarios = parseHorarios(row[7] as String);

        // Agrega los horarios al mapa acumulando los valores
        horarios['Lunes']!.addAll(lunesHorarios);
        horarios['Martes']!.addAll(martesHorarios);
        horarios['Miércoles']!.addAll(miercolesHorarios);
        horarios['Jueves']!.addAll(juevesHorarios);
        horarios['Viernes']!.addAll(viernesHorarios);
        horarios['Sábado']!.addAll(sabadoHorarios);
        horarios['Domingo']!.addAll(domingoHorarios);
      }

      await conn.close();
    } catch (e) {
      print('Error al convertir horarios: $e');
    }

    return horarios;
  }

  static Future<void> updateHorarioConsultorio(
    int consultorioId,
    String lunesHorarios,
    String martesHorarios,
    String miercolesHorarios,
    String juevesHorarios,
    String viernesHorarios,
    String sabadoHorarios,
    String domingoHorarios,
  ) async {
    try {
      final conn = await _connect();

      await conn.execute(
        Sql.named(
            "UPDATE horario_consultorio SET lunes = @lunes, martes = @martes, miercoles = @miercoles, jueves = @jueves, viernes = @viernes, sabado = @sabado, domingo = @domingo WHERE id = @id"),
        parameters: {
          "id": consultorioId,
          "lunes": lunesHorarios,
          "martes": martesHorarios,
          "miercoles": miercolesHorarios,
          "jueves": juevesHorarios,
          "viernes": viernesHorarios,
          "sabado": sabadoHorarios,
          "domingo": domingoHorarios,
        },
      );

      await conn.close();
    } catch (e) {
      print('Error al actualizar el consultorio: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> getEventosByFecha(
      int consultorioId, String fecha) async {
    List<Map<String, dynamic>> eventos = [];
    try {
      final conn = await _connect();

      final result = await conn.execute(
          Sql.named(
              "select id, nombre, TO_CHAR(fecha_inicio,'yyyy-MM-dd HH24:MI:SS') fecha_inicio, TO_CHAR(fecha_fin,'yyyy-MM-dd HH24:MI:SS') fecha_fin from evento WHERE calendario_id=@id AND DATE(fecha_inicio) = DATE(@fecha)"),
          parameters: {
            "id": consultorioId,
            "fecha": fecha,
          });
      for (final row in result) {
        eventos.add({
          'id': row[0],
          'nombre': row[1],
          'fecha_inicio': row[2],
          'fecha_fin': row[3],
        });
      }

      await conn.close();
    } catch (e) {
      print('Error: $e');
    }
    return eventos;
  }

  static Future<List<Map<String, dynamic>>> getTareasByFecha(
      int consultorioId, String fecha) async {
    List<Map<String, dynamic>> tareas = [];
    try {
      final conn = await _connect();

      final result = await conn.execute(
          Sql.named(
              "select id, nombre, TO_CHAR(fecha_inicio,'yyyy-MM-dd HH24:MI:SS') fecha_inicio, TO_CHAR(fecha_fin,'yyyy-MM-dd HH24:MI:SS') fecha_fin from tarea WHERE calendario_id=@id AND DATE(fecha_inicio) = DATE(@fecha)"),
          parameters: {
            "id": consultorioId,
            "fecha": fecha,
          });
      for (final row in result) {
        tareas.add({
          'id': row[0],
          'nombre': row[1],
          'fecha_inicio': row[2],
          'fecha_fin': row[3],
        });
      }

      await conn.close();
    } catch (e) {
      print('Error: $e');
    }
    return tareas;
  }

  static Future<List<Map<String, dynamic>>> getUsuario() async {
    List<Map<String, dynamic>> usuarios = [];
    try {
      final conn = await _connect();

      final result = await conn.execute("""
SELECT
  u.id,
  u.correo,
  u.contrasena,
  u.rol,
  u.nombre,
  u.apellidos,
  u.cuenta_id,
  COALESCE(gm.grupo_id, ga.grupo_id, ge.grupo_id) AS grupo_id
FROM
  usuario u
LEFT JOIN
  grupo_medico gm ON u.id = gm.medico_id
LEFT JOIN
  grupo_asistente ga ON u.id = ga.asistente_id
LEFT JOIN
  grupo_enfermero ge ON u.id = ge.enfermero_id
""");
      for (var row in result) {
        usuarios.add({
          'id': row[0],
          'correo': row[1],
          'contrasena': row[2],
          'rol': row[3],
          'nombre': row[4],
          'apellidos': row[5],
          'cuenta_id': row[6],
          'grupo_id': row[7],
        });
      }

      await conn.close();
    } catch (e) {
      print('Error: $e');
    }
    return usuarios;
  }

  static Future<List<Map<String, dynamic>>> getConsultoriosData_id(
      int userId) async {
    List<Map<String, dynamic>> consultoriosData = [];
    try {
      final conn = await _connect();
      if (usuario_cuenta_id == 3) {
        final result = await conn.execute('''
      SELECT c.id,c.nombre, c.intervalo
FROM consultorio c
JOIN grupo_consultorio gc ON c.id = gc.consultorio_id
WHERE gc.grupo_id = $grupo_id;
    ''');

        for (var row in result) {
          consultoriosData.add({
            'id': row[0],
            'nombre': row[1],
            'intervalo': row[2],
          });
        }
      } else {
        final result = await conn.execute('''
      SELECT c.*
      FROM consultorio c
      JOIN asistente_consultorio ac ON c.id = ac.consultorio_id
      WHERE ac.asistente_id = $userId
    ''');

        for (var row in result) {
          consultoriosData.add({
            'id': row[0],
            'nombre': row[1],
            'direccion': row[2],
            'colonia_id': row[3],
            'telefono': row[5],
            'intervalo': row[8],
          });
        }
      }
      await conn.close();
    } catch (e) {
      print('Error: $e');
    }
    return consultoriosData;
  }

  static Future<void> deleteCita(Object? id) async {
    try {
      final conn = await _connect();
      await conn.execute(
        Sql.named("DELETE FROM evento WHERE id = @id"),
        parameters: {"id": id},
      );
      await conn.close();
    } catch (e) {
      print('Error al eliminar la cita: $e');
    }
  }

  static Future<void> setPermissionsByRole(String role) async {
    try {
      final conn = await _connect();
      final query = '''
      SELECT 
          rp.captura_signos_vitales,
          rp.captura_antecedentes_clinicos,
          rp.agendar_citas_eventos,
          rp.crear_pacientes,
          rp.editar_pacientes,
          rp.eliminar_pacientes
      FROM roles_permisos rp
      WHERE rp.rol = @role
    ''';
      final result =
          await conn.execute(Sql.named(query), parameters: {"role": role});
      if (result.isNotEmpty) {
        var row = result.first;
        // Asignar los valores a las variables globales
        capturaSignosVitales = row[0] as bool;
        capturaAntecedentesClinicos = row[1] as bool;
        agendarCitasEventos = row[2] as bool;
        crearPacientes = row[3] as bool;
        editarPacientes = row[4] as bool;
        eliminarPacientes = row[5] as bool;
      } else {
        print('No se encontraron permisos para el rol $role');
      }

      await conn.close();
    } catch (e) {
      print('Error: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> getDoctores(int grupo_id) async {
    List<Map<String, dynamic>> doctores = [];
    try {
      final conn = await _connect();
      final result = await conn.execute("""
      SELECT u.id,u.nombre, u.apellidos
FROM usuario u
JOIN grupo_medico gm ON u.id = gm.medico_id
WHERE gm.grupo_id = $grupo_id;
    """);
      for (var row in result) {
        doctores.add({
          'id': row[0],
          'nombre': row[1],
          'apellidos': row[2],
        });
      }
      await conn.close();
    } catch (e) {
      print('Error: $e');
    }
    return doctores;
  }

  static Future<bool> reagendarEvento(
    int eventoId,
    int consultorioId,
    String newStartTime,
    String newEndTime,
    int doctorId,
  ) async {
    try {
      final conn = await _connect();

      // Verificar si el nuevo horario ajustado está disponible
      bool puedeReagendar =
          await canReagendar(consultorioId, newStartTime, newEndTime);

      if (!puedeReagendar) {
        print('Conflicto detectado, no se puede reagendar.');
        return false; // No se puede reagendar debido a conflictos
      }

      // Actualizar el evento en la base de datos con las fechas ajustadas
      await conn.execute(
        Sql.named("""
            UPDATE evento
            SET fecha_inicio = @adjustedStartTime,
                fecha_fin = @adjustedEndTime
            WHERE id = @eventoId
            """),
        parameters: {
          'adjustedStartTime': newStartTime,
          'adjustedEndTime': newEndTime,
          'eventoId': eventoId,
        },
      );

      await conn.close();
      return true; // Reagendamiento exitoso
    } catch (e) {
      print('Error en reagendarEvento: $e');
      return false; // Error durante el proceso
    }
  }

  static Future<bool> reagendarTarea(
    int tareaId,
    int consultorioId,
    String newStartTime,
    String newEndTime,
    int doctorId,
  ) async {
    try {
      final conn = await _connect();
      // Verificar si el nuevo horario ajustado está disponible
      bool puedeReagendar =
          await canReagendar(consultorioId, newStartTime, newEndTime);

      if (!puedeReagendar) {
        return false; // No se puede reagendar debido a conflictos
      }

      await conn.execute(
        Sql.named("""UPDATE tarea
            SET fecha_inicio = @newStartTime,
                fecha_fin = @newEndTime,
                calendario_id = @consultorioId,
                asignado_id = @doctorId
            WHERE id = @tareaId
            """),
        parameters: {
          'newStartTime': newStartTime,
          'newEndTime': newEndTime,
          'tareaId': tareaId,
          'consultorioId': consultorioId,
          'doctorId': doctorId,
        },
      );

      await conn.close();
      return true; // Reagendamiento exitoso
    } catch (e) {
      print('Error en reagendarTarea: $e');
      return false; // Error durante el proceso
    }
  }

  static Future<void> insertarListaEspera(
      int consultorioId, Tarea tarea) async {
    try {
      final conn = await _connect();

      final result = await conn.execute("SELECT MAX(id) FROM lista_espera");
      int lastId = (result.first.first as int?) ?? 0;

      int newId = lastId + 1;
      DateTime startDate = DateTime.parse("${tarea.fecha} ${tarea.hora}");
      int duration = int.parse(tarea.duracion);
      DateTime endDate = startDate.add(Duration(minutes: duration));

      await conn.execute(
        Sql.named(
            "INSERT INTO lista_espera(id, token, nombre, descripcion, fecha_inicio, fecha_fin,calendario_id, color, asignado_id, paciente_id, motivo_consulta, tipo_cita) VALUES (@id, @token, @nombre,@descripcion, @fecha_inicio, @fecha_fin, @calendario_id, @color, @asignado_id, @paciente_id, @motivo_consulta, @tipo_cita)"),
        parameters: {
          "id": newId,
          "token": 2,
          "nombre": tarea.nombre,
          "descripcion": tarea.nota,
          "fecha_inicio": startDate.toIso8601String(),
          "fecha_fin": endDate.toIso8601String(),
          "calendario_id": consultorioId,
          "color": '#FF6666',
          "asignado_id": tarea.asignado_id,
          "paciente_id": tarea.paciente_id,
          "motivo_consulta": tarea.motivoConsulta,
          "tipo_cita": tarea.tipoCita,
        },
      );

      await conn.close();
    } catch (e) {
      print('Error al insertar a la lista espera: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> getListaEsperaData(
      int consultorioId) async {
    List<Map<String, dynamic>> tareas = [];
    try {
      final conn = await _connect();

      final result = await conn.execute(Sql.named("""SELECT
  t.id,
  t.nombre AS tarea_nombre,
  TO_CHAR(t.fecha_inicio, 'yyyy-MM-dd HH24:MI:SS') AS fecha_inicio,
  TO_CHAR(t.fecha_fin, 'yyyy-MM-dd HH24:MI:SS') AS fecha_fin,
  t.color,
  m.nombre || ' ' || m.apellidos AS medico_nombre_completo,
  p.nombre || ' ' || p.ap_paterno AS paciente_nombre_completo,
  t.motivo_consulta,
t.status
FROM
  lista_espera t
  LEFT JOIN usuario m ON t.asignado_id = m.id AND m.rol = 'MED'
  LEFT JOIN paciente p ON t.paciente_id = p.id
WHERE
  t.calendario_id = @id"""), parameters: {"id": consultorioId});

      for (final row in result) {
        tareas.add({
          'id': row[0],
          'nombre': row[1],
          'fecha_inicio': row[2],
          'fecha_fin': row[3],
          'color': row[4],
          'asignado_id': row[5],
          'paciente_id': row[6],
          'motivo_consulta': row[7],
          'status': row[8],
        });
      }

      await conn.close();
    } catch (e) {
      print('Error: $e');
    }
    return tareas;
  }

  static Future<bool> isHorarioDisponible(
      int consultorioId, DateTime fechaInicio, DateTime fechaFin) async {
    try {
      print("EJECUTANDO IS HORARIO DISPONIBLE");
      final conn = await _connect();

      final result = await conn.execute(
        Sql.named("""
        SELECT 1 
        FROM tarea 
        WHERE calendario_id = @id 
          AND ((fecha_inicio <= @fechaInicio AND fecha_fin >= @fechaFin))
      """),
        parameters: {
          "id": consultorioId,
          "fechaInicio": fechaInicio.toIso8601String(),
          "fechaFin": fechaFin.toIso8601String(),
        },
      );

      await conn.close();

      return result.isEmpty;
    } catch (e) {
      print('Error en horario disponible: $e');
      return false;
    }
  }

  static Future<void> moverCitaDeListaEspera(
      int listaEsperaId,
      int consultorioId,
      DateTime fechaInicio,
      DateTime fechaFin,
      String nombre,
      String motivoConsulta,
      int asignadoId,
      int pacienteId) async {
    print("EJECUTANDO MOVER CITA DE LISTA ESPERA");
    if (await isHorarioDisponible(consultorioId, fechaInicio, fechaFin)) {
      try {
        final conn = await _connect();

        final result = await conn.execute("SELECT MAX(id) FROM tarea");
        int lastId = (result.first.first as int?) ?? 0;
        int newId = lastId + 1;

        // Insertar en la tabla tarea
        await conn.execute(
          Sql.named("""
          INSERT INTO tarea (id, token, nombre, descripcion, fecha_inicio, fecha_fin, calendario_id, color, status, asignado_id, paciente_id, motivo_consulta, tipo_cita) 
        SELECT @newId, token, nombre, descripcion, @fechaInicio, @fechaFin, calendario_id, color, 'PROGRAMADA', asignado_id, paciente_id, motivo_consulta, tipo_cita
        FROM lista_espera
        WHERE id = @id
        """),
          parameters: {
            "newId": newId,
            "id": listaEsperaId,
            "fechaInicio": fechaInicio.toIso8601String(),
            "fechaFin": fechaFin.toIso8601String(),
          },
        );

        // Eliminar de la lista de espera
        await conn.execute(
          Sql.named("DELETE FROM lista_espera WHERE id = @id"),
          parameters: {
            "id": listaEsperaId,
          },
        );

        await conn.close();
      } catch (e) {
        print('Error en mover cita de lista: $e');
      }
    } else {
      print('El horario no está disponible.');
    }
  }

  static Future<void> verificarYMoverCitasEnEspera() async {
    try {
      final conn = await _connect();

      print("EJECUTANDO VERIFICAR Y MOVER CITAS EN ESPERA");

      final result = await conn.execute("""
      SELECT id, calendario_id, fecha_inicio, fecha_fin, nombre, motivo_consulta, asignado_id, paciente_id 
      FROM lista_espera

    """);

      for (final row in result) {
        final int listaEsperaId = row[0] as int;
        final int consultorioId = row[1] as int;
        final DateTime fechaInicio = row[2] as DateTime;
        final DateTime fechaFin = row[3] as DateTime;
        final String nombre = row[4] as String;
        final String motivoConsulta = row[5] as String;
        final int asignadoId = row[6] as int;
        final int pacienteId = row[7] as int;

        if (await isHorarioDisponible(consultorioId, fechaInicio, fechaFin)) {
          await moverCitaDeListaEspera(
              listaEsperaId,
              consultorioId,
              fechaInicio,
              fechaFin,
              nombre,
              motivoConsulta,
              asignadoId,
              pacienteId);
        }
      }

      await conn.close();
    } catch (e) {
      print('Error en verificar y mover cita: $e');
    }
  }

  static Future<bool> canReagendar(
    int consultorioId,
    String newStartTime,
    String newEndTime,
  ) async {
    try {
      final conn = await _connect();
      // Realiza la consulta y obtén el resultado
      final result = await conn.execute(Sql.named("""
        WITH horarios AS (
  SELECT 
    id,
    unnest(
      CASE EXTRACT(DOW FROM @nuevaFechaInicio::timestamp AT TIME ZONE 'UTC')
        WHEN 0 THEN string_to_array(domingo, ',')
        WHEN 1 THEN string_to_array(lunes, ',')
        WHEN 2 THEN string_to_array(martes, ',')
        WHEN 3 THEN string_to_array(miercoles, ',')
        WHEN 4 THEN string_to_array(jueves, ',')
        WHEN 5 THEN string_to_array(viernes, ',')
        WHEN 6 THEN string_to_array(sabado, ',')
      END
    ) AS horario
  FROM horario_consultorio
  WHERE id = @calendarioId
),
conflicto_horario AS (
  SELECT 1 
  FROM horarios
  WHERE
    (@nuevaFechaInicio::timestamp AT TIME ZONE 'UTC')::time < split_part(horario, '-', 2)::time
    AND (@nuevaFechaFin::timestamp AT TIME ZONE 'UTC')::time > split_part(horario, '-', 1)::time
)
SELECT 
  CASE 
    WHEN EXISTS (
      SELECT 1 
      FROM evento 
      WHERE calendario_id = @calendarioId
        AND ((@nuevaFechaInicio >= fecha_inicio AND @nuevaFechaInicio < fecha_fin) 
        OR (@nuevaFechaFin > fecha_inicio AND @nuevaFechaFin <= fecha_fin) 
        OR (@nuevaFechaInicio < fecha_inicio AND @nuevaFechaFin > fecha_fin))
    ) 
    OR EXISTS (
      SELECT 1 
      FROM tarea 
      WHERE calendario_id = @calendarioId
        AND ((@nuevaFechaInicio >= fecha_inicio AND @nuevaFechaInicio < fecha_fin) 
        OR (@nuevaFechaFin > fecha_inicio AND @nuevaFechaFin <= fecha_fin) 
        OR (@nuevaFechaInicio < fecha_inicio AND @nuevaFechaFin > fecha_fin))
    )
    OR NOT EXISTS (
      SELECT 1 FROM conflicto_horario
    )
    THEN 1
    ELSE 0
  END AS conflicto;

    """), parameters: {
        'calendarioId': consultorioId,
        'nuevaFechaInicio': newStartTime,
        'nuevaFechaFin': newEndTime,
      });

      await conn.close();

      // El resultado es un solo valor en la primera fila, obtenemos ese valor
      final count = result.isNotEmpty ? result.first[0] as int : 1;

      // Si count es 0, no hay conflictos, por lo tanto, se puede reagendar
      final canReagendar = count == 0;

      return canReagendar;
    } catch (e) {
      print('Error en canReagendarEvento: $e');
      return false; // Devuelve false en caso de error
    }
  }

  static Future<void> deleteListaEspera(int listaId) async {
    try {
      final conn = await _connect();

      await conn.execute(Sql.named("DELETE FROM lista_espera WHERE id = @id"),
          parameters: {
            "id": listaId,
          });

      await conn.close();
    } catch (e) {
      print('Error: $e');
    }
  }

  static Future<bool> updateListaEspera(
    int listaEsperaId,
    DateTime newStartTime,
    DateTime newEndTime,
  ) async {
    try {
      final conn = await _connect();

      // Verificar si el nuevo horario ajustado está disponible
      bool puedeReagendar =
          await canReagendarLista(listaEsperaId, newStartTime, newEndTime);

      if (!puedeReagendar) {
        print('Conflicto detectado, no se puede reagendar.');
        return false; // No se puede reagendar debido a conflictos
      }

      // Actualizar el evento en la base de datos con las fechas ajustadas
      await conn.execute(
        Sql.named("""
            UPDATE lista_espera
            SET fecha_inicio = @adjustedStartTime,
                fecha_fin = @adjustedEndTime
            WHERE id = @listaEsperaId
            """),
        parameters: {
          'adjustedStartTime': newStartTime,
          'adjustedEndTime': newEndTime,
          'listaEsperaId': listaEsperaId,
        },
      );

      await conn.close();
      return true; // Reagendamiento exitoso
    } catch (e) {
      print('Error en reagendarEvento: $e');
      return false; // Error durante el proceso
    }
  }

  static Future<bool> canReagendarLista(
    int consultorioId,
    DateTime newStartTime,
    DateTime newEndTime,
  ) async {
    try {
      final conn = await _connect();
      // Realiza la consulta y obtén el resultado
      final result = await conn.execute(Sql.named("""
        WITH horarios AS (
    SELECT 
        id,
        unnest(
            CASE EXTRACT(DOW FROM @nuevaFechaInicio::timestamp)
                WHEN 0 THEN string_to_array(domingo, ',')
                WHEN 1 THEN string_to_array(lunes, ',')
                WHEN 2 THEN string_to_array(martes, ',')
                WHEN 3 THEN string_to_array(miercoles, ',')
                WHEN 4 THEN string_to_array(jueves, ',')
                WHEN 5 THEN string_to_array(viernes, ',')
                WHEN 6 THEN string_to_array(sabado, ',')
            END
        ) AS horario
    FROM horario_consultorio
    WHERE id = @calendarioId
)
SELECT 
  CASE 
    WHEN EXISTS (
      SELECT 1 
      FROM horarios
      WHERE
          @nuevaFechaInicio::timestamp::time < split_part(horario, '-', 2)::time
          AND @nuevaFechaFin::timestamp::time > split_part(horario, '-', 1)::time
    )
    THEN 0 
    ELSE 1 
  END AS conflicto;
    """), parameters: {
        'calendarioId': consultorioId,
        'nuevaFechaInicio': newStartTime,
        'nuevaFechaFin': newEndTime,
      });

      await conn.close();

      // El resultado es un solo valor en la primera fila, obtenemos ese valor
      final count = result.isNotEmpty ? result.first[0] as int : 1;

      // Si count es 0, no hay conflictos, por lo tanto, se puede reagendar
      final canReagendar = count == 0;

      return canReagendar;
    } catch (e) {
      print('Error en canReagendarEvento: $e');
      return false; // Devuelve false en caso de error
    }
  }
}
