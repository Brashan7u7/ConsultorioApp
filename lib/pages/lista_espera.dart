import 'package:calendario_manik/database/database.dart';
import 'package:flutter/material.dart';
import 'package:calendario_manik/pages/calendar_page.dart';
import 'package:intl/intl.dart';

class ListaEspera extends StatefulWidget {
  final int? consultorioId;

  const ListaEspera({
    super.key,
    this.consultorioId,
  });

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

  Future<void> _mostrarDialogoModificarTarea(Map<String, dynamic> tarea) async {
    DateTime? selectedDate = DateTime.tryParse(tarea['fecha_inicio']);
    TimeOfDay selectedTime =
        TimeOfDay.fromDateTime(selectedDate ?? DateTime.now());
    int selectedInterval = 60;

    TextEditingController dateController = TextEditingController(
        text: selectedDate?.toLocal().toString().split(' ')[0] ?? '');
    TextEditingController timeController =
        TextEditingController(text: selectedTime.format(context));

    DateFormat dateFormat = DateFormat('yyyy-MM-dd HH:mm');
    DateTime? newStartDateTime;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Reprogramar'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: dateController,
                decoration: InputDecoration(
                  labelText: 'Fecha',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(width: 1, color: Colors.grey),
                  ),
                  filled: true,
                  fillColor: Colors.transparent,
                ),
                onChanged: (value) {
                  selectedDate = DateTime.tryParse(value);
                  if (selectedDate != null) {
                    newStartDateTime = DateTime(
                      selectedDate!.year,
                      selectedDate!.month,
                      selectedDate!.day,
                      selectedTime.hour,
                      selectedTime.minute,
                    );
                  }
                },
              ),
              const SizedBox(height: 20.0),
              TextField(
                controller: timeController,
                decoration: InputDecoration(
                  labelText: 'Hora',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(width: 1, color: Colors.grey),
                  ),
                  filled: true,
                  fillColor: Colors.transparent,
                ),
                readOnly: true,
                onTap: () async {
                  final TimeOfDay? picked = await showTimePicker(
                    context: context,
                    initialTime: selectedTime,
                  );
                  if (picked != null && picked != selectedTime) {
                    setState(() {
                      selectedTime = picked;
                      timeController.text = selectedTime.format(context);
                      newStartDateTime = DateTime(
                        selectedDate?.year ?? DateTime.now().year,
                        selectedDate?.month ?? DateTime.now().month,
                        selectedDate?.day ?? DateTime.now().day,
                        selectedTime.hour,
                        selectedTime.minute,
                      );
                    });
                  }
                },
              ),
              const SizedBox(height: 20.0),
              DropdownButtonFormField<int>(
                items: const [
                  DropdownMenuItem<int>(value: 60, child: Text('60 minutos')),
                  DropdownMenuItem<int>(value: 30, child: Text('30 minutos')),
                  DropdownMenuItem<int>(value: 20, child: Text('20 minutos')),
                  DropdownMenuItem<int>(value: 15, child: Text('15 minutos')),
                ],
                value: selectedInterval,
                onChanged: (value) {
                  setState(() {
                    selectedInterval = value!;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Intervalo de Atención (minutos)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(width: 1, color: Colors.grey),
                  ),
                  filled: true,
                  fillColor: Colors.transparent,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                final endTime =
                    newStartDateTime!.add(Duration(minutes: selectedInterval));
                int citaId = tarea['id'];
                final canReagendar = await DatabaseManager.canReagendarLista(
                    citaId, newStartDateTime!, endTime);
                if (canReagendar) {
                  await DatabaseManager.updateListaEspera(
                      citaId, newStartDateTime!, endTime);

                  await Future.delayed(const Duration(milliseconds: 1500));

                  Navigator.of(context).pop();
                  setState(() {
                    _loadData();
                  });
                } else {
                  await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Conflicto de horario'),
                        content: const Text(
                            'La nueva fecha y hora chocan con un evento existente o no se puede reagendar en ese horario. Por favor, elige otro horario.'),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              child: Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveChanges() async {
    return;
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
                      trailing: Row(
                        mainAxisSize: MainAxisSize
                            .min, // Ajusta el tamaño para que ocupe solo el espacio necesario
                        children: <Widget>[
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              showDialog<String>(
                                context: context,
                                builder: (BuildContext context) => AlertDialog(
                                  title: const Text('¿Desea eliminar la cita?'),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, 'Cancelar'),
                                      child: const Text('Cancelar'),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        Navigator.pop(context, 'Eliminar');
                                        int listaId =
                                            eventosEnEspera[index]['id'];
                                        await DatabaseManager.deleteListaEspera(
                                            listaId);
                                        setState(() {
                                          eventosEnEspera.removeAt(index);
                                        });
                                      },
                                      child: const Text('Eliminar'),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.calendar_today),
                            onPressed: () {
                              _mostrarDialogoModificarTarea(tarea);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
