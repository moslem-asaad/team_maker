import 'package:flutter/material.dart';
import 'package:team_maker/constants/routes.dart';
import 'package:team_maker/domain/entities/game.dart';
import 'package:team_maker/presentaion/constFunctions/format-date.dart';
import 'package:team_maker/presentaion/views/football/football.dart';
import 'package:team_maker/service/game_service.dart';
import 'package:team_maker/service/score_service.dart';

import '../../../domain/entities/score.dart';
import '../../../domain/entities/team.dart';

class GameView extends StatefulWidget {
  final Game game;
  final bool fromGenerated;
  const GameView({super.key, required this.game, required this.fromGenerated});

  @override
  State<GameView> createState() => _GameViewState();
}

class _GameViewState extends State<GameView> {
  late GameService _gameService;
  late ScoreService _scoreService;
  double cardsRatio = 0.6;
  bool isExtended = false;
  Team? selectedTeam1;
  Team? selectedTeam2;
  int scoreTeam1 = 0;
  int scoreTeam2 = 0;
  bool scoresVisible = true;

  @override
  void initState() {
    // TODO: implement initState
    _gameService = GameService();
    _scoreService = ScoreService();
    super.initState();
  }

  void _showAddScoreDialog() {
  setState(() {
    selectedTeam1 = null;
    selectedTeam2 = null;
    scoreTeam1 = 0;
    scoreTeam2 = 0;
  });

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          return AlertDialog(
            title: const Text('Add Score'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Padding(
                  padding: EdgeInsets.only(bottom: 10.0),
                  child: Text(
                    'Select the teams and enter their respective scores',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ),
                DropdownButtonFormField<Team>(
                  decoration: InputDecoration(
                    labelText: 'Select First Team',
                    labelStyle: const TextStyle(color: Colors.blue),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  items: widget.game.teams!.map((team) {
                    return DropdownMenuItem<Team>(
                      value: team,
                      child: Text(team.defaultName ?? 'Team'),
                    );
                  }).toList(),
                  onChanged: (team) {
                    setModalState(() {
                      selectedTeam1 = team;
                    });
                  },
                  value: selectedTeam1,
                  validator: (value) => value == null ? 'Please select a team' : null,
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<Team>(
                  decoration: InputDecoration(
                    labelText: 'Select Second Team',
                    labelStyle: const TextStyle(color: Colors.blue),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  items: widget.game.teams!.map((team) {
                    return DropdownMenuItem<Team>(
                      value: team,
                      child: Text(team.defaultName ?? 'Team'),
                    );
                  }).toList(),
                  onChanged: (team) {
                    setModalState(() {
                      selectedTeam2 = team;
                    });
                  },
                  value: selectedTeam2,
                  validator: (value) => value == null ? 'Please select a team' : null,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Score Team 1',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          labelStyle: const TextStyle(color: Colors.green),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          setModalState(() {
                            scoreTeam1 = int.tryParse(value) ?? 0;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Score Team 2',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          labelStyle: const TextStyle(color: Colors.green),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          setModalState(() {
                            scoreTeam2 = int.tryParse(value) ?? 0;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel', style: TextStyle(color: Colors.blue)),
              ),
              ElevatedButton(
                onPressed: () {
                  if (selectedTeam1 != null &&
                      selectedTeam2 != null &&
                      selectedTeam1 != selectedTeam2 &&
                      scoreTeam1 >= 0 &&
                      scoreTeam2 >= 0) {
                    _gameService
                        .addScore(
                          widget.game,
                          selectedTeam1!,
                          selectedTeam2!,
                          scoreTeam1,
                          scoreTeam2,
                        )
                        .then((_) {
                      setState(() {
                        // Refresh the scores display
                      });
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Score added successfully')),
                      );
                    }).catchError((error) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error adding score: $error')),
                      );
                    });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please select different teams and enter valid scores.'),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Save', style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      );
    },
  );
}


  void _showTeamPlayersDialog(Team team, Color color) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Players in ${team.defaultName ?? 'Team'}'),
          backgroundColor: color,
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              itemCount: team.players.length,
              itemBuilder: (context, index) {
                final player = team.players[index];
                return ListTile(
                  leading: CircleAvatar(
                    radius: 12,
                    child: Text('${index + 1}'),
                  ),
                  title: Text(player.fullName ?? 'Unnamed Player'),
                  subtitle: Text(
                    'Overall: ${player.overall?.toStringAsFixed(2) ?? 'N/A'}',
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _toggleCardRatio() {
    setState(() {
      if (isExtended) {
        cardsRatio = 0.6; // Collapsed state
      } else {
        cardsRatio = 0.4; // Extended state
      }
      isExtended = !isExtended;
    });
  }

  @override
  Widget build(BuildContext context) {
    
    String date = formatDate(widget.game.gameDate!);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Game'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Custom behavior for the Go Back button
            _customGoBackAction(context, widget.fromGenerated);
          },
        ),
        actions: [
          TextButton.icon(
            label: Text(isExtended ? 'Collapse' : 'Extend'),
            icon: Icon(isExtended ? Icons.expand_less : Icons.expand_more),
            onPressed: _toggleCardRatio,
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Text('Game Date: $date'),
            ),
            _scoreSection(),
            const SizedBox(height: 10),
            _teamsSection(),
          ],
        ),
      ),
    );
  }

  Widget _scoreSection() {
  List<Score> scores = widget.game.scores!;
  return AnimatedContainer(
    duration: const Duration(milliseconds: 300),
    height: scoresVisible ? 300 : 50,
    child: SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: const BorderRadius.all(Radius.circular(10)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Visibility(
                  visible: scoresVisible,
                  child: ElevatedButton.icon(
                    onPressed: _showAddScoreDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: const Text(
                      'Add Score',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      scoresVisible = !scoresVisible;
                    });
                  },
                  icon: Icon(
                    scoresVisible ? Icons.expand_less : Icons.expand_more,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Text(
              'Scores',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 10),
            scores.isNotEmpty
                ? Column(
                    children: scores.map((entry) {
                      final team1 = entry.team1;
                      final team2 = entry.team2;
                      final score1 = entry.team1_score;
                      final score2 = entry.team2_score;
                      return Card(
                        color: Colors.blue[50],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 4,
                        child: ListTile(
                          title: Text(
                            '${team1!.defaultName} VS ${team2!.defaultName}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          subtitle: Text(
                            '$score1 - $score2',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.green),
                                onPressed: () {
                                  // Logic for editing the score can go here
                                },
                                tooltip: 'Edit Score',
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  _confirmDeleteScore(entry);
                                },
                                tooltip: 'Delete Score',
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  )
                : const Center(
                    child: Text(
                      'No scores added yet.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ),
          ],
        ),
      ),
    ),
  );
}

void _confirmDeleteScore(Score score) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Delete Score'),
        content: const Text('Are you sure you want to delete this score?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel', style: TextStyle(color: Colors.blue)),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                widget.game.scores!.remove(score); // Remove the score entry
              });
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Score removed successfully')),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      );
    },
  );
}

  Widget _teamsSection() {
    List<Team> teams = widget.game.teams!;
    return Expanded(
      child: GridView.builder(
        itemCount: teams.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: cardsRatio, // Use the variable here
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
        ),
        itemBuilder: (context, teamIndex) {
          final team = teams[teamIndex];
          final colors = [
            Color.fromARGB(255, 109, 255, 170),
            Color.fromARGB(255, 255, 143, 109),
            Color.fromARGB(255, 109, 167, 255),
            Color.fromARGB(255, 177, 109, 255)
          ];
          return InkWell(
            onTap: () =>
                _showTeamPlayersDialog(team, colors[teamIndex % colors.length]),
            child: Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              color: colors[teamIndex % colors.length],
              elevation: 10.0,
              shadowColor: Colors.black54,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Team ${teamIndex + 1} (Overall: ${team.avgTeamRate?.toStringAsFixed(2) ?? 'N/A'})',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: ListView.builder(
                        itemCount: team.players.length,
                        itemBuilder: (context, playerIndex) {
                          final player = team.players[playerIndex];
                          return Container(
                            padding: EdgeInsets.symmetric(vertical: 7),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: colors[teamIndex % colors.length],
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 12,
                                  child: Text('${playerIndex + 1}'),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        player.fullName ?? 'Unnamed Player',
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                      Text(
                                        'Overall: ${player.overall?.toStringAsFixed(2) ?? 'N/A'}',
                                        style: const TextStyle(
                                            fontSize: 12, color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

void _customGoBackAction(BuildContext context, bool fromGenerated) {
  if (fromGenerated) {
    // Pop the stack until the Football screen is reached
    Navigator.popUntil(
      context,
      (route) {
        // Check if the route is for the Football screen
        return route.settings.name ==
            footballRout; // Replace 'FootballView' with the appropriate route name if using named routes
      },
    );
  } else {
    // Go back to the previous screen
    Navigator.pop(context);
  }
}
