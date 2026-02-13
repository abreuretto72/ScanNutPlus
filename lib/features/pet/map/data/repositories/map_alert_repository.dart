import 'package:geolocator/geolocator.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:scannutplus/features/pet/map/data/models/pet_map_alert.dart';
import 'package:scannutplus/features/pet/data/pet_constants.dart';

class MapAlertRepository {
  static const String boxName = 'map_alerts_box';

  Future<Box<PetMapAlert>> _openBox() async {
    if (!Hive.isBoxOpen(boxName)) {
      return await Hive.openBox<PetMapAlert>(boxName);
    }
    return Hive.box<PetMapAlert>(boxName);
  }

  /// Salva um novo alerta
  Future<void> saveAlert(PetMapAlert alert) async {
    final box = await _openBox();
    await box.put(alert.id, alert);
  }

  /// Recupera alertas num raio de X km (padrão 5km)
  Future<List<PetMapAlert>> getAlertsNear(double lat, double lng, {double radiuskm = 5.0}) async {
    final box = await _openBox();
    final allAlerts = box.values.toList();
    
    // Filtra por data de expiração antes de calcular distância
    final validAlerts = await _cleanExpiredAlerts(allAlerts);
    
    return validAlerts.where((alert) {
      final distanceInMeters = Geolocator.distanceBetween(
        lat, 
        lng, 
        alert.latitude, 
        alert.longitude
      );
      return distanceInMeters <= (radiuskm * 1000);
    }).toList();
  }

  /// Limpa alertas temporários (ex: Cão solto) após 24h
  /// Retorna a lista já limpa
  Future<List<PetMapAlert>> _cleanExpiredAlerts(List<PetMapAlert> alerts) async {
    final now = DateTime.now();
    final List<PetMapAlert> valid = [];
    final box = await _openBox();

    for (var alert in alerts) {
      // Regra de Expiração: Alertas temporários duram 24h.
      // Assumindo que categorias permanentes (buraco, área de risco) não expiram ou têm outro tratamento.
      // Por enquanto, seguimos a regra geral de 24h para simplicidade ou definimos categorias específicas.
      // O prompt diz: "limpe automaticamente alertas temporários... mas mantenha alertas permanentes".
      // Vamos assumir 'temp' como padrão ou verificar categoria.
      
      bool isPermanent = [PetConstants.alertDangerousHole, PetConstants.alertRiskArea].contains(alert.category);
      
      if (!isPermanent && now.difference(alert.timestamp).inHours >= 24) {
        await box.delete(alert.id);
      } else {
        valid.add(alert);
      }
    }
    return valid;
  }
}
