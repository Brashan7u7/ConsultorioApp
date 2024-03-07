import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool _obscureText = true;
  bool _recordarContrasena = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(20.0),
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
              SizedBox(height: 20),

              TextField(
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility : Icons.visibility_off,
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
              SizedBox(height: 10),

            
              Container(
                margin: EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Checkbox(
                      value: _recordarContrasena,
                      onChanged: (value) {
                        setState(() {
                          _recordarContrasena = value!;
                        });
                      },
                    ),
                    Text('Recordar Contraseña'),
                  ],
                ),
              ),

              
              Container(
                margin: EdgeInsets.symmetric(vertical: 5),
                child: TextButton(
                  onPressed: () {
                    
                  },
                  child: Text('¿Olvidaste tu Contraseña?'),
                ),
              ),

              SizedBox(height: 30),

            
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                ),
                onPressed: () {
                
                },
                child: Text('INICIAR SESIÓN'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
