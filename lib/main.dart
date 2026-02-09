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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EnvService.init(); // Priority Init
  await ObjectBoxManager.init();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const ProviderScope(child: ScanNutApp()));
}

class ScanNutApp extends StatelessWidget {
  const ScanNutApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
