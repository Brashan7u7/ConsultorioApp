import 'package:calendario_manik/widgets/custom_scaffold.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // Importa el paquete url_launcher
import 'package:calendario_manik/pages/login_page.dart';
import 'package:url_launcher/url_launcher.dart';

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

  void _showErrorDialog(BuildContext context, String errorMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text(
            errorMessage,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 14, color: Colors.white), // Cambiado a blanco
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK',
                  style: TextStyle(color: Colors.white)), // Cambiado a blanco
            ),
          ],
        );
      },
    );
  }

  bool _validateFields() {
    if (professionalID.isEmpty ||
        phoneNumber.isEmpty ||
        emailConfirmation.isEmpty ||
        passwordConfirmation.isEmpty ||
        selectedGender.isEmpty ||
        selectedSpeciality == null) {
      _showErrorDialog(context, 'Por favor, complete todos los campos.');
      return false;
    } else if (!acceptTerms) {
      _showErrorDialog(
          context, 'Por favor, acepta los términos y condiciones.');
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    String selectedTimeZone = 'America/Mexico_City';
    return CustomScaffold(
      child: Container(
         margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10), 
        decoration: BoxDecoration(
          color: Color.fromARGB(173, 28, 27, 27), // Color de fondo del contenedor con opacidad
          borderRadius: BorderRadius.circular(20), 
           
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'lib/images/logo.png',
                  width: 400,
                  height: 100,
                  fit: BoxFit.fill,
                ),

                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          right:
                              8.0), // Ajusta el espacio entre el texto y el dropdown si es necesario
                      child: Text('Zona horaria',
                          style: TextStyle(
                              color: Colors.white)), // Cambiado a blanco
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    DropdownButton<String>(
                      value: selectedTimeZone,
                      onChanged: (String? value) {
                        setState(() {
                          selectedTimeZone = value!;
                        });
                      },
                      items: [
                        'America/Mexico_City',
                        'America/Cancun',
                        'America/Chihuahua',
                        'America/Hermosillo',
                        'America/Tijuana'
                      ].map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value,
                              style: TextStyle(
                                  color: Color.fromARGB(255, 161, 140, 140))), // Cambiado a blanco
                        );
                      }).toList(),
                    ),
                  ],
                ),

                // Género
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Género',
                        style: TextStyle(
                            color: Colors.white)), // Cambiado a blanco
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
                        Text('Mujer',
                            style: TextStyle(
                                color: Colors.white)), // Cambiado a blanco
                        Radio(
                          value: 'Hombre',
                          groupValue: selectedGender,
                          onChanged: (value) {
                            setState(() {
                              selectedGender = value.toString();
                            });
                          },
                        ),
                        Text('Hombre',
                            style: TextStyle(
                                color: Colors.white)), // Cambiado a blanco
                        Radio(
                          value: 'Intersexual',
                          groupValue: selectedGender,
                          onChanged: (value) {
                            setState(() {
                              selectedGender = value.toString();
                            });
                          },
                        ),
                        const Text('Intersexual',
                            style: TextStyle(
                                color: Colors.white)), // Cambiado a blanco
                      ],
                    ),
                  ],
                ),

                // Especialidades
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('Especialidades',
                        style: TextStyle(
                            color: Colors.white)), // Cambiado a blanco
                    SizedBox(width: 20),
                    SizedBox(
                      height: 40, // Ajusta la altura según sea necesario
                      child: DropdownButton<String>(
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
                            child: Text(value,
                                style: TextStyle(
                                    color: const Color.fromARGB(255, 161, 140, 140))), // Cambiado a blanco
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),

                // Cédula Profesional
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Cédula Profesional',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.credit_card),
                    labelStyle:
                        TextStyle(color: Colors.white), // Cambiado a blanco
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
                    labelStyle:
                        TextStyle(color: Colors.white), // Cambiado a blanco
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
                    labelStyle:
                        TextStyle(color: Colors.white), // Cambiado a blanco
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
                    labelStyle:
                        TextStyle(color: Colors.white), // Cambiado a blanco
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
                    labelStyle:
                        TextStyle(color: Colors.white), // Cambiado a blanco
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
                    labelStyle:
                        TextStyle(color: Colors.white), // Cambiado a blanco
                  ),
                  obscureText: true,
                  onChanged: (value) {
                    setState(() {
                      passwordConfirmation = value;
                    });
                  },
                ),

                const SizedBox(height: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Fecha de Nacimiento',
                        style: TextStyle(
                            color: Colors.white)), // Cambiado a blanco
                    Row(
                      children: [
                        // Campo para el día
                        Expanded(
                          child: TextField(
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Día',
                              border: OutlineInputBorder(),
                              labelStyle: TextStyle(
                                  color: Colors.white), // Cambiado a blanco
                            ),
                          ),
                        ),
                        SizedBox(width: 10), // Separación entre los TextField
                        // Campo para el mes
                        Expanded(
                          child: TextField(
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Mes',
                              border: OutlineInputBorder(),
                              labelStyle: TextStyle(
                                  color: Colors.white), // Cambiado a blanco
                            ),
                          ),
                        ),
                        SizedBox(width: 10), // Separación entre los TextField
                        // Campo para el año
                        Expanded(
                          child: TextField(
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Año',
                              border: OutlineInputBorder(),
                              labelStyle: TextStyle(
                                  color: Colors.white), // Cambiado a blanco
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
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
    Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 20), // Margen a los lados
        child: RichText(
          text: TextSpan(
            style: TextStyle(fontSize: 10, color: Colors.white),
            children: <TextSpan>[
              TextSpan(text: 'He leído y acepto las '),
              TextSpan(
                text: 'condiciones de servicio',
                style: TextStyle(color: Colors.blue),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    launchURL("https://app.medicalmanik.com/MedicalManik/condicionesServicio.html");
                  },
              ),
              TextSpan(text: ' y '),
              TextSpan(
                text: 'aviso de privacidad',
                style: TextStyle(color: Colors.blue),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    launchURL("https://app.medicalmanik.com/MedicalManik/Privacidad.html");
                  },
              ),
            ],
          ),
        ),
      ),
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
                    child: const Text('Volver al Inicio de sesion',
                        style: TextStyle(
                            color: Colors.white)), // Cambiado a blanco
                  ),
                ),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 50, vertical: 5),
                  ),
                  onPressed: () {
                    if (_validateFields()) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Login()),
                      );
                    }
                  },
                  child: const Text('Crear cuenta',
                      style: TextStyle(
                          color: Color.fromARGB(
                              255, 0, 0, 0))), // Cambiado a blanco
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
