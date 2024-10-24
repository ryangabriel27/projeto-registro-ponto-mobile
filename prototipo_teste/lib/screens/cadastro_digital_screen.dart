import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CadastroDigitalFuncionario extends StatefulWidget {
  final String nif;

  CadastroDigitalFuncionario({required this.nif});

  @override
  _CadastroDigitalFuncionarioState createState() =>
      _CadastroDigitalFuncionarioState();
}

class _CadastroDigitalFuncionarioState
    extends State<CadastroDigitalFuncionario> {
  final LocalAuthentication _localAuth = LocalAuthentication();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _cadastrarDigital(String nif) async {
    bool authenticated = false;

    try {
      authenticated = await _localAuth.authenticate(
        localizedReason: 'Toque no sensor para cadastrar sua digital',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } catch (e) {
      print('Erro ao autenticar: $e');
    }

    if (authenticated) {
      // Salvar o hash da digital no Firebase
      await _firestore.collection('funcionarios').doc(nif).update({
        'digital': 'hash_da_digital_aqui', // Substitua pelo hash correto
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Digital cadastrada com sucesso')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Falha ao cadastrar digital')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Supondo que o NIF do funcionário esteja disponível no contexto
    String nif = widget.nif; // Troque pelo NIF real do funcionário

    return Scaffold(
      appBar: AppBar(title: Text('Página do Funcionário')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Bem-vindo!'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _cadastrarDigital(nif),
              child: Text('Cadastrar Digital'),
            ),
          ],
        ),
      ),
    );
  }
}
