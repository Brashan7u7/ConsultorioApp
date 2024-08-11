import 'package:calendario_manik/pages/editingCita_page.dart';
import 'package:calendario_manik/pages/lista_espera.dart';
import 'package:calendario_manik/variab.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:calendario_manik/pages/add_page.dart';
import 'package:calendario_manik/pages/patients_page.dart';
import 'package:calendario_manik/pages/consulting_page.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'package:calendario_manik/database/database.dart';
import 'package:calendario_manik/pages/start_page.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Calendar extends StatefulWidget {
  const Calendar({super.key});

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  @override
  void initState() {
    super.initState();
    _loadConsultorios();
  }

  final CalendarController _calendarController = CalendarController();
  List<Appointment> _calendarDataSource = [];
  List<TimeRegion> _specialRegions = [];

  int intervaloHoras = 60;

  // Lista de consultorios
  List<Consultorio> consultorios = [];
  int currentIndex = 0;
  int consulIndex = 0; // Índice del consultorio actual
  int globalIdConsultorio = 0;

  DateTime? _lastTap;
  final int _tapInterval = 300;
  List<Map<String, dynamic>> consultoriosData = [];

  Future<void> _loadConsultorios() async {
    List<Consultorio> consultoriosList = [];
    if (usuario_rol == 'MED') {
      consultoriosData = await DatabaseManager.getConsultoriosData(usuario_id);
    }
    if (usuario_rol == 'ASI' || usuario_rol == 'ENF') {
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
                telefono: data['telefono'].toString(),
                direccion: data['direccion'].toString(),
                codigoPostal: int.parse(data['colonia_id'].toString()),
                intervaloAtencion: int.parse(data['intervalo'].toString()),
              ))
          .toList();
    }
    setState(() {
      consultorios = consultoriosList;
      if (consultorios.isNotEmpty) {
        _loadSelectedConsultorio();
      }
    });
  }

  void _loadHorariosConsultorios() async {
    Map<String, List<String>> horariosString =
        await DatabaseManager.getHorarioConsultorio(globalIdConsultorio);

    List<TimeRegion> specialRegionsList = [];

    List<String> diasSemana = [
      'Lunes',
      'Martes',
      'Miércoles',
      'Jueves',
      'Viernes',
      'Sábado',
      'Domingo'
    ];

    // Genera todas las horas posibles para cada día de la semana en el rango de 8:00 a 19:59.
    for (String dia in diasSemana) {
      for (int hora = 0; hora <= 23; hora++) {
        String horaInicio = '${hora.toString().padLeft(2, '0')}:00';
        String horaFin = '${hora.toString().padLeft(2, '0')}:59';

        // Si la hora no está en horariosString para el día actual, agrégala a specialRegionsList.
        if (!horariosString.containsKey(dia) ||
            !horariosString[dia]!.any((horario) =>
                horario.startsWith(horaInicio) && horario.endsWith(horaFin))) {
          DateTime startDate = _getDateTimeForDayAndTime(dia, horaInicio);
          DateTime endDate = _getDateTimeForDayAndTime(dia, horaFin);

          TimeRegion timeRegion = TimeRegion(
            startTime: startDate,
            endTime: endDate,
            enablePointerInteraction: false,
            recurrenceRule: _getRecurrenceRuleForDay(dia),
            color:
                Colors.grey.withOpacity(0.2), // Color para horas no disponibles
          );

          specialRegionsList.add(timeRegion);
        }
      }
    }

    setState(() {
      _specialRegions = specialRegionsList;
    });
  }

  String _getRecurrenceRuleForDay(String day) {
    switch (day) {
      case 'Lunes':
        return 'FREQ=WEEKLY;BYDAY=MO';
      case 'Martes':
        return 'FREQ=WEEKLY;BYDAY=TU';
      case 'Miércoles':
        return 'FREQ=WEEKLY;BYDAY=WE';
      case 'Jueves':
        return 'FREQ=WEEKLY;BYDAY=TH';
      case 'Viernes':
        return 'FREQ=WEEKLY;BYDAY=FR';
      case 'Sábado':
        return 'FREQ=WEEKLY;BYDAY=SA';
      case 'Domingo':
        return 'FREQ=WEEKLY;BYDAY=SU';
      default:
        return 'FREQ=WEEKLY';
    }
  }

  DateTime _getDateTimeForDayAndTime(String day, String time) {
    // Ajusta la fecha y hora según tu lógica
    DateTime now = DateTime.now();
    switch (day) {
      case 'Lunes':
        return DateTime(
            now.year,
            now.month,
            now.day + (DateTime.monday - now.weekday),
            int.parse(time.split(':')[0]),
            int.parse(time.split(':')[1]));
      case 'Martes':
        return DateTime(
            now.year,
            now.month,
            now.day + (DateTime.tuesday - now.weekday),
            int.parse(time.split(':')[0]),
            int.parse(time.split(':')[1]));
      case 'Miércoles':
        return DateTime(
            now.year,
            now.month,
            now.day + (DateTime.wednesday - now.weekday),
            int.parse(time.split(':')[0]),
            int.parse(time.split(':')[1]));
      case 'Jueves':
        return DateTime(
            now.year,
            now.month,
            now.day + (DateTime.thursday - now.weekday),
            int.parse(time.split(':')[0]),
            int.parse(time.split(':')[1]));
      case 'Viernes':
        return DateTime(
            now.year,
            now.month,
            now.day + (DateTime.friday - now.weekday),
            int.parse(time.split(':')[0]),
            int.parse(time.split(':')[1]));
      case 'Sábado':
        return DateTime(
            now.year,
            now.month,
            now.day + (DateTime.saturday - now.weekday),
            int.parse(time.split(':')[0]),
            int.parse(time.split(':')[1]));
      case 'Domingo':
        return DateTime(
            now.year,
            now.month,
            now.day + (DateTime.sunday - now.weekday),
            int.parse(time.split(':')[0]),
            int.parse(time.split(':')[1]));
      default:
        return DateTime.now();
    }
  }

  void _loadEventosTareas() async {
    //*Eventos
    List<Map<String, dynamic>> eventosData =
        await DatabaseManager.getEventosData(globalIdConsultorio);
    List<Appointment> eventosAppointments =
        _getCalendarDataSourceEventos(eventosData);

    //*Tareas
    List<Map<String, dynamic>> tareasData =
        await DatabaseManager.getTareaSeleccionadaData(globalIdConsultorio);
    // Añadir esta línea para revisar los datos
    List<Appointment> tareasAppointments =
        _getCalendarDataSourceTareas(tareasData);

    // print('Eventos Appointments: $eventosAppointments');
    // print('Tareas Appointments: $tareasAppointments');

    setState(() {
      _calendarDataSource = [...eventosAppointments, ...tareasAppointments];
      //print('Calendar Data Source Updated: $_calendarDataSource');
    });
  }

  Future<void> _loadSelectedConsultorio() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      consulIndex = prefs.getInt('selectedConsultorioIndex') ?? 0;
      // Ajustar consulIndex a un valor válido si es necesario
      if (consulIndex >= consultorios.length) {
        consulIndex = 0;
      }
      globalIdConsultorio = consultorios[consulIndex].id ?? 0;

      intervaloHoras = consultorios[consulIndex].intervaloAtencion ?? 60;
      _loadEventosTareas();
      _loadHorariosConsultorios();
    });
  }

  Future<void> _saveSelectedConsultorio(int index) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('selectedConsultorioIndex', index);
  }

  _showConfirmationDialog(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Estás seguro de cerrar sesión?'),
        actions: [
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            child: const Text('Cerrar Sesión'),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<Consultorio>(
                isExpanded: true,
                items: consultorios.map((consultorio) {
                  return DropdownMenuItem<Consultorio>(
                    value: consultorio,
                    child: Text(consultorio.nombre!),
                  );
                }).toList(),
                value:
                    consultorios.isNotEmpty ? consultorios[consulIndex] : null,
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      consulIndex = consultorios.indexOf(value);
                      intervaloHoras =
                          consultorios[consulIndex].intervaloAtencion ?? 60;
                    });
                    int newConsultorioId = consultorios[consulIndex].id ?? 0;
                    if (newConsultorioId != globalIdConsultorio) {
                      globalIdConsultorio = newConsultorioId;
                      _saveSelectedConsultorio(consulIndex).then((_) {
                        _loadEventosTareas();
                        _loadHorariosConsultorios();
                      });
                    }
                  }
                },
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 4.0, horizontal: 8.0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(width: 1, color: Colors.grey),
                  ),
                  filled: true,
                  fillColor: Colors.transparent,
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () {
              DateTime currentDate = DateTime.now();
              _calendarController.displayDate = currentDate;
            },
          ),
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () {
              _showMonthlyCalendar(context);
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            DrawerHeader(
              padding: const EdgeInsets.symmetric(horizontal: 80),
              child: Image.asset('lib/images/usuario.png'),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 80.0),
              child: Text(
                '${(usuario_rol == 'ENF' ? 'Enfermero/a: ' : usuario_rol == 'ASI' ? 'Asistente: ' : usuario_rol == 'MED' ? 'Medico: ' : '')} ${usuario_nombre}',
                textAlign: TextAlign.center,
              ),
            ),
            const Divider(
              color: Colors.red,
              thickness: 2,
              height: 20,
              indent: 50,
              endIndent: 50,
            ),
            ListTile(
              contentPadding: const EdgeInsets.only(left: 25.0),
              leading: const Icon(Icons.announcement),
              title: const Text('Lista de espera'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ListaEspera(consultorioId: globalIdConsultorio),
                  ),
                );
              },
            ),
            (usuario_rol != 'ASI' &&
                    usuario_rol != 'ENF' &&
                    usuario_cuenta_id != 3)
                ? ListTile(
                    contentPadding: const EdgeInsets.only(left: 25.0),
                    leading: const Icon(
                      Icons.access_alarm,
                    ),
                    title: const Text('Consultorios'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Consulting(),
                        ),
                      );
                    },
                  )
                : Container(),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(left: 25.0, bottom: 25),
              child: ListTile(
                leading: const Icon(
                  Icons.logout,
                ),
                title: const Text(
                  'Cerrar Sesión',
                ),
                onTap: () async {
                  bool confirmCerrar = await _showConfirmationDialog(context);
                  if (confirmCerrar) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const StartPage()),
                      (Route<dynamic> route) => false,
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
      body: Localizations.override(
        context: context,
        locale: const Locale('es', ''),
        child: SfCalendar(
          key: ValueKey(globalIdConsultorio),
          controller: _calendarController,
          view: CalendarView.day,
          showNavigationArrow: true,
          headerStyle: const CalendarHeaderStyle(textAlign: TextAlign.center),
          headerDateFormat: 'd MMMM y',
          showDatePickerButton: true,
          timeSlotViewSettings: TimeSlotViewSettings(
            startHour: 0,
            endHour: 24,
            timeIntervalHeight: 100,
            timeFormat: 'hh:mm a',
            timeInterval: Duration(minutes: intervaloHoras),
          ),
          dataSource: MeetingDataSource(_calendarDataSource),
          specialRegions: _specialRegions,
          onTap: (CalendarTapDetails details) {
            if (details.targetElement == CalendarElement.appointment) {
              Appointment tappedAppointment = details.appointments![0];
              _showAppointmentDetails(tappedAppointment);
            } else if (details.targetElement == CalendarElement.calendarCell) {
              DateTime selectedDate = details.date!;
              _navigateToSelectedDate(selectedDate);
            }
            if (agendarCitasEventos) {
              if (_lastTap != null &&
                  DateTime.now().difference(_lastTap!) <
                      Duration(milliseconds: _tapInterval)) {
                // Si se hace doble clic en una celda del calendario, redirige a la página de "Cita Rápida"
                _lastTap = null;
                _navigateToAddPage(context);
              } else {
                // Si se hace un solo clic, actualiza el tiempo del último toque
                _lastTap = DateTime.now();
              }
            }
          },
        ),
      ),
      bottomNavigationBar: agendarCitasEventos ||
              crearPacientes ||
              editarPacientes ||
              eliminarPacientes
          ? buildBottomNavigationBar()
          : null,
    );
  }

  BottomNavigationBar buildBottomNavigationBar() {
    List<BottomNavigationBarItem> items = [
      const BottomNavigationBarItem(
        icon: Icon(Icons.home),
        label: 'Calendario',
      ),
    ];

    if (agendarCitasEventos) {
      items.add(
        const BottomNavigationBarItem(
          icon: Icon(Icons.add),
          label: 'Agendar',
        ),
      );
    }

    if (editarPacientes || eliminarPacientes || crearPacientes) {
      items.add(
        const BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Pacientes',
        ),
      );
    }

    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) {
        setState(() {
          currentIndex = index;
        });

        if (index == 0) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const Calendar(),
            ),
          );
        } else if (agendarCitasEventos && index == 1) {
          _showAgendarModal();
        } else if ((editarPacientes || eliminarPacientes)) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Patients(
                consultorioId: globalIdConsultorio,
              ),
            ),
          );
        }
      },
      items: items,
      selectedItemColor: Colors.green,
    );
  }

  void _showAgendarModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (BuildContext builder) {
        return Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
          ),
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.access_time),
                title: const Text('Cita Inmediata'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Add(
                        isCitaInmediata: true,
                        isEvento: false,
                        isPacient: false,
                        isCitaPro: false,
                        consultorioId: globalIdConsultorio,
                      ),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('Cita Programada'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Add(
                        isCitaInmediata: false,
                        isEvento: false,
                        isPacient: false,
                        isCitaPro: true,
                        consultorioId: globalIdConsultorio,
                      ),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.event),
                title: const Text('Evento'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Add(
                        isCitaInmediata: false,
                        isEvento: true,
                        isPacient: false,
                        isCitaPro: false,
                        consultorioId: globalIdConsultorio,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void deleteAppointment(Object? id) async {
    await DatabaseManager.deleteCita(id);
    _loadEventosTareas();
  }

  void _showAppointmentDetails(Appointment appointment) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            appointment.subject,
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color.fromARGB(255, 34, 34, 37)),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Text(
                        'Fecha:',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                      SizedBox(width: 8),
                      Text(
                        '${appointment.startTime.day}/${appointment.startTime.month}/${appointment.startTime.year}',
                        style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Text(
                        'Hora inicio:',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                      SizedBox(width: 8),
                      Text(
                        '${appointment.startTime.hour}:${appointment.startTime.minute.toString().padLeft(2, '0')}',
                        style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Text(
                        'Hora Fin:',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                      SizedBox(width: 8),
                      Text(
                        '${appointment.endTime.hour}:${appointment.endTime.minute.toString().padLeft(2, '0')}',
                        style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Text(
                        'Duración:',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                      SizedBox(width: 8),
                      Text(
                        '${(appointment.endTime.difference(appointment.startTime).inMinutes)} minutos',
                        style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                      ),
                    ],
                  ),
                ),
                // Add more details as needed
              ],
            ),
          ),
          actions: [
            Row(
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Cerrar',
                    style: TextStyle(fontSize: 16, color: Colors.blueGrey),
                  ),
                ),
                PopupMenuButton(
                  child: const Row(
                    children: [
                      Text('Opciones'),
                      Icon(Icons.arrow_drop_down),
                    ],
                  ),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      child: const Text(
                        'Eliminar',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color.fromARGB(255, 0, 0, 0),
                        ),
                      ),
                      onTap: () {
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
                                onPressed: () {
                                  Navigator.pop(context, 'Eliminar');
                                  _deleteAppointment(appointment);
                                },
                                child: const Text('Eliminar'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    PopupMenuItem(
                      child: const Text(
                        'Atender cita',
                        style: TextStyle(
                            fontSize: 16, color: Color.fromARGB(255, 0, 0, 0)),
                      ),
                      onTap: () {},
                    ),
                    PopupMenuItem(
                      child: const Text(
                        'Registrar llegada',
                        style: TextStyle(
                            fontSize: 16, color: Color.fromARGB(255, 0, 0, 0)),
                      ),
                      onTap: () {},
                    ),
                    PopupMenuItem(
                      child: const Text(
                        'Reagendar',
                        style: TextStyle(
                            fontSize: 16, color: Color.fromARGB(255, 0, 0, 0)),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Add(
                              isCitaInmediata: false,
                              isEvento: false,
                              isPacient: false,
                              isCitaPro: false,
                              isEditingCita: true,
                              consultorioId: globalIdConsultorio,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                )
              ],
            ),
          ],
        );
      },
    );
  }

  void _showMonthlyCalendar(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext builder) {
        return SizedBox(
          height: 700,
          child: SfCalendar(
            view: CalendarView.month,
            headerStyle: const CalendarHeaderStyle(textAlign: TextAlign.center),
            showNavigationArrow: true,
            showDatePickerButton: true,
            appointmentTimeTextFormat: 'HH:mm',
            onTap: (CalendarTapDetails details) {
              if (details.targetElement == CalendarElement.calendarCell) {
                DateTime selectedDate = details.date!;
                _navigateToSelectedDate(selectedDate);
                Navigator.pop(context);
              }
            },
            dataSource: MeetingDataSource(_calendarDataSource),
          ),
        );
      },
    );
  }

  void _navigateToSelectedDate(DateTime selectedDate) {
    // Actualiza el controlador diario con la fecha seleccionada
    _calendarController.displayDate = selectedDate;

    // Cambia la vista del calendario a "day"
    _calendarController.view = CalendarView.day;
  }

  void _navigateToAddPage(BuildContext context) {
    String formattedTime = DateFormat('HH:mm')
        .format(_calendarController.selectedDate as DateTime);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Add(
          isCitaInmediata: false,
          isCitaselect: true,
          fechaController: TextEditingController(
            text: _calendarController.selectedDate.toString().split(' ')[0],
          ),
          horaController: TextEditingController(
            text: formattedTime,
          ),
          isCitaPro: false,
          isEvento: false,
          isPacient: false,
          consultorioId: globalIdConsultorio,
        ),
      ),
    );
  }

  void _deleteAppointment(Appointment appointment) {
    String id = appointment.notes ?? '';
    String tipo = appointment.location ?? '';

    if (tipo == 'evento') {
      int eventoId = int.parse(id);
      DatabaseManager.deleteEvento(eventoId).then((_) {
        _loadEventosTareas(); // Recargar los datos del calendario
        _loadHorariosConsultorios(); // Recargar los horarios de los consultorios si es necesario
        setState(() {}); // Actualizar el estado de la interfaz de usuario
      });
    } else if (tipo == 'tarea') {
      int tareaId = int.parse(id);
      DatabaseManager.deleteTarea(tareaId).then((_) {
        _loadEventosTareas(); // Recargar los datos del calendario
        _loadHorariosConsultorios(); // Recargar los horarios de los consultorios si es necesario
        setState(() {}); // Actualizar el estado de la interfaz de usuario
      });
    }

    // Cerrar el diálogo
    Navigator.pop(context);
  }
}

