import 'dart:async'; // For runZonedGuarded
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:scannutplus/l10n/app_localizations.dart';
import 'package:scannutplus/features/pet/l10n/generated/pet_localizations.dart';
import 'package:scannutplus/features/user/presentation/splash_screen.dart';
import 'package:scannutplus/core/services/env_service.dart';
import 'package:scannutplus/core/theme/app_theme.dart';
import 'package:scannutplus/core/data/objectbox_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:scannutplus/features/pet/presentation/my_pets_view.dart';
import 'package:scannutplus/features/pet/presentation/pet_dashboard_view.dart';
import 'package:scannutplus/features/pet/presentation/pet_capture_view.dart';
import 'package:scannutplus/features/pet/presentation/pet_analysis_result_view.dart';
import 'package:scannutplus/features/pet/data/pet_constants.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:scannutplus/features/pet/data/models/pet_event_type.dart';
import 'package:scannutplus/features/pet/data/models/pet_event_model.dart';
import 'package:scannutplus/features/pet/map/data/models/pet_map_alert.dart';
import 'package:scannutplus/pet/agenda/pet_event.dart' as legacy_event;


final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EnvService.init(); // Priority Init
  await ObjectBoxManager.init();
  
  // Hive Registration
  await Hive.initFlutter();
  Hive.registerAdapter(PetEventTypeAdapter());
  Hive.registerAdapter(PetEventAdapter()); // New Model (202)
  Hive.registerAdapter(legacy_event.PetEventAdapter()); // Legacy Model (201)
  Hive.registerAdapter(PetMapAlertAdapter()); // Map Alerts (20)

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Global Error Handling (Protection Shield)
  runZonedGuarded(() {
    runApp(const ProviderScope(child: ScanNutApp()));
  }, (error, stack) {
    // Log error to console (or crashlytics in future)
    debugPrint('[SCAN_NUT_FATAL] Global Error Caught: $error');
    debugPrint('[SCAN_NUT_FATAL] Stack: $stack');
  });

  // Custom Error Widget (Anti-Red Screen)
  ErrorWidget.builder = (FlutterErrorDetails details) {
    final context = navigatorKey.currentContext;
    final l10n = context != null ? AppLocalizations.of(context) : null;
    
    return Material(
      color: const Color(0xFF1E1E1E), // Dark background
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.orangeAccent, size: 60),
              const SizedBox(height: 16),
              Text(
                l10n?.error_unexpected_title ?? 'Ops! Algo inesperado aconteceu.',
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                l10n?.error_unexpected_message ?? 'Nosso time de esquilos já foi notificado. Por favor, reinicie o app.',
                style: const TextStyle(color: Colors.white70, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                   // Attempt to recover or just print
                   debugPrint('[SCAN_NUT_RECOVERY] User clicked restart/recover.');
                }, 
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orangeAccent),
                child: Text(l10n?.error_try_recover ?? 'Tentar Recuperar', style: const TextStyle(color: Colors.black)),
              )
            ],
          ),
        ),
      ),
    );
  };
}

class ScanNutApp extends StatefulWidget {
  const ScanNutApp({super.key});

  @override
  State<ScanNutApp> createState() => _ScanNutAppState();
}

class _ScanNutAppState extends State<ScanNutApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didHaveMemoryPressure() {
    super.didHaveMemoryPressure();
    debugPrint('[SCAN_NUT_MEMORY] Memory Warning! Clearing caches...');
    // Clear Image Cache
    imageCache.clear();
    imageCache.clearLiveImages();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      onGenerateTitle: (context) => AppLocalizations.of(context)!.app_title,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        PetLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      theme: AppTheme.theme,
      routes: {
        '/my_pets': (context) => const MyPetsView(),
        '/pet_dashboard': (context) => const PetDashboardView(),
        '/pet_capture': (context) => const PetCaptureView(),
        '/pet_analysis_result': (context) => PetAnalysisResultView(
          imagePath: (ModalRoute.of(context)!.settings.arguments as Map)[PetConstants.argImagePath],
          analysisResult: (ModalRoute.of(context)!.settings.arguments as Map)[PetConstants.argResult],
          onRetake: () => Navigator.pop(context),
          onShare: () {}, // Handled internally or needs callback
          petDetails: (ModalRoute.of(context)!.settings.arguments as Map)[PetConstants.argPetDetails] as Map<String, String>?,
        ),
      },
      home: const SplashScreen(),
    );
  }
}
