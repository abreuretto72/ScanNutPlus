import 'package:flutter/material.dart';
import 'package:scannutplus/l10n/app_localizations.dart';
import 'package:uuid/uuid.dart';

/// Micro App: PetFriendManager
/// Responsável por identificar e gerenciar a identidade de pets "amigos/visitantes"
/// durante o registro de eventos, sem alterar as telas principais.
class PetFriendManager {
  static const String _logTag = '[FRIEND_MANAGER]';

  /// Identifica se o contexto (notas ou análise da IA) refere-se a um pet amigo/visitante.
  /// Retorna true se encontrar palavras-chave localizadas.
  bool identifyPetContext(String notes, String? aiAnalysis, AppLocalizations l10n) {
    debugPrint('$_logTag Analisando contexto multi-idioma...');
    
    // Carrega keywords do sistema de localização
    // Fallback seguro + Hardcoded para garantir funcionamento na Demo
    final friendKeywords = _getKeywords(l10n.keywordFriend); 
    final guestKeywords = _getKeywords(l10n.keywordGuest);
    
    // SAFETY FALLBACK: Se l10n falhar, usa lista hardcoded (PT/EN mix)
    final fallbackKeywords = {'amigo', 'friend', 'visitante', 'guest', 'vizinho', 'neighbor'};
    
    // Combina todas as keywords relevantes
    final allKeywords = {...friendKeywords, ...guestKeywords, ...fallbackKeywords};
    
    debugPrint('$_logTag Keywords carregadas: ${allKeywords.length}');
    
    if (allKeywords.isEmpty) {
       debugPrint('$_logTag Nenhuma keyword configurada (nem fallback). Retornando false.');
       return false;
    }

    // Normaliza o conteúdo para busca case-insensitive
    final contentToAnalyze = (notes + (aiAnalysis ?? '')).toLowerCase();
    debugPrint('$_logTag Conteúdo analisado: "$contentToAnalyze"');
    
    for (final keyword in allKeywords) {
      if (contentToAnalyze.contains(keyword.toLowerCase())) {
        debugPrint('$_logTag Match encontrado! (Sim) | Termo Detectado: $keyword');
        return true;
      }
    }
    
    debugPrint('$_logTag Nenhum match encontrado.');
    return false;
  }

  /// Helper para processar a string de keywords do ARB (separada por vírgula)
  List<String> _getKeywords(String? localizedString) {
    if (localizedString == null || localizedString.isEmpty) return [];
    return localizedString.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
  }

  /// Retorna o ID do pet de destino. 
  /// Se [isFriend] for true, gera um novo UUID com prefixo 'guest_'.
  /// Caso contrário, retorna o [originalPetId] (ex: LeBron).
  String getTargetPetId(String originalPetId, bool isFriend) {
    String finalId;
    
    if (isFriend) {
      // Gera ID único para o amigo/visitante para separar do histórico do pet principal
      finalId = 'guest_${const Uuid().v4()}';
    } else {
      // Mantém vinculado ao pet original (LeBron)
      finalId = originalPetId;
    }
    
    debugPrint('$_logTag ID de destino definido: $finalId');
    return finalId;
  }
}
