import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:test/components/onboard_content.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late PageController _onboardPageController;

  @override
  void initState() {
    _onboardPageController = PageController()
      ..addListener(() {
        setState(() {});
      });
    super.initState();

    Future.delayed(Duration.zero, () {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        enableDrag:
            false, // This prevents the bottom sheet from being swiped away
        isDismissible:
            false, // This prevents the bottom sheet from being dismissed by tapping outside
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(42),
            topRight: Radius.circular(42),
          ),
        ),
        builder: (_) => const OnboardContent(),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      body: Image.asset(
        "assets/bg.png",
        width: double.infinity,
        fit: BoxFit.cover,
      ),
    );
  }
}
