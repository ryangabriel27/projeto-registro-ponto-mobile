import 'package:flutter/material.dart';
import 'package:prototipo_teste/services/firestore_service.dart'; // Importe o FirestoreService
import 'package:prototipo_teste/screens/dashboard_screen.dart';

class CadastroSenhaScreen extends StatefulWidget {
  final String nif;

  CadastroSenhaScreen({required this.nif});

  @override
  _CadastroSenhaScreenState createState() => _CadastroSenhaScreenState();
}

class _CadastroSenhaScreenState extends State<CadastroSenhaScreen> {
  final TextEditingController _senhaController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService(); // Instância do FirestoreService

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cadastrar Senha')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _senhaController,
              decoration: InputDecoration(labelText: 'Nova Senha'),
              obscureText: true,
            ),
            ElevatedButton(
              onPressed: () async {
                String senha = _senhaController.text;

                try {
                  // Atualiza a senha do funcionário usando o FirestoreService
                  await _firestoreService.atualizarSenhaFuncionario(widget.nif, senha);

                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Senha cadastrada com sucesso')));

                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => PaginaInternaFuncionario(nif: widget.nif,)));
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao cadastrar senha: $e')));
                }
              },
              child: Text('Cadastrar Senha'),
            ),
          ],
        ),
      ),
    );
  }
}
