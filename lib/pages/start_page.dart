import 'package:calendario_manik/pages/createAccount_page.dart';
import 'package:calendario_manik/pages/login_page.dart';
import 'package:calendario_manik/widgets/custom_scaffold.dart';
import 'package:calendario_manik/widgets/welcome_button.dart';
import 'package:flutter/material.dart';

class StartPage extends StatelessWidget {
  const StartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
        child: Column(
      children: [
        Flexible(
            flex: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 40),
              child: Center(
                  child: RichText(
                textAlign: TextAlign.center,
                text: const TextSpan(children: [
                  TextSpan(
                      text: '¡MedicalManik!\n',
                      style: TextStyle(
                          fontSize: 40.0, fontWeight: FontWeight.w800)),
                  TextSpan(text: 'Bienvenido', style: TextStyle(fontSize: 20)),
                ]),
              )),
            )),
        const Flexible(
            flex: 1,
            child: Align(
              alignment: Alignment.bottomRight,
              child: Row(
                children: [
                  Expanded(
                      child: WelcomeButton(
                    buttonText: 'Iniciar Sesión',
                    onTap: Login(),
                    color: Colors.transparent,
                    textColor: Colors.white,
                  )),
                  Expanded(
                      child: WelcomeButton(
                    buttonText: 'Registrate',
                    onTap: CreateP(),
                    color: Colors.white,
                    textColor: Color.fromARGB(255, 11, 66, 105),
                  )),
                ],
              ),
            ))
      ],
    ));
  }
}
