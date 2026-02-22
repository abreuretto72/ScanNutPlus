import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;
import 'dart:io';
// Dynamic Config
// JSON
import 'package:shared_preferences/shared_preferences.dart'; // Cache
// Env
// import 'dart:typed_data'; // Analyzer says unused
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart'; // Reverse Geocoding
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/foundation.dart'; // For kDebugMode
import 'package:image_picker/image_picker.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:intl/intl.dart';
import 'package:scannutplus/features/pet/map/data/repositories/map_alert_repository.dart';
import 'package:scannutplus/features/pet/map/data/models/pet_map_alert.dart';
import 'package:scannutplus/features/pet/agenda/presentation/utils/pet_map_constants.dart';
import '../../data/pet_constants.dart'; // Restored for PetPrompts/Logs
import 'package:scannutplus/features/pet/agenda/presentation/pet_map_styles.dart';

import '../../services/pet_ai_service.dart'; // Real AI Service
import 'package:scannutplus/features/pet/agenda/services/pet_vocal_ai_service.dart'; // Dedicated Vocal AI Service
import 'package:scannutplus/features/pet/agenda/services/pet_video_ai_service.dart'; // Dedicated Video AI Service
// Env Access
// Prompts
// App Keys

import 'package:scannutplus/l10n/app_localizations.dart';
import 'package:scannutplus/pet/agenda/pet_event.dart';
import 'package:scannutplus/pet/agenda/pet_event_repository.dart';
import 'package:scannutplus/features/pet/data/models/pet_event_type.dart';
// Micro App Import
import 'package:uuid/uuid.dart'; // REQUIRED for Uuid().v4()
import 'package:gal/gal.dart'; // Added for saving camera captures to gallery

enum PetMediaSource { camera, gallery, none }

class CreatePetEventScreen extends StatefulWidget {
  final String petName;
  final String petId;
  final VoidCallback? onEventSaved;
  final PetEventType? initialEventType;

  const CreatePetEventScreen({
    super.key,
    required this.petName,
    required this.petId,
    this.onEventSaved,
    this.initialEventType,
  });

  @override
  State<CreatePetEventScreen> createState() => _CreatePetEventScreenState();
}

class _CreatePetEventScreenState extends State<CreatePetEventScreen> {
  // --- CONTROLLERS E ESTADO ---
  late TextEditingController _notesController;
  late TextEditingController _friendNameController;
  late TextEditingController _tutorNameController;
  final stt.SpeechToText _speech = stt.SpeechToText();
  
  bool _isListening = false;
  bool _isRecordingAudio = false; // Separate state for Ambient/Bark recording
  bool _isSaving = false;
  bool _isFriendPresent = false;
  List<Map<String, String>> _knownFriends = [];
  Map<String, String>? _selectedFriend;
  bool _isGpsLoading = true;
  bool _isJournalMinimized = false;
  
  // Legacy Fields restored for compatibility
  PetMediaSource _mediaSource = PetMediaSource.none;
  final PetEventRepository _repository = PetEventRepository();
  final String _darkMapStyle = PetMapStyles.darkMapStyle; // Corrected constant name
  
  final DateTime _selectedDate = DateTime.now();
  final TimeOfDay _selectedTime = TimeOfDay.now();
  
  GoogleMapController? _mapController;
  MapType _currentMapType = MapType.normal; // New State
  LatLng _currentPos = const LatLng(-23.5505, -46.6333); // Default: São Paulo
  String? _currentAddress; // Stores the human-readable address
  Set<Marker> _markers = {}; // Marcadores de alerta (Waze)
  XFile? _capturedImage; // Store captured image
  String? _selectedAudioFile; // Store selected audio file path
  XFile? _capturedVideo; // Store captured video (Short Clip)
  // --- STATE MUTEX (Master Prompt 3) ---
  bool _isUploading = false; // Gallery
  bool _isRecordingVideo = false; // Camera Video
  // _isRecordingAudio is already defined above

  // Getters for UI
  bool get _isCameraActive => _capturedImage != null && !_isUploading && !_isRecordingVideo;
  bool get _isGalleryActive => _isUploading; 
  bool get _isVideoActive => _capturedVideo != null || _isRecordingVideo;
  bool get _isAudioActive => _isRecordingAudio || _selectedAudioFile != null;
  
  bool get _hasContent {
    return _notesController.text.trim().isNotEmpty || 
           _capturedImage != null || 
           _capturedVideo != null || 
           _selectedAudioFile != null;
  }


  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController();
    _friendNameController = TextEditingController();
    _tutorNameController = TextEditingController();
    _loadMapTypePreference(); // Load map preference
    _initGPS();
    _loadKnownFriends();

