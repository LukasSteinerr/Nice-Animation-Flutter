import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:test/utils/colors.dart';

class NewBetsScreen extends StatefulWidget {
  const NewBetsScreen({super.key});

  @override
  State<NewBetsScreen> createState() => _NewBetsScreenState();
}

class _NewBetsScreenState extends State<NewBetsScreen> {
  final PageController _pageController = PageController();
  final List<Widget> _onboardingPages = [
    Container(
      color: kBackgroundColor,
      child: const Center(
        child: Text(
          'Page 1',
          style: TextStyle(color: Colors.white, fontSize: 24),
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
