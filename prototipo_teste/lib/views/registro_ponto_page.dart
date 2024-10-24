import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegistroPontoPage extends StatefulWidget {
  final String tipo;
  RegistroPontoPage({required this.tipo});

  @override
  _RegistroPontoPageState createState() => _RegistroPontoPageState();
}

class _RegistroPontoPageState extends State<RegistroPontoPage> {
  late GoogleMapController mapController;
  late Position currentPosition;
  final LatLng officeLocation =
      LatLng(-23.55052, -46.633308); // Exemplo de coordenadas do escritório

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  void _getCurrentLocation() async {
    currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {});
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void _confirmLocation() async {
    double distanceInMeters = Geolocator.distanceBetween(
      currentPosition.latitude,
      currentPosition.longitude,
      officeLocation.latitude,
      officeLocation.longitude,
    );

    if (distanceInMeters <= 100) {
      await FirebaseFirestore.instance.collection('registros_ponto').add({
        'tipo': widget.tipo,
        'latitude': currentPosition.latitude,
        'longitude': currentPosition.longitude,
        'timestamp': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:
              Text('Localização validada. Ponto registrado com sucesso!')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Você está fora do alcance permitido.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Confirmação de Localização'),
      ),
      body: currentPosition == null
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: <Widget>[
                Expanded(
                  child: GoogleMap(
                    onMapCreated: _onMapCreated,
                    initialCameraPosition: CameraPosition(
                      target: LatLng(
                          currentPosition.latitude, currentPosition.longitude),
                      zoom: 15,
                    ),
                    markers: {
                      Marker(
                        markerId: MarkerId('currentLocation'),
                        position: LatLng(currentPosition.latitude,
                            currentPosition.longitude),
                        infoWindow: InfoWindow(title: 'Você está aqui!'),
                      ),
                    },
                  ),
                ),
                ElevatedButton(
                  onPressed: _confirmLocation,
                  child: Text('Confirmar Localização'),
                ),
              ],
            ),
    );
  }
}
