import 'package:bcrypt/bcrypt.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:prototipo_teste/models/Funcionario.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Cadastra um novo funcionário
  Future<void> cadastrarFuncionario(Funcionario funcionario) async {
    try {
      await _firestore
          .collection('funcionarios')
          .doc(funcionario.nif)
          .set(funcionario.toMap());
      print("Funcionário cadastrado com sucesso");
    } catch (e) {
      print("Erro ao cadastrar funcionário: $e");
      throw e;
    }
  }

  // Verifica se o funcionário existe e retorna suas informações
  // Método para buscar um funcionário por NIF
  Future<Funcionario?> buscarFuncionarioPorNIF(String nif) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('funcionarios').doc(nif).get();
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return Funcionario.fromMap(data); // Usa o fromMap para converter
      } else {
        return null; // Funcionário não encontrado
      }
    } catch (e) {
      print('Erro ao buscar funcionário: $e');
      return null;
    }
  }

  // Atualiza a senha do funcionário com hash
  Future<void> atualizarSenhaFuncionario(String nif, String senha) async {
    try {
      // Gera o hash da senha usando bcrypt
      String hashedSenha = BCrypt.hashpw(senha, BCrypt.gensalt());

      await _firestore.collection('funcionarios').doc(nif).update({
        'senha': hashedSenha,
      });
      print("Senha atualizada com sucesso");
    } catch (e) {
      print("Erro ao atualizar senha: $e");
      throw e;
    }
  }
  // Verifica a senha inserida com a hash armazenada
  Future<bool> verificarSenhaFuncionario(String nif, String senha) async {
    try {
      // Busca o funcionário no Firestore
      DocumentSnapshot docSnapshot = await _firestore.collection('funcionarios').doc(nif).get();

      if (docSnapshot.exists) {
        var funcionarioData = docSnapshot.data() as Map<String, dynamic>;

        // Verifica a senha fornecida comparando com o hash
        String hashedSenha = funcionarioData['senha'];

        // Verifica se a senha fornecida corresponde ao hash
        bool isSenhaCorreta = BCrypt.checkpw(senha, hashedSenha);

        return isSenhaCorreta;
      } else {
        throw Exception("Funcionário não encontrado");
      }
    } catch (e) {
      print("Erro ao verificar senha: $e");
      throw e;
    }
  }


  // Realiza o login verificando a senha
  Future<bool> login(String nif, String senha) async {
    try {
      Funcionario? funcionarioData = await buscarFuncionarioPorNIF(nif);
      if (funcionarioData != null && funcionarioData.senha == senha) {
        // Acesso à senha do funcionário
        print("Login realizado com sucesso");
        return true;
      }
      print("Senha incorreta ou funcionário não encontrado");
      return false;
    } catch (e) {
      print("Erro no login: $e");
      throw e;
    }
  }

  Future<void> registrarPonto(
      {required String tipo,
      required double latitude,
      required double longitude}) async {
    try {
      // Aqui você deve configurar o que deseja armazenar no Firestore
      await _firestore.collection('registros_de_ponto').add({
        'tipo': tipo,
        'latitude': latitude,
        'longitude': longitude,
        'timestamp': FieldValue.serverTimestamp(), // Adiciona um timestamp
      });
      print("Ponto registrado com sucesso");
    } catch (e) {
      print("Erro ao registrar ponto: $e");
      throw e;
    }
  }
}
