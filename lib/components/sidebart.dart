import 'package:flutter/material.dart';
import 'package:calendario_manik/pages/consulting_page.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({Key? key});

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
    );
  }
}
