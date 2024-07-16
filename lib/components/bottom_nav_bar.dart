import 'package:flutter/material.dart';
import 'package:calendario_manik/pages/calendar_page.dart';
import 'package:calendario_manik/pages/patients_page.dart';
import 'package:calendario_manik/pages/add_page.dart';

class BottomNavBar extends StatefulWidget {
  final int? usuario_id;
  const BottomNavBar({super.key, this.usuario_id});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _selectedIndex = 0;

  int state = 0;
  final List<String> _buttonNames = ['Calendario', 'Agendar', 'Pacientes'];
  late List<Widget> _pages;

  void _navigateBottomBar(int index) {
    if (index == 1 && state == 2) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.person_add),
                title: const Text('Registrar paciente'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Add(
                          isCitaInmediata: false,
                          isEvento: false,
                          isPacient: true,
                          isCitaPro: false,
                          usuario_id: widget.usuario_id),
                    ),
                  );
                },
              ),
            ],
          );
        },
      );
    }
    if (index == 1 && state == 1) {
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
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Add(
                        isCitaInmediata: true,
                        isEvento: false,
                        isPacient: false,
                        isCitaPro: false,
                        usuario_id: widget.usuario_id,
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
                        usuario_id: widget.usuario_id,
                      ),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.calendar_month),
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
                        usuario_id: widget.usuario_id,
                      ),
                    ),
                  );
                },
              ),
            ],
          );
        },
      );
    } else {
      setState(() {
        _selectedIndex = index;
        // Cambiar el nombre del botón del medio según la selección
        if (_selectedIndex == 0) {
          _buttonNames[1] = 'Agendar';
          state = 1;
        } else if (_selectedIndex == 2) {
          _buttonNames[1] = 'Registrar';
          state = 2;
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _pages = [
      Calendar(usuario_id: widget.usuario_id),
      Add(
          isCitaInmediata: false,
          isCitaPro: false,
          isEvento: false,
          isPacient: false,
          usuario_id: widget.usuario_id),
      Patients(usuario_id: widget.usuario_id),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _navigateBottomBar,
        fixedColor: Colors.green,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Calendario',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.add),
            label: _buttonNames[1],
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Pacientes',
          ),
        ],
        unselectedIconTheme: const IconThemeData(color: Colors.grey),
      ),
    );
  }
}
