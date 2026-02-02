import 'package:objectbox/objectbox.dart';

@Entity()
class UserEntity {
  @Id()
  int id = 0;

  String name;
  String email;
  
  /// Flag to indicate if this is the currently logged in user
  bool isActive;
  
  String? photoPath;

  UserEntity({
    this.id = 0,
    required this.name,
    required this.email,
    this.isActive = false,
    this.photoPath,
  });
}
