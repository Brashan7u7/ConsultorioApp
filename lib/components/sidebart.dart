import 'package:flutter/material.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
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

          const Padding(
            padding: EdgeInsets.only(left: 25.0),
            child: ListTile(
              leading: Icon(
                Icons.access_alarm,
              ),
              title: Text(
                'Horario',
              ),
            ),
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
    );
  }
}