import 'dart:convert';
import 'package:http/http.dart' as http;

class PetWeatherService {
  final String _apiKey = "YOUR_OPENWEATHER_API_KEY"; // TODO: Move to .env or Remote Config

  Future<Map<String, dynamic>?> getCurrentWeather(double lat, double lng) async {
    try {
      final url = Uri.parse('https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lng&units=metric&lang=pt_br&appid=$_apiKey');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final temp = data['main']['temp'];
        final humidity = data['main']['humidity'];
        final description = data['weather'][0]['description'];
        
        return {
          'temp': temp,
          'humidity': humidity,
          'description': description,
          'uv': 0, // OpenWeather basic API doesn't provide UV in free tier easily, defaulting
        };
      }
    } catch (e) {
      // Fail silently or log
    }
    return null;
  }
}
