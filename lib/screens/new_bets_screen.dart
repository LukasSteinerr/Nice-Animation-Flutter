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

  // Form controllers
  final TextEditingController _nameController = TextEditingController();
  String _frequency = 'one time'; // Default frequency
  DateTime? _endDate; // Selected end date

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
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 60), // Space from top
            SizedBox(
              width: double.infinity,
              child: DefaultTextStyle(
                style: const TextStyle(
                  fontSize: 30.0,
                  fontFamily: 'Agne',
                  color: Colors.white,
                ),
                child: Column(
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
            const SizedBox(height: 40), // Space between text and form
            // Form fields
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name field
                    const Text(
                      'Name',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "E.g. 'Get a job'",
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _nameController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.1),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        hintText: 'Enter commitment name',
                        hintStyle: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Frequency field
                    const Text(
                      'Frequency',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Choose your frequency',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _frequency,
                          dropdownColor: Colors.grey[800],
                          style: const TextStyle(color: Colors.white),
                          icon: const Icon(
                            Icons.arrow_drop_down,
                            color: Colors.white,
                          ),
                          isExpanded: true,
                          items: const [
                            DropdownMenuItem(
                              value: 'one time',
                              child: Text('One time'),
                            ),
                            DropdownMenuItem(
                              value: 'daily',
                              child: Text('Daily'),
                            ),
                            DropdownMenuItem(
                              value: 'weekly',
                              child: Text('Weekly'),
                            ),
                          ],
                          onChanged: (String? newValue) {
                            setState(() {
                              _frequency = newValue!;
                            });
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Duration field
                    const Text(
                      'Duration',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Choose end date',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: _endDate ?? DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null && picked != _endDate) {
                          setState(() {
                            _endDate = picked;
                          });
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _endDate != null
                                  ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                                  : 'Select end date',
                              style: TextStyle(
                                color: _endDate != null
                                    ? Colors.white
                                    : Colors.white.withOpacity(0.5),
                              ),
                            ),
                            const Icon(
                              Icons.calendar_today,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
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
