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
  final FirestoreService _firestoreService = FirestoreService();

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
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => HomeScreen(),
                        ));
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
                String nif = _nifController.text.trim();
                String nome = _nomeController.text.trim();
                String cpf = _cpfController.text.trim();

                // Verificação de campos vazios
                if (nif.isEmpty || nome.isEmpty || cpf.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Todos os campos são obrigatórios')),
                  );
                  return;
                }

                // Verifica se o NIF já existe
                Funcionario? funcionarioExistente =
                    await _firestoreService.buscarFuncionarioPorNIF(nif);

                if (funcionarioExistente != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('NIF já cadastrado')),
                  );
                  return;
                }

                Funcionario funcionario = Funcionario(
                  nif: nif,
                  nome: nome,
                  cpf: cpf,
                  senha: null,
                  isAdmin: false,
                );

                try {
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
