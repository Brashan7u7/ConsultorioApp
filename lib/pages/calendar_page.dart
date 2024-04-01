import 'package:flutter/material.dart';
import 'package:calendario_manik/components/sidebart.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class Calendar extends StatefulWidget {
  static List<Appointment> listaCitas = [];
  const Calendar({Key? key}) : super(key: key);

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
        timeSlotViewSettings: TimeSlotViewSettings(
          startHour: 0,
          endHour: 24,
          timeIntervalHeight:
              120, // Altura de cada intervalo de tiempo en el calendario
          timeInterval: Duration(
              hours:
                  intervaloHoras), // Intervalo de tiempo entre cada intervalo en el calendario
        ),
        onTap: (CalendarTapDetails details) {
          if (details.targetElement == CalendarElement.calendarCell) {
            // Si se toca una celda del calendario, redirige a ese día
            DateTime selectedDate = details.date!;
            _navigateToSelectedDate(selectedDate);
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
