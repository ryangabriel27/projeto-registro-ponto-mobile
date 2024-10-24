import 'package:flutter/material.dart';
import 'package:prototipo_teste/models/Funcionario.dart';
import 'package:prototipo_teste/screens/home_screen.dart';
import 'package:prototipo_teste/services/firestore_service.dart';

class CadastroFuncionariosScreen extends StatefulWidget {
  @override
  _CadastroFuncionariosScreenState createState() =>
      _CadastroFuncionariosScreenState();
}

class _CadastroFuncionariosScreenState
    extends State<CadastroFuncionariosScreen> {
  final TextEditingController _nifController = TextEditingController();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _cpfController = TextEditingController();
  final FirestoreService _firestoreService =
      FirestoreService(); // Instância do FirestoreService

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cadastro de Funcionários')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              child: ElevatedButton(
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                              title: Text("Registro Ponto"),
                              content: Text("Saindo..."),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(
                                        context); // Fecha o AlertDialog
                                  },
                                  child: Text('OK'),
                                ),
                              ],
                            ));
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => HomeScreen(),
                      ),
                    );
                  },
                  child: Text("Fazer Logout")),
            ),
            TextField(
              controller: _nifController,
              decoration: InputDecoration(labelText: 'NIF'),
            ),
            TextField(
              controller: _nomeController,
              decoration: InputDecoration(labelText: 'Nome'),
            ),
            TextField(
              controller: _cpfController,
              decoration: InputDecoration(labelText: 'CPF'),
            ),
            ElevatedButton(
              onPressed: () async {
                String nif = _nifController.text;
                String nome = _nomeController.text;
                String cpf = _cpfController.text;

                // Criação do objeto Funcionario
                Funcionario funcionario = Funcionario(
                  nif: nif,
                  nome: nome,
                  cpf:
                      cpf, // Você pode adicionar um campo para o CPF, se necessário
                  senha: null,
                  isAdmin: false, // Funcionário comum
                );

                try {
                  // Cadastro do funcionário usando o FirestoreService
                  await _firestoreService.cadastrarFuncionario(funcionario);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Funcionário cadastrado com sucesso')));
                  limparCampos();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Erro ao cadastrar funcionário: $e')));
                }
              },
              child: Text('Cadastrar Funcionário'),
            ),
          ],
        ),
      ),
    );
  }

  void limparCampos() {
    _nifController.clear();
    _nomeController.clear();
    _cpfController.clear();
  }
}
