import 'package:shared_preferences/shared_preferences.dart';

class UserPreferencesService {
  static const String _usernameKey = 'username';
  static const String _hasUsernameKey = 'has_username';
  static const String _userIdKey = 'user_id';

  static UserPreferencesService? _instance;
  static SharedPreferences? _preferences;

  UserPreferencesService._();

  static Future<UserPreferencesService> getInstance() async {
    _instance ??= UserPreferencesService._();
    _preferences ??= await SharedPreferences.getInstance();
    return _instance!;
  }

  // Save username locally
  Future<void> saveUsername(String username, String userId) async {
    await _preferences?.setString(_usernameKey, username);
    await _preferences?.setString(_userIdKey, userId);
    await _preferences?.setBool(_hasUsernameKey, true);
  }

  // Get cached username
  String? getUsername() {
    return _preferences?.getString(_usernameKey);
  }

  // Check if user has a username cached
  bool hasUsername() {
    return _preferences?.getBool(_hasUsernameKey) ?? false;
  }

  // Get cached user ID
  String? getUserId() {
    return _preferences?.getString(_userIdKey);
  }

  // Check if the cached data belongs to the current user
  bool isCurrentUser(String userId) {
    final cachedUserId = getUserId();
    return cachedUserId == userId;
  }

  // Clear all cached user data (for sign out)
  Future<void> clearUserData() async {
    await _preferences?.remove(_usernameKey);
    await _preferences?.remove(_hasUsernameKey);
    await _preferences?.remove(_userIdKey);
  }

  // Clear username only (for username updates)
  Future<void> clearUsername() async {
    await _preferences?.remove(_usernameKey);
    await _preferences?.remove(_hasUsernameKey);
  }
}
