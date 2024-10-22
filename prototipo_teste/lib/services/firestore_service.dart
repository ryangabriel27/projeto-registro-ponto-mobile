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
  Future<Funcionario?> buscarFuncionarioPorNIF(String nif) async {
    try {
      DocumentSnapshot funcionarioSnapshot = await _firestore.collection('funcionarios').doc(nif).get();
      if (funcionarioSnapshot.exists) {
        return Funcionario.fromMap(funcionarioSnapshot.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print("Erro ao buscar funcionário: $e");
      throw e;
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
