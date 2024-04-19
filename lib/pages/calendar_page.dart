import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:calendario_manik/pages/add_page.dart';
import 'package:calendario_manik/pages/patients_page.dart';
import 'package:calendario_manik/pages/consulting_page.dart';

class Calendar extends StatefulWidget {
  final String? name, fecha, hora, duracion, servicio, nota;

  const Calendar(
      {Key? key,
      this.name,
      this.fecha,
      this.hora,
      this.duracion,
      this.servicio,
      this.nota})
      : super(key: key);

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  final CalendarController _calendarController = CalendarController();
  int intervaloHoras = 2;

  // Lista de consultorios
  List<String> consultorios = [
    'Consultorio 1',
    'Consultorio 2',
    'Consultorio 3'
  ];
  int currentIndex = 0; // Índice del consultorio actual

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back_ios),
              onPressed: () {
                setState(() {
                  if (currentIndex > 0) currentIndex--;
                });
              },
            ),
            Text(consultorios[currentIndex]), // Nombre del consultorio actual
            IconButton(
              icon: Icon(Icons.arrow_forward_ios),
              onPressed: () {
                setState(() {
                  if (currentIndex < consultorios.length - 1) currentIndex++;
                });
              },
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
            // logo
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

            // Opción de horario que navega a la página de consultorios
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
            const Spacer(),
            const Padding(
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
      body: SfCalendar(
        controller: _calendarController,
        view: CalendarView.day,
        showNavigationArrow: true,
        headerStyle: CalendarHeaderStyle(textAlign: TextAlign.center),
        showDatePickerButton: true,
        timeSlotViewSettings: TimeSlotViewSettings(
          startHour: 0,
          endHour: 24,
          timeIntervalHeight: 120,
          timeInterval: Duration(hours: intervaloHoras),
        ),
        dataSource: _getCalendarDataSource(
            widget.name, widget.fecha, widget.hora, widget.duracion),
        onTap: (CalendarTapDetails details) {
          if (details.targetElement == CalendarElement.appointment) {
            Appointment tappedAppointment = details.appointments![0];
            _showAppointmentDetails(tappedAppointment);
          } else if (details.targetElement == CalendarElement.calendarCell) {
            DateTime selectedDate = details.date!;
            _navigateToSelectedDate(selectedDate);
          }
        },
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
                    'Fecha: ${appointment.startTime.day}/${appointment.startTime.month}/${appointment.startTime.year}'),
                Text(
                    'Hora inicio: ${appointment.startTime.hour}:${appointment.startTime.minute}'),
                Text(
                    'Duración: ${appointment.startTime.difference(appointment.endTime).inMinutes} minutos'),
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
          height: 500,
          child: SfCalendar(
            view: CalendarView.month,
            headerStyle: CalendarHeaderStyle(textAlign: TextAlign.center),
            showNavigationArrow: true,
            showDatePickerButton: true,
            monthViewSettings: MonthViewSettings(showAgenda: true),
            appointmentTimeTextFormat: 'HH:mm',
            onTap: (CalendarTapDetails details) {
              if (details.targetElement == CalendarElement.calendarCell) {
                DateTime selectedDate = details.date!;
                _navigateToSelectedDate(selectedDate);
                Navigator.pop(context);
              }
            },
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
}

class _AppointmentDataSource extends CalendarDataSource {
  _AppointmentDataSource(List<Appointment> source) {
    appointments = source;
  }
}

_AppointmentDataSource _getCalendarDataSource(
    String? name, String? fecha, String? hora, String? duracion) {
  List<Appointment> appointments = <Appointment>[];

  if (name != null && fecha != null && hora != null && duracion != null) {
    // Parse the fecha string into a DateTime object
    DateTime appointmentDate = DateTime.tryParse(fecha) ?? DateTime.now();

    // Assuming 'hora' represents the start time (modify if needed)
    DateTime startTime = DateTime(
      appointmentDate.year,
      appointmentDate.month,
      appointmentDate.day,
      int.parse(hora.split(':')[0]),
      int.parse(hora.split(':')[1]),
    );

    // Assuming 'duracion' represents duration in minutes (modify if needed)
    int durationInMinutes = int.tryParse(duracion) ?? 0;
    DateTime endTime = startTime.add(Duration(minutes: durationInMinutes));

    appointments.add(Appointment(
      subject: name, // Use name for the subject
      startTime: startTime,
      endTime: endTime,
      color: Colors.blue, // Set a color for your appointment
    ));
  }

  return _AppointmentDataSource(appointments);
}
