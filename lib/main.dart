import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:test/onboarding_screen.dart';

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
      home: const OnboardingScreen(),
    );
  }
}
