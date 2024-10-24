import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:prototipo_teste/services/firestore_service.dart';

class RegistroPontoPage extends StatefulWidget {
  final String tipo;

  RegistroPontoPage({required this.tipo});

  @override
  _RegistroPontoPageState createState() => _RegistroPontoPageState();
}

class _RegistroPontoPageState extends State<RegistroPontoPage> {
  late Position _currentPosition;
  bool _isLoading = true;
  final FirestoreService _firestoreService =
      FirestoreService(); // Instância do serviço Firestore

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
      return Future.error('Location permissions are permanently denied.');
    }

    _currentPosition = await Geolocator.getCurrentPosition();
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _registrarPonto() async {
    try {
      await _firestoreService.registrarPonto(
        tipo: widget.tipo,
        latitude: _currentPosition.latitude,
        longitude: _currentPosition.longitude,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ponto registrado com sucesso!')),
      );
      Navigator.pop(context); // Volta para a tela anterior após registrar
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao registrar ponto: $e')),
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
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text('Latitude: ${_currentPosition.latitude}'),
                  Text('Longitude: ${_currentPosition.longitude}'),
                  ElevatedButton(
                    onPressed:
                        _registrarPonto, // Chama a função de registrar ponto
                    child: Text('Confirmar Registro de Ponto'),
                  ),
                ],
              ),
            ),
    );
  }
}
