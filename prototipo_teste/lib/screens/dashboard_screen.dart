import 'package:flutter/material.dart';
import 'package:prototipo_teste/views/registro_ponto_page.dart';

class PaginaInternaFuncionario extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registro de Ponto'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => RegistroPontoPage(tipo: 'entrada')),
                );
              },
              child: Text('Bater Ponto de Entrada'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => RegistroPontoPage(tipo: 'saida')),
                );
              },
              child: Text('Bater Ponto de Saída'),
            ),
          ],
        ),
      ),
    );
  }
}
