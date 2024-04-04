import 'package:calendario_manik/pages/add_page.dart';
import 'package:calendario_manik/pages/calendar_page.dart';
import 'package:calendario_manik/pages/consulting_page.dart';
import 'package:calendario_manik/pages/createAccount_page.dart';
import 'package:calendario_manik/pages/home_page.dart';
import 'package:calendario_manik/pages/patients_page.dart';
import 'package:calendario_manik/pages/resetPassword_page.dart';
import 'package:flutter/material.dart';

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
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } else {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('lib/images/usuario.png',
                  width: 200, height: 200, fit: BoxFit.fill),
              const SizedBox(height: 50),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                onChanged: (value) {},
              ),
              const SizedBox(height: 20),
              TextField(
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  ),
                ),
                obscureText: _obscureText,
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
                    ),
                    const Text('Recordar Contraseña'),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 5),
                child: TextButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => ResetP()));
                  },
                  child: const Text('¿Olvidaste tu Contraseña?'),
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
                  child: const Text('Registrate'),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 50, vertical: 5),
                ),
                onPressed: _iniciarSesion,
                child: const Text('Iniciar Sesión'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
