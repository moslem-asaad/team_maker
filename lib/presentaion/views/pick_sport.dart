import 'package:flutter/material.dart';

class PickSport extends StatefulWidget {
  const PickSport({super.key});

  @override
  State<PickSport> createState() => _PickSportState();
}

class _PickSportState extends State<PickSport> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pick a Sport'),
      ),
      backgroundColor: Colors.amber,
      body: Center(
        child: const Text(
          'Select your favorite sport',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
