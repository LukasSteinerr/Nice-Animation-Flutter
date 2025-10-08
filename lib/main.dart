import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:test/screens/onboarding_screen.dart';
import 'package:test/screens/home_screen.dart';
import 'package:test/screens/username_screen.dart';
import 'package:test/services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://wsvqksmobmezuaeiycii.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndzdnFrc21vYm1lenVhZWl5Y2lpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTk0MTAxMTcsImV4cCI6MjA3NDk4NjExN30.Asbj_pDqEtSJSUF2Wd07RYdtLapaMQNgp-6pI0l7oj0',
  );

  runApp(const MyApp());
}

// Get a reference to the Supabase client
final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'The Flutter Way',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final AuthService _authService = AuthService();
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    try {
      // Initialize the preferences service
      await _authService.initPreferencesService();
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      // If initialization fails, still mark as initialized to allow app to continue
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      // Show loading indicator while initializing services
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return StreamBuilder<AuthState>(
      stream: supabase.auth.onAuthStateChange,
      builder: (context, snapshot) {
        // Check if there's an active session
        final session = snapshot.data?.session;

        // Show loading indicator while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // If user is authenticated, check if they have a username
        if (session != null) {
          return FutureBuilder<bool>(
            future: _checkHasUsername(),
            builder: (context, usernameSnapshot) {
              if (usernameSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              // If user doesn't have a username, show username screen
              if (usernameSnapshot.data == false) {
                return const UsernameScreen();
              }

              // Otherwise, show home screen
              return const HomeScreen();
            },
          );
        }

        // Otherwise, show onboarding screen
        return const OnboardingScreen();
      },
    );
  }

  Future<bool> _checkHasUsername() async {
    try {
      // This will now check cache first, making it much faster and work offline
      return await _authService.hasUsername();
    } catch (e) {
      // If there's an error checking username, assume user doesn't have one
      return false;
    }
  }
}
