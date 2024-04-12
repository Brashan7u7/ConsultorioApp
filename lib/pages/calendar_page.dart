import 'package:calendario_manik/pages/add_page.dart';
import 'package:flutter/material.dart';
import 'package:calendario_manik/components/sidebart.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class Calendar extends StatefulWidget {
  const Calendar({Key? key}) : super(key: key);

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  final CalendarController _calendarController = CalendarController();
  int intervaloHoras = 2; // Intervalo de horas entre cada hora mostrada en el calendario

  // Lista de consultorios
  List<String> consultorios = ['Consultorio 1', 'Consultorio 2', 'Consultorio 3'];
  int currentIndex = 0; // Índice del consultorio actual

  DateTime? _lastTap;
  static const int _tapInterval = 300; // Intervalo de tiempo en milisegundos para considerar un doble clic

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Padding(
              padding: EdgeInsets.only(left: 8.0),
              child: Icon(Icons.menu),
            ),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        title: Row(
          children: [
            DropdownButton<String>(
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
          startHour: 0,
          endHour: 24,
          timeIntervalHeight: 120,
          timeInterval: Duration(hours: intervaloHoras),
        ),
        dataSource: _getCalendarDataSource(),
        onTap: (CalendarTapDetails details) {
          if (_lastTap != null &&
              DateTime.now().difference(_lastTap!) < Duration(milliseconds: _tapInterval)) {
            // Si se hace doble clic en una celda del calendario, redirige a la página de "Cita Rápida"
            _lastTap = null;
            _navigateToAddPage(context);
          } else {
            // Si se hace un solo clic, actualiza el tiempo del último toque
            _lastTap = DateTime.now();
          }
        },
      ),
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

  void _navigateToAddPage(BuildContext context) {
    // Navega a la página de "Cita Rápida"
    Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Add(isCitaRapida: true),
              ),
            );
  }

  _AppointmentDataSource _getCalendarDataSource() {
    List<Appointment> appointments = <Appointment>[];

    appointments.add(Appointment(
      startTime: DateTime.now(),
      endTime: DateTime.now().add(Duration(minutes: 60)),
      subject: 'Meeting',
      color: Colors.red,
    ));

    return _AppointmentDataSource(appointments);
  }
}

class _AppointmentDataSource extends CalendarDataSource {
  _AppointmentDataSource(List<Appointment> source) {
    appointments = source;
  }
}