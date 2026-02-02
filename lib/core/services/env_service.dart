import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';
import 'package:scannutplus/core/constants/app_keys.dart';

class EnvService {
  static Future<void> init() async {
    if (dotenv.isInitialized) return;
    try {
      await dotenv.load(fileName: AppKeys.envFile);
    } catch (e) {
      if (kDebugMode) {
        debugPrint("${AppKeys.errorEnvMissing}$e");
      }
    }
  }

  static String get geminiApiKey {
    final key = dotenv.env[AppKeys.geminiApiKey];
    if (kDebugMode && key != null) {
       debugPrint('[CORE_LOG]: API Key format check - Length: ${key.length}');
    }
    if (key == null || key.isEmpty) {
      if (kDebugMode) {
        debugPrint(AppKeys.errorGeminiMissing);
      }
      return ''; // Or throw
    }
    return key;
  }
}
