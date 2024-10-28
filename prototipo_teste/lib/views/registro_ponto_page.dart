import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:prototipo_teste/models/RegistroPonto.dart';
import 'package:prototipo_teste/services/firestore_service.dart';
import 'package:local_auth/local_auth.dart'; // Import do pacote de autenticação biométrica

class RegistroPontoPage extends StatefulWidget {
  final String tipo; // Tipo de ponto (ex: entrada, saída)
  final String nif; // Identificador do colaborador (nif)

  RegistroPontoPage({required this.tipo, required this.nif});

  @override
  _RegistroPontoPageState createState() => _RegistroPontoPageState();
}

class _RegistroPontoPageState extends State<RegistroPontoPage> {
  late Position _currentPosition; // Armazena a posição atual do usuário
  bool _isLoading = true; // Controla o estado de carregamento
  FirestoreService _firestore =
      new FirestoreService(); // Serviço do Firestore para registrar ponto
  final LocalAuthentication auth =
      LocalAuthentication(); // Instância para autenticação biométrica

  // Coordenadas específicas da empresa para verificar distância
  final double specificLatitude = -22.5708699;
  final double specificLongitude = -47.403842;

  // Formata a distância entre o colaborador e a localização da empresa
  String get formattedDistance {
    double distance = Geolocator.distanceBetween(
      _currentPosition.latitude,
      _currentPosition.longitude,
      specificLatitude,
      specificLongitude,
    );
    return distance.toStringAsFixed(
        2); // Retorna a distância formatada com 2 casas decimais
  }

  @override
  void initState() {
    super.initState();
    _getCurrentLocation(); // Obtém a localização ao iniciar o widget
  }

  // Método para obter a localização atual do colaborador
  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Verifica se o serviço de localização está ativado
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _isLoading = false;
      });
      return Future.error('Location services are disabled.');
    }

    // Verifica e solicita permissão de localização
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

    // Verifica se a permissão foi permanentemente negada
    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _isLoading = false;
      });
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // Obtém a localização atual do colaborador
    _currentPosition = await Geolocator.getCurrentPosition();
    setState(() {
      _isLoading =
          false; // Atualiza o estado para remover o indicador de carregamento
    });
  }

  // Método para autenticação biométrica do colaborador
  Future<bool> _authenticate() async {
    try {
      // Verifica se o dispositivo suporta autenticação biométrica
      bool canCheckBiometrics = await auth.canCheckBiometrics;
      if (!canCheckBiometrics) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('A autenticação biométrica não está disponível.')),
        );
        return false;
      }

      // Realiza a autenticação com uma mensagem para o usuário
      bool authenticated = await auth.authenticate(
        localizedReason: 'Por favor, autentique-se para registrar o ponto.',
        options: const AuthenticationOptions(
          useErrorDialogs: true, // Exibe diálogos de erro padrão do sistema
          stickyAuth:
              true, // Mantém a autenticação ativa em caso de falha temporária
        ),
      );

      return authenticated; // Retorna o resultado da autenticação
    } catch (e) {
      // Em caso de erro na autenticação, exibe uma mensagem
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao tentar autenticar: $e')),
      );
      return false;
    }
  }

  // Método para registrar o ponto no Firestore
  Future<void> _registrarPonto() async {
    // Calcula a distância entre o colaborador e a empresa
    double distance = Geolocator.distanceBetween(_currentPosition.latitude,
        _currentPosition.longitude, specificLatitude, specificLongitude);

    String distanciaFormatada =
        distance.toStringAsFixed(2) + "m"; // Formata a distância

    if (distance <= 100) {
      // Verifica se o colaborador está no raio permitido
      try {
        // Cria um novo registro de ponto com as informações do colaborador
        RegistroPonto newRegistro = new RegistroPonto(
            nif: widget.nif,
            tipo: widget.tipo,
            latitude: _currentPosition.latitude,
            longitude: _currentPosition.longitude,
            distancia: distanciaFormatada,
            nome: "");

        await _firestore
            .registrarPonto(newRegistro); // Envia o registro ao Firestore
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
          ? Center(
              child:
                  CircularProgressIndicator()) // Exibe indicador de carregamento
          : Column(
              children: <Widget>[
                // Mapa interativo com localização atual e localização da empresa
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
                          // Marcador da localização atual do colaborador
                          Marker(
                            point: LatLng(_currentPosition.latitude,
                                _currentPosition.longitude),
                            builder: (ctx) => Container(
                              child: Icon(Icons.location_history,
                                  color: Colors.deepPurpleAccent, size: 50),
                            ),
                          ),
                          // Marcador da localização da empresa
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
                      // Exibe a distância atual do colaborador até a empresa
                      Text(
                        'Distância da empresa: ${formattedDistance}m',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      ElevatedButton(
                        onPressed:
                            _handleRegistroPonto, // Botão para iniciar o registro de ponto
                        child: Text('Confirmar Registro de Ponto'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
