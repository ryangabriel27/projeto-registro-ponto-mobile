import 'package:cloud_firestore/cloud_firestore.dart';

class RegistroPonto {
  final String nif;
  final String tipo;
  final double latitude;
  final double longitude;
  final String distancia;
  final String nome;
  final DateTime? timestamp;

  RegistroPonto({
    required this.nif,
    required this.tipo,
    required this.latitude,
    required this.longitude,
    required this.distancia,
    required this.nome,
    this.timestamp,
  });
  // Método para converter dados do Firestore para um objeto RegistroPonto
  factory RegistroPonto.fromMap(Map<String, dynamic> data) {
    return RegistroPonto(
      nif: data['nif'] ?? '',
      tipo: data['tipo'] ?? 'Desconhecido',
      latitude: (data['latitude'] ?? 0).toDouble(),
      longitude: (data['longitude'] ?? 0).toDouble(),
      distancia: data['distancia']?.toString() ?? '0',
      nome: data['nome'] ?? 'Nome desconhecido',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
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
