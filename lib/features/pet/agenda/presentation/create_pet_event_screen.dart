import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:scannutplus/core/theme/app_colors.dart'; // REQUIRED FOR BLUE THEME
import 'dart:ui' as ui;
import 'dart:io';
import 'dart:async';
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
import 'package:scannutplus/features/pet/agenda/presentation/utils/pet_map_markers.dart';
import '../../data/pet_constants.dart'; // Restored for PetPrompts/Logs
import 'package:scannutplus/features/pet/agenda/presentation/pet_map_styles.dart';

import '../../services/pet_ai_service.dart'; // Real AI Service
import 'package:scannutplus/features/pet/agenda/services/pet_vocal_ai_service.dart'; // Dedicated Vocal AI Service
import 'package:scannutplus/features/pet/agenda/services/pet_video_ai_service.dart'; // Dedicated Video AI Service
import 'package:scannutplus/core/services/universal_ai_service.dart'; // New RAG Flow
import 'package:scannutplus/features/pet/agenda/domain/pet_weather_service.dart'; // Telemetry Background
// Env Access
// Prompts
// App Keys

import 'package:scannutplus/l10n/app_localizations.dart';
import 'package:scannutplus/pet/agenda/pet_event.dart';
import 'package:scannutplus/pet/agenda/pet_event_repository.dart';
import 'package:scannutplus/features/pet/data/models/pet_event_type.dart';
import 'package:scannutplus/features/pet/presentation/widgets/pet_ai_cards_renderer.dart';
// Micro App Import
import 'package:scannutplus/features/pet/data/repositories/pending_analysis_repository.dart';
import 'package:scannutplus/features/pet/agenda/data/models/pending_analysis.dart';
import 'package:uuid/uuid.dart'; // REQUIRED for Uuid().v4()
import 'package:gal/gal.dart'; // Added for saving camera captures to gallery

enum PetMediaSource { camera, gallery, none }

class CreatePetEventScreen extends StatefulWidget {
  final String petName;
  final String petId;
  final VoidCallback? onEventSaved;
  final PetEventType? initialEventType;
  final bool isFriendFlow;
  final Map<String, String>? initialFriendData;
  final VoidCallback? onSummaryStarted;

  const CreatePetEventScreen({
    super.key,
    required this.petId,
    required this.petName,
    this.initialEventType = PetEventType.food,
    this.isFriendFlow = false, // Default is false for retrocompatibility
    this.initialFriendData,
    this.onEventSaved,
    this.onSummaryStarted,
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
  
  // Background Processing State
  bool _isBackgroundProcessing = false;
  PetEvent? _readyBackgroundEvent;
  
  // Legacy Fields restored for compatibility
  PetMediaSource _mediaSource = PetMediaSource.none;
  final PetEventRepository _repository = PetEventRepository();
  final PendingAnalysisRepository _pendingRepository = PendingAnalysisRepository();
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

  BitmapDescriptor? _petMarkerIcon;

  // --- REAL-TIME WALK TRACKING ---
  StreamSubscription<Position>? _positionStream;
  StreamSubscription<Position>? _idlePositionStream; // Watch for unrecorded movement
  Timer? _walkTimer;
  int _walkDurationSeconds = 0;
  double _walkDistanceKm = 0.0;
  Position? _lastRecordedPosition;
  bool _isTracking = false; // Modificação: Controle Manual de Play/Stop
  bool _hasWarnedAboutTracking = false;

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
    _isFriendPresent = widget.isFriendFlow; // Auto-set based on route
    _notesController = TextEditingController();
    _friendNameController = TextEditingController();
    _tutorNameController = TextEditingController();
    _currentMapType = MapType.hybrid; // Mudado para satélite por padrão
    _initPetMarker();
    _initGPS();
    _loadKnownFriends();

    _checkPendingAnalyses();

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
    // Agora configurado dinamicamente via initState (hybrid)
  }

  Future<void> _saveMapTypePreference(MapType type) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(PetConstants.keyMapTypeIndex, type.index);
  }

  @override
  void dispose() {
    _walkTimer?.cancel();
    _positionStream?.cancel();
    _idlePositionStream?.cancel();
    // DO NOT invoke _mapController?.dispose() manually here. 
    // The google_maps_flutter plugin handles its own platform view lifecycle on Android.
    // Manually disposing it can cause the SurfaceProducer to corrupt and disappear on subsequent screen pushes.
    _speech.cancel(); // Stop any active listening
    _notesController.dispose();
    
    // START BACKGROUND AUTO-WALK SUMMARY
    if (_walkDurationSeconds > 0) {
      debugPrint("[SCAN_NUT_TRACE] Delegating Walk Summary to Background Task...");
      widget.onSummaryStarted?.call();
      final callback = widget.onEventSaved;
      _generateWalkSummaryInBackground(callback);
    }
    
    super.dispose();
  }

  // --- BACKGROUND RECOVERY ENGINE ---
  Future<void> _checkPendingAnalyses() async {
     try {
         final pendingList = await _pendingRepository.getAllPendingAnalyses();
         if (pendingList.isNotEmpty) {
             debugPrint('[BACKGROUND_AI_TRACE] 🚨 FOUND ${pendingList.length} PENDING ANALYSES! RECOVERY INITIATED.');
             for (var entry in pendingList) {
                // Determine Map to string dynamically to ensure no type crash on older data
                final Map<String, dynamic> m = Map<String, dynamic>.from(entry.metrics);
                // Retrigger the async task, but passing the specific parameters
                _runBackgroundAnalysis(
                  eventId: entry.eventId,
                  detectedType: entry.eventType,
                  finalImagePath: entry.imagePath,
                  finalAudioPath: entry.audioPath,
                  finalVideoPath: entry.videoPath,
                  notes: entry.notes,
                  metrics: m,
                  isFriend: entry.isFriendUrl,
                );
             }
             if (mounted) {
               ScaffoldMessenger.of(context).showSnackBar(
                 SnackBar(
                   content: Text(AppLocalizations.of(context)!.pet_journal_bg_resuming(pendingList.length)), 
                   backgroundColor: Colors.orange,
                 )
               );
             }
         }
     } catch(e) {
         debugPrint('[BACKGROUND_AI_TRACE] 🚨 Error fetching pending analyses from Hive: $e');
     }
  }


