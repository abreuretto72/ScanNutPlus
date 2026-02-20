import 'package:google_maps_flutter/google_maps_flutter.dart';

class Partner {
  final String id;
  final String name;
  final String address;
  final double rating;
  final int totalRatings;
  final bool isOpenNow;
  final String? phoneNumber;
  final String? website;
  final LatLng location;
  final List<String> types;

  // Modifiers para a UI (Distância e Categoria Mapeada)
  double? distanceRaw; 
  String? category;

  Partner({
    required this.id,
    required this.name,
    required this.address,
    required this.rating,
    required this.totalRatings,
    required this.isOpenNow,
    this.phoneNumber,
    this.website,
    required this.location,
    required this.types,
    this.distanceRaw,
    this.category,
  });

  factory Partner.fromJson(Map<String, dynamic> json) {
    return Partner(
      id: json['place_id'] ?? '',
      name: json['name'] ?? '',
      address: json['vicinity'] ?? json['formatted_address'] ?? '',
      rating: (json['rating'] ?? 0.0).toDouble(),
      totalRatings: json['user_ratings_total'] ?? 0,
      isOpenNow: json['opening_hours']?['open_now'] ?? false,
      phoneNumber: json['formatted_phone_number'] ?? json['international_phone_number'],
      website: json['website'],
      location: LatLng(
        json['geometry']['location']['lat'] ?? 0.0,
        json['geometry']['location']['lng'] ?? 0.0,
      ),
      types: List<String>.from(json['types'] ?? []),
      category: json['cached_category'],
      distanceRaw: json['cached_distance'] != null ? (json['cached_distance'] as num).toDouble() : null,
    );
  }

  String get formattedDistance {
    if (distanceRaw == null) return '';
    if (distanceRaw! < 1000) {
      return '${distanceRaw!.toStringAsFixed(0)}m';
    } else {
      return '${(distanceRaw! / 1000).toStringAsFixed(1)}km';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'place_id': id,
      'name': name,
      'formatted_address': address,
      'rating': rating,
      'user_ratings_total': totalRatings,
      'opening_hours': {'open_now': isOpenNow},
      'formatted_phone_number': phoneNumber,
      'website': website,
      'geometry': {
        'location': {
          'lat': location.latitude,
          'lng': location.longitude,
        }
      },
      'types': types,
      'cached_category': category, // Custom extension
      'cached_distance': distanceRaw, // Custom extension
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Partner && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
