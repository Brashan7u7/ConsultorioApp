import 'package:calendario_manik/variab.dart';
import 'package:flutter/material.dart';
import 'package:calendario_manik/pages/calendar_page.dart';
import 'package:calendario_manik/pages/createAccount_page.dart';
import 'package:calendario_manik/pages/resetPassword_page.dart';
import 'package:calendario_manik/widgets/custom_scaffold.dart';
import 'package:calendario_manik/pages/consulting_page.dart';
import 'package:calendario_manik/database/database.dart';
import 'dart:collection';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool _obscureText = true;
  bool _recordarContrasena = false;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  List<Map<String, dynamic>> consultoriosData = [];

  Future<void> _loadConsultorios() async {
    if (usuario_rol == 'MED') {
      consultoriosData = await DatabaseManager.getConsultoriosData(usuario_id);
      await DatabaseManager.setPermissionsByRole(usuario_rol);
    }
    if (usuario_rol == 'ASI' || usuario_rol == 'ENF') {
      consultoriosData =
          await DatabaseManager.getConsultoriosData_id(usuario_id);
      await DatabaseManager.setPermissionsByRole(usuario_rol);
    }

    await Future.delayed(const Duration(milliseconds: 1500));
    if (consultoriosData.isEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const Consulting()),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const Calendar()),
      );
    }
  }

  void _iniciarSesion() async {
    String email = emailController.text;
    String password = passwordController.text;

    List<Map<String, dynamic>> usuarios = await DatabaseManager.getUsuario();
    final user = usuarios.firstWhere(
        (u) => u['correo'] == email && u['contrasena'] == password,
        orElse: () => {});

    if (user.isNotEmpty) {
      usuario_id = user['id'];
      usuario_rol = user['rol'];
      usuario_nombre = user['nombre'];
      usuario_cuenta_id = user['cuenta_id'];
      _loadConsultorios();
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: const Text('Correo electrónico o contraseña incorrectos'),
          actions: [
            TextButton(
              child: const Text('Aceptar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: const Color.fromARGB(
                      128, 0, 0, 0), // Color de fondo del contenedor
                  borderRadius: BorderRadius.circular(20), // Bordes redondeados
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Image.asset(
                      'lib/images/usuario.png',
                      width: 200,
                      height: 200,
                      fit: BoxFit.fill,
                    ),
                    const SizedBox(height: 50),
                    TextField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.email),
                        labelStyle: TextStyle(
                          color: Color.fromARGB(255, 255, 255, 255),
                        ),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(
                        color: Color.fromARGB(255, 255, 255, 255),
                      ), // Letras negras
                      onChanged: (value) {},
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: passwordController,
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        labelStyle: const TextStyle(
                          color: Color.fromARGB(255, 255, 255, 255),
                        ),
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureText
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: const Color.fromARGB(
                                255, 255, 255, 255), // Icono negro
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureText = !_obscureText;
                            });
                          },
                        ),
                      ),
                      obscureText: _obscureText,
                      style: const TextStyle(
                        color: Color.fromARGB(255, 255, 255, 255),
                      ), // Letras negras
                      onChanged: (value) {},
                    ),
                    const SizedBox(height: 10),
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Checkbox(
                            value: _recordarContrasena,
                            onChanged: (value) {
                              setState(() {
                                _recordarContrasena = value!;
                              });
                            },
                            checkColor: const Color.fromARGB(
                                255, 255, 255, 255), // Color del check negro
                          ),
                          const Text(
                            'Recordar Contraseña',
                            style: TextStyle(
                                color: Color.fromRGBO(255, 255, 255, 1)),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const ResetP()),
                          );
                        },
                        child: const Text(
                          '¿Olvidaste tu Contraseña?',
                          style: TextStyle(
                              color: Color.fromARGB(255, 255, 255, 255)),
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const CreateP()),
                          );
                        },
                        child: const Text(
                          'Regístrate',
                          style: TextStyle(
                            color: Color.fromARGB(255, 255, 255, 255),
                          ),
                        ),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 50, vertical: 5),
                        backgroundColor:
                            (const Color.fromARGB(255, 230, 38, 38)),
                      ),
                      onPressed: _iniciarSesion,
                      child: const Text('Iniciar Sesión',
                          style: TextStyle(
                              color: Color.fromARGB(255, 255, 255, 255))),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
