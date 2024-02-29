import 'package:calendario_manik/pages/add_page.dart';
import 'package:calendario_manik/pages/calendar_page.dart';
import 'package:calendario_manik/pages/patients_page.dart';
import 'package:flutter/material.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  //esto realiza un seguimiento de la página actual para mostrar
  int _selectedIndex = 0;
  //este método actualiza el nuevo índice seleccionado
  void _navigateBottomBar(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  //paginas que tenemos en nuestra app
  final List _pages = [
        //pagina agregar
    const Add(),
    //pagina calendario
    const Calendar(),
    //pagina pacientes
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
                    //ADD
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            label: 'Añadir',
          ),
          //CALENDAR
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Calendario',
          ),
          //PATIENTS
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
