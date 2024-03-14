import 'package:flutter/material.dart';
import 'package:calendario_manik/pages/login_page.dart';

class CreateP extends StatefulWidget {
  const CreateP({Key? key});

  @override
  _CreatePState createState() => _CreatePState();
}

class _CreatePState extends State<CreateP> {
  String selectedTimeZone = "UTC"; // Zona horaria predeterminada
  String selectedGender = ""; // Género seleccionado

  String? selectedSpeciality; // Variable para la especialidad seleccionada

  List<String> specialities = [];
  String professionalID = "";
  String phoneNumber = "";
  String emailConfirmation = "";
  String passwordConfirmation = "";

  bool acceptTerms = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 50),
              Image.asset(
                'lib/images/logo.png',
                width: 400,
                height: 100,
                fit: BoxFit.fill,
              ),
              const SizedBox(height: 50),
              // ... (Código existente)
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                        right:
                            8.0), // Ajusta el espacio entre el texto y el dropdown si es necesario
                    child: Text('Zona horaria'),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  DropdownButton<String>(
                    value: selectedTimeZone,
                    onChanged: (String? value) {
                      setState(() {
                        selectedTimeZone = value!;
                      });
                    },
                    items: <String>['UTC', 'GMT', 'EST', 'CST', 'PST']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ],
              ),

              // Género
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Género'),
                  Row(
                    children: [
                      Radio(
                        value: 'Mujer',
                        groupValue: selectedGender,
                        onChanged: (value) {
                          setState(() {
                            selectedGender = value.toString();
                          });
                        },
                      ),
                      Text('Mujer'),
                      Radio(
                        value: 'Hombre',
                        groupValue: selectedGender,
                        onChanged: (value) {
                          setState(() {
                            selectedGender = value.toString();
                          });
                        },
                      ),
                      Text('Hombre'),
                      Radio(
                        value: 'Intersexual',
                        groupValue: selectedGender,
                        onChanged: (value) {
                          setState(() {
                            selectedGender = value.toString();
                          });
                        },
                      ),
                      Text('Intersexual'),
                    ],
                  ),
                ],
              ),

              // Especialidades
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Especialidades'),
                  SizedBox(width: 20),
                  DropdownButton<String>(
                    value: selectedSpeciality,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedSpeciality = newValue!;
                        if (!specialities.contains(newValue)) {
                          specialities.add(newValue);
                        }
                      });
                    },
                    items: <String>[
                      'Especialidad 1',
                      'Especialidad 2',
                      'Especialidad 3',
                      // Agrega más especialidades aquí si es necesario
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ],
              ),

              // Cédula Profesional
              TextField(
                decoration: InputDecoration(
                  labelText: 'Cédula Profesional',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.credit_card),
                ),
                onChanged: (value) {
                  setState(() {
                    professionalID = value;
                  });
                },
              ),
              const SizedBox(height: 20),

              // Teléfono
              TextField(
                decoration: InputDecoration(
                  labelText: 'Teléfono Personal',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
                onChanged: (value) {
                  setState(() {
                    phoneNumber = value;
                  });
                },
              ),
              const SizedBox(height: 20),

              // Confirmación de correo electrónico
              TextField(
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                onChanged: (value) {
                  setState(() {
                    emailConfirmation = value;
                  });
                },
              ),
              const SizedBox(height: 20),

              // Confirmación de correo electrónico
              TextField(
                decoration: InputDecoration(
                  labelText: 'Confirmar Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                onChanged: (value) {
                  setState(() {
                    emailConfirmation = value;
                  });
                },
              ),
              const SizedBox(height: 20),

              // Confirmación de contraseña
              TextField(
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
                onChanged: (value) {
                  setState(() {
                    passwordConfirmation = value;
                  });
                },
              ),
              const SizedBox(height: 20),

              // Confirmación de contraseña
              TextField(
                decoration: InputDecoration(
                  labelText: 'Confirmar Contraseña',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
                onChanged: (value) {
                  setState(() {
                    passwordConfirmation = value;
                  });
                },
              ),

              // Acepto términos y condiciones
              Row(
                children: [
                  Checkbox(
                    value: acceptTerms,
                    onChanged: (value) {
                      setState(() {
                        acceptTerms = value!;
                      });
                    },
                  ),
                  Text(
                    'He leído y acepto las condiciones de servicio y aviso de privacidad',
                    style: TextStyle(fontSize: 9),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Botones
              Container(
                margin: const EdgeInsets.symmetric(vertical: 5),
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Login()),
                    );
                  },
                  child: const Text('Volver al Inicio de sesion'),
                ),
              ),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 50, vertical: 5),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Login()),
                  );
                },
                child: const Text('Crear cuenta'),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
