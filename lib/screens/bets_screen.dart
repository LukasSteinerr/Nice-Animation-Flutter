import 'package:flutter/material.dart';

class BetsScreen extends StatefulWidget {
  const BetsScreen({super.key});

  @override
  State<BetsScreen> createState() => _BetsScreenState();
}

class _BetsScreenState extends State<BetsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: const Center(child: Text('Bets Screen')));
  }
}