  // --- LÓGICA DE SENSORES ---

  Future<void> _initPetMarker() async {
    _petMarkerIcon = await PetMapMarkers.getMarkerIcon(
      Icons.pets,
      Colors.white,
      Colors.deepOrangeAccent, // Mudado para Laranja Intenso para maior contraste
      24, // Tamanho reduzido 50% conforme solicitado (de 48 para 24)
    );
    if (mounted) {
       _updatePetMarker(_currentPos); // Garante que o mapa redesenha caso GPS já tenha carregado
    }
  }

  void _updatePetMarker(LatLng pos) {
    if (_petMarkerIcon == null) return;
    setState(() {
      _markers.removeWhere((m) => m.markerId.value == 'pet_location');
      _markers.add(
        Marker(
          markerId: const MarkerId('pet_location'),
          position: pos,
          icon: _petMarkerIcon!,
          anchor: const Offset(0.5, 0.5),
        ),
      );
    });
  }

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
        _updatePetMarker(_currentPos);
        _mapController?.animateCamera(CameraUpdate.newLatLngZoom(_currentPos, 19)); // Zoom mais perto (19)
        
        // Start Reverse Geocoding
        if (position != null) {
           _lastRecordedPosition = position; // Sync for real time tracking
           _startIdleTracking();
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

  void _startWalkTracking() {
    _walkTimer?.cancel(); // Safety kill
    setState(() {
      _isTracking = true;
    });

    _walkTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _walkDurationSeconds++;
        });
      }
    });

    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5,
    );
    
    _positionStream = Geolocator.getPositionStream(locationSettings: locationSettings).listen((Position position) {
      if (_lastRecordedPosition != null) {
        final distanceInMeters = Geolocator.distanceBetween(
          _lastRecordedPosition!.latitude,
          _lastRecordedPosition!.longitude,
          position.latitude,
          position.longitude,
        );
        if (mounted) {
          setState(() {
            _walkDistanceKm += distanceInMeters / 1000.0;
            _lastRecordedPosition = position;
            _currentPos = LatLng(position.latitude, position.longitude);
          });
          _updatePetMarker(_currentPos);
          // Centraliza a câmera no pet durante o passeio com zoom maior!
          _mapController?.animateCamera(CameraUpdate.newLatLngZoom(_currentPos, 19));
        }
      } else {
        _lastRecordedPosition = position;
      }
    });
  }

  void _startIdleTracking() {
    // Watches the user when they haven't explicitly pressed Play
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 15, // Only trigger if they walked 15 meters
    );

    _idlePositionStream = Geolocator.getPositionStream(locationSettings: locationSettings).listen((Position position) {
      if (_isTracking || _hasWarnedAboutTracking) return;
      
      if (_lastRecordedPosition != null) {
        final distanceInMeters = Geolocator.distanceBetween(
          _lastRecordedPosition!.latitude,
          _lastRecordedPosition!.longitude,
          position.latitude,
          position.longitude,
        );

        // Se andou mais de 30 metros totais sem iniciar
        if (distanceInMeters > 30.0) {
          _hasWarnedAboutTracking = true;
          if (mounted) {
             ScaffoldMessenger.of(context).showSnackBar(
               SnackBar(
                 content: Row(
                   children: const [
                     Icon(Icons.directions_walk, color: Colors.white),
                     SizedBox(width: 8),
                     Expanded(child: Text("Você está se movendo! Esqueceu de apertar o Play? ▶️")),
                   ],
                 ),
                 backgroundColor: Colors.orange,
                 duration: const Duration(seconds: 4),
                 action: SnackBarAction(
                   label: 'INICIAR',
                   textColor: Colors.white,
                   onPressed: () {
                     _startWalkTracking();
                   },
                 ),
               ),
             );
          }
        }
      }
    });
  }

  void _stopWalkTracking() {
    setState(() {
      _isTracking = false;
    });
    _walkTimer?.cancel();
    _walkTimer = null;
    _positionStream?.cancel();
    _positionStream = null;
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
      Future.delayed(const Duration(milliseconds: 300), _saveEvent);
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
          Future.delayed(const Duration(milliseconds: 300), _saveEvent);
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
                 Future.delayed(const Duration(milliseconds: 300), _saveEvent);
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
             Future.delayed(const Duration(milliseconds: 300), _saveEvent);
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
        allowedExtensions: [...PetConstants.audioExtensions, ...PetConstants.videoExtensions],
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
               _capturedImage = null; // Mutex
               _selectedAudioFile = null;
               _isUploading = false;
               _mediaSource = PetMediaSource.gallery;
             });
             if (mounted) {
                 ScaffoldMessenger.of(context).showSnackBar(
                   SnackBar(content: Text(AppLocalizations.of(context)!.pet_journal_video_saved ?? "Video saved!")),
                 );
                 Future.delayed(const Duration(milliseconds: 300), _saveEvent);
             }
        } else {
            setState(() {
              _selectedAudioFile = file.path;
              _capturedVideo = null; // Mutex
              _capturedImage = null;
            });
            if (mounted) {
              final l10n = AppLocalizations.of(context)!;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.pet_journal_file_selected(result.files.single.name))),
              );
              Future.delayed(const Duration(milliseconds: 300), _saveEvent);
            }
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
        Future.delayed(const Duration(milliseconds: 300), _saveEvent);
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

    // Formatar Tempo em tempo real
    final int hours = _walkDurationSeconds ~/ 3600;
    final int minutes = (_walkDurationSeconds % 3600) ~/ 60;
    final int seconds = _walkDurationSeconds % 60;
    final String timeString = hours > 0 
        ? '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}'
        : '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    // Distância formatada
    final String distString = _walkDistanceKm.toStringAsFixed(2);

    final scaffold = PopScope(
      canPop: true,
      onPopInvoked: (didPop) {
        if (_walkDurationSeconds > 0) {
           final l10n = AppLocalizations.of(context);
           final messenger = ScaffoldMessenger.maybeOf(context);
           if (l10n != null && messenger != null) {
              messenger.showSnackBar(
                SnackBar(
                  content: Text("${l10n.pet_journal_bg_evaluating} (Resumo do Passeio)"), 
                  backgroundColor: Colors.orange, 
                  duration: const Duration(seconds: 4),
                  behavior: SnackBarBehavior.floating, // Descola do rodapé para visibilidade máxima
                )
              );
           }
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
        children: [
          // 1. MAPA (WAZE STYLE)
          // 1. MAPA (WAZE STYLE)
          Positioned.fill(
            child: Stack(
              children: [
                // ALWAYS render GoogleMap to prevent SurfaceView teardown bugs on Android OpenGLES (Pilar 0)
                GoogleMap(
                  initialCameraPosition: CameraPosition(target: _currentPos, zoom: 19), // Zoom maior no início (19)
                  onMapCreated: (controller) {
                    _mapController = controller;
                    // 1. Forçar movimento inicial se já tivermos GPS (correção de "Sé")
                    if (_currentPos.latitude != -23.5505) {
                       controller.animateCamera(CameraUpdate.newLatLngZoom(_currentPos, 19)); // Força zoom maior aqui também
                    }
                    debugPrint('[UI_TRACE] Escala do pino central reduzida para melhor precisão (Radius 7).');
                  },
                  myLocationEnabled: false, // Oculta o ponto azul nativo em favor do ícone da patinha
                  myLocationButtonEnabled: false, // 2. Botão nativo DESATIVADO para usar customizado
                  zoomControlsEnabled: false,
                  mapType: _currentMapType,
                  style: _currentMapType == MapType.normal ? _darkMapStyle : null, // Dark style only for normal
                  markers: _markers, // Exibe os alertas persistidos
                ),
                
                if (_isGpsLoading)
                  const Center(child: CircularProgressIndicator(color: AppColors.petIconAction)),
                
                  
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
                        prefixIcon: Icon(Icons.search, color: AppColors.petIconAction),
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
                icon: const Icon(Icons.arrow_back, color: Colors.blue),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
            

          // WAZE ALERT FAB (Topo Direito)
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            right: 16,
            child: FloatingActionButton.small(
              heroTag: PetConstants.heroQuickAlertFab,
              elevation: 0,
              backgroundColor: Colors.white, // Fundo sólido branco intenso em vez de translúcido
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              onPressed: () {
                HapticFeedback.heavyImpact();
                _showDangerDialog(context);
              },
              child: const Icon(Icons.report_problem, color: AppColors.petIconAction), // Ícone com contraste
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
                    backgroundColor: Colors.white, // Fundo branco sólido
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    onPressed: () {
                       HapticFeedback.mediumImpact();
                       _showMapLayersMenu(context);
                    },
                    child: const Icon(Icons.layers, color: AppColors.petIconAction),
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
                 backgroundColor: Colors.white, // Fundo branco sólido para destacar na imagem satélite
                 shape: RoundedRectangleBorder(
                   borderRadius: BorderRadius.circular(12),
                 ),
                 onPressed: () {
                   HapticFeedback.selectionClick();
                   if (_mapController != null) {
                      _mapController!.animateCamera(CameraUpdate.newLatLng(_currentPos));
                   }
                 },
                 child: const Icon(Icons.my_location, color: AppColors.petIconAction), // Ícone azul com alto contraste
               ),
             ),

          // LOADING PILL FOR BACKGROUND ANALYSIS
          if (_isBackgroundProcessing)
            Positioned(
              top: MediaQuery.of(context).padding.top + 70, // Below Alert FAB
              left: 0,
              right: 0,
              child: IgnorePointer(
                child: Center(
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: _isBackgroundProcessing ? 1.0 : 0.0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.petIconAction.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4))],
                        border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          ),
                          const SizedBox(width: 12),
                          Flexible(
                            child: Text(
                              l10n.pet_journal_bg_evaluating,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
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
                        Flexible(
                          child: Text(
                            l10n.pet_journal_report_action,  
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
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
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(
                                          color: AppColors.petIconAction,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.info_outline, size: 16, color: Colors.white),
                                      ),
                                    ),
                                    Text(
                                      l10n.pet_journal_friend_label,
                                      style: TextStyle(
                                        color: _isFriendPresent ? AppColors.petIconAction : Colors.grey[500],
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Transform.scale(
                                      scale: 0.8,
                                      child: Switch(
                                        value: _isFriendPresent,
                                        trackColor: WidgetStateProperty.resolveWith((states) {
                                          if (states.contains(WidgetState.selected)) {
                                            return AppColors.petIconAction;
                                          }
                                          return Colors.transparent; // Fundo transparente quando inativo
                                        }),
                                        thumbColor: WidgetStateProperty.resolveWith((states) {
                                          if (states.contains(WidgetState.selected)) {
                                            return Colors.white;
                                          }
                                          return AppColors.petIconAction; // Bolinha azul quando inativo
                                        }),
                                        trackOutlineColor: WidgetStateProperty.resolveWith((states) {
                                           if (states.contains(WidgetState.selected)) {
                                              return Colors.transparent; // Sem borda quando ativado (fundo sólido)
                                           }
                                           return Colors.white; // Borda branca quando desativado
                                        }),
                                        onChanged: (val) {
                                          HapticFeedback.lightImpact();
                                          setState(() => _isFriendPresent = val);
                                        },
                                      ),
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
                                         icon: const Icon(Icons.arrow_drop_down, color: Colors.blue),
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

                          // Data e Hora e Tempo/KM (Tracking)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(
                                        text: "⏱ $timeString  •  🗺 $distString km\n",
                                        style: TextStyle(
                                          color: _isTracking ? Colors.greenAccent : Colors.grey, 
                                          fontSize: 16, 
                                          fontWeight: FontWeight.bold
                                        ),
                                      ),
                                      TextSpan(
                                        text: "${DateFormat('dd/MM').format(_selectedDate)} • ${_selectedTime.format(context)}",
                                        style: TextStyle(color: Colors.grey[400], fontSize: 14),
                                      ),
                                      if (_currentAddress != null)
                                        TextSpan(
                                          text: " • 📍 $_currentAddress",
                                          style: const TextStyle(color: Colors.white, fontSize: 14),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                              
                              // Botão Play/Stop Redondo
                              GestureDetector(
                                onTap: () {
                                  HapticFeedback.heavyImpact();
                                  if (_isTracking) {
                                    _stopWalkTracking();
                                  } else {
                                    _startWalkTracking();
                                  }
                                },
                                child: CircleAvatar(
                                  radius: 20,
                                  backgroundColor: _isTracking ? Colors.redAccent : AppColors.petIconAction,
                                  child: Icon(
                                    _isTracking ? Icons.stop : Icons.play_arrow,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                              ),
                            ],
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
                                  maxLines: 2,
                                  style: const TextStyle(color: Colors.white),
                                  cursorColor: AppColors.petIconAction,
                                  decoration: InputDecoration(
                                    hintText: l10n.pet_journal_hint_text,
                                    hintStyle: TextStyle(color: Colors.grey[600]),
                                    border: InputBorder.none,
                                  ),
                                ),
                                FloatingActionButton.small(
                                  elevation: 0,
                                  backgroundColor: _isListening ? Colors.red : Colors.blue,
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
                              }), 
                              
                              _sensorButton(Icons.photo_library_outlined, l10n.label_gallery, () {
                                _pickGalleryMedia();
                                HapticFeedback.selectionClick();
                              }), 
                              
                              _sensorButton(Icons.videocam_outlined, l10n.label_video ?? "Video", () {
                                _pickVideo();
                                HapticFeedback.selectionClick();
                              }), 
                              
                              _sensorButton(
                                Icons.campaign, 
                                l10n.label_sounds, 
                                () {
                                 _toggleAudioRecording();
                                 HapticFeedback.selectionClick();
                                },
                              ),
                              
                              _sensorButton(Icons.file_upload_outlined, l10n.label_vocal, () {
                                 _pickAudioFile();
                                 HapticFeedback.selectionClick();
                              }),
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
    ),
    ); // <-- Fechando o PopScope adicionado
    
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
              padding: const EdgeInsets.all(10), // Reduced slightly to avoid overflow
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.petIconAction, // Fundo azul sólido (resolve o serrilhado da borda)
              ),
              child: Icon(icon, color: Colors.white, size: 22), // Ícone branco
            ),
            const SizedBox(height: 6),
            Text(label, style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold)),
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
          // Previne que a carga de alertas asincrona destrua o pino principal do pet
          final existingPetMarkers = _markers.where((m) => m.markerId.value == 'pet_location').toList();
          _markers = newMarkers;
          _markers.addAll(existingPetMarkers);
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

      // Keywords that trigger PLANT category
      final plantKeywords = ['planta', 'plant', 'flor', 'mato', 'folha', 'árvore', 'arvore', 'grama', 'vegetação', 'vegetal'];
      final isKeywordPlant = plantKeywords.any((k) => textLower.contains(k));

      // Universal AI Trigger: 
      // 1. If Image Exists OR Keywords Match OR Audio Exists OR Video Exists -> Potentially Health
      // 2. BUT we must handle the 'Walk' case (Activity).
      //    - If it's a Walk (Activity), we ONLY trigger AI if specific keywords (like poop/vomit) are found.
      //    - Otherwise, standard walks (just distance/time) don't need AI unless user adds these keywords.
      
      bool shouldAnalyze = false;

      // Universal Mode: Analyze if keywords OR media are present, regardless of Walk/Journal mode
      shouldAnalyze = isKeywordHealth || isKeywordPlant || _capturedImage != null || _selectedAudioFile != null || _capturedVideo != null;
      
      PetEventType resolvedType = PetEventType.other;
      if (shouldAnalyze) {
          if (isKeywordPlant && _capturedImage != null) {
              resolvedType = PetEventType.plant;
          } else {
              resolvedType = PetEventType.health;
          }
      }
      
      final detectedType = widget.initialEventType ?? resolvedType;
      
      // Force override to plant if media and keyword plant are present during a walk
      final finalDetectedType = (widget.initialEventType == PetEventType.activity && isKeywordPlant && _capturedImage != null) 
          ? PetEventType.plant 
          : detectedType;

      final isHealth = shouldAnalyze;
      
      if (kDebugMode && isHealth) {
        debugPrint('APP_TRACE: 🚑 Classification: AI Triggered (KeywordHealth: $isKeywordHealth, KeywordPlant: $isKeywordPlant, Media: ${_capturedImage != null})');
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
            return sourcePath;
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

      // Build base metrics
      final baseMetrics = {
        PetConstants.keyLatitude: _currentPos.latitude,
        PetConstants.keyLongitude: _currentPos.longitude,
        PetConstants.keyAddress: _currentAddress, 
        if (finalAudioPath != null) PetConstants.keyAudioPath: finalAudioPath, 
        if (finalVideoPath != null) PetConstants.keyVideoPath: finalVideoPath, 
        if (_walkDurationSeconds > 0) 'walk_duration_seconds': _walkDurationSeconds,
        if (_walkDistanceKm > 0.0) 'walk_distance_km': _walkDistanceKm,
        'source': widget.initialEventType == PetEventType.activity ? 'walk_journal' : 'journal',
      };

      // Helper to format friend notes
      String processFriendNotes(String originalNotes, bool friendActive) {
        if (!friendActive) return originalNotes;
        String friendName = "?";
        String tutorName = "?";

        if (_selectedFriend != null && _selectedFriend!['friend'] != 'novo') {
            friendName = _selectedFriend!['friend']!;
            tutorName = _selectedFriend!['tutor']!;
        } else {
            friendName = _friendNameController.text.trim().isNotEmpty ? _friendNameController.text.trim() : "?";
            tutorName = _tutorNameController.text.trim().isNotEmpty ? _tutorNameController.text.trim() : "?";
        }
        
        return "$originalNotes [${l10n.pet_friend_prefix}: $friendName | ${l10n.pet_label_tutor}: $tutorName]";
      }

      final processedNotes = processFriendNotes(_notesController.text, _isFriendPresent);

      // NON-BLOCKING AI LOGIC
      if (isHealth) {
          // It needs AI. 
          if (widget.initialEventType == PetEventType.activity) {
            // Walk Mode: Enter Background processing and keep screen active
            setState(() {
               _isBackgroundProcessing = true;
               _readyBackgroundEvent = null;
               _isJournalMinimized = true; // Minimize form
               _isSaving = false; // Unblock UI explicitly
            });
            // Show toast indicating background evaluation
            // Removed: Temporary toast replaced by persistent animated pill UI in the Stack
            // Fire and forget
            _runBackgroundAnalysis(
               eventId: eventId,
               detectedType: finalDetectedType,
               finalImagePath: finalImagePath,
               finalAudioPath: finalAudioPath,
               finalVideoPath: finalVideoPath,
               notes: processedNotes,
               metrics: baseMetrics,
               isFriend: _isFriendPresent,
            );
            return; // We skip finalizeSave and let async handle it
          } else {
             // Agenda Mode (Not Walk): Close screen and process in background
             // Fire and forget, then pop
             _runBackgroundAnalysis(
               eventId: eventId,
               detectedType: finalDetectedType,
               finalImagePath: finalImagePath,
               finalAudioPath: finalAudioPath,
               finalVideoPath: finalVideoPath,
               notes: processedNotes,
               metrics: baseMetrics,
               isFriend: _isFriendPresent,
             );
             
             // In Agenda mode (Not Walk), we pop the screen immediately, so a toast is appropriate
             ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.pet_journal_bg_evaluating), backgroundColor: Colors.orange, duration: const Duration(seconds: 3)),
             );
             if (mounted) {
               setState(() => _isSaving = false);
               if (widget.onEventSaved != null) widget.onEventSaved!();
               Navigator.pop(context);
             }
             return;
          }
      }

      // --- NO AI NEEDED: Immediate Save --- 
      PetEvent newEventToSave = PetEvent(
        id: eventId,
        startDateTime: DateTime.now(), 
        petIds: [widget.petId], 
        eventTypeIndex: finalDetectedType.index, 
        hasAIAnalysis: false, 
        notes: processedNotes, 
        address: _currentAddress, 
        metrics: baseMetrics,
        mediaPaths: finalImagePath != null ? [finalImagePath] : null,
      );

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

  // New async method for non-blocking analysis with Hive recovery
  Future<void> _runBackgroundAnalysis({
    required String eventId,
    required PetEventType detectedType,
    String? finalImagePath,
    String? finalAudioPath,
    String? finalVideoPath,
    required String notes,
    required Map<String, dynamic> metrics,
    required bool isFriend,
  }) async {
      String? aiSummary;
      
      // 1. SAVE PENDING ANALYSIS TO HIVE (ANTI-CRASH GUARANTEE)
      if (kDebugMode) debugPrint('[BACKGROUND_AI_TRACE] 💾 Saving PendingAnalysis state to Hive before firing AI...');
      final pendingEntry = PendingAnalysis(
        eventId: eventId,
        petUuid: widget.petId,
        petName: widget.petName,
        eventType: detectedType,
        imagePath: finalImagePath,
        audioPath: finalAudioPath,
        videoPath: finalVideoPath,
        notes: notes,
        metrics: metrics,
        isFriendUrl: isFriend,
        timestamp: DateTime.now(),
      );
      
      await _pendingRepository.savePendingAnalysis(pendingEntry);

      // 2. Executa a análise de IA isoladamente e apenas alerta em caso de falha (não quebra o salvamento do evento)
      try {
          if (kDebugMode) debugPrint('[BACKGROUND_AI_TRACE] 🏁 Starting Background AI Analysis...');
          final lang = mounted ? Localizations.localeOf(context).languageCode : 'pt';
          
          if (finalImagePath != null) {
              if (kDebugMode) debugPrint('[BACKGROUND_AI_TRACE] 📸 Analyzing Image via PetAiService...');
              // Mapeamento Inteligente: Se for planta, força o contexto botânico
              PetImageType mappedType = PetImageType.general;
              if (detectedType == PetEventType.plant) {
                 mappedType = PetImageType.plantCheck;
              } else if (detectedType == PetEventType.health) {
                 mappedType = PetImageType.general;
              }

              final api = PetAiService();
              final result = await api.analyzePetImage(
                finalImagePath, 
                lang, 
                type: mappedType,
                petName: widget.petName,
                petUuid: widget.petId
              );
              aiSummary = result.$1;

              // [SMART CLASSIFICATION EXTRATOR] - PetImageType.plantCheck
              // Se a análise botânica nos devolveu os tags, formatamos como título pro usuário e limpamos do texto
              if (mappedType == PetImageType.plantCheck && aiSummary != null) {
                 final plantMatch = RegExp(r'\[TAG_PLANT_NAME\](.*?)\[\/TAG_PLANT_NAME\]', dotAll: true).firstMatch(aiSummary!);
                 final toxMatch = RegExp(r'\[TAG_TOXICITY\](.*?)\[\/TAG_TOXICITY\]', dotAll: true).firstMatch(aiSummary!);
                 
                 if (plantMatch != null && toxMatch != null) {
                     final plantName = plantMatch.group(1)?.trim() ?? '';
                     final toxicity = toxMatch.group(1)?.trim() ?? '';
                     if (plantName.isNotEmpty) {
                        metrics['custom_title'] = "🌿 $plantName ($toxicity)";
                        metrics['plant_toxicity'] = toxicity; 
                     }
                 }
                 
                 // Remove tags para o Renderer não mostrá-las puras na UI
                 aiSummary = aiSummary!.replaceAll(RegExp(r'\[TAG_PLANT_NAME\].*?\[\/TAG_PLANT_NAME\]\n?', dotAll: true), '');
                 aiSummary = aiSummary!.replaceAll(RegExp(r'\[TAG_TOXICITY\].*?\[\/TAG_TOXICITY\]\n?', dotAll: true), '');
                 aiSummary = aiSummary!.trim();
              }
          } else if (finalAudioPath != null) {
              if (kDebugMode) debugPrint('[BACKGROUND_AI_TRACE] 🎙️ Analyzing Audio via PetVocalAiService...');
              final vocalService = PetVocalAiService();
              aiSummary = await vocalService.analyzeBarking(
                audioFile: File(finalAudioPath),
                languageCode: lang,
                petName: widget.petName,
                tutorNotes: notes
              );
          } else if (finalVideoPath != null) {
              if (kDebugMode) debugPrint('[BACKGROUND_AI_TRACE] 🎥 Analyzing Video via PetVideoAiService...');
              final videoService = PetVideoAiService();
              aiSummary = await videoService.analyzeVideo(
                videoFile: File(finalVideoPath),
                petName: widget.petName,
                notes: notes,
                lang: lang
              );
          }
          if (kDebugMode) debugPrint('[BACKGROUND_AI_TRACE] ✅ AI Analysis completed. Summary length: ${aiSummary?.length ?? 0}');
      } catch (e, st) {
          debugPrint('[BACKGROUND_AI_TRACE] ❌ AI Provider Failed: $e');
          debugPrint('[BACKGROUND_AI_TRACE] Stacktrace: $st');
          
          if (mounted) {
             ScaffoldMessenger.of(context).showSnackBar(
               SnackBar(content: Text(AppLocalizations.of(context)!.pet_journal_bg_error), backgroundColor: Colors.red),
             );
          }
          // Remove pending state so it doesn't try to auto-recover this specific failed event indefinitely
          await _pendingRepository.deletePendingAnalysis(eventId);
          // Still proceed to save the basic event logic
      }

      // 3. Grava o Evento Final no Banco de Dados
      try {
          if (kDebugMode) debugPrint('[BACKGROUND_AI_TRACE] 💾 Preparing to save event into ObjectBox/Hive...');
          if (aiSummary != null) metrics[PetConstants.keyAiSummary] = aiSummary;

          PetEvent newEventToSave = PetEvent(
            id: eventId,
            startDateTime: DateTime.now(), 
            petIds: [widget.petId], 
            eventTypeIndex: detectedType.index, 
            hasAIAnalysis: aiSummary != null, 
            notes: notes, 
            address: _currentAddress, 
            metrics: metrics,
            mediaPaths: finalImagePath != null ? [finalImagePath] : null,
          );

          if (kDebugMode) debugPrint('[BACKGROUND_AI_TRACE] Event populated. Calling repository.saveEvent...');
          final result = await _repository.saveEvent(newEventToSave);
          
          if (result.isSuccess) {
             if (kDebugMode) debugPrint('[BACKGROUND_AI_TRACE] ✅ Event saved successfully! Cleaning Pending Box...');
             
             // 4. CLEANUP PENDING BOX
             await _pendingRepository.deletePendingAnalysis(eventId);

             if (mounted) {
                if (widget.onEventSaved != null) widget.onEventSaved!();
                
                if (widget.initialEventType == PetEventType.activity) {
                    setState(() {
                       _isBackgroundProcessing = false;
                    });
                    
                    if (aiSummary != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(AppLocalizations.of(context)!.pet_journal_bg_ready),
                            backgroundColor: Colors.green,
                            duration: const Duration(seconds: 4),
                          )
                        );
                        // Delay modal presentation slightly to let the map render loop settle (prevents gray tiles)
                        Future.delayed(const Duration(milliseconds: 400), () {
                            if (mounted) {
                                _showAiAnalysisBottomSheet(context, newEventToSave);
                            }
                        });
                    }
                }
             }
          } else {
             debugPrint('[BACKGROUND_AI_TRACE] ❌ Repository Save Event reported Failure: ${result.status}');
             if (mounted) {
               ScaffoldMessenger.of(context).showSnackBar(
                   SnackBar(content: Text(AppLocalizations.of(context)!.pet_journal_bg_save_fail), backgroundColor: Colors.red),
               );
             }
          }
      } catch (e, st) {
          debugPrint('[BACKGROUND_AI_TRACE] 🚨 FATAL UNHANDLED EXCEPTION IN BACKGROUND THREAD: $e');
          debugPrint('[BACKGROUND_AI_TRACE] Fatal Stacktrace: $st');
          if (mounted) {
             setState(() {
                 _isBackgroundProcessing = false;
             });
             ScaffoldMessenger.of(context).showSnackBar(
               SnackBar(content: Text(AppLocalizations.of(context)!.pet_journal_bg_fatal), backgroundColor: Colors.red),
             );
          }
      }
  }

  void _resetFormAndShowSuccessMessage(bool isFriend) {
      if (!mounted) return;
      setState(() {
          _isSaving = false;
          _isFriendPresent = widget.isFriendFlow;
          _selectedFriend = null;
          _friendNameController.clear();
          _tutorNameController.clear();
          _notesController.clear();
          _capturedImage = null;
          _capturedVideo = null;
          _selectedAudioFile = null;
          if (widget.initialEventType == PetEventType.activity) {
              _isJournalMinimized = true;
          }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(children: [
             Icon(isFriend ? Icons.people : Icons.check, color: Colors.white),
             const SizedBox(width: 10),
             Text(isFriend ? AppLocalizations.of(context)!.pet_journal_saved_friend : AppLocalizations.of(context)!.pet_journal_saved_own),
          ]),
          backgroundColor: isFriend ? Colors.purple : Colors.green,
          duration: const Duration(seconds: 3),
        )
      );
  }

  Future<void> _finalizeSave(PetEvent event, BuildContext context, {required bool isFriend}) async {
      final result = await _repository.saveEvent(event);

      if (result.isSuccess) {
        if (kDebugMode) debugPrint('APP_TRACE: Sucesso ao gravar no banco/API');
        
        if (mounted) {
            debugPrint('[UI_TRACE] Disparando refresh da agenda após salvamento (No AI).');
            if (widget.onEventSaved != null) {
               widget.onEventSaved!(); 
            }

            _resetFormAndShowSuccessMessage(isFriend);

            if (widget.initialEventType != PetEventType.activity) {
                // NORMAL MODE: Pop screen
                Navigator.pop(context); 
            }
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

  String _extractShortSummary(String markdown) {
    // Busca exata pelo bloco delimitado solicitado pelo usuário
    final regex = RegExp(r'\[START?_SUMMARY\](.*?)\[END_SUMMARY\]', dotAll: true, caseSensitive: false);
    final match = regex.firstMatch(markdown);
    
    if (match != null && match.group(1) != null && match.group(1)!.trim().isNotEmpty) {
         // Retornar exatamente o que está entre as tags, limpando asteriscos fortes de markdown se quiser manter legível
         return match.group(1)!.trim().replaceAll('**', '');
    }

    // Fallback: Busca por tags diretas de resumo alternativas caso as tags principais faltem
    final tagsToTry = [r'\[VISUAL_SUMMARY\]', r'\[VISUAL SUMMARY\]', r'\[DESCRIPTION\]', r'\[RESUMO\]', r'\[OVERALL\]'];
    for (var tag in tagsToTry) {
        // The regex now matches until [END_SUMMARY] or the start of the next card marker like [CARD_START] or [SOURCES], or end of string ($)
        final regexFallback = RegExp('$tag(.*?)(?=\\[END_SUMMARY\\]|\\[CARD_START\\]|\\[SOURCES\\]|\\[METADATA\\]|\$)', dotAll: true, caseSensitive: false);
        final matchFb = regexFallback.firstMatch(markdown);
        if (matchFb != null && matchFb.group(1) != null && matchFb.group(1)!.trim().isNotEmpty) {
             String text = matchFb.group(1)!.trim().replaceAll('**', '');
             // Limpeza extra de segurança para retirar tags soltas que por ventura o modelo injete colado
             text = text.replaceAll('[END_SUMMARY]', '').replaceAll('[VISUAL_SUMMARY]', '').replaceAll('[VISUAL SUMMARY]', '').trim();
             
             // Remove any leftover numbers from lists if the AI hallucinated them before [END_SUMMARY]
             text = text.replaceAll(RegExp(r'\n\d+\.\s*$'), '').trim();

             // Ensure we do not cut halfway through a word
             if (text.length > 800) return "${text.substring(0, 800)}...";
             return text;
        }
    }

    // Fallback final: pega o primeiro texto parágrafo visível
    final lines = markdown.split('\n');
    String summary = "";
    int lineCount = 0;
    for (var line in lines) {
      final t = line.trim();
      if (t.isEmpty || t.startsWith('[') || t.startsWith('#') || t.startsWith('TITLE:') || t.startsWith('ICON:') || t.startsWith('CONTENT:')) continue;
      summary += "$t\n";
      lineCount++;
      if (lineCount >= 20 || summary.length > 800) break;
    }
    
    if (summary.trim().isNotEmpty) {
        String cleanTxt = summary.trim().replaceAll('**', '');
        return cleanTxt.length > 800 ? "${cleanTxt.substring(0, 800)}..." : cleanTxt;
    }
    
    return "Análise concluída com sucesso! Acesse o histórico na agenda para rever o laudo veterinário oficial.";
  }

  void _showAiAnalysisBottomSheet(BuildContext context, PetEvent event) {
    if (event.metrics?[PetConstants.keyAiSummary] == null) return;
    
    final fullText = event.metrics![PetConstants.keyAiSummary] as String;
    
    if (kDebugMode) {
      debugPrint("==================== RAW AI SUMMARY ====================");
      debugPrint(fullText);
      debugPrint("========================================================\n");
    }

    String shortSummary = _extractShortSummary(fullText);

    // --- LÓGICA DE URGÊNCIA (Pilar 0) ---
    // Extract: [URGENCY] EXCELENTE [/URGENCY] or [URGENCY] ALTO
    Color urgencyColor = Colors.orange; // Default Sparkles
    IconData urgencyIcon = Icons.auto_awesome;
    
    final urgencyRegex = RegExp(r'\[URGENCY\](.*?)(?:\[\/URGENCY\]|\\n)', caseSensitive: false);
    final urgencyMatch = urgencyRegex.firstMatch(fullText);
    if (urgencyMatch != null && urgencyMatch.group(1) != null) {
         final u = urgencyMatch.group(1)!.trim().toUpperCase();
         if (u.contains('EXCELENTE') || u.contains('BAIXO') || u.contains('BOM')) {
             urgencyColor = Colors.green;
             urgencyIcon = Icons.check_circle;
         } else if (u.contains('ALERTA') || u.contains('MEDIO') || u.contains('MÉDIO') || u.contains('ATENÇÃO')) {
             urgencyColor = Colors.orangeAccent;
             urgencyIcon = Icons.warning_rounded;
         } else if (u.contains('RUIM') || u.contains('ALTO') || u.contains('URGENTE') || u.contains('CRÍTICO') || u.contains('GRAVE')) {
             urgencyColor = Colors.red;
             urgencyIcon = Icons.error;
         }
    }
    
    // Clean up urgency tag if it leaked into the short summary
    shortSummary = shortSummary.replaceAll(urgencyRegex, '').replaceAll('[URGENCY]', '').trim();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF9F9F9),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).padding.bottom + 16,
          left: 16,
          right: 16,
          top: 12
        ),
        child: Column(
           mainAxisSize: MainAxisSize.min, // Ocupa apenas o espaço necessário
           children: [
              // Handle bar
              Container(
                 margin: const EdgeInsets.only(bottom: 20),
                 width: 40,
                 height: 5,
                 decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
              ),
              Row(
                children: [
                  Icon(urgencyIcon, color: urgencyColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context)!.pet_journal_bg_ready, 
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                      overflow: TextOverflow.ellipsis,
                    )
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Resumo curto
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(ctx).size.height * 0.4, // Limita altura para 40% da tela
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200)
                ),
                child: SingleChildScrollView(
                  child: Text(
                     shortSummary,
                     style: const TextStyle(fontSize: 15, color: Colors.black87, height: 1.4),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Botão OK
              SizedBox(
                width: double.infinity,
                child: TextButton(
                   onPressed: () { 
                       Navigator.pop(ctx);
                       _resetFormAndShowSuccessMessage(_isFriendPresent);
                   },
                   style: TextButton.styleFrom(
                     backgroundColor: const Color(0xFFFFD1DC), // Domain Pink
                     padding: const EdgeInsets.symmetric(vertical: 14),
                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Colors.black, width: 2)),
                   ),
                   child: Text(AppLocalizations.of(context)!.pet_btn_ok, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              )
           ]
        )
      )
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

  // --- BACKGROUND WALK SUMMARY (AUTO) ---
  Future<void> _captureRealTelemetryHidden(AppLocalizations l10n) async {
    try {
      final position = _lastRecordedPosition ?? await Geolocator.getLastKnownPosition();
      if (position == null) return;
      
      final now = DateTime.now();
      final String? address = await _getAddressFromLatLng(LatLng(position.latitude, position.longitude));
      
      if (address != null) {
          await _repository.saveEvent(PetEvent(
            id: const Uuid().v4(),
            startDateTime: now,
            petIds: [widget.petId],
            eventTypeIndex: 5, // Other
            notes: address,
            metrics: {
              'custom_title': '📍 Ponto de Referência',
              'is_google_event': true, 
              'google_type': 'location',
              'source': 'walk',
              'address': address
            },
            hasAIAnalysis: false,
          ));
      }

      final weatherService = PetWeatherService();
      final weatherData = await weatherService.getCurrentWeather(position.latitude, position.longitude);
      
      // We only use the current weather to enrich the AI's prompt as the User requested not to produce useless UI cards anymore.
      // But just in case, we still grab it on memory or we could save a very hidden metric if needed.
    } catch (e) {
      debugPrint("[SCAN_NUT_TRACE] [TELEMETRY_ERROR] Erro ao capturar telemetria em bg: $e");
    }
  }

  Future<void> _generateWalkSummaryInBackground(VoidCallback? onEventSavedCallback) async {
     try {
        if (_walkDurationSeconds == 0) return; // Nenhuma caminhada feita

        // Grab locale for AI and internal formatting
        final sysLang = Platform.localeName.split('_')[0];
        final Locale loc = Locale(sysLang);
        final AppLocalizations? delegateStr = await AppLocalizations.delegate.load(loc);
        final l10n = delegateStr ?? await AppLocalizations.delegate.load(const Locale('en'));

        final endDateTime = DateTime.now();
        // Aproxima o inicio subtraindo a duração
        final startDateTime = endDateTime.subtract(Duration(seconds: _walkDurationSeconds));

        // Busca telemetria final (encerra a jornada com o endereco final da rota)
        await _captureRealTelemetryHidden(l10n);

        // Busca tudo gravado no banco durante esse intervalo exato de passeio
        final eventsResult = await _repository.getByPetId(widget.petId);
        if (!eventsResult.isSuccess || eventsResult.data == null) return;

        final walkEvents = eventsResult.data!.where((e) {
            return e.startDateTime.isAfter(startDateTime) && e.startDateTime.isBefore(endDateTime.add(const Duration(minutes: 5)));
        }).toList();

        if (walkEvents.isEmpty) return;

        final double totalDistanceKm = walkEvents.fold(0.0, (sum, e) => sum + ((e.metrics?['walk_distance_km'] as num?)?.toDouble() ?? 0.0));
        final int totalDurationSeconds = walkEvents.fold(0, (sum, e) => sum + ((e.metrics?['walk_duration_seconds'] as num?)?.toInt() ?? 0));
        
        final int hours = totalDurationSeconds ~/ 3600;
        final int minutes = (totalDurationSeconds % 3600) ~/ 60;
        final int seconds = totalDurationSeconds % 60;
        final String timeString = hours > 0 
            ? '${hours.toString().padLeft(2, '0')}h ${minutes.toString().padLeft(2, '0')}m'
            : '${minutes.toString().padLeft(2, '0')}m ${seconds.toString().padLeft(2, '0')}s';

        final String metricsText = totalDistanceKm > 0 || totalDurationSeconds > 0 
            ? " (🗺 ${totalDistanceKm.toStringAsFixed(2)}km • ⏱ $timeString)" 
            : "";

        final eventsText = walkEvents.map((e) {
          final time = DateFormat.Hm(l10n.localeName).format(e.startDateTime);
          final notes = e.notes ?? l10n.walk_no_notes;
          final typeStr = e.eventTypeIndex == 0 ? "Food" : 
                          e.eventTypeIndex == 3 ? "Hygiene/Stool/Urine" : 
                          e.eventTypeIndex == 4 ? "Activity" : "Other"; 
          
          final explicitTitle = e.metrics?['custom_title']?.toString() ?? typeStr;
          return "- $time [$explicitTitle]: $notes";
        }).join("\n");

        // Fetch Weather string strictly string-based without bloating DB
        String weatherStr = "";
        try {
            final position = _lastRecordedPosition;
            if (position != null) {
              final weatherData = await PetWeatherService().getCurrentWeather(position.latitude, position.longitude);
              if (weatherData != null) {
                 weatherStr = "WEATHER: Temp: ${weatherData['temp']}°C, Condition: ${weatherData['description']}";
              }
            }
        } catch(_) {}

        final prompt = "${PetPrompts.promptWalkSummary}\n\nCONTEXT: Pet Name: ${widget.petName}\nTotal Distance: ${totalDistanceKm.toStringAsFixed(2)} km\nTotal Time: $timeString\n$weatherStr\n\nEVENTS LOG:\n$eventsText";

        final summary = await UniversalAiService().analyzeText(
          systemPrompt: prompt,
          userPrompt: "Generate the Walk Summary now. Take into account the total distance and time when generating the report.",
          l10n: l10n,
        );

        final summaryTitle = l10n.pet_walk_summary_title_generated(
          DateFormat.Hm(l10n.localeName).format(startDateTime),
          DateFormat.Hm(l10n.localeName).format(endDateTime)
        ) + metricsText;
        
        final newEvent = PetEvent(
          id: const Uuid().v4(),
          startDateTime: endDateTime.add(const Duration(seconds: 10)), // Joga por ultimo na lista
          petIds: [widget.petId],
          eventTypeIndex: 5, // Other
          hasAIAnalysis: true,
          notes: summary,
          metrics: {
            'custom_title': summaryTitle, 
            'is_summary': true,
            PetConstants.keyAiSummary: summary,
            'source': 'walk',
          },
        );

        await _repository.saveEvent(newEvent);
        
        // RECUPERAÇÃO DO PASSEIO: Atualiza a listagem de eventos via callback injetado pela rota mãe
        onEventSavedCallback?.call();
        
        debugPrint("[SCAN_NUT_TRACE] [AUTO_WALK_SUMMARY] Successfully generated and saved Walk BG Summary!");

     } catch (e) {
        debugPrint("[SCAN_NUT_TRACE] [AUTO_WALK_SUMMARY_ERROR] Failed to gen BG Walk summary: $e");
     } finally {
        // GARANTIA: Atualiza a listagem mãe e DESLIGA o spinner visual, independente de sucesso ou falha
        onEventSavedCallback?.call();
     }
   }

}
