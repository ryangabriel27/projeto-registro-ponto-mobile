class Funcionario {
  final String nif;
  final String nome;
  final String cpf;
  final String? senha;
  final bool isAdmin;

  Funcionario(
      {required this.nif,
      required this.nome,
      required this.cpf,
      this.senha,
      required this.isAdmin});

// Converte a instância da classe Funcionario para um mapa
  Map<String, dynamic> toMap() {
    return {
      'nif': nif,
      'nome': nome,
      'cpf': cpf,
      'isAdmin': isAdmin,
    };
  }

  // Cria uma instância da classe Funcionario a partir de um mapa
  factory Funcionario.fromMap(Map<String, dynamic> map) {
    return Funcionario(
      nif: map['nif'],
      nome: map['nome'],
      cpf: map['cpf'],
      isAdmin: map['isAdmin'],
    );
  }
}
