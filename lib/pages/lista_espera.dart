import 'package:calendario_manik/database/database.dart';
import 'package:flutter/material.dart';
import 'package:calendario_manik/models/tarea.dart';
import 'package:calendario_manik/pages/calendar_page.dart';

class ListaEspera extends StatefulWidget {
  final int? consultorioId;

  const ListaEspera({super.key, this.consultorioId});

  @override
  _ListaEsperaState createState() => _ListaEsperaState();
}

class _ListaEsperaState extends State<ListaEspera> {
  List<Map<String, dynamic>> eventosEnEspera = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    List<Map<String, dynamic>> lista =
        await DatabaseManager.getListaEsperaData(widget.consultorioId!);
    setState(() {
      eventosEnEspera = lista;
      _isLoading = false;
    });
  }

  Future<void> _verificarYMoverCitas() async {
    setState(() {
      _isLoading = true;
    });
    await DatabaseManager.verificarYMoverCitasEnEspera();
    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Espera'),
        leading: IconButton(
          icon: Icon(
              Icons.close), // Usa el ícono de calendario o cualquier otro ícono
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Calendar(),
              ),
            );
          },
        ),
      ),
      body: _isLoading
          ? Center(
              child:
                  CircularProgressIndicator(), // Indicador de carga mientras se obtienen los datos
            )
          : eventosEnEspera.isEmpty
              ? Center(
                  child: Text('Por el momento no hay pacientes esperando'),
                )
              : ListView.builder(
                  itemCount: eventosEnEspera.length,
                  itemBuilder: (context, index) {
                    final tarea = eventosEnEspera[index];
                    return ListTile(
                      title: Text(tarea['nombre']),
                      subtitle: Text(
                          '${tarea['fecha_inicio']} \n${tarea['fecha_fin']} \n${tarea['status']}'),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          setState(() async {
                            eventosEnEspera.removeAt(index);
                            //await DatabaseManager.delete();
                          });
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
