import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:prototipo_teste/models/Funcionario.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Cadastra um novo funcionário
  Future<void> cadastrarFuncionario(Funcionario funcionario) async {
    try {
      await _firestore.collection('funcionarios').doc(funcionario.nif).set(funcionario.toMap());
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
      DocumentSnapshot doc = await _firestore.collection('funcionarios').doc(nif).get();
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

  // Atualiza a senha do funcionário
  Future<void> atualizarSenhaFuncionario(String nif, String senha) async {
    try {
      await _firestore.collection('funcionarios').doc(nif).update({
        'senha': senha,
      });
      print("Senha atualizada com sucesso");
    } catch (e) {
      print("Erro ao atualizar senha: $e");
      throw e;
    }
  }


  // Realiza o login verificando a senha
  Future<bool> login(String nif, String senha) async {
    try {
      Funcionario? funcionarioData = await buscarFuncionarioPorNIF(nif);
      if (funcionarioData != null && funcionarioData.senha == senha) { // Acesso à senha do funcionário
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
}
