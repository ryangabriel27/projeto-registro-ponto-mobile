import 'package:flutter/material.dart';
import 'package:prototipo_teste/screens/cadastro_screen.dart';
import 'package:prototipo_teste/screens/login_screen.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registro de Ponto - Home'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Bem-vindo ao Sistema de Registro de Ponto',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navega para a tela de login
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
              child: Text('Login'),
            ),
            SizedBox(height: 10),
            // ElevatedButton(
            //   onPressed: () {
            //     // Navega para a tela de cadastro de funcionários (para ADM)
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(builder: (context) => CadastroFuncionariosScreen()),
            //     );
            //   },
            //   child: Text('Cadastro de Funcionário (ADM)'),
            // ),
          ],
        ),
      ),
    );
  }
}
