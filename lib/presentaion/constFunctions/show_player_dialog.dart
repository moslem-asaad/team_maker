// player_data_dialog.dart
import 'package:flutter/material.dart';

void showPlayerDataDialog(BuildContext context, Function(String, int, int, int) onSave) {
  final TextEditingController playerNameController = TextEditingController();
  final TextEditingController attackRateController = TextEditingController();
  final TextEditingController defenceRateController = TextEditingController();
  final TextEditingController midfieldRateController = TextEditingController();

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Add New Player'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: playerNameController,
              decoration: const InputDecoration(labelText: 'Player Name'),
            ),
            TextFormField(
              controller: attackRateController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Attack Rate'),
            ),
            TextFormField(
              controller: defenceRateController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Defence Rate'),
            ),
            TextFormField(
              controller: midfieldRateController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Midfield Rate'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              playerNameController.clear();
              attackRateController.clear();
              defenceRateController.clear();
              midfieldRateController.clear();
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final String name = playerNameController.text;
              final int attackRate = int.tryParse(attackRateController.text) ?? 0;
              final int defenceRate = int.tryParse(defenceRateController.text) ?? 0;
              final int midfieldRate = int.tryParse(midfieldRateController.text) ?? 0;

              onSave(name, attackRate, midfieldRate, defenceRate);

              playerNameController.clear();
              attackRateController.clear();
              defenceRateController.clear();
              midfieldRateController.clear();
              Navigator.of(context).pop();
            },
            child: const Text('Save'),
          ),
        ],
      );
    },
  );
}
