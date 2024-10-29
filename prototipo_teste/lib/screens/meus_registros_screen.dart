import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class MeusRegistrosPage extends StatefulWidget {
  final String nif;

  MeusRegistrosPage({required this.nif});

  @override
  _MeusRegistrosPageState createState() => _MeusRegistrosPageState();
}

class _MeusRegistrosPageState extends State<MeusRegistrosPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  DateTime _selectedDate = DateTime.now();

  Future<List<QueryDocumentSnapshot>> _getRegistros(DateTime date) async {
    // Cria data inicial (começo do dia) e final (fim do dia)
    DateTime startDate = DateTime(date.year, date.month, date.day, 0, 0, 0);
    DateTime endDate = DateTime(date.year, date.month, date.day, 23, 59, 59);

    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('registros_ponto')
          .where('nif', isEqualTo: widget.nif)
          .where('timestamp', isGreaterThanOrEqualTo: startDate)
          .where('timestamp', isLessThanOrEqualTo: endDate)
          .orderBy('timestamp', descending: true)
          .get();

      return querySnapshot.docs;
    } catch (e) {
      print('Erro ao buscar registros: $e');
      return [];
    }
  }

  Widget _buildRegistroCard(QueryDocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    Timestamp timestamp = data['timestamp'] as Timestamp;
    DateTime dateTime = timestamp.toDate();
    
    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: Icon(
          data['tipo'] == 'Entrada' ? Icons.login : Icons.logout,
          color: data['tipo'] == 'Entrada' 
              ? Colors.green 
              : Colors.red,
        ),
        title: Text(
          'Ponto de ${data['tipo']}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Horário: ${DateFormat('HH:mm:ss').format(dateTime)}',
              style: TextStyle(fontSize: 14),
            ),
            Text(
              'Distância: ${data['distancia']}',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              DateFormat('dd/MM/yyyy').format(dateTime),
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
        title: Text(
          'Meus Registros',
          style: TextStyle(fontWeight: FontWeight.w300),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Calendar/Date Picker
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back_ios),
                  onPressed: () {
                    setState(() {
                      _selectedDate = _selectedDate.subtract(Duration(days: 1));
                    });
                  },
                ),
                TextButton(
                  onPressed: () async {
                    final DateTime? date = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      setState(() {
                        _selectedDate = date;
                      });
                    }
                  },
                  child: Text(
                    DateFormat('dd/MM/yyyy').format(_selectedDate),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.arrow_forward_ios),
                  onPressed: () {
                    final tomorrow = _selectedDate.add(Duration(days: 1));
                    if (!tomorrow.isAfter(DateTime.now())) {
                      setState(() {
                        _selectedDate = tomorrow;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          
          // Registros List
          Expanded(
            child: FutureBuilder<List<QueryDocumentSnapshot>>(
              future: _getRegistros(_selectedDate),
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
                          'Nenhum registro encontrado para esta data',
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
                    return _buildRegistroCard(snapshot.data![index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}