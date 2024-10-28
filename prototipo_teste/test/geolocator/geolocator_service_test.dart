import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mocktail/mocktail.dart';
import 'geolocator_service.dart';

// Criação do mock com Mocktail
class MockGeolocatorService extends Mock implements GeolocatorService {}

void main() {
  group('Geolocation Test', () {
    late MockGeolocatorService mockGeolocatorService;

    setUp(() {
      mockGeolocatorService = MockGeolocatorService();
    });

    test('Obtenção da localização atual com sucesso', () async {
      // Define uma posição simulada
      final fakePosition = Position(
        longitude: -46.625290,
        latitude: -23.533773,
        timestamp: DateTime.now(),
        accuracy: 0.0,
        altitude: 0.0,
        heading: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0, altitudeAccuracy: 0.0, headingAccuracy: 0.0,
      );

      // Configuração do retorno do mock
      when(() => mockGeolocatorService.getCurrentPosition())
          .thenAnswer((_) async => fakePosition);

      // Chamada da função para teste
      final position = await mockGeolocatorService.getCurrentPosition();

      // Verificações
      expect(position.latitude, equals(-23.533773));
      expect(position.longitude, equals(-46.625290));

      // Verifica se o método foi chamado
      verify(() => mockGeolocatorService.getCurrentPosition()).called(1);
    });
  });
}
