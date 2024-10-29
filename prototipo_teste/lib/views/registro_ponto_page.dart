import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:prototipo_teste/models/RegistroPonto.dart';
import 'package:prototipo_teste/services/firestore_service.dart';
import 'package:local_auth/local_auth.dart';

class RegistroPontoPage extends StatefulWidget {
  final String tipo;
  final String nif;

  RegistroPontoPage({required this.tipo, required this.nif});

  @override
  _RegistroPontoPageState createState() => _RegistroPontoPageState();
}

class _RegistroPontoPageState extends State<RegistroPontoPage> {
  late Position _currentPosition;
  bool _isLoading = true;
  FirestoreService _firestore = new FirestoreService();
  final LocalAuthentication auth =
      LocalAuthentication(); // Instância para autenticação biométrica

  // Coordenadas do local específico
  final double specificLatitude = -22.5708699;
  final double specificLongitude = -47.403842;

  String get formattedDistance {
    // Método para formatar a distância
    double distance = Geolocator.distanceBetween(
      _currentPosition.latitude,
      _currentPosition.longitude,
      specificLatitude,
      specificLongitude,
    );
    return distance.toStringAsFixed(2);
  }

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _checkBiometrics();
  }

  Future<void> _getCurrentLocation() async {
    // Método para pegar a localização do celular
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _isLoading = false;
      });
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _isLoading = false;
        });
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _isLoading = false;
      });
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    _currentPosition = await Geolocator.getCurrentPosition();
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _checkBiometrics() async {
    // Verifica se há biometria disponivel no dispositivo
    try {
      List<BiometricType> availableBiometrics =
          await auth.getAvailableBiometrics();

      print('Available biometrics:');
      for (var biometric in availableBiometrics) {
        print('  - $biometric');
      }

      // Check specific types
      final hasFingerprint =
          availableBiometrics.contains(BiometricType.fingerprint);
      final hasFaceId = availableBiometrics.contains(BiometricType.face);

      print('Has Fingerprint: $hasFingerprint');
      print('Has FaceID: $hasFaceId');
    } on PlatformException catch (e) {
      print('Failed to get available biometrics: ${e.message}');
    }
  }

  // Método para autenticação biométrica do colaborador
  Future<bool> _authenticate() async {
    try {
      // First check if biometrics are available
      bool canCheckBiometrics = await auth.canCheckBiometrics;
      List<BiometricType> availableBiometrics =
          await auth.getAvailableBiometrics();

      if (!canCheckBiometrics || availableBiometrics.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Biometria não disponível neste dispositivo')),
        );
        return false;
      }

      // Print available biometrics for debugging
      print('Available biometrics: $availableBiometrics');

      bool authenticated = await auth.authenticate(
        localizedReason: 'Por favor, autentique-se para registrar o ponto',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true, // Only allow biometric authentication
          useErrorDialogs: true,
        ),
      );

      return authenticated;
    } on PlatformException catch (e) {
      // Caso, pegue um erro do tipo PlatformException especifica o erro
      print('PlatformException - code: ${e.code}, message: ${e.message}');

      String message;
      switch (e.code) {
        case 'NotAvailable':
          message = 'Autenticação biométrica não está disponível';
          break;
        case 'NotEnrolled':
          message = 'Nenhuma biometria cadastrada no dispositivo';
          break;
        case 'LockedOut':
          message = 'Autenticação bloqueada. Tente novamente mais tarde';
          break;
        case 'PermanentlyLockedOut':
          message =
              'Autenticação biométrica permanentemente bloqueada. Use seu PIN/Senha';
          break;
        case 'PasscodeNotSet':
          message = 'Nenhum PIN/Senha configurado no dispositivo';
          break;
        default:
          message = 'Erro na autenticação: ${e.message}';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
      return false;
    } catch (e) {
      print('Generic error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro inesperado durante a autenticação')),
      );
      return false;
    }
  }

  Future<void> _registrarPonto() async {
    // Método para registrar o ponto
    double distance = Geolocator.distanceBetween(_currentPosition.latitude,
        _currentPosition.longitude, specificLatitude, specificLongitude);

    String distanciaFormatada = distance.toStringAsFixed(2) + "m";

    if (distance <= 100) {
      try {
        RegistroPonto newRegistro = new RegistroPonto(
            nif: widget.nif,
            tipo: widget.tipo,
            latitude: _currentPosition.latitude,
            longitude: _currentPosition.longitude,
            distancia: distanciaFormatada,
            nome: "");

        await _firestore.registrarPonto(newRegistro);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ponto registrado com sucesso!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao registrar ponto: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Você está fora do alcance permitido para bater o ponto.'),
        ),
      );
    }
  }

  // Função que chama a autenticação e, caso tenha sucesso, registra o ponto
  Future<void> _handleRegistroPonto() async {
    bool isAuthenticated =
        await _authenticate(); // Realiza a autenticação biométrica
    if (isAuthenticated) {
      // Se autenticação for bem-sucedida, registra o ponto
      await _registrarPonto();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            "Registro de ponto - " + widget.tipo,
            style: TextStyle(
              fontWeight: FontWeight.w200,
            ),
          ),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: <Widget>[
                Container(
                  height: 300,
                  child: FlutterMap(
                    options: MapOptions(
                      center: LatLng(_currentPosition.latitude,
                          _currentPosition.longitude),
                      zoom: 15.0,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                        subdomains: ['a', 'b', 'c'],
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: LatLng(_currentPosition.latitude,
                                _currentPosition.longitude),
                            builder: (ctx) => Container(
                              child: Icon(Icons.location_history,
                                  color: Colors.deepPurpleAccent, size: 50),
                            ),
                          ),
                          Marker(
                            point: LatLng(specificLatitude, specificLongitude),
                            builder: (ctx) => Container(
                              child: Icon(Icons.location_on,
                                  color: const Color.fromARGB(255, 56, 32, 99),
                                  size: 40),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(height: 10.0),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Distância da empresa - ${formattedDistance}m',
                          style: TextStyle(
                            fontSize: 14.0,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ),
                      SizedBox(height: 20.0),
                      ElevatedButton(
                        onPressed: _handleRegistroPonto,
                        child: Text('Confirmar Registro de Ponto', style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12.0,
                        ),),
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                                Colors.deepPurpleAccent)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
