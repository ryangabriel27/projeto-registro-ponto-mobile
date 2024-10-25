import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart'; // Para buscar a imagem
import 'package:prototipo_teste/models/Funcionario.dart';
import 'package:prototipo_teste/screens/upload_foto_screen.dart';
import 'package:prototipo_teste/services/firestore_service.dart';
import 'package:prototipo_teste/views/registro_ponto_page.dart';

class PaginaInternaFuncionario extends StatefulWidget {
  final String nif; // Adiciona o NIF para buscar a foto de perfil

  PaginaInternaFuncionario({required this.nif});

  @override
  _PaginaInternaFuncionarioState createState() =>
      _PaginaInternaFuncionarioState();
}

class _PaginaInternaFuncionarioState extends State<PaginaInternaFuncionario> {
  String? _fotoPerfilUrl; // Para armazenar a URL da foto de perfil
  String? nomeUsuario;
  FirestoreService _firestoreService = new FirestoreService();

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
      return null; // Retorna null se houver um erro
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
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            FutureBuilder<String?>(
                future: carregaNomeUsuario(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    // Mostra um ícone de carregamento enquanto o nome é carregado
                    return Text('Carregando...');
                  } else if (snapshot.hasError) {
                    // Se houver um erro, exibe o erro
                    return Text('Erro ao carregar o nome: ${snapshot.error}');
                  } else {
                    // Exibe o nome do funcionário
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                        child: Text(
                          'Olá, ' + nomeUsuario!,
                          style: TextStyle(
                              fontSize: 40.0, fontWeight: FontWeight.bold),
                        ),
                      ),
                    );
                  }
                }),
            FutureBuilder<String?>(
              future: _carregarFotoPerfil(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  // Mostra um ícone de carregamento enquanto a imagem é carregada
                  return CircleAvatar(
                    radius: 50,
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError ||
                    !snapshot.hasData ||
                    snapshot.data == null) {
                  // Se houver erro, ou não houver dados, exibe um ícone padrão
                  return CircleAvatar(
                    radius: 80,
                    child: Icon(Icons.person),
                  );
                } else {
                  // Exibe a imagem de perfil carregada
                  return CircleAvatar(
                    radius: 80,
                    backgroundImage: NetworkImage(snapshot.data!),
                  );
                }
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => UploadFotoScreen(nif: widget.nif)),
                );
              },
              child: Text('Colocar foto de perfil'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          RegistroPontoPage(tipo: 'entrada', nif: widget.nif)),
                );
              },
              style: ButtonStyle(
                padding: MaterialStateProperty.all(
                    EdgeInsets.all(25.0)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize
                    .min, // Para evitar que o botão seja muito largo
                children: [
                  Icon(Icons.schedule), // Substitua pelo ícone que deseja
                  SizedBox(width: 3), // Espaçamento entre o ícone e o texto
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
                      builder: (context) =>
                          RegistroPontoPage(tipo: 'saida', nif: widget.nif)),
                );
              },
              style: ButtonStyle(
                padding: MaterialStateProperty.all(
                    EdgeInsets.all(25.0)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize
                    .min, // Para evitar que o botão seja muito largo
                children: [
                  Icon(Icons.keyboard_return), // Substitua pelo ícone que deseja
                  SizedBox(width: 3), // Espaçamento entre o ícone e o texto
                  Text('Bater Ponto de Saída'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
