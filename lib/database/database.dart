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
        host: '192.168.1.72',
        //host: '192.168.1.181',
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

  static Future<List<Map<String, dynamic>>> getRecomeDiaria() async {
    List<Map<String, dynamic>> recomeDiaria = [];
    try {
      final conn = await _connect();
      print('Zona horaria actual: ${await conn.execute('SHOW timezone;')}');
      print(
          'Fecha y hor actual: ${await conn.execute('SELECT CURRENT_TIMESTAMP;')}');
      print('Zona horaria actual: ${await conn.execute('SHOW timezone;')}');
      final result = await conn.execute("""
 


WITH fechas AS (
    SELECT CURRENT_DATE + s.i AS recomendacion_semanal,
        lower(translate(to_char((CURRENT_DATE + s.i)::timestamp with time zone, 'TMDay'::text), 'ÁÉÍÓÚáéíóú'::text, 'AEIOUaeiou'::text)) AS dia_de_la_semana,
        to_char(CURRENT_TIMESTAMP AT TIME ZONE 'America/Mexico_City', 'HH24:MI'::text) AS hora_actual,
        to_char(CURRENT_TIMESTAMP AT TIME ZONE 'America/Mexico_City', 'YYYY-MM-DD HH24:MI:SS TZ') AS fecha_hora_zona,
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
    SELECT date(evento.fecha_inicio) AS fecha_evento,
        to_char(evento.fecha_inicio, 'HH24:MI'::text) AS hora_inicio,
        to_char(evento.fecha_fin, 'HH24:MI'::text) AS hora_fin
    FROM evento
), tareas AS (
    SELECT
        date(tarea.fecha_inicio) AS fecha_tarea,
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
        AND to_char(f.recomendacion_semanal + (split_part(h.hora, '-'::text, 1)::interval), 'HH24:MI'::text) >= e.hora_inicio
        AND to_char(f.recomendacion_semanal + (split_part(h.hora, '-'::text, 2)::interval), 'HH24:MI'::text) <= e.hora_fin
    )
    AND NOT EXISTS (
        SELECT 1
        FROM tareas t
        WHERE f.recomendacion_semanal = t.fecha_tarea
        AND to_char(f.recomendacion_semanal + (split_part(h.hora, '-'::text, 1)::interval), 'HH24:MI'::text) >= t.hora_inicio_tarea
        AND to_char(f.recomendacion_semanal + (split_part(h.hora, '-'::text, 2)::interval), 'HH24:MI'::text) <= t.hora_fin_tarea
    )
    AND (
        f.recomendacion_semanal > CURRENT_DATE OR
        f.recomendacion_semanal = CURRENT_DATE AND to_char(f.recomendacion_semanal + (split_part(h.hora, '-'::text, 1)::interval), 'HH24:MI'::text) >= f.hora_actual
    )
    ORDER BY f.recomendacion_semanal, h.hora
)
SELECT to_char(recomendacion_semanal::timestamp with time zone, 'YYYY-MM-DD'::text) AS recomendacion_semanal,
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
      print(result);
      await conn.close();
    } catch (e) {
      print('Error: $e');
    }
    return recomeDiaria;
  }

  static Future<List<Map<String, dynamic>>> getRecomeSema() async {
    List<Map<String, dynamic>> recomeSema = [];
    try {
      final conn = await _connect();
      final result = await conn.execute("""
     
WITH fechas AS (
    SELECT 
        CURRENT_DATE + i AS recomendacion_semanal,
        LOWER(translate(TO_CHAR(CURRENT_DATE + i, 'TMDay'), 'ÁÉÍÓÚáéíóú', 'AEIOUaeiou')) AS dia_de_la_semana,
        TO_CHAR(CURRENT_TIMESTAMP, 'HH24:MI') AS hora_actual
    FROM 
        generate_series(7, 30) AS s(i)
), 
horario AS (
    SELECT id, 'lunes' AS dia_de_la_semana, UNNEST(string_to_array(lunes, ',')) AS hora FROM horario_consultorio
    UNION ALL
    SELECT id, 'martes' AS dia_de_la_semana, UNNEST(string_to_array(martes, ',')) AS hora FROM horario_consultorio
    UNION ALL
    SELECT id, 'miercoles' AS dia_de_la_semana, UNNEST(string_to_array(miercoles, ',')) AS hora FROM horario_consultorio
    UNION ALL
    SELECT id, 'jueves' AS dia_de_la_semana, UNNEST(string_to_array(jueves, ',')) AS hora FROM horario_consultorio
    UNION ALL
    SELECT id, 'viernes' AS dia_de_la_semana, UNNEST(string_to_array(viernes, ',')) AS hora FROM horario_consultorio
    UNION ALL
    SELECT id, 'sabado' AS dia_de_la_semana, UNNEST(string_to_array(sabado, ',')) AS hora FROM horario_consultorio
    UNION ALL
    SELECT id, 'domingo' AS dia_de_la_semana, UNNEST(string_to_array(domingo, ',')) AS hora FROM horario_consultorio
), 
eventos AS (
    SELECT 
        DATE(fecha_inicio) AS fecha_evento,
        TO_CHAR(fecha_inicio, 'HH24:MI') AS hora_inicio,
        TO_CHAR(fecha_fin, 'HH24:MI') AS hora_fin
    FROM 
        evento
), 
tareas AS (
    SELECT 
        DATE(fecha_inicio) AS fecha_tarea,
        TO_CHAR(fecha_inicio, 'HH24:MI') AS hora_inicio,
        TO_CHAR(fecha_fin, 'HH24:MI') AS hora_fin
    FROM 
        tarea
), 
horas_libres AS (
    SELECT 
        f.recomendacion_semanal,
        f.dia_de_la_semana,
        SUBSTR(h.hora, 1, 5) AS hora_disponible
    FROM 
        fechas f
    JOIN 
        horario h ON f.dia_de_la_semana = h.dia_de_la_semana
    LEFT JOIN 
        eventos e ON f.recomendacion_semanal = e.fecha_evento 
        AND (
            (split_part(h.hora, '-', 1) >= e.hora_inicio AND split_part(h.hora, '-', 1) < e.hora_fin) 
            OR (split_part(h.hora, '-', 2) > e.hora_inicio AND split_part(h.hora, '-', 2) <= e.hora_fin) 
            OR (e.hora_inicio >= split_part(h.hora, '-', 1) AND e.hora_inicio < split_part(h.hora, '-', 2)) 
            OR (e.hora_fin > split_part(h.hora, '-', 1) AND e.hora_fin <= split_part(h.hora, '-', 2))
        )
    LEFT JOIN 
        tareas t ON f.recomendacion_semanal = t.fecha_tarea 
        AND (
            (split_part(h.hora, '-', 1) >= t.hora_inicio AND split_part(h.hora, '-', 1) < t.hora_fin) 
            OR (split_part(h.hora, '-', 2) > t.hora_inicio AND split_part(h.hora, '-', 2) <= t.hora_fin) 
            OR (t.hora_inicio >= split_part(h.hora, '-', 1) AND t.hora_inicio < split_part(h.hora, '-', 2)) 
            OR (t.hora_fin > split_part(h.hora, '-', 1) AND t.hora_fin <= split_part(h.hora, '-', 2))
        )
    WHERE 
        e.fecha_evento IS NULL 
        AND t.fecha_tarea IS NULL 
        AND (f.recomendacion_semanal > CURRENT_DATE OR (f.recomendacion_semanal = CURRENT_DATE AND split_part(h.hora, '-', 1) >= f.hora_actual))
    ORDER BY 
        f.recomendacion_semanal, h.hora
)
SELECT 
    TO_CHAR(recomendacion_semanal, 'YYYY-MM-DD') AS recomendacion_semanal,
    dia_de_la_semana,
    hora_disponible
FROM 
    horas_libres
LIMIT 20;


    """);
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

  static Future<List<Map<String, dynamic>>> getRecomeMen() async {
    List<Map<String, dynamic>> recomeMen = [];
    try {
      final conn = await _connect();
      final result = await conn.execute("""
      WITH fechas AS (
    SELECT 
        CURRENT_DATE + i AS recomendacion_semanal,
        LOWER(translate(TO_CHAR(CURRENT_DATE + i, 'TMDay'), 'ÁÉÍÓÚáéíóú', 'AEIOUaeiou')) AS dia_de_la_semana,
        TO_CHAR(CURRENT_TIMESTAMP, 'HH24:MI') AS hora_actual
    FROM 
        generate_series(31, 90) AS s(i)
), 
horario AS (
    SELECT id, 'lunes' AS dia_de_la_semana, UNNEST(string_to_array(lunes, ',')) AS hora FROM horario_consultorio
    UNION ALL
    SELECT id, 'martes' AS dia_de_la_semana, UNNEST(string_to_array(martes, ',')) AS hora FROM horario_consultorio
    UNION ALL
    SELECT id, 'miercoles' AS dia_de_la_semana, UNNEST(string_to_array(miercoles, ',')) AS hora FROM horario_consultorio
    UNION ALL
    SELECT id, 'jueves' AS dia_de_la_semana, UNNEST(string_to_array(jueves, ',')) AS hora FROM horario_consultorio
    UNION ALL
    SELECT id, 'viernes' AS dia_de_la_semana, UNNEST(string_to_array(viernes, ',')) AS hora FROM horario_consultorio
    UNION ALL
    SELECT id, 'sabado' AS dia_de_la_semana, UNNEST(string_to_array(sabado, ',')) AS hora FROM horario_consultorio
    UNION ALL
    SELECT id, 'domingo' AS dia_de_la_semana, UNNEST(string_to_array(domingo, ',')) AS hora FROM horario_consultorio
), 
eventos AS (
    SELECT 
        DATE(fecha_inicio) AS fecha_evento,
        TO_CHAR(fecha_inicio, 'HH24:MI') AS hora_inicio,
        TO_CHAR(fecha_fin, 'HH24:MI') AS hora_fin
    FROM 
        evento
), 
tareas AS (
    SELECT 
        DATE(fecha_inicio) AS fecha_tarea,
        TO_CHAR(fecha_inicio, 'HH24:MI') AS hora_inicio,
        TO_CHAR(fecha_fin, 'HH24:MI') AS hora_fin
    FROM 
        tarea
), 
horas_libres AS (
    SELECT 
        f.recomendacion_semanal,
        f.dia_de_la_semana,
        SUBSTR(h.hora, 1, 5) AS hora_disponible
    FROM 
        fechas f
    JOIN 
        horario h ON f.dia_de_la_semana = h.dia_de_la_semana
    LEFT JOIN 
        eventos e ON f.recomendacion_semanal = e.fecha_evento 
        AND (
            (split_part(h.hora, '-', 1) >= e.hora_inicio AND split_part(h.hora, '-', 1) < e.hora_fin) 
            OR (split_part(h.hora, '-', 2) > e.hora_inicio AND split_part(h.hora, '-', 2) <= e.hora_fin) 
            OR (e.hora_inicio >= split_part(h.hora, '-', 1) AND e.hora_inicio < split_part(h.hora, '-', 2)) 
            OR (e.hora_fin > split_part(h.hora, '-', 1) AND e.hora_fin <= split_part(h.hora, '-', 2))
        )
    LEFT JOIN 
        tareas t ON f.recomendacion_semanal = t.fecha_tarea 
        AND (
            (split_part(h.hora, '-', 1) >= t.hora_inicio AND split_part(h.hora, '-', 1) < t.hora_fin) 
            OR (split_part(h.hora, '-', 2) > t.hora_inicio AND split_part(h.hora, '-', 2) <= t.hora_fin) 
            OR (t.hora_inicio >= split_part(h.hora, '-', 1) AND t.hora_inicio < split_part(h.hora, '-', 2)) 
            OR (t.hora_fin > split_part(h.hora, '-', 1) AND t.hora_fin <= split_part(h.hora, '-', 2))
        )
    WHERE 
        e.fecha_evento IS NULL 
        AND t.fecha_tarea IS NULL 
        AND (f.recomendacion_semanal > CURRENT_DATE OR (f.recomendacion_semanal = CURRENT_DATE AND split_part(h.hora, '-', 1) >= f.hora_actual))
    ORDER BY 
        f.recomendacion_semanal, h.hora
)
SELECT 
    TO_CHAR(recomendacion_semanal, 'YYYY-MM-DD') AS recomendacion_semanal,
    dia_de_la_semana,
    hora_disponible
FROM 
    horas_libres
LIMIT 20;

    """);
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
      print('Connecting to database...');
      final conn = await _connect();

      print('Connected. Executing query with consultorioId: $consultorioId');
      final result = await conn.execute(Sql.named("""SELECT
  t.id,
  t.nombre AS tarea_nombre,
  TO_CHAR(t.fecha_inicio, 'yyyy-MM-dd HH24:MI:SS') AS fecha_inicio,
  TO_CHAR(t.fecha_fin, 'yyyy-MM-dd HH24:MI:SS') AS fecha_fin,
  t.color,
  m.nombre || ' ' || m.apellidos AS medico_nombre_completo,
  p.nombre || ' ' || p.ap_paterno AS paciente_nombre_completo,
  t.motivo_consulta
FROM
  tarea t
  LEFT JOIN usuario m ON t.asignado_id = m.id AND m.rol = 'MED'
  LEFT JOIN paciente p ON t.paciente_id = p.id
WHERE
  t.calendario_id = @id"""), parameters: {"id": consultorioId});

      print('Query executed. Processing results...');
      for (final row in result) {
        // print('Row: $row'); // Imprimir cada fila para verificar los datos
        tareas.add({
          'id': row[0],
          'nombre': row[1],
          'fecha_inicio': row[2],
          'fecha_fin': row[3],
          'color': row[4],
          'asignado_id': row[5],
          'paciente_id': row[6],
          'motivo_consulta': row[7],
        });
      }

      await conn.close();
      // print('Connection closed.');
    } catch (e) {
      print('Error: $e');
    }
    // print('Tareas: $tareas'); // Imprimir el resultado final
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
            "INSERT INTO evento(id, token, nombre, descripcion, fecha_inicio, fecha_fin, all_day, usuario_id, calendario_id,tarea) VALUES (@id, @token, @nombre,@descripcion, @fecha_inicio, @fecha_fin, @all_day, @usuario_id, @calendario_id, @tarea)"),
        parameters: {
          "id": newId,
          "token": 2,
          "nombre": evento.nombre,
          "descripcion": evento.nota,
          "fecha_inicio": startDate.toIso8601String(),
          "fecha_fin": endDate.toIso8601String(),
          "all_day": evento.allDay,
          "usuario_id": 1, // Aquí deberías obtener el usuario_id correcto
          "calendario_id": consultorioId,
          "tarea": evento.servicio,
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
              "select id, nombre,TO_CHAR(fecha_inicio,'yyyy-MM-dd HH24:MI:SS') fecha_inicio,  TO_CHAR(fecha_fin,'yyyy-MM-dd HH24:MI:SS')fecha_fin from evento WHERE calendario_id=@id"),
          parameters: {
            "id": consultorioId,
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
      int consultorioId, int offset, int limit) async {
    List<Map<String, dynamic>> pacientes = [];
    try {
      final conn = await _connect();
      String query;

      if (usuario_cuenta_id == 3) {
        // Consulta SQL para el caso de usuario con ID 3
        query = """
        SELECT u.*
        FROM paciente u
        JOIN grupo_paciente gp ON u.id = gp.paciente_id
        WHERE gp.grupo_id = $grupo_id
        LIMIT ? OFFSET ?;
      """;
        final result = await conn.execute(Sql.named(query),
            parameters: {"limit": limit, "offset": offset});
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
  COALESCE(gm.grupo_id, ga.grupo_id) AS grupo_id
FROM
  usuario u
LEFT JOIN
  grupo_medico gm ON u.id = gm.medico_id
LEFT JOIN
  grupo_asistente ga ON u.id = ga.asistente_id
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
}
