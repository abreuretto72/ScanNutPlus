import 'package:shared_preferences/shared_preferences.dart';
import 'package:scannutplus/core/data/objectbox_manager.dart';
import 'package:scannutplus/features/user/data/models/user_entity.dart';
import 'package:scannutplus/objectbox.g.dart'; // generated

enum AuthResult { success, failure, error }

class SimpleAuthService {
  static const String prefIsRegistered = 'is_user_registered';
  
  Box<UserEntity>? _userBox;

  Future<void> _ensureDb() async {
    if (_userBox != null) return;
    // ensure initialized in case main didn't finish or race condition
    await ObjectBoxManager.init(); 
    _userBox = ObjectBoxManager.currentStore.box<UserEntity>();
  }

  String? get loggedUserEmail => "user@example.com";
  // Simulating biometrics for logic completeness
  bool get isBiometricEnabled => true; 

  Future<bool> checkPersistentSession() async {
    await _ensureDb();
    final activeUser = _userBox!.query(UserEntity_.isActive.equals(true)).build().findFirst();
    return activeUser != null;
  }

  Future<AuthResult> authenticateWithBiometrics({required String localizedReason}) async {
    // Mock success for easy testing
    await Future.delayed(const Duration(milliseconds: 500));
    return AuthResult.success;
  }

  Future<bool> get hasRegisteredUsers async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(prefIsRegistered) ?? false;
  }

  static const String _dbDefaultUser = ""; // Internal DB Value
  static const String _dbDemoUser = "User Demo"; // Internal DB Value

  Future<void> registerUserDemo() async {
     final prefs = await SharedPreferences.getInstance();
     await prefs.setBool(prefIsRegistered, true);
     
     // Create generic user in DB if not exists
     await _ensureDb();
     if (_userBox!.count() == 0) {
       final user = UserEntity(
         name: _dbDemoUser,
         email: "demo@scannut.com",
         isActive: true
       );
       _userBox!.put(user);
     } else {
       // Ensure one is active
       final user = _userBox!.getAll().first;
       user.isActive = true;
       _userBox!.put(user);
     }
  }

  Future<UserEntity?> getCurrentUser() async {
    await _ensureDb();
    return _userBox!.query(UserEntity_.isActive.equals(true)).build().findFirst();
  }

  Future<String> getCurrentUserName() async {
    final user = await getCurrentUser();
    return user?.name ?? _dbDefaultUser;
  }

  Future<void> updateUser(UserEntity user) async {
    await _ensureDb();
    _userBox!.put(user);
  }

  // Simulate Logic Login: "abreu@multiversodigital.com.br"
  Future<bool> quickLogin(String email, String password) async {
    await _ensureDb();
    
    // 1. Find user by email (mock or real check)
    final existingUserQuery = _userBox!.query(UserEntity_.email.equals(email)).build();
    UserEntity? user = existingUserQuery.findFirst();
    existingUserQuery.close();

    if (user == null) {
      // Create new user for this session if not exists
      user = UserEntity(
        name: "", // Default name empty, UI handles default
        email: email,
        isActive: true,
      );
      _userBox!.put(user);
    } else {
      // Activate existing user
      user.isActive = true;
      _userBox!.put(user);
    }
    
    // 2. Ensure only one active user (cleanup others)
    final allActive = _userBox!.query(UserEntity_.isActive.equals(true)).build().find();
    for (var u in allActive) {
      if (u.id != user.id) {
        u.isActive = false;
        _userBox!.put(u);
      }
    }

    return true; // Login success
  }

  Future<void> logout() async {
    await _ensureDb();
    final users = _userBox!.query(UserEntity_.isActive.equals(true)).build().find();
    for (var u in users) {
      u.isActive = false;
    }
    _userBox!.putMany(users);
  }
}

final simpleAuthService = SimpleAuthService();