class MeetingDataSource extends CalendarDataSource {
  MeetingDataSource(List<Appointment> source) {
    appointments = source;
  }
}

List<Appointment> _getCalendarDataSourceEventos(
    List<Map<String, dynamic>> eventosData) {
  List<Appointment> appointments = [];

  for (final evento in eventosData) {
    DateTime startTime = DateTime.parse(evento['fecha_inicio']);
    DateTime endTime = DateTime.parse(evento['fecha_fin']);

    String nombre = evento['nombre'].toString();
    String horario =
        '${DateFormat.jm().format(startTime)} - ${DateFormat.jm().format(endTime)}'; // Formato del horario (ejemplo: 9:00 AM - 10:00 AM)
    String id = evento['id'].toString();

    appointments.add(Appointment(
      subject:
          '$nombre\n$horario', // Combina nombre y horario en una sola línea
      startTime: startTime,
      endTime: endTime,
      color: const Color.fromARGB(255, 6, 230, 99),
      notes: id, // Guardar el id en la propiedad notes
      location: 'evento', // Marcar como evento
    ));
  }

  // print('Processed Eventos Appointments: $appointments');
  return appointments;
}

List<Appointment> _getCalendarDataSourceTareas(
    List<Map<String, dynamic>> tareasData) {
  List<Appointment> appointments = [];

  for (final tarea in tareasData) {
    //  print('Processing tarea: $tarea');
    DateTime startTime = DateTime.parse(tarea['fecha_inicio']);
    DateTime endTime = DateTime.parse(tarea['fecha_fin']);

    String nombre = tarea['nombre'].toString();
    String horario =
        '${DateFormat.jm().format(startTime)} - ${DateFormat.jm().format(endTime)}';
    String color = tarea['color'].toString();
    String id = tarea['id'].toString();
    String medico = tarea['asignado_id'].toString();
    String paciente = tarea['paciente_id'].toString();
    String motivo = tarea['motivo_consulta'].toString();

    if (usuario_cuenta_id == 3) {
      appointments.add(Appointment(
        subject:
            '$nombre\n$horario\nMédico: $medico\nPaciente: $paciente\nMotivo: $motivo',
        startTime: startTime,
        endTime: endTime,
        color: HexColor(color),
        notes: id, // Guardar el id en la propiedad notes
        location: 'tarea', // Marcar como tarea
      ));
    } else {
      appointments.add(Appointment(
        subject: '$nombre\n$horario\nPaciente: $paciente\nMotivo: $motivo',
        startTime: startTime,
        endTime: endTime,
        color: HexColor(color),
        notes: id, // Guardar el id en la propiedad notes
        location: 'tarea', // Marcar como tarea
      ));
    }
  }

  return appointments;
}
