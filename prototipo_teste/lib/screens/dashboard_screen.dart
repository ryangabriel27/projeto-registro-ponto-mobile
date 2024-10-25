import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:prototipo_teste/models/Funcionario.dart';
import 'package:prototipo_teste/screens/home_screen.dart';
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

  @override
  void initState() {
    super.initState();
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
          child: Text(
            "Registro de ponto",
            style: TextStyle(
              fontWeight: FontWeight.w200,
            ),
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Primeira parte: Saudação, Foto de Perfil e Botão de Carregar Imagem
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              UploadFotoScreen(nif: widget.nif)),
                    );
                  },
                  child: Text('Colocar foto de perfil'),
                ),
              ],
            ),

            SizedBox(height: 40),

            // Segunda parte: Botões de "Ponto de Entrada" e "Ponto de Saída"
            Column(
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RegistroPontoPage(
                          tipo: 'Entrada',
                          nif: widget.nif,
                        ),
                      ),
                    );
                  },
                  style: ButtonStyle(
                    padding: MaterialStateProperty.all(EdgeInsets.all(25.0)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.schedule),
                      SizedBox(width: 3),
                      Text('Bater Ponto de Entrada'),
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
                          tipo: 'Saida',
                          nif: widget.nif,
                        ),
                      ),
                    );
                  },
                  style: ButtonStyle(
                    padding: MaterialStateProperty.all(EdgeInsets.all(25.0)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.keyboard_return),
                      SizedBox(width: 3),
                      Text('Bater Ponto de Saída'),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 40),

            // Terceira parte: Novo botão adicional
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
