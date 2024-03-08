import 'package:flutter/material.dart';
import 'package:calendario_manik/pages/calendar_page.dart';
import 'package:calendario_manik/pages/patients_page.dart';
import 'package:calendario_manik/pages/add_page.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({Key? key}) : super(key: key);

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _selectedIndex = 0;
  String? selectedCitaType;

  void _navigateBottomBar(int index) {
    if (index == 1) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.access_time),
                title: const Text('Cita Rápida'),
                onTap: () {
                  setState(() {
                    selectedCitaType = 'Cita Rápida';
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title:  const Text('Cita Programada'),
                onTap: () {
                  setState(() {
                    selectedCitaType = 'Cita Programada';
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          );
        },
      );
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  final List _pages = [
    const Calendar(),
    const Add(),
    const Patients(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("")),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _navigateBottomBar,
        fixedColor: Colors.green,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
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
        unselectedIconTheme: const IconThemeData(color: Colors.grey),
      ),
    );
  }
}
