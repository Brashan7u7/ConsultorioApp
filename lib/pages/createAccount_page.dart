import 'package:flutter/material.dart';

class CreateP extends StatelessWidget {
  const CreateP({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Crear Cuenta'),
        backgroundColor: Color.fromARGB(255, 100, 170, 86),
      ),
      body: Padding(
        padding:
            EdgeInsets.all(20.0), // Agrega padding alrededor del formulario
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                onChanged: (value) {},
              ),
              SizedBox(height: 20), // Espacio entre los campos de texto

              TextField(
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
                onChanged: (value) {},
              ),
              SizedBox(height: 40),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                ),
                onPressed: () {
                  // Acción al presionar el botón
                },
                child: Text('Crear cuenta'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
