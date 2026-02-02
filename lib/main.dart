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
      home: const SplashScreen(), 
    );
  }
}
