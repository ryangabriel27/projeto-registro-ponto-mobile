import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

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
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Coordenadas do local específico
  final double specificLatitude = -22.5708699;
  final double specificLongitude = -47.403842;

  String get formattedDistance {
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
  }

  Future<void> _getCurrentLocation() async {
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

  Future<void> _registrarPonto() async {
    double distance = Geolocator.distanceBetween(_currentPosition.latitude,
        _currentPosition.longitude, specificLatitude, specificLongitude);

    String distanciaFormatada = distance.toStringAsFixed(2);

    if (distance <= 100) {
      try {
        await _firestore.collection('registros_ponto').add({
          'nif': widget.nif,
          'tipo': widget.tipo,
          'latitude': _currentPosition.latitude,
          'longitude': _currentPosition.longitude,
          'distancia': distanciaFormatada,
          'timestamp': FieldValue.serverTimestamp(),
        });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registro de Ponto - ${widget.tipo}'),
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
                                  color: Colors.deepPurpleAccent, size: 80),
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
                      Text(
                        'Distância da empresa: ${formattedDistance}m',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: _registrarPonto,
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
