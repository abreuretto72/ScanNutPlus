import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:scannutplus/l10n/app_localizations.dart';

class PetMapScreen extends StatefulWidget {
  const PetMapScreen({super.key});

  @override
  State<PetMapScreen> createState() => _PetMapScreenState();
}

class _PetMapScreenState extends State<PetMapScreen> {
  // Controlador para manipular o mapa
  Completer<GoogleMapController> _mapController = Completer<GoogleMapController>();
  
  // Estado da localização
  Position? _currentPosition;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    // Inicia o fluxo de verificação assim que a tela abre
    _initLocationFlow();
  }

  /// Fluxo principal de inicialização: Permissão -> Localização -> Câmera
  Future<void> _initLocationFlow() async {
    try {
      bool hasPermission = await _checkPermission();
      if (hasPermission) {
        await _getCurrentLocation();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  /// MÉTODO: _checkPermission
  /// Verifica serviço de GPS e solicita permissões ao tutor
  Future<bool> _checkPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 1. Verifica se o GPS do celular está ligado
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) setState(() => _errorMessage = AppLocalizations.of(context)!.map_gps_disabled);
      return false;
    }

    // 2. Verifica o status da permissão
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) setState(() => _errorMessage = AppLocalizations.of(context)!.map_permission_denied);
        return false;
      }
    }

    // 3. Tratamento para negação permanente (iOS e Android)
    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        setState(() {
          _errorMessage = AppLocalizations.of(context)!.map_permission_denied_forever;
        });
      }
      return false;
    }

    return true;
  }

  /// MÉTODO: _getCurrentLocation
  /// Coleta as coordenadas reais usando precisão alta
  Future<void> _getCurrentLocation() async {
    try {
      const LocationSettings locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 100,
      );
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: locationSettings,
      );

      if (mounted) {
        setState(() {
          _currentPosition = position;
          _isLoading = false;
        });
      }

      // Move a câmera assim que a posição é obtida
      _moveCamera(position);
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = AppLocalizations.of(context)!.map_error_location(e.toString());
          _isLoading = false;
        });
      }
    }
  }

  /// MÉTODO: _moveCamera
  /// Executa a animação fluida para o local do tutor (Fim do efeito Praça da Sé)
  Future<void> _moveCamera(Position position) async {
    final GoogleMapController controller = await _mapController.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          zoom: 16.0, // Zoom solicitado
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.map_title_pet_location),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Exibe o mapa apenas se não houver erro crítico
          _errorMessage.isEmpty
              ? GoogleMap(
                  onMapCreated: (GoogleMapController controller) {
                    _mapController.complete(controller);
                  },
                  initialCameraPosition: const CameraPosition(
                    target: LatLng(-23.5505, -46.6333), // Fallback inicial (Sé), será movido logo em seguida
                    zoom: 10,
                  ),
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  compassEnabled: true,
                  trafficEnabled: false,
                  mapType: MapType.normal,
                )
              : Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.location_off, size: 60, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(_errorMessage, textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => Geolocator.openAppSettings(),
                          child: Text(AppLocalizations.of(context)!.action_open_settings),
                        ),
                      ],
                    ),
                  ),
                ),

          // UX: Indicador de carregamento sobre o mapa
          if (_isLoading)
            Container(
              color: Colors.white.withValues(alpha: 0.8),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(AppLocalizations.of(context)!.map_sync_satellites, 
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // Evita memory leak ao destruir a tela
    super.dispose();
  }
}
