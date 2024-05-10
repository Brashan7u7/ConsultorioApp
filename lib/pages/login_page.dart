import 'package:flutter/material.dart';
import 'package:calendario_manik/pages/calendar_page.dart';
import 'package:calendario_manik/pages/createAccount_page.dart';
import 'package:calendario_manik/pages/resetPassword_page.dart';
import 'package:calendario_manik/widgets/custom_scaffold.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool _obscureText = true;
  bool _recordarContrasena = false;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  // Datos estáticos para verificar el inicio de sesión
  final String usuarioCorrecto = '1';
  final String contrasenaCorrecta = '1';

  void _iniciarSesion() {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email == usuarioCorrecto && password == contrasenaCorrecta) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Calendar()),
      );
    } else {}
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
                  color: Color.fromARGB(
                      119, 255, 255, 255), // Color de fondo del contenedor
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
                          color: Colors.black,
                        ),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      style: TextStyle(
                        color: Colors.black,
                      ), // Letras negras
                      onChanged: (value) {},
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: passwordController,
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        labelStyle: TextStyle(
                          color: Colors.black,
                        ),
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureText
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.black, // Icono negro
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureText = !_obscureText;
                            });
                          },
                        ),
                      ),
                      obscureText: _obscureText,
                      style: TextStyle(
                        color: Colors.black,
                      ), // Letras negras
                      onChanged: (value) {},
                    ),
                    const SizedBox(height: 10),
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Checkbox(
                            value: _recordarContrasena,
                            onChanged: (value) {
                              setState(() {
                                _recordarContrasena = value!;
                              });
                            },
                            checkColor: Colors.black, // Color del check negro
                          ),
                          Text(
                            'Recordar Contraseña',
                            style: TextStyle(color: Colors.black),
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
                            MaterialPageRoute(builder: (context) => ResetP()),
                          );
                        },
                        child: const Text(
                          '¿Olvidaste tu Contraseña?',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => CreateP()),
                          );
                        },
                        child: const Text(
                          'Regístrate',
                          style: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 50, vertical: 5),
                        backgroundColor: (Color.fromARGB(182, 0, 0, 0)),
                      ),
                      onPressed: _iniciarSesion,
                      child: const Text('Iniciar Sesión',
                          style: TextStyle(color: Color.fromARGB(255, 255, 255, 255))),
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
