import 'package:calendario_manik/pages/add_page.dart';
import 'package:calendario_manik/pages/consulting_page.dart';
import 'package:postgres/postgres.dart';

class DatabaseManager {
  static Future<Connection> _connect() async {
    return await Connection.open(
      Endpoint(
        host: 'localhost',
        database: 'medicalmanik',
        username: 'postgres',
        password: '123',
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

  static Future<void> insertConsultorio(Consultorio consultorio) async {
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
    } catch (e) {
      print('Error al insertar el consultorio: $e');
    }
  }

  static Future<void> insertHorarioConsultorio(
    int consultorioId,
    List<int> lunes,
    List<int> martes,
    List<int> miercoles,
    List<int> jueves,
    List<int> viernes,
    List<int> sabado,
    List<int> domingo,
  ) async {
    try {
      final conn = await _connect();

      await conn.execute(
        Sql.named(
            "INSERT INTO horario_consultorio(id, lunes, martes, miercoles, jueves, viernes, sabado, domingo) VALUES (@id,  @lunes, @martes, @miercoles, @jueves, @viernes, @sabado, @domingo)"),
        parameters: {
          "id": consultorioId,
          "lunes": lunes.join(
              ','), // Convertir la lista de enteros en una cadena de texto separada por comas
          "martes": martes.join(','),
          "miercoles": miercoles.join(','),
          "jueves": jueves.join(','),
          "viernes": viernes.join(','),
          "sabado": sabado.join(','),
          "domingo": domingo.join(','),
        },
      );

      await conn.close();
    } catch (e) {
      print('Error al insertar los horarios: $e');
    }
  }

  static Future<Map<String, List<int>>> getHorarioConsultorio(
      int consultorioId) async {
    Map<String, List<int>> horarios = {};

    try {
      final conn = await _connect();

      final result = await conn.execute(
        Sql.named("SELECT * FROM horario_consultorio WHERE id = @id"),
        parameters: {"id": consultorioId},
      );

      for (var row in result) {
        // Procesar los horarios recuperados y actualizar el mapa
        // Acceder directamente a las columnas por su nombre
        List<int> lunesHorarios =
            row[1]?.toString().split(',').map(int.parse).toList() ?? [];
        List<int> martesHorarios =
            row[2]?.toString().split(',').map(int.parse).toList() ?? [];
        // List<int> miercolesHorarios =
        //     row[3]?.toString().split(',').map(int.parse).toList() ?? [];
        // List<int> juevesHorarios =
        //     row[4]?.toString().split(',').map(int.parse).toList() ?? [];
        // List<int> viernesHorarios =
        //     row[5]?.toString().split(',').map(int.parse).toList() ?? [];
        // List<int> sabadoHorarios =
        //     row[6]?.toString().split(',').map(int.parse).toList() ?? [];
        // List<int> domingoHorarios =
        //     row[7]?.toString().split(',').map(int.parse).toList() ?? [];
        // Actualiza el mapa de horarios
        horarios['Lunes'] = lunesHorarios;
        horarios['Martes'] = martesHorarios;
        // horarios['Miércoles'] = miercolesHorarios;
        // horarios['Jueves'] = juevesHorarios;
        // horarios['Viernes'] = viernesHorarios;
        // horarios['Sábado'] = sabadoHorarios;
        // horarios['Domingo'] = domingoHorarios;
        // Actualiza los demás días de la semana
        print(horarios);
      }

      await conn.close();
    } catch (e) {
      print('Error al convertir horarios del lunes: $e');
    }

    return horarios;
  }

  static Future<void> updateHorarioConsultorio(
    int consultorioId,
    List<int> lunesHorarios,
    List<int> martesHorarios,
    List<int> miercolesHorarios,
    List<int> juevesHorarios,
    List<int> viernesHorarios,
    List<int> sabadoHorarios,
    List<int> domingoHorarios,
  ) async {
    try {
      final conn = await _connect();

      await conn.execute(
        Sql.named(
            "UPDATE horario_consultorio SET lunes = @lunes, martes = @martes, miercoles = @miercoles, jueves = @jueves, viernes = @viernes, sabado = @sabado, domingo = @domingo WHERE id = @id"),
        parameters: {
          "id": consultorioId,
          "lunes": lunesHorarios.join(
              ','), // Convierte la lista de horarios en un string separado por comas
          "martes": martesHorarios.join(','),
          "miercoles": miercolesHorarios.join(','),
          "jueves": juevesHorarios.join(','),
          "viernes": viernesHorarios.join(','),
          "sabado": sabadoHorarios.join(','),
          "domingo": domingoHorarios.join(','),
        },
      );

      await conn.close();
    } catch (e) {
      print('Error al actualizar el consultorio: $e');
    }
  }

  static Future<void> insertEvento(Evento evento) async {
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
          "token": 1,
          "nombre": evento.nombre,
          "descripcion": evento.nota,
          "fecha_inicio": startDate.toIso8601String(),
          "fecha_fin": endDate.toIso8601String(),
          "usuario_id": 1,
          "calendario_id": 1,
        },
      );

      await conn.close();
    } catch (e) {
      print('Error al insertar el evento: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> getEventosData() async {
    List<Map<String, dynamic>> eventos = [];
    try {
      final conn = await _connect();

      final result = await conn.execute("SELECT * FROM evento");
      for (final row in result) {
        eventos.add({
          'id': row[0],
          'nombre': row[2],
          'fecha_inicio': row[4],
          'fecha_fin': row[5],
        });
      }

      print(eventos);
      await conn.close();
    } catch (e) {
      print('Error: $e');
    }
    return eventos;
  }
}
