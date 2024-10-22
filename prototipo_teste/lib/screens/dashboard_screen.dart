import 'package:flutter/material.dart';

class PaginaInternaFuncionario extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Página do Funcionário')),
      body: Center(child: Text('Bem-vindo! Você está logado como Funcionário Comum')),
    );
  }
}
