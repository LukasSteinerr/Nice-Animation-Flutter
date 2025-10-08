import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:test/services/user_preferences_service.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;
  UserPreferencesService? _userPreferencesService;

  // Sign up with email and password
  Future<AuthResponse> signUpWithEmail(String email, String password) async {
    try {
      return await _supabase.auth.signUp(email: email, password: password);
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Sign in with email and password
  Future<AuthResponse> signInWithEmail(String email, String password) async {
    try {
      return await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Initialize preferences service
  Future<void> initPreferencesService() async {
    _userPreferencesService = await UserPreferencesService.getInstance();
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
      // Clear cached user data on sign out
      await _userPreferencesService?.clearUserData();
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Get current user
  User? get currentUser => _supabase.auth.currentUser;

  // Stream of auth state changes
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  // Handle authentication errors
  String _handleAuthError(dynamic error) {
    if (error is AuthException) {
      switch (error.message) {
        case 'Invalid login credentials':
          return 'Invalid email or password';
        case 'User already registered':
          return 'An account with this email already exists';
        case 'Email not confirmed':
          return 'Please confirm your email address';
        case 'Password should be at least 6 characters':
          return 'Password must be at least 6 characters long';
        case 'Unable to validate email address: invalid format':
          return 'Please enter a valid email address';
        default:
          return error.message;
      }
    }
    return 'An unexpected error occurred. Please try again.';
  }

  // Validate email format
  bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // Validate password
  String? validatePassword(String password) {
    if (password.isEmpty) {
      return 'Password is required';
    }
    if (password.length < 6) {
      return 'Password must be at least 6 characters long';
    }
    return null;
  }

  // Save username for the current user
  Future<void> saveUsername(String username) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('No authenticated user found');
      }

      // Initialize preferences service if not already done
      _userPreferencesService ??= await UserPreferencesService.getInstance();

      // Check if username is already taken
      final existingUser = await _supabase
          .from('user_profiles')
          .select('id')
          .eq('username', username)
          .maybeSingle();

      if (existingUser != null) {
        throw Exception('Username is already taken');
      }

      // Insert or update user profile with username
      await _supabase.from('user_profiles').upsert({
        'id': user.id,
        'username': username,
        'updated_at': DateTime.now().toIso8601String(),
      });

      // Cache username locally
      await _userPreferencesService!.saveUsername(username, user.id);
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Get username for the current user (checks cache first)
  Future<String?> getUsername() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        return null;
      }

      // Initialize preferences service if not already done
      _userPreferencesService ??= await UserPreferencesService.getInstance();

      // Check cache first
      if (_userPreferencesService!.isCurrentUser(user.id) &&
          _userPreferencesService!.hasUsername()) {
        return _userPreferencesService!.getUsername();
      }

      // If not in cache or user changed, fetch from database
      final profile = await _supabase
          .from('user_profiles')
          .select('username')
          .eq('id', user.id)
          .maybeSingle();

      final username = profile?['username'] as String?;

      // Cache the username if it exists
      if (username != null && username.isNotEmpty) {
        await _userPreferencesService!.saveUsername(username, user.id);
      }

      return username;
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Check if current user has a username (checks cache first)
  Future<bool> hasUsername() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        return false;
      }

      // Initialize preferences service if not already done
      _userPreferencesService ??= await UserPreferencesService.getInstance();

      // Check cache first
      if (_userPreferencesService!.isCurrentUser(user.id) &&
          _userPreferencesService!.hasUsername()) {
        return true;
      }

      // If not in cache or user changed, check database
      final profile = await _supabase
          .from('user_profiles')
          .select('username')
          .eq('id', user.id)
          .maybeSingle();

      final username = profile?['username'] as String?;
      final hasUsername = username != null && username.isNotEmpty;

      // Cache the result
      if (hasUsername) {
        await _userPreferencesService!.saveUsername(username!, user.id);
      }

      return hasUsername;
    } catch (e) {
      // If there's an error (e.g., offline), fall back to cache
      if (_userPreferencesService != null) {
        return _userPreferencesService!.hasUsername();
      }
      return false;
    }
  }

  // Check if a username is available
  Future<bool> isUsernameAvailable(String username) async {
    try {
      final existingUser = await _supabase
          .from('user_profiles')
          .select('id')
          .eq('username', username)
          .maybeSingle();

      return existingUser == null;
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Update username for the current user
  Future<void> updateUsername(String newUsername) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('No authenticated user found');
      }

      // Initialize preferences service if not already done
      _userPreferencesService ??= await UserPreferencesService.getInstance();

      // Check if new username is already taken
      final existingUser = await _supabase
          .from('user_profiles')
          .select('id')
          .eq('username', newUsername)
          .neq('id', user.id)
          .maybeSingle();

      if (existingUser != null) {
        throw Exception('Username is already taken');
      }

      // Update username
      await _supabase
          .from('user_profiles')
          .update({
            'username': newUsername,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', user.id);

      // Update cached username
      await _userPreferencesService!.saveUsername(newUsername, user.id);
    } catch (e) {
      throw _handleAuthError(e);
    }
  }
}