    // Listener para atualizar a UI (ativar/desativar ícones) enquanto digita
    _notesController.addListener(() {
      setState(() {});
    });
  }

  Future<void> _loadKnownFriends() async {
    final result = await _repository.getByPetId(widget.petId);
    if (!result.isSuccess || result.data == null) return;
    
    final RegExp regex = RegExp(r'\[Amigo: (.*?) \| Tutor: (.*?)\]');
    final Set<String> uniqueFriends = {};
    final List<Map<String, String>> parsedFriends = [];

    for (var event in result.data!) {
      if (event.notes == null) continue;
      final matches = regex.allMatches(event.notes!);
      for (var match in matches) {
        if (match.groupCount >= 2) {
            final friend = match.group(1)?.trim() ?? "";
            final tutor = match.group(2)?.trim() ?? "";
            final key = "$friend-$tutor";
            if (!uniqueFriends.contains(key) && friend.isNotEmpty) {
               uniqueFriends.add(key);
               parsedFriends.add({'friend': friend, 'tutor': tutor});
            }
        }
      }
    }
    
    if (mounted) {
       setState(() {
          _knownFriends = parsedFriends;
       });
    }
  }

  Future<void> _loadMapTypePreference() async {
    final prefs = await SharedPreferences.getInstance();
    final mapTypeIndex = prefs.getInt(PetConstants.keyMapTypeIndex) ?? 0; // Default to normal (0)
    setState(() {
      _currentMapType = MapType.values[mapTypeIndex];
    });
  }

  Future<void> _saveMapTypePreference(MapType type) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(PetConstants.keyMapTypeIndex, type.index);
  }

  @override
  void dispose() {
    // DO NOT invoke _mapController?.dispose() manually here. 
    // The google_maps_flutter plugin handles its own platform view lifecycle on Android.
    // Manually disposing it can cause the SurfaceProducer to corrupt and disappear on subsequent screen pushes.
    _speech.cancel(); // Stop any active listening
    _notesController.dispose();
    super.dispose();
  }

  // --- LÓGICA DE SENSORES ---

  Future<void> _initGPS() async {
    try {
    // 0. Verifica Permissões e Serviços (CRÍTICO PARA FUNCIONAR FORA DO EMULADOR)
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (kDebugMode) debugPrint('APP_TRACE: Location services are disabled.');
        // Não retorna, tenta pegar LastKnown ou Default
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (kDebugMode) debugPrint('APP_TRACE: Location permissions are denied');
          // Não retorna, segue para fallback
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        if (kDebugMode) debugPrint('APP_TRACE: Location permissions are permanently denied.');
        // Não retorna, segue para fallback
      }

      // 1. Tenta pegar posição com precisão Média e Timeout de 5s (GPS Sensível)
      Position? position;
      try {
        // Só tenta getCurrentPosition se tiver permissão
        if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
            position = await Geolocator.getCurrentPosition(
              locationSettings: const LocationSettings(
                accuracy: LocationAccuracy.medium, // Mais rápido e funciona indoor
                timeLimit: Duration(seconds: 5),   // Evita travamento eterno
              )
            );
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('APP_TRACE: GPS Timeout/Error, trying LastKnown');
        }
      }

      // 2. Fallback: Se falhar ou demorar, pega a última conhecida
      position ??= await Geolocator.getLastKnownPosition();

      // 3. Se ainda for nulo, usa posição padrão (SP) mas não mostra erro na UI
      // Isso permite que o mapa carregue mesmo sem GPS perfeito.
      final safePos = position != null 
          ? LatLng(position.latitude, position.longitude) 
          : _currentPos; // Mantém a default (SP)

      if (mounted) {
        setState(() {
          _currentPos = safePos;
          _isGpsLoading = false; // Destrava a UI imediatamente
        });
        
        _loadMapAlerts();
        _mapController?.animateCamera(CameraUpdate.newLatLng(_currentPos));
        
        // Start Reverse Geocoding
        if (position != null) {
           final addr = await _getAddressFromLatLng(LatLng(position.latitude, position.longitude));
           if (mounted && addr != null) {
             setState(() => _currentAddress = addr);
           }
        }
      }
    } catch (e) {
      // Catch-all apenas para logs, não trava a UI
      debugPrint("${PetMapConstants.logErrorGps}$e");
      if (mounted) {
        setState(() => _isGpsLoading = false);
      }
    }
  }

  void _onMicPressed() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(onResult: (val) {
          setState(() {
            _notesController.text = val.recognizedWords;
          });
        });
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  // Lógica de Gravação de Som Ambiente (Ex: Latidos) - Separado do STT
  void _toggleAudioRecording() {
    setState(() {
      _isRecordingAudio = !_isRecordingAudio;
    });
    
    if (_isRecordingAudio) {
      // Simulação de início de gravação
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.pet_journal_recording), duration: const Duration(seconds: 1)),
      );
    } else {
      // Simulação de fim de gravação
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.pet_journal_audio_saved)),
      );
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    if (kDebugMode) {
      debugPrint('APP_TRACE: Pick Image source: $source');
    }
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(source: source);
      if (image != null) {
        // Save to gallery if taken with camera
        if (source == ImageSource.camera) {
           try {
              await Gal.putImage(image.path);
              if (kDebugMode) debugPrint('[GAL] Saved photo to gallery: ${image.path}');
           } catch (e) {
              if (kDebugMode) debugPrint('[GAL_ERROR] Failed to save photo to gallery: $e');
           }
        }

        setState(() {
          _capturedImage = image;
          _capturedVideo = null; // Exclusive: Clear video
          _mediaSource = PetMediaSource.camera;
        });
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)!.pet_journal_photo_saved)),
          );
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('APP_TRACE: Erro ao selecionar imagem: $e');
      }
    }
  }

  Future<void> _pickGalleryMedia() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: PetConstants.galleryExtensions,
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final sizeInBytes = await file.length();
        final sizeInMb = sizeInBytes / (1024 * 1024);
        final extension = result.files.single.extension?.toLowerCase();

        if (sizeInMb > 30) {
           if (mounted) {
             ScaffoldMessenger.of(context).showSnackBar(
               SnackBar(content: Text(AppLocalizations.of(context)!.error_file_too_large ?? "File too large")),
             );
           }
           return;
        }

        if (extension != null && PetConstants.videoExtensions.contains(extension)) {
             setState(() {
               _capturedVideo = XFile(file.path);
               _capturedImage = null; // Enforce single media
               _mediaSource = PetMediaSource.gallery;
             });
             if (mounted) {
                 ScaffoldMessenger.of(context).showSnackBar(
                   SnackBar(content: Text(AppLocalizations.of(context)!.pet_journal_video_saved ?? "Video saved!")),
                 );
             }
        } else if (extension != null && PetConstants.imageExtensions.contains(extension)) {
             setState(() {
               _capturedImage = XFile(file.path);
               // MUTEX: Clear others
               _capturedVideo = null; 
               _selectedAudioFile = null;
               _isUploading = true; // Activate Gallery Glow
               _isRecordingVideo = false;
             });
             // ... snackbar ...
        }
      }
    } catch (e) {
      debugPrint("Error picking gallery media: $e");
    }
  }

  Future<void> _pickAudioFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: PetConstants.audioExtensions,
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _selectedAudioFile = result.files.single.path;
        });
        
        if (mounted) {
          final l10n = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.pet_journal_file_selected(result.files.single.name))),
          );
        }
      } 
    } catch (e) {
      debugPrint("Error picking audio file: $e");
      if (mounted) {
         final l10n = AppLocalizations.of(context)!;
         ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.pet_journal_file_error(e.toString())), backgroundColor: Colors.red),
          );
      }
    }
  }

  Future<void> _pickVideo() async {
    final ImagePicker picker = ImagePicker();
    try {
      // Limit video to 5 seconds for memory/processing safety
      final XFile? video = await picker.pickVideo(
        source: ImageSource.camera, 
        maxDuration: const Duration(seconds: 5),
      );
      
      if (video != null) {
        // Save video to gallery
        try {
           await Gal.putVideo(video.path);
           if (kDebugMode) debugPrint('[GAL] Saved video to gallery: ${video.path}');
        } catch (e) {
           if (kDebugMode) debugPrint('[GAL_ERROR] Failed to save video to gallery: $e');
        }

        setState(() {
          _capturedVideo = video;
          // MUTEX
          _capturedImage = null; 
          _isUploading = false;
          _isRecordingVideo = true; // Activate Video Glow
        });
        // ... snackbar ...
      }
    } catch (e) {
      debugPrint("Error picking video: $e");
    }
  }

  Future<String?> _getAddressFromLatLng(LatLng position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        
        // --- DEBUG GEOCoding BRUTO ---
        debugPrint('--- DEBUG GEOCoding BRUTO ---');
        debugPrint('Name: ${place.name}');
        debugPrint('Street: ${place.street}');
        debugPrint('Thoroughfare: ${place.thoroughfare}');
        debugPrint('SubThoroughfare (Número): ${place.subThoroughfare}');
        debugPrint('Locality: ${place.locality}');
        debugPrint('SubLocality (Bairro): ${place.subLocality}');
        debugPrint('AdministrativeArea: ${place.administrativeArea}');
        debugPrint('PostalCode: ${place.postalCode}');
        debugPrint('-----------------------------');
        // Format: "Rua X, 123 - Bairro, Cidade"
        // User requested: `rua + ', ' + numero + ' - ' + bairro + ', ' + cidade`
        
        // Lógica de Endereço 'Universal' (Phase 3)
        // Garante que pegamos o nome da rua mesmo se thoroughfare for nulo (comum em API levels diferentes)
        // e concatena com cidade para contexto global.
        
        final String street = place.street ?? place.thoroughfare ?? place.name ?? '';
        final String number = place.subThoroughfare ?? '';
        final String district = place.subLocality ?? '';
        final String city = place.locality ?? place.subAdministrativeArea ?? '';
        
        // Formato: "Rua X, 123 - Bairro, Cidade"
        String finalAddr = '$street, $number - $district, $city';

        // Limpeza de redundâncias (Ex: ", ,", "- -")
        finalAddr = finalAddr.replaceAll(RegExp(r', \s*,'), ',');
        finalAddr = finalAddr.replaceAll(RegExp(r'-\s*-'), '-');
        finalAddr = finalAddr.replaceAll(RegExp(r',\s*-'), ' -');
        
        if (kDebugMode) {
           debugPrint('APP_TRACE: Endereço FINAL: $finalAddr');
        }

        return finalAddr;
      }
    } catch (e) {
      debugPrint("Error getting address: $e");
    }
    return null;
  }

  // --- INTERFACE (UI) ---

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final scaffold = Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. MAPA (WAZE STYLE)
          // 1. MAPA (WAZE STYLE)
          Positioned.fill(
            child: Stack(
              children: [
                if (_isGpsLoading)
                  const Center(child: CircularProgressIndicator(color: Colors.orange)),
                
                if (!_isGpsLoading)
                  GoogleMap(
                    initialCameraPosition: CameraPosition(target: _currentPos, zoom: 16),
                    onMapCreated: (controller) {
                      _mapController = controller;
                      // 1. Forçar movimento inicial se já tivermos GPS (correção de "Sé")
                      if (_currentPos.latitude != -23.5505) {
                         controller.animateCamera(CameraUpdate.newLatLng(_currentPos));
                      }
                      debugPrint('[UI_TRACE] Escala do pino central reduzida para melhor precisão (Radius 7).');
                    },
                    myLocationEnabled: true,
                    myLocationButtonEnabled: false, // 2. Botão nativo DESATIVADO para usar customizado
                    zoomControlsEnabled: false,
                    mapType: _currentMapType,
                    style: _currentMapType == MapType.normal ? _darkMapStyle : null, // Dark style only for normal
                    markers: _markers, // Exibe os alertas persistidos
                  ),
                  
                // BARRA DE PESQUISA (TOPO)
                Positioned(
                  top: MediaQuery.of(context).padding.top + 10,
                  left: 60, // Space for Back Button
                  right: 70, // Space for Alert FAB
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
                    ),
                    child: TextField(
                      textInputAction: TextInputAction.search,
                      decoration: InputDecoration(
                        hintText: l10n.pet_journal_searching_address,
                        border: InputBorder.none,
                        prefixIcon: Icon(Icons.search, color: Colors.grey),
                        contentPadding: EdgeInsets.symmetric(vertical: 8),
                      ),
                      style: const TextStyle(color: Colors.black),
                      onSubmitted: (value) async {
                         if (value.trim().isNotEmpty) {
                           try {
                             List<Location> locations = await locationFromAddress(value);
                             if (locations.isNotEmpty) {
                               final loc = locations.first;
                               final newPos = LatLng(loc.latitude, loc.longitude);
                               _mapController?.animateCamera(CameraUpdate.newLatLngZoom(newPos, 16));
                               setState(() => _currentPos = newPos);
                               
                               // Force Address Update
                               final addr = await _getAddressFromLatLng(newPos);
                               if (mounted && addr != null) {
                                 setState(() => _currentAddress = addr);
                               }
                             }
                           } catch (e) {
                             debugPrint("Search error: $e");
                             ScaffoldMessenger.of(context).showSnackBar(
                               SnackBar(content: Text(l10n.pet_journal_address_not_found), backgroundColor: Colors.red),
                             );
                           }
                         }
                      },
                    ),
                  ),
                ),
                  
                // PINO CENTRAL (FIXO)
                if (!_isGpsLoading)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 20), // Reduced bottom padding for alignment
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(2), // Reduced padding further (3->2)
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(color: Colors.black26, blurRadius: 5, offset: Offset(0, 2)) // Tighter shadow
                              ]
                            ),
                            child: const CircleAvatar(
                              radius: 7, // Master Prompt: 40% smaller (was 11)
                              backgroundColor: Colors.orange,
                              child: Icon(Icons.pets, color: Colors.white, size: 8), // Smaller icon
                            ),
                          ),
                          Container(
                            width: 2, // Minute point
                            height: 2, 
                            decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle)
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // 2. BOTÃO VOLTAR
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 16,
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
            ),),

          // WAZE ALERT FAB (Topo Direito)
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            right: 16,
            child: FloatingActionButton.small(
              heroTag: PetConstants.heroQuickAlertFab,
              elevation: 0, // Flat
              backgroundColor: Colors.white.withOpacity(0.15), // Translucent
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.white.withOpacity(0.3), width: 1)
              ),
              onPressed: () {
                HapticFeedback.heavyImpact();
                _showDangerDialog(context);
              },
              child: const Icon(Icons.report_problem, color: Colors.black), // Black Icon
            ),
          ),

          // MAP CONTROLS COLUMN (Right Side)
          if (!_isJournalMinimized)
            Positioned(
              top: MediaQuery.of(context).padding.top + 70, // Below Alert FAB
              right: 16,
              child: Column(
                children: [
                   // LAYERS BUTTON
                   FloatingActionButton.small(
                    heroTag: PetConstants.heroLayersFab,
                    elevation: 0,
                    backgroundColor: Colors.white.withOpacity(0.15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.white.withOpacity(0.3), width: 1)
                    ),
                    onPressed: () {
                       HapticFeedback.mediumImpact();
                       _showMapLayersMenu(context);
                    },
                    child: const Icon(Icons.layers, color: Colors.black),
                  ),

                ],
              ),
            ),

          // MY LOCATION BUTTON (BOTTOM RIGHT)
          if (!_isJournalMinimized)
             Positioned(
               bottom: MediaQuery.of(context).size.height * 0.55 + 20, // Above expanded journal
               right: 16,
               child: FloatingActionButton.small(
                 heroTag: 'gps_fab',
                 elevation: 0,
                 backgroundColor: Colors.black.withOpacity(0.3), // Transparent Black
                 shape: RoundedRectangleBorder(
                   borderRadius: BorderRadius.circular(12),
                   side: BorderSide(color: Colors.white.withOpacity(0.1), width: 1)
                 ),
                 onPressed: () {
                   HapticFeedback.selectionClick();
                   if (_mapController != null) {
                      _mapController!.animateCamera(CameraUpdate.newLatLng(_currentPos));
                   }
                 },
                 child: const Icon(Icons.my_location, color: Colors.white), // White icon on black
               ),
             ),

          // 3. CARD DO DIÁRIO INTERATIVO (EXPANSÍVEL)
          Align(
            alignment: Alignment.bottomCenter,
            child: GestureDetector(
              onTap: _isJournalMinimized ? () {
                HapticFeedback.mediumImpact();
                setState(() => _isJournalMinimized = false);
              } : null, // Só expande ao clicar se estiver minimizado
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                curve: Curves.fastOutSlowIn,
                margin: _isJournalMinimized 
                    ? const EdgeInsets.only(bottom: 30) 
                    : EdgeInsets.zero,
                width: _isJournalMinimized 
                    ? 140 
                    : MediaQuery.of(context).size.width,
                height: _isJournalMinimized 
                    ? 56 
                    : MediaQuery.of(context).size.height * 0.55,
                decoration: BoxDecoration(
                  color: _isJournalMinimized 
                      ? const Color(0xFF1C1C1E) 
                      : const Color(0xFF1C1C1E),
                  borderRadius: _isJournalMinimized 
                      ? BorderRadius.circular(30) 
                      : const BorderRadius.vertical(top: Radius.circular(32)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5), 
                      blurRadius: _isJournalMinimized ? 10 : 20,
                      offset: _isJournalMinimized ? const Offset(0, 4) : Offset.zero
                    )
                  ],
                ),
                padding: _isJournalMinimized 
                    ? const EdgeInsets.symmetric(horizontal: 16) 
                    : const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: _isJournalMinimized 
                  ? // MODO PÍLULA (MINIMIZADO)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.edit_note, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          l10n.pet_journal_report_action,  
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
                        ),
                      ],
                    )
                  : // MODO EXPANDIDO (NORMAL)
                    SingleChildScrollView(
                      physics: const BouncingScrollPhysics(), // Melhor experiência de scroll
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                            
                          // Pergunta + Botão Minimizar
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Wrap(
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  spacing: 8,
                                  runSpacing: 4,
                                  children: [
                                    Text(
                                      l10n.pet_journal_question,
                                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        HapticFeedback.mediumImpact();
                                        _showHelpDialog(context);
                                      },
                                      child: Icon(Icons.info_outline, size: 20, color: Colors.grey[400]),
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          "Amigo",
                                          style: TextStyle(
                                            color: _isFriendPresent ? Colors.greenAccent : Colors.grey[500],
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Transform.scale(
                                          scale: 0.8,
                                          child: Switch(
                                            value: _isFriendPresent,
                                            activeThumbColor: Colors.greenAccent,
                                            inactiveTrackColor: Colors.grey[800],
                                            onChanged: (val) {
                                              HapticFeedback.lightImpact();
                                              setState(() => _isFriendPresent = val);
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
                                onPressed: () {
                                  HapticFeedback.mediumImpact();
                                  FocusScope.of(context).unfocus(); // Esconde teclado ao minimizar
                                  setState(() => _isJournalMinimized = true);
                                },
                              ),
                            ],
                          ),
                          
                          // Optional: Friend Details Fields (Neobrutalism Style)
                          if (_isFriendPresent) ...[
                            const SizedBox(height: 16),
                            Container(
                               decoration: BoxDecoration(
                                 color: Colors.white,
                                 border: Border.all(color: Colors.black, width: 3),
                                 borderRadius: BorderRadius.circular(12),
                               ),
                               child: Padding(
                                 padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                 child: Column(
                                   children: [
                                     DropdownButtonFormField<Map<String, String>>(
                                         decoration: InputDecoration(
                                            border: InputBorder.none,
                                            icon: const Icon(Icons.people, color: Colors.black),
                                         ),
                                         hint: Text(l10n.pet_friend_select, style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.bold, shadows: [])),
                                         initialValue: _selectedFriend,
                                         dropdownColor: Colors.white,
                                         items: [
                                           // Option: New Friend
                                           DropdownMenuItem(
                                                value: const {'friend': 'novo', 'tutor': 'novo'},
                                                child: Text("+ ${l10n.pet_friend_new}", style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 16, shadows: [])),
                                           ),
                                           ..._knownFriends.map((f) => DropdownMenuItem(
                                               value: f,
                                               child: Text("${f['friend']} (${f['tutor']})", style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, shadows: [])),
                                           ))
                                         ],
                                         onChanged: (val) {
                                            setState(() {
                                               _selectedFriend = val;
                                            });
                                         },
                                     ),
                                     if (_selectedFriend == null || _selectedFriend!['friend'] == 'novo') ...[
                                        const Divider(color: Colors.black, thickness: 2, height: 16),
                                        TextField(
                                          controller: _friendNameController,
                                          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                                          decoration: InputDecoration(
                                              border: InputBorder.none,
                                              hintText: AppLocalizations.of(context)!.pet_friend_name_label,
                                              hintStyle: const TextStyle(color: Colors.black54, fontWeight: FontWeight.normal),
                                              icon: const Icon(Icons.pets, color: Colors.black),
                                          ),
                                        ),
                                        const Divider(color: Colors.black, thickness: 1, height: 16),
                                        TextField(
                                          controller: _tutorNameController,
                                          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                                          decoration: InputDecoration(
                                              border: InputBorder.none,
                                              hintText: AppLocalizations.of(context)!.pet_tutor_name_label,
                                              hintStyle: const TextStyle(color: Colors.black54, fontWeight: FontWeight.normal),
                                              icon: const Icon(Icons.person, color: Colors.black),
                                          ),
                                        ),
                                     ]
                                   ],
                                 ),
                               ),
                            ),
                          ],
                          
                          const SizedBox(height: 16),

                          // Data e Hora
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: "${DateFormat('dd/MM').format(_selectedDate)} • ${_selectedTime.format(context)}",
                                  style: TextStyle(color: Colors.grey[400], fontSize: 14),
                                ),
                                if (_currentAddress != null)
                                  TextSpan(
                                    text: " • 📍 $_currentAddress",
                                    style: const TextStyle(color: Colors.orangeAccent, fontSize: 14),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          // CAMPO DE TEXTO COM MIC INTEGRADO
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF2C2C2E), // Dark Input
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.all(12),
                            child: Stack(
                              alignment: Alignment.bottomRight,
                              children: [
                                TextField(
                                  controller: _notesController,
                                  maxLines: 4,
                                  style: const TextStyle(color: Colors.white),
                                  cursorColor: Colors.orange,
                                  decoration: InputDecoration(
                                    hintText: l10n.pet_journal_hint_text,
                                    hintStyle: TextStyle(color: Colors.grey[600]),
                                    border: InputBorder.none,
                                  ),
                                ),
                                FloatingActionButton.small(
                                  elevation: 0,
                                  backgroundColor: _isListening ? Colors.red : Colors.orange,
                                  onPressed: _onMicPressed,
                                  child: Icon(_isListening ? Icons.stop : Icons.mic, color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // SENSORES (ATALHOS)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                              _sensorButton(Icons.camera_alt_outlined, l10n.label_photo, () {
                                  _pickImage(ImageSource.camera);
                                  HapticFeedback.selectionClick();
                                }, iconColor: _isCameraActive ? Colors.orange : Colors.black), 
                                
                                _sensorButton(Icons.photo_library_outlined, l10n.label_gallery, () {
                                  _pickGalleryMedia();
                                  HapticFeedback.selectionClick();
                                }, iconColor: _isGalleryActive ? Colors.orange : Colors.black), 

                                _sensorButton(Icons.videocam_outlined, l10n.label_video ?? "Video", () {
                                  _pickVideo();
                                  HapticFeedback.selectionClick();
                                }, iconColor: _isVideoActive ? Colors.orange : Colors.black), 

                                _sensorButton(
                                  Icons.campaign, 
                                  l10n.label_sounds, 
                                  () {
                                   _toggleAudioRecording();
                                   HapticFeedback.selectionClick();
                                  },
                                  iconColor: _isAudioActive ? Colors.deepOrange : Colors.black, 
                                ),
                                
                                _sensorButton(Icons.file_upload_outlined, l10n.label_vocal, () {
                                   _pickAudioFile();
                                   HapticFeedback.selectionClick();
                                }, iconColor: _selectedAudioFile != null ? Colors.orange : Colors.black), // Black by default
                              ],
                            ),

                          const SizedBox(height: 32),

                          // BOTÃO REGISTRAR
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black,
                                disabledBackgroundColor: const Color(0xFF2C2C2E),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                elevation: 0,
                              ),
                              onPressed: _hasContent ? _saveEvent : null,
                              child: _isSaving 
                                ? const CircularProgressIndicator(color: Colors.black)
                                : Text(
                                    l10n.pet_journal_register_button,
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                            ),
                          ),
                          SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 120), // Responsive bottom padding based on keyboard
                        ],
                      ),
                    ),
              ),
            ),
          ),
        ],
      ),
    );
    
    // UI Trace (Outside of widget tree building strictly, but fine here for this request context)
    // Ideally in initState but user requested log insertion.
    debugPrint('[UI_TRACE] Controles do mapa reposicionados e transparência aplicada.');
    debugPrint('[UI_TRACE] Escala do pino central reduzida para melhor precisão.');
    
    return scaffold;
  }

  void _showHelpDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1C1C1E),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                   // Handle Bar
                  Container(
                    width: 40, height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(color: Colors.grey[700], borderRadius: BorderRadius.circular(2)),
                  ),
                  Text(
                    l10n.help_guide_title,
                    style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      physics: const BouncingScrollPhysics(),
                      children: [
                        _helpItem(Icons.camera_alt, Colors.green, l10n.pet_journal_help_photo_title, l10n.pet_journal_help_photo_desc),
                        _helpItem(Icons.graphic_eq, Colors.orange, l10n.pet_journal_help_audio_title, l10n.pet_journal_help_audio_desc),
                        _helpItem(Icons.map, Colors.blue, l10n.pet_journal_help_map_title, l10n.pet_journal_help_map_desc),
                        _helpItem(Icons.notes, Colors.teal, l10n.pet_journal_help_notes_title, l10n.pet_journal_help_notes_desc),
                        _helpItem(Icons.videocam, Colors.redAccent, l10n.pet_journal_help_videos_title, l10n.pet_journal_help_videos_desc),
                        _helpItem(Icons.auto_awesome, Colors.purpleAccent, l10n.pet_journal_help_ai_title, l10n.pet_journal_help_ai_desc),
                        _helpItem(Icons.group, Colors.pinkAccent, l10n.pet_journal_help_friends_title, l10n.pet_journal_help_friends_desc),
                        _helpItem(Icons.psychology, Colors.deepPurple, l10n.pet_journal_help_specialized_ai_title, l10n.pet_journal_help_specialized_ai_desc),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: Text(l10n.btn_got_it, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                ],
              ),
            );
          }
        );
      },
    );
  }

  Widget _helpItem(IconData icon, Color color, String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.2),
            radius: 24,
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(desc, style: TextStyle(color: Colors.grey[400], fontSize: 14, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget auxiliar para os botões de sensor
  Widget _sensorButton(IconData icon, String label, VoidCallback onTap, {Color? iconColor}) {
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: 1.0, // Always visible/enabled
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.1),
                border: Border.all(color: Colors.white),
              ),
              child: Icon(icon, color: iconColor ?? Colors.white),
            ),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.white)),
          ],
        ),
      ),
    );
  }


  // Carrega alertas persistidos no raio de 5km
  Future<void> _loadMapAlerts() async {
    try {
      final alerts = await MapAlertRepository().getAlertsNear(
        _currentPos.latitude, 
        _currentPos.longitude
      );
      
      final newMarkers = <Marker>{};

      for (var alert in alerts) {
        // Define ícone e cores baseados na categoria
        IconData iconData = Icons.warning;
        Color color = Colors.white;
        Color bgColor = Colors.red;

        switch (alert.category) {
          case PetMapConstants.alertPoison:
            iconData = Icons.warning;
            color = Colors.black;
            bgColor = Colors.red;
            break;
          case PetMapConstants.alertDogLoose:
            iconData = Icons.pets;
            color = Colors.white;
            bgColor = Colors.orange;
            break;
          case PetMapConstants.alertRiskArea:
            iconData = Icons.dangerous;
            color = Colors.white;
            bgColor = Colors.redAccent;
            break;
          case PetMapConstants.alertNoise:
            iconData = Icons.volume_up;
            color = Colors.black;
            bgColor = Colors.amber;
            break;
        }

        final icon = await _createMarkerBitmap(iconData, color, bgColor, 32);

        newMarkers.add(
          Marker(
            markerId: MarkerId(alert.id),
            position: LatLng(alert.latitude, alert.longitude),
            infoWindow: InfoWindow(title: alert.category, snippet: alert.description),
            icon: icon,
            anchor: const Offset(0.5, 0.5), // Center icon on location
          ),
        );
      }

      if (mounted) {
        setState(() {
          _markers = newMarkers;
        });
      }
    } catch (e) {
      debugPrint("${PetMapConstants.logErrorMapLoad}$e");
    }
  }

  Future<BitmapDescriptor> _createMarkerBitmap(
      IconData iconData, Color color, Color backgroundColor, double size) async {
    
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final double radius = size / 2;

    // 1. Desenha o Círculo de Fundo
    final Paint circlePaint = Paint()..color = backgroundColor;
    canvas.drawCircle(Offset(radius, radius), radius, circlePaint);

    // 2. Desenha um contorno branco para contraste (opcional, estilo Waze)
    final Paint borderPaint = Paint()
      ..color = Colors.white
      ..style = ui.PaintingStyle.stroke
      ..strokeWidth = size * 0.05; // 5% do tamanho
    canvas.drawCircle(Offset(radius, radius), radius, borderPaint);

    // 3. Configura o Ícone de Texto
    final TextPainter textPainter = TextPainter(
      textDirection: ui.TextDirection.ltr,
    );

    textPainter.text = TextSpan(
      text: String.fromCharCode(iconData.codePoint),
      style: TextStyle(
        fontSize: size * 0.6, // Ícone ocupa 60% do círculo
        fontFamily: iconData.fontFamily,
        color: color,
      ),
    );

    textPainter.layout();
    
    // 4. Centraliza o Ícone no Círculo
    textPainter.paint(
      canvas,
      Offset(
        radius - textPainter.width / 2,
        radius - textPainter.height / 2,
      ),
    );

    // 5. Converte para Imagem -> Bytes -> BitmapDescriptor
    final ui.Image image = await pictureRecorder.endRecording().toImage(
          size.toInt(),
          size.toInt(),
        );
    
    final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List? pngBytes = byteData?.buffer.asUint8List();

    if (pngBytes == null) {
      return BitmapDescriptor.defaultMarker;
    }

    return BitmapDescriptor.bytes(pngBytes);
  }

  void _showDangerDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1C1C1E),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.map_alert_title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _alertOption(ctx, Icons.pets, l10n.map_alert_dog, PetMapConstants.alertDogLoose, Colors.orange),
                  _alertOption(ctx, Icons.warning_amber, l10n.map_alert_risk, PetMapConstants.alertRiskArea, Colors.red),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _alertOption(ctx, Icons.volume_up, l10n.map_alert_noise, PetMapConstants.alertNoise, Colors.yellow),
                  _alertOption(ctx, Icons.dangerous, l10n.map_alert_poison, PetMapConstants.alertPoison, Colors.purple),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _alertOption(BuildContext ctx, IconData icon, String label, String category, Color color) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(ctx);
        _registerAlert(category);
      },
      child: Column(
        children: [
          CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.2),
            radius: 30,
            child: Icon(icon, color: color, size: 30),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }

  Future<void> _registerAlert(String category) async {
    final l10n = AppLocalizations.of(context)!;
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final alert = PetMapAlert(
      id: id,
      latitude: _currentPos.latitude,
      longitude: _currentPos.longitude,
      category: category,
      description: l10n.map_alert_description_user,
      timestamp: DateTime.now(),
    );

    await MapAlertRepository().saveAlert(alert);
    _loadMapAlerts(); // Refresh map
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.map_alert_success), 
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        )
      );
    }
  }

  Future<void> _saveEvent() async {
    final l10n = AppLocalizations.of(context)!;
    // Implicit Geolocation Logic (Strict Sync)
    // Removed strict block on default coordinate to allow saving even if GPS fails
    if (_isGpsLoading) {
       ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.pet_journal_loading_gps), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _isSaving = true);
    
    // Trace Start
    if (kDebugMode) {
      debugPrint('APP_TRACE: Iniciando salvamento. Notas: ${_notesController.text}, Lat: ${_currentPos.latitude}');
      debugPrint('APP_TRACE: Vinculando evento ao Pet ID: ${widget.petId}');
    }

    // 🚨 GEOCODING SYNC CHECK (Fix for null address)
    if (_currentAddress == null) {
      if (kDebugMode) debugPrint('APP_TRACE: Endereço é null, recuperando via coordenadas...');
      _currentAddress = await _getAddressFromLatLng(_currentPos);
    }
    
    if (kDebugMode) {
      debugPrint('APP_TRACE: Salvando agora com endereço: $_currentAddress');
    }

    try {
      final repository = PetEventRepository();
      final eventId = DateTime.now().millisecondsSinceEpoch.toString();
      
      // 🧠 SMART CLASSIFICATION LOGIC (Universal AI)
      final textLower = _notesController.text.toLowerCase();
      
      // Keywords that trigger HEALTH category (Localized + Legacy)
      // Uses l10n.pet_logic_keywords_health (comma separated) for current locale
      // AND matches against PetConstants for basic fallback if l10n fails or is empty
      final localKeywords = l10n.pet_logic_keywords_health.split(',').map((e) => e.trim().toLowerCase()).toList();
      // Combine unique keywords
      final allKeywords = {...PetConstants.healthKeywords, ...localKeywords}.toSet().toList();
      
      final isKeywordHealth = allKeywords.any((k) => k.isNotEmpty && textLower.contains(k));

      // Universal AI Trigger: 
      // 1. If Image Exists OR Keywords Match OR Audio Exists OR Video Exists -> Potentially Health
      // 2. BUT we must handle the 'Walk' case (Activity).
      //    - If it's a Walk (Activity), we ONLY trigger AI if specific keywords (like poop/vomit) are found.
      //    - Otherwise, standard walks (just distance/time) don't need AI unless user adds these keywords.
      
      bool shouldAnalyze = false;

      // Universal Mode: Analyze if keywords OR media are present, regardless of Walk/Journal mode
      shouldAnalyze = isKeywordHealth || _capturedImage != null || _selectedAudioFile != null || _capturedVideo != null;
      
      // Calculate type: If analysis is triggered, we might want to flag it as Health or keep as Activity?
      // For Walk context, we keep as Activity (so it shows in Walk history) but hasAIAnalysis=true.
      // For others, we default to Health if analyzed.
      
      final detectedType = widget.initialEventType ?? (shouldAnalyze ? PetEventType.health : PetEventType.other);
      final isHealth = shouldAnalyze; // Renaming variable for clarity in blocks below
      
      if (kDebugMode && isHealth) {
        debugPrint('APP_TRACE: 🚑 Classification: AI Analysis Triggered (Keyword: $isKeywordHealth, Media: ${_capturedImage != null})');
      }

      String? aiSummary;

      // RESTORED AI LOGIC (Universal)
      if (isHealth) {
          try {
             if (kDebugMode) debugPrint('[AI_TRACE] Starting AI Analysis...');
             final lang = Localizations.localeOf(context).languageCode;
             
             if (_capturedImage != null) {
                 final api = PetAiService();
                 final result = await api.analyzePetImage(
                    _capturedImage!.path, 
                    lang, 
                    type: detectedType == PetEventType.health ? PetImageType.general : PetImageType.general,
                    petName: widget.petName,
                    petUuid: widget.petId
                 );
                 aiSummary = result.$1;
             } else if (_selectedAudioFile != null) {
                 final vocalService = PetVocalAiService();
                 aiSummary = await vocalService.analyzeBarking(
                    audioFile: File(_selectedAudioFile!),
                    languageCode: lang,
                    petName: widget.petName,
                    tutorNotes: _notesController.text
                 );
             } else if (_capturedVideo != null) {
                 final videoService = PetVideoAiService();
                 aiSummary = await videoService.analyzeVideo(
                    videoFile: File(_capturedVideo!.path),
                    petName: widget.petName,
                    notes: _notesController.text,
                    lang: lang
                 );
             }
          } catch (e) {
             debugPrint('[AI_TRACE] Analysis Failed: $e');
          }
      }

      // HELPER: Copy media from temporary cache to permanent app storage
      Future<String> secureMedia(String sourcePath) async {
         try {
            final appDir = await getApplicationDocumentsDirectory();
            final mediaDir = Directory('${appDir.path}/pet_event_media');
            if (!mediaDir.existsSync()) {
               mediaDir.createSync(recursive: true);
            }
            final ext = path.extension(sourcePath);
            final newFileName = '${eventId}_${DateTime.now().millisecondsSinceEpoch}$ext';
            final targetPath = '${mediaDir.path}/$newFileName';
            await File(sourcePath).copy(targetPath);
            return targetPath;
         } catch (e) {
            debugPrint('[MEDIA_TRACE] Failed to secure media file: $e');
            return sourcePath; // Fallback to original
         }
      }

      String? finalImagePath;
      String? finalVideoPath;
      String? finalAudioPath;

      if (_capturedImage != null) {
          finalImagePath = await secureMedia(_capturedImage!.path);
      }
      if (_capturedVideo != null) {
          finalVideoPath = await secureMedia(_capturedVideo!.path);
      }
      if (_selectedAudioFile != null) {
          finalAudioPath = await secureMedia(_selectedAudioFile!);
      }

       // FLUXO NORMAL (PET PRINCIPAL)
      PetEvent newEventToSave = PetEvent(
        id: eventId,
        startDateTime: DateTime.now(), 
        petIds: [widget.petId], 
        eventTypeIndex: detectedType.index, // Respect detected/initial type
        hasAIAnalysis: isHealth, // Use the computed flag logic 
        notes: _notesController.text, 
        address: _currentAddress, 
        metrics: {
          PetConstants.keyLatitude: _currentPos.latitude,
          PetConstants.keyLongitude: _currentPos.longitude,
          PetConstants.keyAddress: _currentAddress, 
          if (finalAudioPath != null) PetConstants.keyAudioPath: finalAudioPath, 
          if (finalVideoPath != null) PetConstants.keyVideoPath: finalVideoPath, 
          if (aiSummary != null) PetConstants.keyAiSummary: aiSummary,
          'source': widget.initialEventType == PetEventType.activity ? 'walk_journal' : 'journal', // Tag source for filtering
        },
        mediaPaths: finalImagePath != null ? [finalImagePath] : null,
      );

      // Inject the 'Friend' keyword automatically if the switch is ON.
      if (_isFriendPresent) {
        String friendName = "?";
        String tutorName = "?";

        if (_selectedFriend != null && _selectedFriend!['friend'] != 'novo') {
            friendName = _selectedFriend!['friend']!;
            tutorName = _selectedFriend!['tutor']!;
        } else {
            friendName = _friendNameController.text.trim().isNotEmpty ? _friendNameController.text.trim() : "?";
            tutorName = _tutorNameController.text.trim().isNotEmpty ? _tutorNameController.text.trim() : "?";
        }
        
        final l10n = AppLocalizations.of(context)!;
        newEventToSave = newEventToSave.copyWith(
          notes: "${newEventToSave.notes ?? ''} [${l10n.pet_friend_prefix}: $friendName | ${l10n.pet_label_tutor}: $tutorName]",
        );
      }

      await _finalizeSave(newEventToSave, context, isFriend: _isFriendPresent);

    } catch (e) {
       // ... existing error handling ...
       if (mounted) {
         setState(() => _isSaving = false);
         ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.pet_error_saving_event(e.toString())), backgroundColor: Colors.red),
         );
       }
       debugPrint('[APP_TRACE] CreatePetEventScreen: Erro ao salvar: $e');
    } 
  }

  Future<void> _finalizeSave(PetEvent event, BuildContext context, {required bool isFriend}) async {
      final result = await _repository.saveEvent(event);

      if (result.isSuccess) {
        if (kDebugMode) debugPrint('APP_TRACE: Sucesso ao gravar no banco/API');
        
        if (mounted) {
            // REFRESH: Immediate Update (Master Prompt 3)
            debugPrint('[UI_TRACE] Disparando refresh da agenda após salvamento.');
            if (widget.onEventSaved != null) {
               widget.onEventSaved!(); 
            }

            // Reset UI state before pop so transition is clean
            setState(() {
              _isFriendPresent = false;
              _selectedFriend = null;
              _friendNameController.clear();
              _tutorNameController.clear();
              _notesController.clear();
              _capturedImage = null;
              _capturedVideo = null;
              _selectedAudioFile = null;
            });

            Navigator.pop(context); // Close Screen immediately
            
            // Show Feedback via SnackBar on Parent Screen instead of blocking Dialog
            // This makes it feel faster "Instant Refresh"
             ScaffoldMessenger.of(context).showSnackBar(
               SnackBar(
                 content: Row(children: [
                    Icon(isFriend ? Icons.people : Icons.check, color: Colors.white),
                    const SizedBox(width: 10),
                    Text(isFriend ? "Evento de Amigo Salvo na Agenda!" : "Evento Salvo!"),
                 ]),
                 backgroundColor: isFriend ? Colors.purple : Colors.green,
                 duration: const Duration(seconds: 3),
               )
             );
        }
      } else {
        throw Exception(AppLocalizations.of(context)!.pet_error_repository_failure(result.status.toString()));
      }
  }

  void _showMapLayersMenu(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    
    // Simpler Approach: Show standard PopupMenu logic as a BottomSheet for better UX
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1C1C1E),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.label_map_type,
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _mapTypeOption(ctx, MapType.normal, l10n.map_type_normal, Icons.map),
              _mapTypeOption(ctx, MapType.satellite, l10n.map_type_satellite, Icons.satellite),
              _mapTypeOption(ctx, MapType.hybrid, l10n.map_type_hybrid, Icons.layers),
              _mapTypeOption(ctx, MapType.terrain, l10n.map_type_terrain, Icons.terrain),
            ],
          ),
        );
      },
    );
  }

  Widget _mapTypeOption(BuildContext context, MapType type, String label, IconData icon) {
    final isSelected = _currentMapType == type;
    return ListTile(
      leading: Icon(icon, color: isSelected ? Colors.orange : Colors.grey),
      title: Text(label, style: TextStyle(color: isSelected ? Colors.orange : Colors.white)),
      trailing: isSelected ? const Icon(Icons.check, color: Colors.orange) : null,
      onTap: () {
        setState(() {
          _currentMapType = type;
        });
        _saveMapTypePreference(type);
        Navigator.pop(context);
      },
    );
  }

  // --- AUDIO AI IMPLEMENTATION DELEGATED TO PetVocalAiService ---
  // Local methods _analyzeAudio and _fetchActiveModel removed to favor the dedicated service.
}