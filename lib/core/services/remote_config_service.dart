import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Ensure package import
import 'package:scannutplus/features/pet/data/pet_constants.dart';
import 'package:scannutplus/core/constants/app_keys.dart';

class RemoteConfigService {
  static const String _defaultModel = 'gemini-2.5-flash';

  Future<Map<String, dynamic>> fetchConfig(String url) async {
    try {
      final uri = Uri.parse(url);
      final response = await http.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        if (kDebugMode) {
          debugPrint('${PetConstants.logTagPetFatal} Remote Config Failed: ${response.statusCode}');
        }
        return {};
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('${PetConstants.logTagPetFatal} Remote Config Exception: $e');
      }
      return {};
    }
  }

  /// Extracts the model name safely, defaulting only if absolutely necessary
  Future<String> getActiveModel() async {
    try {
        // 1. Coleta a URL do arquivo .env (Pilar 3)
        final remoteUrl = dotenv.env[AppKeys.envSiteUrl];
        
        if (remoteUrl == null || remoteUrl.isEmpty) {
          debugPrint('${AppKeys.logPrefixPetError} Chave SITE_BASE_URL não encontrada no .env');
          // Fallback to Constant if Env missing (Safety net during transition)
          return await _fetchFromConstUrl(); 
        }

        // 2. Busca o JSON no Multiverso Digital
        final config = await fetchConfig(remoteUrl);
        final modelName = config[PetConstants.fieldActiveModel];

        if (modelName != null && modelName.toString().isNotEmpty) {
          if (kDebugMode) {
              debugPrint('${AppKeys.logPrefixPetTrace} Modelo Remoto: $modelName');
          }
          return modelName.toString();
        }
    } catch (e) {
        debugPrint('${AppKeys.logPrefixPetError} Erro na coleta remota: $e');
    }
    
    return _defaultModel; // Fallback only on total failure
  }
  
  Future<String> _fetchFromConstUrl() async {
       final config = await fetchConfig(PetConstants.remoteConfigUrl);
       final model = config[PetConstants.fieldActiveModel];
       return (model != null && model.toString().isNotEmpty) ? model.toString() : _defaultModel;
  }
}

final remoteConfigService = RemoteConfigService();
