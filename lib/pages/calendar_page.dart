import 'package:flutter/material.dart';

class Calendar extends StatefulWidget {
  const Calendar({super.key});

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  
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
              }),
        ),
      ),
      drawer: Drawer(
        child: Column(
          children: [
            //logo
            DrawerHeader(
              child: Image.asset('lib/images/usuario.png'),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 25.0),
              child: Divider(
                color: Colors.red,
              ),
            ),

            //otras paginas
            const Padding(
              padding: EdgeInsets.only(left: 25.0),
              child: ListTile(
                leading: Icon(
                  Icons.article,
                ),
                title: Text(
                  'Citas de hoy',
                ),
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
          ],
        ),
      ),
    );
  }
}
