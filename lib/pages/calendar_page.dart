import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:calendario_manik/pages/add_page.dart';
import 'package:calendario_manik/pages/patients_page.dart';
import 'package:calendario_manik/pages/consulting_page.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'package:calendario_manik/database/database.dart';

class Calendar extends StatefulWidget {
  const Calendar({
    Key? key,
  }) : super(key: key);

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  @override
  void initState() {
    super.initState();
    _loadConsultorios(); // Carga los consultorios al inicializar el widget
    _loadEventos();
  }

  final CalendarController _calendarController = CalendarController();
  final MeetingDataSource _calendarDataSource = MeetingDataSource([]);

  int intervaloHoras = 1;

  // Lista de consultorios
  List<String> consultorios = [];

  void _loadConsultorios() async {
    List<Map<String, dynamic>> consultoriosData =
        await DatabaseManager.getConsultoriosData();
    List<String> consultoriosList = consultoriosData
        .map((consultorio) => consultorio['nombre'] as String)
        .toList();
    setState(() {
      consultorios = consultoriosList;
    });
  }

  void _loadEventos() async {
    List<Map<String, dynamic>> eventosData =
        await DatabaseManager.getEventosData();
    List<Appointment> eventosAppointments = _getCalendarDataSource(eventosData);
    setState(() {
      // Actualiza la lista de citas en el dataSource directamente
      _calendarDataSource.appointments = eventosAppointments;
    });
  }

  int currentIndex = 0;
  int consulIndex = 0; // Índice del consultorio actual

  DateTime? _lastTap;
  int _tapInterval = 300;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            DropdownButton<String>(
              value:
                  consultorios.isNotEmpty && consulIndex < consultorios.length
                      ? consultorios[consulIndex]
                      : null,
              onChanged: (newValue) {
                setState(() {
                  consulIndex =
                      consultorios.indexOf(newValue ?? consultorios.first);
                });
                _loadConsultorios();
              },
              items: consultorios.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
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
                        Consulting(), // Nueva página de consultorios
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
          dataSource: _calendarDataSource,
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
                builder: (context) => Calendar(),
              ),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Patients(),
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
                title: Text('Cita Rápida'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Add(
                        isCitaRapida: true,
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
                        isCitaRapida: false,
                        isEvento: false,
                        isPacient: false,
                        isCitaPro: true,
                      ),
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
                        isCitaRapida: false,
                        isEvento: true,
                        isPacient: false,
                        isCitaPro: false,
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
            monthViewSettings: MonthViewSettings(
              showAgenda: true,
              agendaViewHeight: 70,
            ),
            appointmentTimeTextFormat: 'HH:mm',
            // onTap: (CalendarTapDetails details) {
            //   if (details.targetElement == CalendarElement.calendarCell) {
            //     DateTime selectedDate = details.date!;
            //     _navigateToSelectedDate(selectedDate);
            //     Navigator.pop(context);
            //   }
            // },
            dataSource: _calendarDataSource,
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
          isCitaRapida: false,
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
        ),
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
    DateTime boorstartTime = evento['fecha_inicio'].toUtc();
    String formattedDateStart =
        DateFormat('yyyy-MM-dd kk:mm').format(boorstartTime);
    DateTime startTime = DateTime.parse(formattedDateStart);

    DateTime boorendTime = evento['fecha_fin'].toUtc();
    String formattedDateEnd =
        DateFormat('yyyy-MM-dd kk:mm').format(boorendTime);
    DateTime endTime = DateTime.parse(formattedDateEnd);

    appointments.add(Appointment(
      subject: evento['nombre'].toString(),
      startTime: startTime,
      endTime: endTime,
      color: Colors.blue,
    ));
  }

  return appointments;
}
