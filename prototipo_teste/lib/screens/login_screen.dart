import 'package:flutter/material.dart';
import 'package:prototipo_teste/models/Funcionario.dart';
import 'package:prototipo_teste/screens/cadastro_screen.dart';
import 'package:prototipo_teste/services/firestore_service.dart';
import 'package:prototipo_teste/screens/cadastro_senha_screen.dart';
import 'package:prototipo_teste/screens/dashboard_screen.dart';
import '../views/dashboard_page.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _nifController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();

  bool _senhaFieldVisible =
      false; // Para controlar a exibição do campo de senha

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nifController,
              decoration: InputDecoration(labelText: 'NIF'),
            ),
            if (_senhaFieldVisible) // Mostra o campo de senha apenas se for necessário
              TextField(
                controller: _senhaController,
                decoration: InputDecoration(labelText: 'Senha'),
                obscureText: true,
              ),
            ElevatedButton(
              onPressed: () async {
                String nif = _nifController.text;

                if (!_senhaFieldVisible) {
                  // Primeiro passo: verificar se o funcionário existe e se tem senha
                  Funcionario? funcionarioData =
                      await _firestoreService.buscarFuncionarioPorNIF(nif);

                  if (funcionarioData != null) {
                    if (funcionarioData.senha == null) {
                      // Se a senha não estiver cadastrada, redireciona para cadastro de senha
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CadastroSenhaScreen(nif: nif),
                        ),
                      );
                    } else {
                      // Se a senha estiver cadastrada, exibe o campo de senha
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
                  // Segundo passo: verificar a senha
                  String senha = _senhaController.text;
                  Funcionario? funcionarioData =
                      await _firestoreService.buscarFuncionarioPorNIF(nif);

                  if (funcionarioData != null) {
                    if(funcionarioData.isAdmin == true && funcionarioData.senha == senha){
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CadastroFuncionariosScreen(),
                          ),
                        );
                    }
                    bool senhaCorreta = await _firestoreService
                        .verificarSenhaFuncionario(nif, senha);
                        print(senhaCorreta);
                    if (senhaCorreta) {
                      if (funcionarioData.isAdmin == true) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CadastroFuncionariosScreen(),
                          ),
                        );
                      } else {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PaginaInternaFuncionario(nif: nif,),
                          ),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Senha incorreta')),
                      );
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
          ],
        ),
      ),
    );
  }
}
