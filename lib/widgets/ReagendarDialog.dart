import 'package:calendario_manik/database/database.dart';
import 'package:calendario_manik/models/consultorio.dart';
import 'package:calendario_manik/variab.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:calendario_manik/models/doctor.dart';

class ReagendarDialog extends StatefulWidget {
  final Appointment appointment;
  final VoidCallback onSave;
  final int consultorioId;

  const ReagendarDialog(
      {super.key,
      required this.appointment,
      required this.onSave,
      required this.consultorioId});
  @override
  State<ReagendarDialog> createState() => _ReagendarDialogState();
}

class _ReagendarDialogState extends State<ReagendarDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  List<Consultorio> consultorios = [];
  int consulIndex = 0;
  String tipoCita = '';

  String? _selectedConsultorio;
  int selectedInterval = 60;
  List<DropdownMenuItem<String>> _recomendations = [];
  List<DropdownMenuItem<String>> _consultorioItems = [];
  DateTime _selectedDateTime = DateTime.now();
  bool useRecommendation = false;
  String? selectedRecommendation;

  List<Doctor> doctores = [];
  Doctor? selectedDoctor;
  int doctorId = 0;

  List<Map<String, dynamic>> tareasData = [];
  Map<String, dynamic> tareaSeleccionada = {};
  List<Map<String, dynamic>> eventosData = [];
  Map<String, dynamic> eventoSeleccionado = {};

  int? selectedEventoId;
  int? selectedTareaId;

  @override
  void initState() {
    super.initState();
    _dateController.text =
        DateFormat('yyyy-MM-dd').format(widget.appointment.startTime);
    _timeController.text =
        DateFormat('HH:mm').format(widget.appointment.startTime);
    _selectedDateTime = widget.appointment.startTime;
    //_selectedAppointments();
    _loadConsultorios();
    if (usuario_cuenta_id == 3) _fetchDoctores();
    if (usuario_rol == 'MED') doctorId = usuario_id;
    tipoCita = widget.appointment.location ?? 'evento';
    _selectedAppointments().then((_) {
      if (tipoCita == 'tarea') {
        _findSelectedTareaId();
      } else if (tipoCita == 'evento') {
        _findSelectedEventoId();
      }
    });
  }

  void _findSelectedTareaId() {
    String? id = widget.appointment.notes;
    selectedTareaId = int.tryParse(id!);
    tareaSeleccionada = tareasData.firstWhere(
      (tarea) => tarea['id'] == selectedTareaId,
    );

    doctorId = tareaSeleccionada['doctorid'];
  }

  void _findSelectedEventoId() {
    String? id = widget.appointment.notes;
    selectedEventoId = int.tryParse(id!);
    eventoSeleccionado = eventosData.firstWhere(
      (evento) => evento['id'] == selectedEventoId,
    );
  }

  Future<void> _pickDate() async {
    DateTime now = DateTime.now();
    DateTime initialDate =
        _selectedDateTime.isBefore(now) ? now : _selectedDateTime;

    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );

    if (pickedDate != null) {
      setState(() {
        _dateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
        _updateSelectedDateTime();
      });
    }
  }

  Future<void> _pickTime() async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
    );
    if (pickedTime != null) {
      setState(() {
        final now = DateTime.now();
        _timeController.text = DateFormat('HH:mm').format(
          DateTime(
              now.year, now.month, now.day, pickedTime.hour, pickedTime.minute),
        );
        //print(_timeController);
        _updateSelectedDateTime();
      });
    }
  }

  Future<void> _updateSelectedDateTime() async {
    final date = DateFormat('yyyy-MM-dd').parse(_dateController.text);
    final time = DateFormat('HH:mm').parse(_timeController.text);
    setState(() {
      _selectedDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
      _recomendations = []; // Vaciar las recomendaciones antes de actualizar
      selectedRecommendation = null; // Resetear la selección de recomendación
      _selectedAppointments(); // Actualizar las recomendaciones automáticamente
    });
  }

  Future<void> _selectedAppointments() async {
    List<Map<String, dynamic>> recommendations = [];
    recommendations =
        await DatabaseManager.getRecomeDiariaDesdeFecha(_selectedDateTime);

    tareasData =
        await DatabaseManager.getTareaSeleccionadaData(widget.consultorioId);

    eventosData = await DatabaseManager.getEventosData(widget.consultorioId);

    setState(() {
      _recomendations = recommendations.map((recommendation) {
        return DropdownMenuItem<String>(
          value: recommendation['fecha'] + ' ' + recommendation['hora'],
          child: Text(recommendation['fecha'] + ' ' + recommendation['hora']),
        );
      }).toList();
    });
  }

  List<Map<String, dynamic>> consultoriosData = [];

  Future<void> _loadConsultorios() async {
    List<Consultorio> consultoriosList = [];
    if (usuario_rol == 'MED') {
      consultoriosData = await DatabaseManager.getConsultoriosData(usuario_id);
    } else if (usuario_rol == 'ASI' || usuario_rol == 'ENF') {
      consultoriosData =
          await DatabaseManager.getConsultoriosData_id(usuario_id);
    }

    if (usuario_cuenta_id == 3) {
      consultoriosList = consultoriosData
          .map((data) => Consultorio(
                grupo_nombre: data['grupo_nombre'],
                id: data['id'],
                nombre: data['nombre'],
              ))
          .toList();
    } else {
      consultoriosList = consultoriosData
          .map((data) => Consultorio(
                id: data['id'],
                nombre: data['nombre'].toString(),
                telefono: int.parse(data['telefono'].toString()),
                direccion: data['direccion'].toString(),
                codigoPostal: int.parse(data['colonia_id'].toString()),
                intervaloAtencion: int.parse(data['intervalo'].toString()),
              ))
          .toList();
    }

    setState(() {
      consultorios = consultoriosList;
      if (consultorios.isNotEmpty) {
        _consultorioItems = consultorios.map((consultorio) {
          return DropdownMenuItem<String>(
            value: consultorio.id.toString(),
            child: Text(consultorio.nombre ?? 'Sin nombre'),
          );
        }).toList();
        //_selectedConsultorio = consultorios.first.id.toString();
      }
    });
  }

  Future<void> _saveChanges() async {
    if (useRecommendation && selectedRecommendation == null) {
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text(
                'Debe seleccionar una recomendación de fecha y hora.'),
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
      return;
    }

    final newDate = _dateController.text;
    final newTime = _timeController.text;

    final newStartTime = useRecommendation
        ? DateFormat('yyyy-MM-dd HH:mm').parse(selectedRecommendation!)
        : DateFormat('yyyy-MM-dd HH:mm').parse('$newDate $newTime');
    final newEndTime = newStartTime.add(Duration(minutes: selectedInterval));

    final canReagendar = await DatabaseManager.canReagendar(
      int.parse(_selectedConsultorio ?? widget.consultorioId.toString()),
      newStartTime.toIso8601String(),
      newEndTime.toIso8601String(),
    );

    if (canReagendar) {
      // Guardar los cambios en la base de datos según el tipo
      tipoCita =
          widget.appointment.location ?? 'evento'; // Aquí se obtiene el tipo

      if (tipoCita == 'evento') {
        // Aquí colocas la lógica para guardar un evento
        String id = widget.appointment.notes ?? '';
        int eventId = int.parse(id);
        int consultorioId =
            int.parse(_selectedConsultorio ?? widget.consultorioId.toString());
        final localStartTime = newStartTime.toLocal();
        final localEndTime = newEndTime.toLocal();
        await DatabaseManager.reagendarEvento(
          eventId,
          consultorioId,
          newStartTime.toIso8601String(),
          newEndTime.toIso8601String(),
          doctorId,
        );

        await Future.delayed(const Duration(milliseconds: 1500));
      } else if (tipoCita == 'tarea') {
        // Aquí colocas la lógica para guardar un evento
        String id = widget.appointment.notes ?? '';
        int eventId = int.parse(id);
        int consultorioId =
            int.parse(_selectedConsultorio ?? widget.consultorioId.toString());
        final localStartTime = newStartTime.toLocal();
        final localEndTime = newEndTime.toLocal();
        await DatabaseManager.reagendarTarea(
          eventId,
          consultorioId,
          newStartTime.toIso8601String(),
          newEndTime.toIso8601String(),
          doctorId,
        );

        await Future.delayed(const Duration(milliseconds: 1500));
      }
      widget.onSave();
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('No hubo conflictos'),
            content: const Text(
                'La nueva fecha y hora no chocan con eventos existentes.'),
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

      Navigator.of(context)
          .pop(); // Cerrar el diálogo después de guardar los cambios
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
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: const Text(
        'Reprogramar',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Color.fromARGB(255, 0, 0, 0),
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _buildInfoRow('Fecha:',
                '${widget.appointment.startTime.day}/${widget.appointment.startTime.month}/${widget.appointment.startTime.year}'),
            const SizedBox(height: 16),
            _buildInfoRow('Hora:',
                '${widget.appointment.startTime.hour}:${widget.appointment.startTime.minute.toString().padLeft(2, '0')}'),
            const SizedBox(height: 16),
            _buildInfoRow('Nota:', ''),
            const Text(
                'Si no selecciona un consultorio o un medico, se reagendará en el mismo consultorio y con el mismo medico'),
            const SizedBox(height: 16),
            _buildConsultoriosDropdown(),
            if (tipoCita != 'evento') ...[
              const SizedBox(height: 16),
              _buildDoctoresDropdown(),
            ],
            const SizedBox(height: 16),
            _buildDateField(),
            const SizedBox(height: 16),
            _buildTimeField(),
            const SizedBox(height: 16),
            _buildRecomendationsDropdown(),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _saveChanges,
          child: const Text('Guardar cambios'),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: <Widget>[
        Text(
          '$label ',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(value),
      ],
    );
  }

  Widget _buildConsultoriosDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedConsultorio,
      decoration: const InputDecoration(
        labelText: 'Selecciona un consultorio',
        border: OutlineInputBorder(),
      ),
      items: _consultorioItems,
      onChanged: (value) {
        setState(() {
          _selectedConsultorio = value;
        });
      },
    );
  }

  Future<void> _fetchDoctores() async {
    try {
      List<Map<String, dynamic>> doctoresData =
          await DatabaseManager.getDoctores(grupo_id);

      List<Doctor> doctoresList = doctoresData.map((data) {
        return Doctor(
          id: data['id'],
          nombre: data['nombre'],
          apellidos: data['apellidos'],
        );
      }).toList();

      setState(() {
        doctores = doctoresList;
        //selectedDoctor = doctores.first;
      });
    } catch (e) {
      print('Error fetching doctores: $e');
    }
  }

  Widget _buildDoctoresDropdown() {
    return DropdownButtonFormField<Doctor>(
      value: selectedDoctor,
      decoration: const InputDecoration(
        labelText: 'Selecciona el médico',
        border: OutlineInputBorder(),
      ),
      isExpanded: true,
      items: doctores.map((doctor) {
        return DropdownMenuItem<Doctor>(
          value: doctor,
          child: Text('${doctor.nombre} ${doctor.apellidos}'),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          selectedDoctor = value;
          if (selectedDoctor != null) {
            doctorId = selectedDoctor!.id!;
          }
        });
      },
    );
  }

  Widget _buildDateField() {
    return TextFormField(
      controller: _dateController,
      decoration: const InputDecoration(
        labelText: 'Fecha',
        border: OutlineInputBorder(),
      ),
      onTap: _pickDate,
      readOnly: true,
    );
  }

  Widget _buildTimeField() {
    return TextFormField(
      controller: _timeController,
      decoration: const InputDecoration(
        labelText: 'Hora',
        border: OutlineInputBorder(),
      ),
      onTap: _pickTime,
      readOnly: true,
    );
  }

  Widget _buildRecomendationsDropdown() {
    return Column(
      children: [
        CheckboxListTile(
          title: const Text('Usar recomendación de fecha y hora'),
          value: useRecommendation,
          onChanged: (value) {
            setState(() {
              useRecommendation = value ?? false;
            });
          },
        ),
        if (useRecommendation)
          DropdownButtonFormField<String>(
            value: selectedRecommendation,
            decoration: const InputDecoration(
              labelText: 'Selecciona una recomendación',
              border: OutlineInputBorder(),
            ),
            items: _recomendations,
            onChanged: (value) {
              setState(() {
                selectedRecommendation = value;
              });
            },
          ),
      ],
    );
  }
}
