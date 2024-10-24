import 'dart:io'; // Para manipulação de arquivos
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart'; // Para Cloud Storage
import 'package:image_picker/image_picker.dart'; // Para selecionar a imagem
import 'package:firebase_auth/firebase_auth.dart'; // Para autenticação
import 'package:path/path.dart'; // Para manipular nomes de arquivos

class UploadFotoScreen extends StatefulWidget {
  final String nif;

  UploadFotoScreen({required this.nif});

  @override
  _UploadFotoScreenState createState() => _UploadFotoScreenState();
}

class _UploadFotoScreenState extends State<UploadFotoScreen> {
  File? _image; // A imagem selecionada
  final ImagePicker _picker = ImagePicker(); // Para selecionar a imagem

  // Função para pegar imagem da galeria
  Future<void> _getImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  // Função para fazer o upload da imagem
  Future<void> _uploadImage() async {
    if (_image != null) {
      try {
        // Referência para o Firebase Storage
        FirebaseStorage storage = FirebaseStorage.instance;

        // Definir o nome do arquivo usando o NIF
        String fileName = '${widget.nif}.jpg';
        Reference ref = storage.ref().child('fotos_perfil/$fileName');

        // Fazer o upload do arquivo
        UploadTask uploadTask = ref.putFile(_image!);
        TaskSnapshot taskSnapshot = await uploadTask;

        // Obter a URL da imagem armazenada
        String downloadUrl = await taskSnapshot.ref.getDownloadURL();

        print('Upload concluído! URL da imagem: $downloadUrl');

        // Aqui você pode salvar a URL no Firestore, associada ao usuário
        // ...
      } catch (e) {
        print('Erro ao fazer upload: $e');
        // ScaffoldMessenger.of(context as BuildContext).showSnackBar(
        //   SnackBar(content: Text('Erro ao fazer upload da imagem'))
        // );
      }
    } else {
      // caffoldMessenger.of(context as BuildContext).showSnackBar(
      //   SnackBar(content: Text('Nenhuma imagem selecionada'))
      // );S
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Upload Foto de Perfil')),
      body: Column(
        children: [
          _image == null
              ? Text('Nenhuma imagem selecionada.')
              : Image.file(_image!), // Exibe a imagem selecionada
          ElevatedButton(
            onPressed: _getImage,
            child: Text('Selecionar Imagem'),
          ),
          ElevatedButton(
            onPressed: _uploadImage,
            child: Text('Upload'),
          ),
        ],
      ),
    );
  }
}
