import 'package:flutter/material.dart';
import 'package:test/components/landed_content.dart';
import 'package:test/components/sing_up_form.dart';
import 'package:test/components/sign_in_form.dart';
import 'package:test/services/auth_service.dart';

class OnboardContent extends StatefulWidget {
  const OnboardContent({super.key});

  @override
  State<OnboardContent> createState() => _OnboardContentState();
}

class _OnboardContentState extends State<OnboardContent> {
  late PageController _pageController;
  final AuthService _authService = AuthService();
  final GlobalKey _signUpFormKey = GlobalKey();
  final GlobalKey _signInFormKey = GlobalKey();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    _pageController = PageController()
      ..addListener(() {
        setState(() {});
      });
    super.initState();
  }

  void goToSignInPage() {
    _pageController.animateToPage(
      2, // Assuming 'Sign In' is the third page (index 2)
      duration: const Duration(milliseconds: 400),
      curve: Curves.ease,
    );
  }

  Future<void> _handleAuthentication() async {
    final currentPage = _pageController.page?.round() ?? 0;

    if (currentPage == 1) {
      // Sign up flow
      if ((_signUpFormKey.currentState as dynamic)?.isValid ?? false) {
        await _performSignUp();
      } else {
        setState(() {
          _errorMessage = "Please fill in all fields correctly";
        });
      }
    } else if (currentPage == 2) {
      // Sign in flow
      if ((_signInFormKey.currentState as dynamic)?.isValid ?? false) {
        await _performSignIn();
      } else {
        setState(() {
          _errorMessage = "Please fill in all fields correctly";
        });
      }
    }
  }

  Future<void> _performSignUp() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final signUpFormState = _signUpFormKey.currentState as dynamic;
      final email = signUpFormState?.email ?? '';
      final password = signUpFormState?.password ?? '';

      await _authService.signUpWithEmail(email, password);

      // Show success message or navigate to next screen
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Account created successfully! Please check your email to verify.',
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(
            bottom:
                MediaQuery.of(context).size.height -
                100, // Adjust this value as needed
            left: 10,
            right: 10,
          ),
        ),
      );

      // Navigate to sign in page after successful sign up
      goToSignInPage();
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _performSignIn() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final signInFormState = _signInFormKey.currentState as dynamic;
      final email = signInFormState?.email ?? '';
      final password = signInFormState?.password ?? '';

      await _authService.signInWithEmail(email, password);

      // Show success message or navigate to home screen
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Signed in successfully!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(
            bottom:
                MediaQuery.of(context).size.height -
                100, // Adjust this value as needed
            left: 10,
            right: 10,
          ),
        ),
      );

      // Close the bottom sheet after successful sign in
      Navigator.of(context).pop();
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double progress = _pageController.hasClients
        ? (_pageController.page ?? 0)
        : 0;

    return SizedBox(
      height: 400 + (progress > 1 ? 1 : progress) * 160,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Column(
            children: [
              const SizedBox(height: 16),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  children: [
                    const LandingContent(),
                    SignUpForm(
                      key: _signUpFormKey,
                      onSignInPressed: goToSignInPage,
                    ),
                    SignInForm(key: _signInFormKey),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            height: 56,
            bottom: 48 + (progress > 1 ? 1 : progress) * 180,
            right: 16,
            child: GestureDetector(
              onTap: _isLoading
                  ? null
                  : () async {
                      final currentPage = _pageController.page?.round() ?? 0;

                      if (currentPage == 0) {
                        _pageController.animateToPage(
                          1,
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.ease,
                        );
                      } else if (currentPage == 1 || currentPage == 2) {
                        await _handleAuthentication();
                      }
                    },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(25)),
                  gradient: LinearGradient(
                    begin: Alignment.bottomLeft,
                    end: Alignment.topRight,
                    stops: [0.4, 0.8],
                    colors: _isLoading
                        ? [Colors.grey.shade400, Colors.grey.shade600]
                        : [
                            const Color.fromARGB(255, 239, 104, 80),
                            const Color.fromARGB(255, 139, 33, 146),
                          ],
                  ),
                ),
                child: DefaultTextStyle(
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width:
                            92 +
                            (progress > 1
                                ? (2 - progress) * 32
                                : progress * 32),
                        child: Stack(
                          fit: StackFit.passthrough,
                          children: [
                            FadeTransition(
                              opacity: AlwaysStoppedAnimation(1 - progress),
                              child: Text(
                                _isLoading ? "Loading..." : "Get Started",
                              ),
                            ),
                            FadeTransition(
                              opacity: AlwaysStoppedAnimation(
                                progress > 1 ? 1 - (progress - 1) : progress,
                              ),
                              child: Text(
                                _isLoading ? "Loading..." : "Create account",
                                maxLines: 1,
                                overflow: TextOverflow.fade,
                                softWrap: false,
                              ),
                            ),
                            FadeTransition(
                              opacity: AlwaysStoppedAnimation(
                                progress > 1 ? (progress - 1) : 0,
                              ),
                              child: Text(
                                _isLoading ? "Loading..." : "Sign in",
                                maxLines: 1,
                                overflow: TextOverflow.fade,
                                softWrap: false,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Icon(
                              Icons.chevron_right,
                              size: 24,
                              color: Colors.white,
                            ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Error message display
          if (_errorMessage != null)
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error, color: Colors.red.shade600, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(
                          color: Colors.red.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        color: Colors.red.shade600,
                        size: 18,
                      ),
                      onPressed: () {
                        setState(() {
                          _errorMessage = null;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
