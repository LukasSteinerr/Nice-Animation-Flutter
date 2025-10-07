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
  String _animatedText = 'Create your commitment'; // Initial animated text
  String _durationText = ''; // Text for duration information
  String _difficultyText = ''; // Text for difficulty information
  bool _isUserTyping = false; // Track if user is typing
  bool _hasAnimated = false; // Track if animation has already played

  // Form controllers
  final TextEditingController _nameController = TextEditingController();
  String _frequency = 'one time'; // Default frequency
  String _difficulty = 'Medium'; // Default difficulty
  DateTime? _endDate; // Selected end date

  @override
  void initState() {
    super.initState();

    // Add listener to name controller
    _nameController.addListener(_onNameChanged);
  }

  @override
  void dispose() {
    _nameController.removeListener(_onNameChanged);
    _nameController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onNameChanged() {
    final text = _nameController.text.trim();
    _updateCommitmentText(text);
  }

  void _updateCommitmentText(String text) {
    setState(() {
      if (text.isEmpty) {
        _animatedText = 'Create your commitment';
        _durationText = '';
        _difficultyText = '';
        _isUserTyping = false;
        _hasAnimated = false; // Reset animation state when text is empty
      } else {
        _animatedText = 'I commit to $text';
        _isUserTyping = true;

        // Update duration text if end date is selected
        if (_endDate != null) {
          _updateDurationText();
        } else {
          _durationText = '';
          _difficultyText = '';
        }

        if (!_hasAnimated) {
          _hasAnimated = true; // Mark that animation has played once
        }
      }
    });
  }

  void _updateDurationText() {
    if (_endDate == null) {
      setState(() {
        _durationText = '';
        _difficultyText = '';
      });
      return;
    }

    final String formattedDate =
        '${_endDate!.day} ${_getMonthName(_endDate!.month)} ${_endDate!.year}';

    setState(() {
      switch (_frequency) {
        case 'one time':
          _durationText = 'by $formattedDate';
          _difficultyText = '';
          break;
        case 'daily':
          _durationText = 'Daily until $formattedDate';
          _difficultyText = 'Difficulty: $_difficulty';
          break;
        case 'weekly':
          _durationText = 'Weekly until $formattedDate';
          _difficultyText = 'Difficulty: $_difficulty';
          break;
        default:
          _durationText = '';
          _difficultyText = '';
      }
    });
  }

  String _getMonthName(int month) {
    const monthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return monthNames[month - 1];
  }

  List<Widget> get _onboardingPages => [
    Container(
      color: kBackgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 90), // Adjusted space from top
            SizedBox(
              width: double.infinity,
              height:
                  115, // Reduced height to prevent pushing content down when text wraps
              child: DefaultTextStyle(
                style: const TextStyle(
                  fontSize: 30.0,
                  fontFamily: 'Agne',
                  color: Colors.white,
                ),
                child: Column(
                  children: [
                    // Show animated text only when animation should play
                    if (!_isUserTyping || (_isUserTyping && !_hasAnimated))
                      AnimatedTextKit(
                        key: ValueKey(
                          _isUserTyping
                              ? 'typing_animation'
                              : 'initial_animation',
                        ), // Key to control animation
                        animatedTexts: [
                          TypewriterAnimatedText(
                            _animatedText,
                            textAlign: TextAlign.center,
                            textStyle: const TextStyle(
                              fontSize: 26.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            speed: const Duration(milliseconds: 100),
                          ),
                        ],
                        isRepeatingAnimation: false,
                        displayFullTextOnTap: true,
                        onFinished: () {
                          if (_isUserTyping) {
                            setState(() {
                              _hasAnimated = true;
                            });
                          }
                        },
                      ),
                    // Show static text after animation has played
                    if (_isUserTyping && _hasAnimated)
                      Column(
                        children: [
                          Text(
                            _animatedText,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 26.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          // Show duration text if available
                          if (_durationText.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                _durationText,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 16.0,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          // Show difficulty text if available
                          if (_difficultyText.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                _difficultyText,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 16.0,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 5), // Reduced space between text and form
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

                    const SizedBox(height: 12), // Reduced spacing
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
                              // Update duration text if both name and end date are set
                              if (_nameController.text.trim().isNotEmpty &&
                                  _endDate != null) {
                                _updateDurationText();
                              }
                            });
                          },
                        ),
                      ),
                    ),

                    // Difficulty field (only show for daily and weekly)
                    if (_frequency == 'daily' || _frequency == 'weekly') ...[
                      const SizedBox(height: 12), // Reduced spacing
                      Row(
                        children: [
                          const Text(
                            'Difficulty',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    backgroundColor: Colors.grey[800],
                                    title: const Text(
                                      'Difficulty',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    content: const Text(
                                      'Determines what percentage of your commitment needs to be reached to succeed.',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    actions: <Widget>[
                                      TextButton(
                                        child: const Text(
                                          'Close',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            child: const Icon(
                              Icons.info_outline,
                              color: Colors.grey,
                              size: 16,
                            ),
                          ),
                        ],
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
                            value: _difficulty,
                            dropdownColor: Colors.grey[800],
                            style: const TextStyle(color: Colors.white),
                            icon: const Icon(
                              Icons.arrow_drop_down,
                              color: Colors.white,
                            ),
                            isExpanded: true,
                            items: const [
                              DropdownMenuItem(
                                value: 'Easy',
                                child: Text('Easy (60%)'),
                              ),
                              DropdownMenuItem(
                                value: 'Medium',
                                child: Text('Medium (80%)'),
                              ),
                              DropdownMenuItem(
                                value: 'Hard',
                                child: Text('Hard (100%)'),
                              ),
                            ],
                            onChanged: (String? newValue) {
                              setState(() {
                                _difficulty = newValue!;
                                // Update duration text if both name and end date are set
                                if (_nameController.text.trim().isNotEmpty &&
                                    _endDate != null) {
                                  _updateDurationText();
                                }
                              });
                            },
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 12), // Reduced spacing
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
                            // Update duration text if name is not empty
                            if (_nameController.text.trim().isNotEmpty) {
                              _updateDurationText();
                            }
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
