import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignUpForm extends StatefulWidget {
  const SignUpForm({
    Key? key,
    required this.onModeChanged,
    required this.authTriggerStream,
  }) : super(key: key);

  final ValueChanged<bool>
  onModeChanged; // Callback to notify when mode changes
  final Stream<void> authTriggerStream;

  @override
  SignUpFormState createState() => SignUpFormState();
}

class SignUpFormState extends State<SignUpForm> {
  late StreamSubscription<void> _authTriggerSubscription;

  void authenticate() {
    if (_isSignUpMode) {
      signUp();
    } else {
      signIn();
    }
  }

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isSignUpMode = true;

  @override
  void initState() {
    super.initState();
    // Notify parent of initial mode after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onModeChanged(_isSignUpMode);
    });

    _authTriggerSubscription = widget.authTriggerStream.listen((_) {
      authenticate();
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _authTriggerSubscription.cancel();
    super.dispose();
  }

  Future<void> signUp() async {
    print('signUp method called in SignUpForm');
    if (!_formKey.currentState!.validate()) {
      print('Form validation failed');
      return;
    }

    print('Form validation passed, starting sign-up process');
    setState(() {
      _isLoading = true;
    });

    try {
      print('Attempting to sign up with Supabase');
      final response = await Supabase.instance.client.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (response.user != null) {
        print('Sign-up successful');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please check your email to confirm your signup!'),
          ),
        );
      }
    } on AuthException catch (error) {
      print('AuthException: ${error.message}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } catch (error) {
      print('Unexpected error: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unexpected error occurred'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> signIn() async {
    print('signIn method called in SignUpForm');
    if (!_formKey.currentState!.validate()) {
      print('Form validation failed for sign-in');
      return;
    }

    print('Form validation passed, starting sign-in process');
    setState(() {
      _isLoading = true;
    });

    try {
      print('Attempting to sign in with Supabase');
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (response.user != null) {
        print('Sign-in successful');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Sign-in successful!')));
      }
    } on AuthException catch (error) {
      print('AuthException during sign-in: ${error.message}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } catch (error) {
      print('Unexpected error during sign-in: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unexpected error occurred during sign-in'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _isSignUpMode ? "Create an account" : "Sign in to your account",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 26),
            ),
            const SizedBox(height: 16),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!RegExp(
                        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                      ).hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      hintText: "Email address",
                      hintStyle: const TextStyle(
                        fontWeight: FontWeight.normal,
                        color: Colors.grey,
                      ),
                      suffixIcon: Icon(Icons.mail, color: Colors.grey.shade400),
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      hintText: "Password",
                      hintStyle: const TextStyle(
                        fontWeight: FontWeight.normal,
                        color: Colors.grey,
                      ),
                      suffixIcon: Icon(Icons.lock, color: Colors.grey.shade400),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 200),
            Center(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _isSignUpMode = !_isSignUpMode;
                    // Notify parent of mode change
                    widget.onModeChanged(_isSignUpMode);
                  });
                },
                child: Text(
                  _isSignUpMode
                      ? "Already have an account? Sign in."
                      : "Don't have an account? Sign up.",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.blueGrey.shade300,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
