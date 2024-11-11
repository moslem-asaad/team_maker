import 'package:flutter/material.dart';
import 'package:team_maker/constants/colors.dart';

class CreatePlayer extends StatefulWidget {
  Function(String, int, int, int) onSave;
  CreatePlayer({super.key, required this.onSave});

  @override
  State<CreatePlayer> createState() => _CreatePlayerState();
}

class _CreatePlayerState extends State<CreatePlayer> {
  final TextEditingController playerNameController = TextEditingController();
  int _attRating = 75;
  int _midRating = 75;
  int _defRating = 75;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Create New Player',
        style: TextStyle(color: boldBlue),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: playerNameController,
              decoration: const InputDecoration(
                labelText: 'Player Name',
                labelStyle: TextStyle(color: boldGreen),
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: boldGreen),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildSliderRow('Attack Rating:', _attRating, 1),
            _buildSliderRow('Midfield Rating:', _midRating, 2),
            _buildSliderRow('Defence Rating:', _defRating, 3),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              onPressed: _onSave,
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _onSave() {
    final String name = playerNameController.text;
    widget.onSave(name, _attRating, _midRating, _defRating);
    playerNameController.clear();
    Navigator.of(context).pop();
  }

  Widget _buildSliderRow(String label, int currentValue, int type) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label $currentValue',
            style: const TextStyle(fontSize: 16, color: boldBlue),
          ),
          Slider(
            value: currentValue.toDouble(),
            min: 1,
            max: 99,
            divisions: 98,
            label: currentValue.toString(),
            onChanged: (double value) {
              setState(() {
                if (type == 1) {
                  _attRating = value.toInt();
                } else if (type == 2) {
                  _midRating = value.toInt();
                } else if (type == 3) {
                  _defRating = value.toInt();
                }
              });
            },
            activeColor: Colors.green,
            inactiveColor: Colors.green[100],
          ),
        ],
      ),
    );
  }
}
