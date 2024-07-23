import 'package:calendario_manik/models/tarea.dart';
import 'package:calendario_manik/pages/consulting_page.dart';
import 'package:postgres/postgres.dart';
import 'package:calendario_manik/models/evento.dart';
import 'package:calendario_manik/models/paciente.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:intl/intl.dart';

class DatabaseManager {
  static Future<Connection> _connect() async {
    tz.setLocalLocation(tz.getLocation('America/Mexico_City'));
    return await Connection.open(
      Endpoint(
        //host: '192.168.1.71',
        host: '192.168.1.182',
        port: 5432,
        database: 'medicalmanik',
        username: 'postgres',
        password: 'DJE20ben',
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
            "INSERT INTO tarea(id, token, nombre, descripcion, fecha_inicio, fecha_fin, calendario_id, asignado_id, color, motivo_consulta, tipo_cita) VALUES (@id, @token, @nombre,@descripcion, @fecha_inicio, @fecha_fin, @calendario_id, @asignado_id, @color, @motivo_consulta, @tipo_cita)"),
        parameters: {
          "id": newId,
          "token": 2,
          "nombre": tarea.nombre,
          "descripcion": tarea.nota,
          "fecha_inicio": startDate.toIso8601String(),
          "fecha_fin": endDate.toIso8601String(),
          "calendario_id": consultorioId,
          "asignado_id": 1,
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

  static Future<List<Map<String, dynamic>>> getTareasSeleccionadasData(
      int consultorioId) async {
    List<Map<String, dynamic>> tareas = [];
    try {
      final conn = await _connect();

      final result = await conn.execute(
          Sql.named(
              "select id, nombre, TO_CHAR(fecha_inicio,'yyyy-MM-dd HH24:MI:SS') fecha_inicio,  TO_CHAR(fecha_fin,'yyyy-MM-dd HH24:MI:SS') fecha_fin, color from tarea WHERE calendario_id=@id"),
          parameters: {
            "id": consultorioId,
          });
      for (final row in result) {
        tareas.add({
          'id': row[0],
          'nombre': row[1],
          'fecha_inicio': row[2],
          'fecha_fin': row[3],
          'color': row[4], // Agrega la columna color
        });
      }

      await conn.close();
    } catch (e) {
      print('Error: $e');
    }
    return tareas;
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
          "INSERT INTO tarea(id, token, nombre, descripcion, fecha_inicio, fecha_fin,  calendario_id,asignado_id, color, motivo_consulta, tipo_cita) VALUES (@id, @token, @nombre, @descripcion, @fecha_inicio, @fecha_fin,  @calendario_id, @asignado_id, @color, @motivo_consulta, @tipo_cita)",
        ),
        parameters: {
          "id": newId,
          "token": 2, // Asegúrate de obtener el token correcto
          "nombre": tarea.nombre, // Puedes cambiar esto según tus requisitos
          "descripcion": nota,
          "fecha_inicio": fechaInicioString,
          "fecha_fin": fechaFinString, // Utiliza la fecha y hora fin calculadas

          "calendario_id": consultorioId,
          "asignado_id": 1,
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
            "INSERT INTO tarea(id, token, nombre, descripcion, fecha_inicio, fecha_fin,calendario_id, color, asignado_id, motivo_consulta, tipo_cita) VALUES (@id, @token, @nombre,@descripcion, @fecha_inicio, @fecha_fin, @calendario_id, @color, @asignado_id, @motivo_consulta, @tipo_cita)"),
        parameters: {
          "id": newId,
          "token": 2,
          "nombre": tarea.nombre,
          "descripcion": tarea.nota,
          "fecha_inicio": startDate.toIso8601String(),
          "fecha_fin": endDate.toIso8601String(),
          "calendario_id": consultorioId,
          "color": '#0EEED6',
          "asignado_id": 1,
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
      final result = await conn.execute(
          Sql.named(
              "select id, nombre, TO_CHAR(fecha_inicio,'yyyy-MM-dd HH24:MI:SS') fecha_inicio,  TO_CHAR(fecha_fin,'yyyy-MM-dd HH24:MI:SS') fecha_fin, color from tarea WHERE calendario_id=@id"),
          parameters: {"id": consultorioId});

      print('Query executed. Processing results...');
      for (final row in result) {
        // print('Row: $row'); // Imprimir cada fila para verificar los datos
        tareas.add({
          'id': row[0],
          'nombre': row[1],
          'fecha_inicio': row[2],
          'fecha_fin': row[3],
          'color': row[4]
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

      // print(evento.fecha);
      // print(evento.hora);
      // Calcular la fecha de inicio y fin basándose en la duración
      DateTime startDate = DateTime.parse("${evento.fecha} ${evento.hora}");
      int duration = int.parse(evento.duracion);
      DateTime endDate = startDate.add(Duration(minutes: duration));

      await conn.execute(
        Sql.named(
            "INSERT INTO evento(id, token, nombre, descripcion, fecha_inicio, fecha_fin, usuario_id, calendario_id) VALUES (@id, @token, @nombre,@descripcion, @fecha_inicio, @fecha_fin, @usuario_id, @calendario_id)"),
        parameters: {
          "id": newId,
          "token": 2,
          "nombre": evento.nombre,
          "descripcion": evento.nota,
          "fecha_inicio": startDate.toIso8601String(),
          "fecha_fin": endDate.toIso8601String(),
          "usuario_id": 1, // Aquí deberías obtener el usuario_id correcto
          "calendario_id": consultorioId,
        },
      );

      await conn.close();
    } catch (e) {
      print('Error al insertar el evento: $e');
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
              "select id, nombre, TO_CHAR(fecha_inicio,'yyyy-MM-dd HH24:MI:SS') fecha_inicio,  TO_CHAR(fecha_fin,'yyyy-MM-dd HH24:MI:SS') fecha_fin from evento WHERE calendario_id=@id"),
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
  static Future<List<String>> searchPatients(String query) async {
    List<String> patients = [];
    try {
      final conn = await _connect();

      final result = await conn.execute(
        Sql.named("SELECT nombre FROM paciente WHERE nombre LIKE @query"),
        parameters: {"query": '%$query%'},
      );

      for (var row in result) {
        patients.add(row[0] as String);
      }

      await conn.close();
    } catch (e) {
      print('Error al buscar pacientes: $e');
    }
    return patients;
  }

  static Future<int> insertPaciente(Paciente paciente) async {
    try {
      final conn = await _connect();

      final result = await conn.execute("SELECT MAX(id) FROM paciente");
      int lastId = (result.first.first as int?) ?? 0;

      int newId = lastId + 1;

      await conn.execute(
        Sql.named(
            "INSERT INTO paciente(id, nombre, ap_paterno, ap_materno, fecha_nacimiento, sexo, telefono_movil, telefono_fijo, correo, direccion, identificador, curp, codigo_postal) VALUES (@id, @nombre, @ap_paterno, @ap_materno, @fechaNacimiento, @sexo, @telefonoMovil, @telefonoFijo, @correo, @direccion, @identificador, @curp, @codigoPostal)"),
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
          //"fechaRegistro": paciente.fechaRegistro.toIso8601String(),
          //"avatar": paciente.avatar,
          "fechaRegistro": paciente.fechaRegistro.toIso8601String(),
          "direccion": paciente.direccion,
          // "identificador": paciente.identificador,
          "curp": paciente.curp,
          "codigoPostal": paciente.codigoPostal,
          // "municipioId": paciente.municipioId,
          // "estadoId": paciente.estadoId,
          // "pais": paciente.pais,
          // "paisId": paciente.paisId,
          // "entidadNacimientoId": paciente.entidadNacimientoId,
          // "generoId": paciente.generoId,
        },
      );

      await conn.close();

      return newId;
    } catch (e) {
      print('Error al insertar el paciente: $e');
      return -1;
    }
  }

  static Future<List<Map<String, dynamic>>> getPacientes() async {
    List<Map<String, dynamic>> pacientes = [];
    try {
      final conn = await _connect();
      final result = await conn.execute("SELECT * FROM paciente");
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
          'identificador': row[13],
        });
      }
      await conn.close();
    } catch (e) {
      print('Error: $e');
    }
    return pacientes;
  }

  static Future<void> deletePaciente(int id) async {
    try {
      final conn = await _connect();
      await conn.execute(
        Sql.named("DELETE FROM paciente WHERE id = @id"),
        parameters: {"id": id},
      );
      await conn.close();
    } catch (e) {
      print('Error al eliminar el paciente: $e');
    }
  }

  //*Consultorios
  static Future<List<Map<String, dynamic>>> getConsultoriosData(id) async {
    List<Map<String, dynamic>> consultoriosData = [];
    try {
      final conn = await _connect();
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
      Consultorio consultorio, int usuarioId) async {
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
          "usuario_id": usuarioId,
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

  //*Horarios

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

  //*Usuario
  static Future<List<Map<String, dynamic>>> getUsuario() async {
    List<Map<String, dynamic>> usuarios = [];
    try {
      final conn = await _connect();
      final result = await conn.execute("SELECT * FROM usuario");
      for (var row in result) {
        usuarios.add({
          'id': row[0],
          'correo': row[1],
          'contrasena': row[2],
        });
      }

      await conn.close();
    } catch (e) {
      print('Error: $e');
    }
    return usuarios;
  }
}
