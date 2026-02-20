import 'package:geocoding/geocoding.dart';

class PetContextService {
  Future<String?> getPlaceContext(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        // Ex: "Parque Ibirapuera, São Paulo"
        final name = place.name ?? '';
        final street = place.thoroughfare ?? '';
        final subLocality = place.subLocality ?? '';
        
        if (name.isNotEmpty && name != street) {
           return "$name ($subLocality)"; // Likely a POI name
        }
        return "$street, $subLocality";
      }
    } catch (e) {
      // Fail silently
    }
    return null;
  }
}
