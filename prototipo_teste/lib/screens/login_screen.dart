import 'package:flutter/material.dart';
import 'package:prototipo_teste/models/Funcionario.dart';
import 'package:prototipo_teste/screens/cadastro_screen.dart';
import 'package:prototipo_teste/screens/home_screen.dart';
import 'package:prototipo_teste/services/firestore_service.dart';
import 'package:prototipo_teste/screens/cadastro_senha_screen.dart';
import 'package:prototipo_teste/screens/dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _nifController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();

  bool _senhaFieldVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Container(
            width: 200,
            height: 50,
            child: Image.asset('assets/images/logo1.png'),
          ),
        ),
      ),
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nifController,
              decoration: InputDecoration(
                labelText: 'NIF',
                labelStyle: TextStyle(
                    color: Colors.white
                        .withOpacity(0.6)), // Label com 60% de opacidade
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Colors.white
                          .withOpacity(0)), // Borda com 20% de opacidade
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Colors.deepPurpleAccent
                          .withOpacity(0.4)), // Borda ao focar
                ),
              ),
            ),
            if (_senhaFieldVisible)
              TextField(
                controller: _senhaController,
                decoration: InputDecoration(
                  labelText: 'Senha',
                  labelStyle: TextStyle(
                      color: Colors.white
                          .withOpacity(0.6)), // Label com 60% de opacidade
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Colors.white
                            .withOpacity(0)), // Borda com 0% de opacidade
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Colors.deepPurpleAccent
                            .withOpacity(0.4)), // Borda ao focar
                  ),
                ),
                obscureText: true,
              ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    const Color.fromARGB(36, 0, 0, 0), // Cor de fundo do botão
                foregroundColor:
                    Colors.deepPurpleAccent, // Cor do texto do botão
              ),
              onPressed: () async {
                String nif = _nifController.text;

                if (!_senhaFieldVisible) {
                  Funcionario? funcionarioData =
                      await _firestoreService.buscarFuncionarioPorNIF(nif);

                  if (funcionarioData != null) {
                    if (funcionarioData.senha == null) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CadastroSenhaScreen(nif: nif),
                        ),
                      );
                    } else {
                      setState(() {
                        _senhaFieldVisible = true;
                      });
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Funcionário não encontrado')),
                    );
                  }
                } else {
                  String senha = _senhaController.text;
                  Funcionario? funcionarioData =
                      await _firestoreService.buscarFuncionarioPorNIF(nif);

                  if (funcionarioData != null) {
                    if (funcionarioData.isAdmin == true &&
                        funcionarioData.senha == senha) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CadastroFuncionariosScreen(),
                        ),
                      );
                    } else {
                      bool senhaCorreta = await _firestoreService
                          .verificarSenhaFuncionario(nif, senha);
                      if (senhaCorreta) {
                        if (funcionarioData.isAdmin == true) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CadastroFuncionariosScreen(),
                            ),
                          );
                        } else {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PaginaInternaFuncionario(
                                nif: nif,
                              ),
                            ),
                          );
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Senha incorreta')),
                        );
                      }
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Senha incorreta')),
                    );
                  }
                }
              },
              child: Text(_senhaFieldVisible ? 'Login' : 'Continuar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    const Color.fromARGB(15, 0, 0, 0), // Cor de fundo do botão
                foregroundColor:
                    Colors.deepPurpleAccent, // Cor do texto do botão
              ),
              onPressed: () {
                Navigator.pushReplacement(
                    context, MaterialPageRoute(builder: (_) => HomeScreen()));
              },
              child: Text("Voltar ao ínicio"),
            ),
          ],
        ),
      ),
    );
  }
}
