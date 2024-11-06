import 'package:flutter/material.dart';
import '../../../domain/controllers/teamController.dart';
import '../../../domain/entities/team.dart';
import '../../../service/team_service.dart';


class Game extends StatefulWidget {
  const Game({super.key});

  @override
  State<Game> createState() => _GameState();
}

class _GameState extends State<Game> {
  late final TeamService _teamService;
  List<Team> _teams = [];
  Team? _selectedTeam1;
  Team? _selectedTeam2;
  final TextEditingController _scoreTeam1Controller = TextEditingController();
  final TextEditingController _scoreTeam2Controller = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  DateTime _matchDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    final teamController = TeamController();
    _teamService = TeamService(teamController);
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _teamService.initialize();
    setState(() {
      _teams = _teamService.getAllTeams();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Game Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Team Selection
            const Text('Select Teams:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            DropdownButton<Team>(
              hint: const Text("Select Team 1"),
              value: _selectedTeam1,
              onChanged: (Team? newValue) {
                setState(() {
                  _selectedTeam1 = newValue;
                });
              },
              items: _teams.map((Team team) {
                return DropdownMenuItem<Team>(
                  value: team,
                  child: Text(team.defaultName ?? 'Unnamed Team'),
                );
              }).toList(),
            ),
            DropdownButton<Team>(
              hint: const Text("Select Team 2"),
              value: _selectedTeam2,
              onChanged: (Team? newValue) {
                setState(() {
                  _selectedTeam2 = newValue;
                });
              },
              items: _teams.map((Team team) {
                return DropdownMenuItem<Team>(
                  value: team,
                  child: Text(team.defaultName ?? 'Unnamed Team'),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Final Score Input
            const Text('Final Score:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _scoreTeam1Controller,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: _selectedTeam1?.defaultName ?? "Team 1 Score",
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _scoreTeam2Controller,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: _selectedTeam2?.defaultName ?? "Team 2 Score",
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Played Duration
            TextField(
              controller: _durationController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Played Duration (in minutes)'),
            ),
            const SizedBox(height: 20),

            // Location
            TextField(
              controller: _locationController,
              decoration: const InputDecoration(labelText: 'Location'),
            ),
            const SizedBox(height: 20),

            // Match Date
            Row(
              children: [
                const Text('Match Date:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(width: 10),
                TextButton(
                  onPressed: () async {
                    DateTime? selectedDate = await showDatePicker(
                      context: context,
                      initialDate: _matchDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                    if (selectedDate != null) {
                      setState(() {
                        _matchDate = selectedDate;
                      });
                    }
                  },
                  child: Text(
                    "${_matchDate.toLocal()}".split(' ')[0],
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),

            const Spacer(),

            // Save Button
            Center(
              child: ElevatedButton(
                onPressed: _saveGameDetails,
                child: const Text('Save Game Details'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveGameDetails() {
    // Collect the data from the input fields
    String team1Score = _scoreTeam1Controller.text;
    String team2Score = _scoreTeam2Controller.text;
    String duration = _durationController.text;
    String location = _locationController.text;

    // Display a confirmation (or save the details as required)
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Game Details Saved'),
        content: Text(
          'Teams: ${_selectedTeam1?.defaultName ?? "Team 1"} vs ${_selectedTeam2?.defaultName ?? "Team 2"}\n'
          'Score: $team1Score - $team2Score\n'
          'Duration: $duration minutes\n'
          'Location: $location\n'
          'Date: ${_matchDate.toLocal()}'.split(' ')[0],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
