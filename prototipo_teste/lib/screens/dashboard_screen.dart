import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:prototipo_teste/models/Funcionario.dart';
import 'package:prototipo_teste/screens/home_screen.dart';
import 'package:prototipo_teste/screens/meus_registros_screen.dart';
import 'package:prototipo_teste/screens/upload_foto_screen.dart';
import 'package:prototipo_teste/services/firestore_service.dart';
import 'package:prototipo_teste/views/registro_ponto_page.dart';

class PaginaInternaFuncionario extends StatefulWidget {
  final String nif;

  PaginaInternaFuncionario({required this.nif});

  @override
  _PaginaInternaFuncionarioState createState() =>
      _PaginaInternaFuncionarioState();
}

class _PaginaInternaFuncionarioState extends State<PaginaInternaFuncionario> {
  String? _fotoPerfilUrl;
  String? nomeUsuario;
  FirestoreService _firestoreService = FirestoreService();
  String _timeString = '';
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timeString = _formatDateTime(DateTime.now()); // Inicializar o relógio
    _timer =
        Timer.periodic(Duration(seconds: 60), (Timer t) => _getTime()); // Atualiza a hora
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancela o relógio
    super.dispose();
  }

  // Método para formatar a data
  String _formatDateTime(DateTime dateTime) {
    return "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
  }

  // Pega a hora local de define o estado.
  void _getTime() {
    final DateTime now = DateTime.now();
    final String formattedDateTime = _formatDateTime(now);
    setState(() {
      _timeString = formattedDateTime;
    });
  }

  Future<String?> carregaNomeUsuario() async {
    Funcionario? funcionario =
        await _firestoreService.buscarFuncionarioPorNIF(widget.nif);
    nomeUsuario = funcionario?.nome;
    return nomeUsuario;
  }

  Future<String?> _carregarFotoPerfil() async {
    try {
      FirebaseStorage storage = FirebaseStorage.instance;
      String caminhoArquivo = 'fotos_perfil/${widget.nif}.jpg';
      return await storage.ref(caminhoArquivo).getDownloadURL();
    } catch (e) {
      print('Erro ao carregar a foto de perfil: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Column(
            children: [
              Container(
                width: 120,
                height: 30,
                child: Image.asset('assets/images/logo1.png'),
              ),
              Text(
                "Registro de ponto",
                style: TextStyle(
                  fontSize: 15.0,
                  fontWeight: FontWeight.w200,
                ),
              ),
            ],
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Column(
              children: [
                FutureBuilder<String?>(
                  future: carregaNomeUsuario(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Text('Carregando...');
                    } else if (snapshot.hasError) {
                      return Text('Erro ao carregar o nome: ${snapshot.error}');
                    } else {
                      // Texto com nome do usuário
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                          child: Text(
                            'Olá, ${nomeUsuario ?? ''}',
                            style: TextStyle(
                              fontSize: 30.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    }
                  },
                ),
                FutureBuilder<String?>(
                  future: _carregarFotoPerfil(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircleAvatar(
                        radius: 50,
                        child: CircularProgressIndicator(),
                      );
                    } else if (snapshot.hasError ||
                        !snapshot.hasData ||
                        snapshot.data == null) {
                      return CircleAvatar(
                        radius: 80,
                        child: Icon(Icons.person),
                      );
                    } else {
                      return CircleAvatar(
                        radius: 80,
                        backgroundImage: NetworkImage(snapshot.data!),
                      );
                    }
                  },
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              UploadFotoScreen(nif: widget.nif)),
                    );
                  },
                  child: Text('Colocar foto de perfil'),
                ),
                ElevatedButton(onPressed: (){
                  // Chama a classe meusRegistro
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              MeusRegistrosPage(nif: widget.nif)),
                    );
                }, child: Text('Ver meus registros'))
              ],
            ),

            SizedBox(
              height: 20.0,
            ),

            // Relógio
            Container(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text(
                  _timeString,
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurpleAccent,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ),

            SizedBox(height: 40),

            // Botões para Registro de ponto
            Column(
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RegistroPontoPage(
                          tipo: 'entrada',
                          nif: widget.nif,
                        ),
                      ),
                    );
                  },
                  style: ButtonStyle(
                    padding: MaterialStateProperty.all(EdgeInsets.all(20.0)),
                    backgroundColor: MaterialStateProperty.all<Color>(
                        Colors.deepPurpleAccent),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.schedule),
                      SizedBox(width: 3),
                      Text('Bater Ponto de Entrada',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RegistroPontoPage(
                          tipo: 'saida',
                          nif: widget.nif,
                        ),
                      ),
                    );
                  },
                  style: ButtonStyle(
                    padding: MaterialStateProperty.all(EdgeInsets.all(20.0)),
                    backgroundColor: MaterialStateProperty.all<Color>(
                        Colors.deepPurpleAccent),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.keyboard_return),
                      SizedBox(width: 3),
                      Text('Bater Ponto de Saída',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 40),

            // Botão de logout
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => HomeScreen(),
                    ));
              },
              style: ButtonStyle(
                padding: MaterialStateProperty.all(EdgeInsets.all(20.0)),
              ),
              child: Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
