import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart'; // Added for debugPrint
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart'; // To calculate distance

import 'package:scannutplus/features/pet/agenda/data/models/partner_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PetPartnerService {
  static const String _baseUrl = 'https://maps.googleapis.com/maps/api/place/nearbysearch/json';
  static const String _detailsUrl = 'https://maps.googleapis.com/maps/api/place/details/json';

  static String get _apiKey => dotenv.env['GOOGLE_PLACES_API_KEY'] ?? '';

  static Future<List<Partner>> fetchNearbyPartners(double userLat, double userLng, {bool forceRefresh = false}) async {
    debugPrint('[PetPartnerService] Iniciando busca com LAT: $userLat, LNG: $userLng, Force: $forceRefresh');
    
    if (_apiKey.isEmpty) {
      debugPrint('[PetPartnerService] ERRO: API Key não encontrada no arquivo .env!');
      return [];
    }
    
    debugPrint('[PetPartnerService] API Key carregada com sucesso.');

    // 1. Tentar ler do cache primeiro
    if (!forceRefresh) {
      try {
        final prefs = await SharedPreferences.getInstance();
        final String? cachedJson = prefs.getString('cached_pet_partners');
        if (cachedJson != null) {
          debugPrint('[PetPartnerService] Parceiros em cache encontrados! Validando distância...');
          final List<dynamic> decoded = json.decode(cachedJson);
          final cachedPartners = decoded.map((e) => Partner.fromJson(e)).toList();
          
          bool hasClosePartner = false;
          for (var p in cachedPartners) {
            p.distanceRaw = Geolocator.distanceBetween(
              userLat, 
              userLng, 
              p.location.latitude, 
              p.location.longitude
            );
            if (p.distanceRaw! <= 10000) { // Se tiver pelo menos um num raio de 10km
               hasClosePartner = true;
            }
          }

          if (hasClosePartner && cachedPartners.isNotEmpty) {
            // Ordem por distância recalculada
            cachedPartners.sort((a, b) => (a.distanceRaw ?? 99999).compareTo(b.distanceRaw ?? 99999));
            return cachedPartners;
          } else {
            debugPrint('[PetPartnerService] Cache ignorado: Usuário mudou de região (>10km de todos os itens).');
          }
        }
      } catch (e) {
        debugPrint('[PetPartnerService] Erro ao ler cache: $e');
      }
    } else {
       debugPrint('[PetPartnerService] Refresh Forçado. Ignorando cache.');
    }

    // Map Categories to Keywords for better filtering
    final Map<String, List<String>> keywordMap = {
      'Saúde': ['veterinario', 'clínica veterinária', 'hospital veterinario'],
      'Hospitalidade': ['hotel pet', 'daycare pet', 'creche canina'],
      'Estética': ['pet shop', 'banho e tosa', 'groomer'],
      'Educação': ['adestrador', 'passeador'],
      'Serviços': ['pet taxi', 'farmácia veterinária'],
    };

    List<Partner> allResults = [];
    final Set<String> seenIds = {};

    for (var entry in keywordMap.entries) {
      final category = entry.key;
      final keywords = entry.value;

      for (var keyword in keywords) {
        final encodedKeyword = Uri.encodeComponent(keyword);
        final url = '$_baseUrl?location=$userLat,$userLng&radius=10000&keyword=$encodedKeyword&key=$_apiKey';
        debugPrint('[PetPartnerService] Fazendo request para Category ($category), Keyword ($keyword)...');
        
        try {
          final response = await http.get(Uri.parse(url));

          if (response.statusCode == 200) {
            final data = json.decode(response.body);
            final status = data['status'];
            
            if (status != 'OK' && status != 'ZERO_RESULTS') {
                debugPrint('[PetPartnerService] ERRO NA API (Status: $status): ${data['error_message']}');
            } else {
                debugPrint('[PetPartnerService] Sucesso API: Recebidos ${(data['results'] as List?)?.length ?? 0} resultados para $keyword.');
            }
            
            final results = data['results'] as List<dynamic>?;
            
            if (results != null) {
              for (var place in results) {
                final placeId = place['place_id'] as String;
                
                if (!seenIds.contains(placeId)) {
                  seenIds.add(placeId);
                  
                  final partner = Partner.fromJson(place as Map<String, dynamic>);
                  partner.category = category;
                  
                  // Calculate distance
                  partner.distanceRaw = Geolocator.distanceBetween(
                    userLat, 
                    userLng, 
                    partner.location.latitude, 
                    partner.location.longitude
                  );

                  allResults.add(partner);
                }
              }
            }
          } else {
             debugPrint('[PetPartnerService] HTTP ERRO: ${response.statusCode} - ${response.body}');
          }
        } catch (e) {
          debugPrint('[PetPartnerService] Exceção durante requisição HTTP para $keyword: $e');
        }
      }
    }

    debugPrint('[PetPartnerService] Finalizado. Retornando ${allResults.length} locais.');

    // Sort by distance
    allResults.sort((a, b) => (a.distanceRaw ?? 99999).compareTo(b.distanceRaw ?? 99999));

    // 2. Salvar no cache para as próximas vezes
    try {
      final prefs = await SharedPreferences.getInstance();
      final String jsonToSave = json.encode(allResults.map((p) => p.toJson()).toList());
      await prefs.setString('cached_pet_partners', jsonToSave);
      debugPrint('[PetPartnerService] Salvos ${allResults.length} parceiros no cache local.');
    } catch (e) {
       debugPrint('[PetPartnerService] Erro ao salvar cache: $e');
    }

    return allResults;
  }

  /// Busca os detalhes de um local específico (Telefone, Endereço formatado, etc)
  static Future<Map<String, String?>> fetchPlaceDetails(String placeId) async {
    debugPrint('[PetPartnerService] Buscando Detalhes para o PlaceID: $placeId...');
    
    if (_apiKey.isEmpty) {
      return {};
    }

    final url = '$_detailsUrl?place_id=$placeId&fields=formatted_phone_number,international_phone_number,formatted_address&key=$_apiKey';
    
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final status = data['status'];
        
        if (status == 'OK') {
           final result = data['result'];
           final phone = result['international_phone_number'] ?? result['formatted_phone_number'];
           final address = result['formatted_address'];
           
           debugPrint('[PetPartnerService] Detalhes recuperados -> Telefone: $phone, Endereço: $address');
           return {
             'phone': phone?.toString(),
             'address': address?.toString(),
           };
        }
      }
    } catch (e) {
      debugPrint('[PetPartnerService] Erro ao buscar detalhes locais: $e');
    }
    
    return {};
  }
}
