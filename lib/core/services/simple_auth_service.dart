import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/local_auth.dart';
import 'package:scannutplus/core/data/objectbox_manager.dart';
import 'package:scannutplus/features/user/data/models/user_entity.dart';
import 'package:scannutplus/objectbox.g.dart'; // generated

enum AuthResult { success, failure, error }

class SimpleAuthService {
  static const String prefIsRegistered = 'is_user_registered';
  static const String keyUseBiometrics = 'use_biometrics'; // Unified Key
  
  // Singleton
  static final SimpleAuthService _instance = SimpleAuthService._internal();

  factory SimpleAuthService() {
    return _instance;
  }

  SimpleAuthService._internal();

  Box<UserEntity>? _userBox;

  Future<void> _ensureDb() async {
    if (_userBox != null) return;
    // ensure initialized in case main didn't finish or race condition
    await ObjectBoxManager.init(); 
    _userBox = ObjectBoxManager.currentStore.box<UserEntity>();
  }

  String? get loggedUserEmail => "user@example.com";
  // Changed to async to support SharedPreferences (Unified Key)
  Future<bool> get isBiometricEnabled async {
    final prefs = await SharedPreferences.getInstance();
    final val = prefs.getBool(keyUseBiometrics) ?? false;
    return val;
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keyUseBiometrics, enabled);
  }

  Future<bool> checkPersistentSession() async {
    await _ensureDb();
    final activeUser = _userBox!.query(UserEntity_.isActive.equals(true)).build().findFirst();
    return activeUser != null;
  }

  Future<AuthResult> authenticateWithBiometrics({required String localizedReason}) async {
    // 1. Check User Preference (Strict)
    if (!await isBiometricEnabled) {
       return AuthResult.failure; 
    }

    final auth = LocalAuthentication();
    
    // 2. Hardware Availability Check (Prompt Strictness)
    final bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
    // final bool isDeviceSupported = await auth.isDeviceSupported(); // Unused in relaxed check

    try {
      await auth.getAvailableBiometrics();
    } catch (e) {
      // Log error internally if needed, or ignore for production
    }

    // Relaxed check: Allow proceeding if canCheckBiometrics is true, even if isDeviceSupported says false (common in emulators/some ROMs)
    if (!canAuthenticateWithBiometrics) return AuthResult.failure;

    try {
      // 3. Authenticate (Real Hardware Trigger)
      final bool didAuthenticate = await auth.authenticate(
        localizedReason: localizedReason,
        options: const AuthenticationOptions(
          biometricOnly: false, // Changed to false to allow PIN/Pattern fallback
          stickyAuth: true,
        ),
      );

      if (didAuthenticate) {
          // 4. Session Activation (Success Logic - Preserved for App Functionality)
          await _ensureDb();
          
          UserEntity? user = _userBox!.query(UserEntity_.isActive.equals(true)).build().findFirst();
          // Fallback if no active user found (e.g. forced logout)
          user ??= _userBox!.query().build().findFirst();

          if (user != null) {
              user.isActive = true;
              _userBox!.put(user);
              return AuthResult.success;
          } else {
              return AuthResult.failure; 
          }
      } else {
        return AuthResult.failure;
      }
    } catch (e) {
      return AuthResult.error;
    }
  }

  Future<bool> get hasRegisteredUsers async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(prefIsRegistered) ?? false;
  }

  static const String _dbDefaultUser = ""; // Internal DB Value


  Future<void> registerUser({required String email, required String password}) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Sanitize key for consistent storage
    final cleanEmail = email.trim().toLowerCase();
    
    // Save password safely (simulated secure storage)
    // FIX: Using dynamic key by removing backslash before $cleanEmail
    await prefs.setString('pwd_$cleanEmail', password); 
    await prefs.setBool(prefIsRegistered, true);

    await _ensureDb();
    
    // Check if distinct user exists?
    final existingUserQuery = _userBox!.query(UserEntity_.email.equals(cleanEmail)).build();
    UserEntity? user = existingUserQuery.findFirst();
    existingUserQuery.close();

    if (user == null) {
      user = UserEntity(
        name: cleanEmail.split('@').first, 
        email: cleanEmail,
        isActive: true,
      );
      _userBox!.put(user);
    } else {
      user.isActive = true;
      _userBox!.put(user);
    }
  }

  // Deprecated: Logic removed to enforce security
  Future<void> registerUserDemo() async {
    // Redirects to standard flow validation if called, or does nothing safely.
    // We keep it to avoid build errors if SignUpPage isn't updated simultaneously in a single atomic step, 
    // but we will update SignUpPage next.
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

  Future<bool> quickLogin(String email, String password) async {
    final cleanEmail = email.trim().toLowerCase();
    
    await _ensureDb();
    final prefs = await SharedPreferences.getInstance();

    // 1. Strict Validation: User must exist in DB (using clean email)
    final existingUserQuery = _userBox!.query(UserEntity_.email.equals(cleanEmail)).build();
    UserEntity? user = existingUserQuery.findFirst();
    existingUserQuery.close();

    if (user == null) {
      // Security: User not found
      return false;
    }

    // 2. Strict Validation: Password must match stored credential
    // Correct Key Access: Using normalized email
    // FIX: Using dynamic key by removing backslash before $cleanEmail
    final key = 'pwd_$cleanEmail';
    final storedPwd = prefs.getString(key);
    
    if (storedPwd == null || storedPwd != password) {
       // Security: Password mismatch or no password set
       return false;
    }

    // 3. Activation Flow
    user.isActive = true;
    _userBox!.put(user);
    
    // 4. Ensure only one active user (cleanup others)
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
