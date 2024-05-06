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

  static Future<List<String>> getConsultorios() async {
    List<String> consultorios = [];
    try {
      final conn = await _connect();

      final result = await conn.execute("SELECT nombre FROM consultorio");
      for (var row in result) {
        consultorios.add(row[0].toString());
      }

      await conn.close();
    } catch (e) {
      print('Error: $e');
    }
    return consultorios;
  }

  static Future<void> insertConsultorio(Consultorio consultorio) async {
    try {
      final conn = await _connect();

      final result = await conn.execute("SELECT MAX(id) FROM consultorio");
      int lastId = (result.first.first as int?) ?? 0;

      int newId = lastId + 1;

      await conn.execute(
        Sql.named(
            "INSERT INTO consultorio(id, nombre, telefono, direccion) VALUES (@id, @nombre, @telefono, @direccion)"),
        parameters: {
          "id": newId,
          "nombre": consultorio.nombre,
          "telefono": consultorio.telefono,
          "direccion": consultorio.direccion
        },
      );

      await conn.close();
    } catch (e) {
      print('Error al insertar el consultorio: $e');
    }
  }
}
