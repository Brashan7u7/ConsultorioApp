import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:calendario_manik/pages/add_page.dart';
import 'package:calendario_manik/pages/patients_page.dart';
import 'package:calendario_manik/pages/consulting_page.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'package:calendario_manik/database/database.dart';
import 'package:calendario_manik/pages/login_page.dart';

import 'package:shared_preferences/shared_preferences.dart';

class Calendar extends StatefulWidget {
  final int? usuario_id;
  Calendar({Key? key, this.usuario_id}) : super(key: key);

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  @override
  void initState() {
    super.initState();
    _loadConsultorios();
    //_loadSelectedConsultorio();
  }

  final CalendarController _calendarController = CalendarController();
  List<Appointment> _calendarDataSource = [];
  List<TimeRegion> _specialRegions = [];

  int intervaloHoras = 1;

  // Lista de consultorios
  List<Consultorio> consultorios = [];
  int currentIndex = 0;
  int consulIndex = 0; // Índice del consultorio actual
  int globalIdConsultorio = 0;

  DateTime? _lastTap;
  int _tapInterval = 300;

  Future<void> _loadConsultorios() async {
    List<Consultorio> consultoriosList = [];
    List<Map<String, dynamic>> consultoriosData =
        await DatabaseManager.getConsultoriosData(widget.usuario_id);
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
    setState(() {
      consultorios = consultoriosList;
      if (consultorios.isNotEmpty) {
        // Ajustar consulIndex a un valor válido
        // if (consulIndex >= consultorios.length) {
        //   consulIndex = 0;
        // }
        // globalIdConsultorio = consultorios[consulIndex].id ?? 0;
        // _loadEventos();
        // _loadHorariosConsultorios();
        // print(globalIdConsultorio);
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
        String horaInicio = hora.toString().padLeft(2, '0') + ':00';
        String horaFin = hora.toString().padLeft(2, '0') + ':59';

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

  void _loadEventos() async {
    List<Map<String, dynamic>> eventosData =
        await DatabaseManager.getEventosData(globalIdConsultorio);
    List<Appointment> eventosAppointments = _getCalendarDataSource(eventosData);
    setState(() {
      // Actualiza la lista de citas en el dataSource directamente
      _calendarDataSource = eventosAppointments;
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
      _loadEventos();
      _loadHorariosConsultorios();
    });
  }

  Future<void> _saveSelectedConsultorio(int index) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('selectedConsultorioIndex', index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Expanded(
              child: DropdownButton<Consultorio>(
                items: consultorios.map((consultorio) {
                  return DropdownMenuItem<Consultorio>(
                    value: consultorio,
                    child: Text(consultorio.nombre),
                  );
                }).toList(),
                value:
                    consultorios.isNotEmpty ? consultorios[consulIndex] : null,
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      consulIndex = consultorios.indexOf(value);
                    });
                    int newConsultorioId = consultorios[consulIndex].id ?? 0;
                    if (newConsultorioId != globalIdConsultorio) {
                      globalIdConsultorio = newConsultorioId;
                      _saveSelectedConsultorio(consulIndex).then((_) {
                        _loadEventos();
                        _loadHorariosConsultorios();
                      });
                    }
                  }
                },
                hint: Text("Selecciona un consultorio"),
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
          children: [
            DrawerHeader(
              child: Image.asset('lib/images/usuario.png'),
              padding: EdgeInsets.symmetric(horizontal: 80),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 50.0),
              child: Divider(
                color: Colors.red,
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 25.0),
              child: ListTile(
                leading: Icon(
                  Icons.announcement,
                ),
                title: Text(
                  'Pacientes esperando',
                ),
              ),
            ),
            ListTile(
              contentPadding: EdgeInsets.only(left: 25.0),
              leading: Icon(
                Icons.access_alarm,
              ),
              title: Text(
                'Consultorios',
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        Consulting(usuario_id: widget.usuario_id),
                  ),
                );
              },
            ),
            Spacer(),
            Padding(
              padding: EdgeInsets.only(left: 25.0, bottom: 25),
              child: ListTile(
                leading: Icon(
                  Icons.logout,
                ),
                title: Text(
                  'Cerrar Sesión',
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Login(),
                    ),
                  );
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
          controller: _calendarController,
          view: CalendarView.day,
          showNavigationArrow: true,
          headerStyle: CalendarHeaderStyle(textAlign: TextAlign.center),
          headerDateFormat: 'd MMMM y',
          showDatePickerButton: true,
          timeSlotViewSettings: TimeSlotViewSettings(
            startHour: 0,
            endHour: 24,
            timeIntervalHeight: 120,
            timeInterval: Duration(hours: intervaloHoras),
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
          },
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });

          if (index == 1) {
            _showAgendarModal();
          } else if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Calendar(usuario_id: widget.usuario_id),
              ),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Patients(usuario_id: widget.usuario_id),
              ),
            );
          }
        },
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Calendario',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Agendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Pacientes',
          ),
        ],
        selectedItemColor: Colors.green,
      ),
    );
  }

  void _showAgendarModal() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (BuildContext builder) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
          ),
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(Icons.access_time),
                title: Text('Cita Inmediata'),
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
                      ),
                    ),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.calendar_today),
                title: Text('Cita Programada'),
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
                          usuario_id: widget.usuario_id),
                    ),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.event),
                title: Text('Evento'),
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
                          usuario_id: widget.usuario_id),
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

  void _showAppointmentDetails(Appointment appointment) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(appointment.subject),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Fecha: ${appointment.startTime.day}/${appointment.startTime.month}/${appointment.startTime.year}',
                ),
                Text(
                  'Hora inicio: ${appointment.startTime.hour}:${appointment.startTime.minute}',
                ),
                Text(
                  'Hora Fin: ${appointment.endTime.hour}:${appointment.endTime.minute}',
                ),
                Text(
                  'Duración: ${appointment.startTime.difference(appointment.endTime).inMinutes} minutos',
                ),
                // Add more details as needed
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cerrar'),
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
        return Container(
          height: 700,
          child: SfCalendar(
            view: CalendarView.month,
            headerStyle: CalendarHeaderStyle(textAlign: TextAlign.center),
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
              text: _calendarController.selectedDate.toString().split(' ')[1],
            ),
            isCitaPro: false,
            isEvento: false,
            isPacient: false,
            usuario_id: widget.usuario_id),
      ),
    );
  }
}

class MeetingDataSource extends CalendarDataSource {
  MeetingDataSource(List<Appointment> source) {
    appointments = source;
  }
}

List<Appointment> _getCalendarDataSource(
    List<Map<String, dynamic>> eventosData) {
  List<Appointment> appointments = [];

  for (final evento in eventosData) {
    DateTime startTime = DateTime.parse(evento['fecha_inicio']);
    DateTime endTime = DateTime.parse(evento['fecha_fin']);

    String nombre = evento['nombre'].toString();
    String horario = DateFormat.jm().format(startTime) +
        ' - ' +
        DateFormat.jm().format(
            endTime); // Formato del horario (ejemplo: 9:00 AM - 10:00 AM)

    appointments.add(Appointment(
      subject:
          '$nombre\n$horario', // Combina nombre y horario en una sola línea
      startTime: startTime,
      endTime: endTime,
      color: Colors.blue,
    ));
  }

  return appointments;
}
