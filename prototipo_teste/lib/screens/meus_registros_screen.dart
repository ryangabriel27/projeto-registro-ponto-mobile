import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:prototipo_teste/models/RegistroPonto.dart';
import 'package:prototipo_teste/screens/dashboard_screen.dart';
import 'package:prototipo_teste/services/firestore_service.dart';

class MeusRegistrosPage extends StatefulWidget {
  final String nif;

  MeusRegistrosPage({required this.nif});

  @override
  _MeusRegistrosPageState createState() => _MeusRegistrosPageState();
}

class _MeusRegistrosPageState extends State<MeusRegistrosPage> {
  final FirestoreService _firestoreService = FirestoreService();

  Widget _buildRegistroCard(RegistroPonto registro) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: Icon(
          registro.tipo == 'entrada' ? Icons.login : Icons.logout,
          color: registro.tipo == 'entrada' ? Colors.green : Colors.red,
        ),
        title: Text(
          'Ponto de ${registro.tipo}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Horário: ${DateFormat('HH:mm:ss').format(registro.timestamp!)}', // Alterar para timestamp real
              style: TextStyle(fontSize: 14),
            ),
            Text(
              'Distância: ${registro.distancia}',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              DateFormat('dd/MM/yyyy').format(registro.timestamp!), // Alterar para timestamp real
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => PaginaInternaFuncionario(nif: widget.nif),
              ),
            );
          },
          icon: Icon(Icons.arrow_back),
        ),
        title: Text(
          'Meus Registros',
          style: TextStyle(fontWeight: FontWeight.w300),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<List<RegistroPonto>>(
        future: _firestoreService.getRegistrosByNif(widget.nif),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Erro ao carregar registros: ${snapshot.error}'),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.event_busy,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Nenhum registro encontrado',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final registro = snapshot.data![index];
              return _buildRegistroCard(registro);
            },
          );
        },
      ),
    );
  }
}
