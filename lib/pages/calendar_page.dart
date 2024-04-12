import 'dart:async';
import 'package:flutter/material.dart';
import 'package:calendario_manik/components/sidebart.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

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
  int intervaloHoras =
      2; // Intervalo de horas entre cada hora mostrada en el calendario

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
          leading: Builder(
            builder: (context) => IconButton(
              icon: const Padding(
                padding: EdgeInsets.only(left: 8.0),
                child: Icon(
                  Icons.menu,
                ),
              ),
<<<<<<< HEAD
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            ),
          ),
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
        drawer: Sidebar(),
        body: SfCalendar(
          controller: _calendarController,
          view: CalendarView.day,
          showNavigationArrow: true,
          headerStyle: CalendarHeaderStyle(textAlign: TextAlign.center),
          showDatePickerButton: true,
          timeSlotViewSettings: TimeSlotViewSettings(
            startHour: 0, endHour: 24,
            timeIntervalHeight:
                120, // Altura de cada intervalo de tiempo en el calendario
            timeInterval: Duration(
                hours:
                    intervaloHoras), // Intervalo de tiempo entre cada intervalo en el calendario
=======
            ),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        title: Row(
  
  children: [DropdownButton<String> (
  value: consultorios[currentIndex],
  onChanged: (newValue) {
    setState(() {
      currentIndex = consultorios.indexOf(newValue ?? consultorios.first);

    });
  },
  items: consultorios.map<DropdownMenuItem<String>>((String value) {
    return DropdownMenuItem<String>(
      value: value,
      child: Text(value),
    );
  }).toList(),
)
],
),

        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () {
              DateTime currentDate = DateTime.now();
              _calendarController.displayDate = currentDate;
            },
>>>>>>> 1162946edaf88d06d5239f22f73923388827d49e
          ),
          dataSource: _getCalendarDataSource(
              widget.name, widget.fecha, widget.hora, widget.duracion),
          onTap: (CalendarTapDetails details) {
            if (details.targetElement == CalendarElement.appointment) {
              // If an appointment is tapped, show its details
              Appointment tappedAppointment = details.appointments![0];
              _showAppointmentDetails(tappedAppointment);
            } else if (details.targetElement == CalendarElement.calendarCell) {
              // If an empty cell is tapped, navigate to that day
              DateTime selectedDate = details.date!;
              _navigateToSelectedDate(selectedDate);
            }
          },

          // If an appointment is tapped, show its details
        ));
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
                // Si se toca una celda del calendario, redirige a ese día
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
