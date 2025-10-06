import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:test/utils/colors.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class NewBetsScreen extends StatefulWidget {
  const NewBetsScreen({super.key});

  @override
  State<NewBetsScreen> createState() => _NewBetsScreenState();
}

class _NewBetsScreenState extends State<NewBetsScreen> {
  final PageController _pageController = PageController();
  bool _showSecondText =
      false; // State variable to control visibility of the second text

  @override
  void initState() {
    super.initState();
    // Start a timer to show the second text after the first animation completes
    // "Create your commitment" has 22 characters. 22 * 100ms = 2200ms. Add a small buffer.
    Future.delayed(const Duration(milliseconds: 2300), () {
      if (mounted) {
        setState(() {
          _showSecondText = true;
        });
      }
    });
  }

  List<Widget> get _onboardingPages => [
    Container(
      color: kBackgroundColor,
      child: Center(
        child: SizedBox(
          width: 250.0,
          child: DefaultTextStyle(
            style: const TextStyle(
              fontSize: 30.0,
              fontFamily: 'Agne',
              color: Colors.white,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedTextKit(
                  animatedTexts: [
                    TypewriterAnimatedText(
                      'Create your commitment',
                      textAlign: TextAlign.center,
                      textStyle: const TextStyle(
                        fontSize: 28.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      speed: const Duration(milliseconds: 100),
                    ),
                  ],
                  isRepeatingAnimation: false,
                  displayFullTextOnTap: true,
                ),
                // Add some spacing between the texts
                const SizedBox(height: 10),
                // Conditionally display the second AnimatedTextKit
                if (_showSecondText)
                  AnimatedTextKit(
                    animatedTexts: [
                      TypewriterAnimatedText(
                        'Let us know what you want to commit to.',
                        textAlign: TextAlign.center,
                        textStyle: const TextStyle(
                          fontSize: 18.0,
                          color: Colors.grey,
                        ),
                        speed: const Duration(milliseconds: 50),
                      ),
                    ],
                    isRepeatingAnimation: false,
                    displayFullTextOnTap: true,
                  ),
              ],
            ),
          ),
        ),
      ),
    ),
    Container(
      color: kBackgroundColor,
      child: const Center(
        child: Text(
          'Page 2',
          style: TextStyle(color: Colors.white, fontSize: 24),
        ),
      ),
    ),
    Container(
      color: kBackgroundColor,
      child: const Center(
        child: Text(
          'Page 3',
          style: TextStyle(color: Colors.white, fontSize: 24),
        ),
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(controller: _pageController, children: _onboardingPages),
          Positioned(
            bottom: 20,
            left: 20,
            child: SmoothPageIndicator(
              controller: _pageController,
              count: _onboardingPages.length,
              effect: const ExpandingDotsEffect(
                dotHeight: 10,
                dotWidth: 10,
                activeDotColor: Colors.white,
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: () {
                if (_pageController.page!.toInt() ==
                    _onboardingPages.length - 1) {
                  // Last page, handle navigation to home screen or login
                } else {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.ease,
                  );
                }
              },
              child: SvgPicture.asset('assets/Right.svg'),
            ),
          ),
        ],
      ),
    );
  }
}
