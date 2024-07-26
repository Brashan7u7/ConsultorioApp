import 'package:flutter/material.dart';
import 'package:calendario_manik/models/tarea.dart';

class ListaEspera extends StatefulWidget {
  final Tarea? tarea;

  const ListaEspera({super.key, this.tarea});

  @override
  _ListaEsperaState createState() => _ListaEsperaState();
}

class _ListaEsperaState extends State<ListaEspera> {
  List<Tarea> eventosEnEspera = [];

  @override
  void initState() {
    super.initState();
    if (widget.tarea != null) {
      // Agrega el evento recibido a la lista de espera si no es nulo
      eventosEnEspera.add(widget.tarea!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Espera'),
      ),
      body: eventosEnEspera.isEmpty
          ? Center(
              child: Text('Por el momento no hay pacientes esperando'),
            )
          : ListView.builder(
              itemCount: eventosEnEspera.length,
              itemBuilder: (context, index) {
                final tarea = eventosEnEspera[index];
                return ListTile(
                  title: Text(tarea.nombre),
                  subtitle: Text(' ${tarea.fecha} ${tarea.hora}'),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      setState(() {
                        eventosEnEspera.removeAt(index);
                      });
                    },
                  ),
                );
              },
            ),
    );
  }
}
