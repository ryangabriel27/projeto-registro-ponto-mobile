class Funcionario {
  final String nif;
  final String nome;
  final String cpf;
  final bool isAdmin;
  final String? senha; // Permite que a senha seja nula

  Funcionario({
    required this.nif,
    required this.nome,
    required this.cpf,
    required this.isAdmin,
    this.senha,
  });

  // Método para converter dados do Firestore para um objeto Funcionario
  factory Funcionario.fromMap(Map<String, dynamic> data) {
    return Funcionario(
      nif: data['nif'] ?? '',
      nome: data['nome'] ?? '',
      cpf: data['cpf'] ?? '',
      isAdmin: data['isAdmin'] ?? false,
      senha: data['senha'], // Certifique-se de que isso está correto
    );
  }

  // Método para converter um objeto Funcionario para um Map
  Map<String, dynamic> toMap() {
    return {
      'nif': nif,
      'nome': nome,
      'cpf': cpf,
      'isAdmin': isAdmin,
      'senha': senha,
    };
  }
}
