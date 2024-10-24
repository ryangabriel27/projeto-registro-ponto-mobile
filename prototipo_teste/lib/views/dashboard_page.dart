import 'package:flutter/material.dart';
import 'registro_ponto_page.dart';

class DashboardPage extends StatelessWidget {
  final String nif;

  DashboardPage({required this.nif});

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
                    builder: (context) =>
                        RegistroPontoPage(tipo: 'entrada', nif: nif),
                  ),
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
                    builder: (context) =>
                        RegistroPontoPage(tipo: 'saida', nif: nif),
                  ),
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
