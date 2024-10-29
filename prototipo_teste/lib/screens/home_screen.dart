import 'package:flutter/material.dart';
import 'package:prototipo_teste/screens/cadastro_screen.dart';
import 'package:prototipo_teste/screens/login_screen.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: [0.0, 0.99],
            colors: [
              Colors.transparent,
              Colors.deepPurpleAccent.withOpacity(0.2),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 400,
                height: 200,
                child: Image.asset('assets/images/logo1.png'),
              ),
              SizedBox(height: 0),
              ElevatedButton(
                onPressed: () {
                  // Navega para a tela de login
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  );
                },
                child: Text(
                  'Login',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(
                      Colors.deepPurpleAccent), // Fundo roxo
                ),
              ),
              SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
