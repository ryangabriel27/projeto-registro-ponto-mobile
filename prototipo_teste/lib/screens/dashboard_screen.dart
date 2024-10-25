import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart'; // Para buscar a imagem
import 'package:prototipo_teste/screens/upload_foto_screen.dart';
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

  @override
  void initState() {
    super.initState();
    _carregarFotoPerfil();
  }

  // Função para carregar a URL da foto de perfil do Firebase Storage
  Future<void> _carregarFotoPerfil() async {
    try {
      // Referência ao Firebase Storage
      FirebaseStorage storage = FirebaseStorage.instance;

      // Caminho da imagem no Cloud Storage
      String caminhoArquivo =
          'fotos_perfil/${widget.nif}.jpg'; // Exemplo: '12345678.jpg'
      String url = await storage.ref(caminhoArquivo).getDownloadURL();

      // Atualiza o estado para exibir a foto
      setState(() {
        _fotoPerfilUrl = url;
      });
    } catch (e) {
      print('Erro ao carregar a foto de perfil: $e');
    }
  }

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
            // Exibe o ícone da foto de perfil ou um ícone padrão enquanto carrega
            _fotoPerfilUrl != null
                ? CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(_fotoPerfilUrl!),
                  )
                : CircleAvatar(
                    radius: 50,
                    child: Icon(Icons.person),
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
              child: Text('Bater Ponto de Entrada'),
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
              child: Text('Bater Ponto de Saída'),
            ),
          ],
        ),
      ),
    );
  }
}
