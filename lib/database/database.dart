import 'package:calendario_manik/pages/add_page.dart';
import 'package:calendario_manik/pages/consulting_page.dart';
import 'package:postgres/postgres.dart';
import 'package:calendario_manik/pages/evento_content.dart';
import 'package:calendario_manik/models/evento.dart';
import 'package:calendario_manik/models/paciente.dart';

class DatabaseManager {
  static Future<Connection> _connect() async {
    return await Connection.open(
      Endpoint(
        host: 'localhost',
        database: 'medicalmanik',
        username: 'postgres',
        password: 'DJE20ben',
      ),
      settings: ConnectionSettings(sslMode: SslMode.disable),
    );
  }

  static Future<void> connectAndExecuteQuery() async {
    try {
      final conn = await _connect();
      print('Conexion a base de datos exitosa!');

      await conn.close();
    } catch (e) {
      print('Error: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> getConsultoriosData() async {
    List<Map<String, dynamic>> consultoriosData = [];
    try {
      final conn = await _connect();
      // final result = await conn.execute(
      //     Sql.named("SELECT * FROM consultorio WHERE usuario_id=@id"),
      //     parameters: {"id": id});
      final result = await conn.execute("SELECT * FROM consultorio");
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

  static Future<int> insertConsultorio(Consultorio consultorio) async {
    try {
      final conn = await _connect();
      final result = await conn.execute("SELECT MAX(id) FROM consultorio");
      int lastId = (result.first.first as int?) ?? 0;
      int newId = lastId + 1;
      await conn.execute(
        Sql.named(
            "INSERT INTO consultorio(id, nombre, direccion, colonia_id, telefono, intervalo) VALUES (@id, @nombre, @direccion, @colonia_id, @telefono, @intervalo)"),
        parameters: {
          "id": newId,
          "nombre": consultorio.nombre,
          "direccion": consultorio.direccion,
          "colonia_id": consultorio.codigoPostal,
          "telefono": consultorio.telefono,
          "intervalo": consultorio.intervaloAtencion,
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

  static List<String> parseHorarios(String horarios) {
    if (horarios.isEmpty) return [];
    return horarios.split(',');
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

  static Future<int> insertPaciente(Paciente paciente) async {
    try {
      final conn = await _connect();

      final result = await conn.execute("SELECT MAX(id) FROM paciente");
      int lastId = (result.first.first as int?) ?? 0;

      int newId = lastId + 1;

      await conn.execute(
        Sql.named(
            "INSERT INTO paciente(id, nombre, ap_paterno, ap_materno, fecha_nacimiento, sexo, telefono_movil, telefono_fijo, correo,  direccion, identificador, curp, codigo_postal) VALUES (@id, @nombre, @ap_paterno, @ap_materno, @fechaNacimiento, @sexo, @telefonoMovil, @telefonoFijo, @correo, @direccion, @identificador, @curp, @codigoPostal)"),
        parameters: {
          "id": newId,
          "nombre": paciente.nombre,
          "ap_paterno": paciente.apPaterno,
          "ap_materno": paciente.apMaterno,
          "fechaNacimiento": paciente.fechaNacimiento,
          "sexo": paciente.sexo,
          //"coloniaId": paciente.coloniaId,
          "telefonoMovil": paciente.telefonoMovil,
          "telefonoFijo": paciente.telefonoFijo,
          "correo": paciente.correo,
          //"avatar": paciente.avatar,
          //"fechaRegistro": paciente.fechaRegistro.toIso8601String(),
          "direccion": paciente.direccion,
          "identificador": paciente.identificador,
          "curp": paciente.curp,
          "codigoPostal": paciente.codigoPostal,
          //"municipioId": paciente.municipioId,
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

  static Future<void> insertEvento(int consultorioId, Evento evento) async {
    try {
      final conn = await _connect();

      final result = await conn.execute("SELECT MAX(id) FROM evento");
      int lastId = (result.first.first as int?) ?? 0;

      int newId = lastId + 1;

      // Calcular la fecha de inicio y fin basándose en la duración
      DateTime startDate = DateTime.parse(evento.fecha + " " + evento.hora);
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

  static Future<int> insertCitaInmediata(
      int consultorioId, Evento evento, String nota) async {
    try {
      final conn = await _connect();

      final result = await conn.execute("SELECT MAX(id) FROM evento");
      int lastId = (result.first.first as int?) ?? 0;

      int newId = lastId + 1;

      // Obtener la fecha y hora actual
      DateTime now = DateTime.now();

      await conn.execute(
        Sql.named(
          "INSERT INTO evento(id, token, nombre, descripcion, fecha_inicio, fecha_fin, usuario_id, calendario_id) VALUES (@id, @token, @nombre, @descripcion, @fecha_inicio, @fecha_fin, @usuario_id, @calendario_id)",
        ),
        parameters: {
          "id": newId,
          "token": 2, // Asegúrate de obtener el token correcto
          "nombre": evento.nombre, // Puedes cambiar esto según tus requisitos
          "descripcion": nota,
          "fecha_inicio": now.toIso8601String(),
          "fecha_fin":
              now.toIso8601String(), // Misma fecha y hora para cita inmediata
          "usuario_id":
              1, // Ajusta el usuario_id según tu lógica de autenticación
          "calendario_id": consultorioId,
        },
      );

      await conn.close();

      return newId;
    } catch (e) {
      print('Error al insertar la cita inmediata: $e');
      return -1;
    }
  }

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

  static Future<List<Map<String, dynamic>>> getPatients() async {
    try {
      final conn = await _connect();
      final result = await conn.execute("SELECT * FROM paciente");
      List<Map<String, dynamic>> patients = [];
      for (var row in result) {
        patients.add({
          'id': row[0],
          'nombre': row[1],
          'apPaterno': row[2],
          'apMaterno': row[3],
          'fechaNacimiento': row[4],
          'sexo': row[5],
          'telefonoMovil': row[7],
          'telefonoFijo': row[8],
          'correo': row[9],
        });
      }
      await conn.close();
      return patients;
    } catch (e) {
      print('Error: $e');
      return [];
    }
  }
}
