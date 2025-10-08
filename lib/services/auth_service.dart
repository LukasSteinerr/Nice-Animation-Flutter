import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

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

  // Sign out
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
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
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Get username for the current user
  Future<String?> getUsername() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        return null;
      }

      final profile = await _supabase
          .from('user_profiles')
          .select('username')
          .eq('id', user.id)
          .maybeSingle();

      return profile?['username'] as String?;
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Check if current user has a username
  Future<bool> hasUsername() async {
    final username = await getUsername();
    return username != null && username.isNotEmpty;
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
    } catch (e) {
      throw _handleAuthError(e);
    }
  }
}
