class RegistroPonto {
  final String nif;
  final String tipo;
  final double latitude;
  final double longitude;
  final String distancia;
  final String nome; // Permite que a senha seja nula

  RegistroPonto({
    required this.nif,
    required this.tipo,
    required this.latitude,
    required this.longitude,
    required this.distancia,
    required this.nome,
  });
  // Método para converter dados do Firestore para um objeto RegistroPonto
  factory RegistroPonto.fromMap(Map<String, dynamic> data) {
    return RegistroPonto(
      nif: data['nif'] ?? '',
      tipo: data['tipo'] ?? '',
      latitude:  data['latitude'] ?? '',
      longitude:  data['longitude'] ?? '',
      distancia: data['distancia'] ?? '',
      nome: data['nome'],
    );
  }

  // Método para converter um objeto RegistroPonto para um Map
  Map<String, dynamic> toMap() {
    return {
      'nif': nif,
      'tipo': tipo,
      'latitude': latitude,
      'longitude': longitude,
      'distancia': distancia,
      'nome': nome,
    };
  }
}
