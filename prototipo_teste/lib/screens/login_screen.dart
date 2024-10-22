import 'package:flutter/material.dart';
import 'package:prototipo_teste/models/Funcionario.dart';
import 'package:prototipo_teste/services/firestore_service.dart'; // Importe o FirestoreService
import 'package:prototipo_teste/screens/cadastro_screen.dart';
import 'package:prototipo_teste/screens/cadastro_senha_screen.dart';
import 'package:prototipo_teste/screens/dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _nifController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService(); // Instância do FirestoreService

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
            TextField(
              controller: _senhaController,
              decoration: InputDecoration(labelText: 'Senha'),
              obscureText: true,
            ),
            ElevatedButton(
              onPressed: () async {
                String nif = _nifController.text;
                String senha = _senhaController.text;

                try {
                  // Busca o funcionário no Firestore
                  Funcionario? funcionarioData = await _firestoreService.buscarFuncionarioPorNIF(nif);
                  
                  if (funcionarioData != null) {
                    if (funcionarioData.senha == null || funcionarioData.senha!.isEmpty) {
                      // Se a senha não estiver cadastrada, redireciona para a tela de registro de senha
                      Navigator.push(context, MaterialPageRoute(builder: (_) => CadastroSenhaScreen(nif: nif)));
                    } else if (funcionarioData.senha == senha) {
                      // Se o login for bem-sucedido
                      if (funcionarioData.isAdmin == true) {
                        // Redireciona para a página de ADM
                        Navigator.push(context, MaterialPageRoute(builder: (_) => CadastroFuncionariosScreen()));
                      } else {
                        // Redireciona para a página interna do funcionário
                        Navigator.push(context, MaterialPageRoute(builder: (_) => PaginaInternaFuncionario()));
                      }
                    } else {
                      // Senha incorreta
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Senha incorreta')));
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Funcionário não encontrado')));
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao realizar login: $e')));
                }
              },
              child: Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
