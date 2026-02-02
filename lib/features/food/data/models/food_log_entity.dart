import 'package:objectbox/objectbox.dart';

@Entity()
class FoodLogEntity {
  @Id()
  int id = 0;

  String foodName;
  double calories;
  double protein;
  double carbs;
  double fat;
  String imagePath;
  DateTime timestamp;

  FoodLogEntity({
    this.id = 0,
    required this.foodName,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.imagePath,
    required this.timestamp,
  });
}
