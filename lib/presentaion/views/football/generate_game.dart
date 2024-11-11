import 'package:flutter/material.dart';
import 'package:team_maker/domain/entities/game.dart';
import 'package:team_maker/domain/entities/team.dart';
import 'package:team_maker/domain/entities/player.dart';
import 'package:team_maker/presentaion/views/football/game.dart';
import 'package:team_maker/service/game_service.dart';
import 'package:team_maker/service/team_service.dart';

class GeneratedTeamsScreen extends StatefulWidget {
  final Game game;

  const GeneratedTeamsScreen({Key? key, required this.game}) : super(key: key);

  @override
  _GeneratedTeamsScreenState createState() => _GeneratedTeamsScreenState();
}

class _GeneratedTeamsScreenState extends State<GeneratedTeamsScreen> {
  late List<Team> teams;
  double cardsRatio = 0.6;
  bool isExtended = false;
  late final TeamService _teamService;
  late final GameService _gameService;
  Map<String, bool> selectedPlayers = {}; // Map to track the selection state

  @override
  void initState() {
    _teamService = TeamService();
    _gameService = GameService();
    super.initState();
    teams = widget.game.teams!;

    // Initialize the selection state for each player
    for (var team in teams) {
      for (var player in team.players) {
        selectedPlayers[player.id!] = false;
      }
    }
  }

  /*void _swapPlayers() {
  // Find selected players and their teams
  List<Map<String, dynamic>> selectedPlayersData = [];

  for (int teamIndex = 0; teamIndex < teams.length; teamIndex++) {
    for (var player in teams[teamIndex].players) {
      if (selectedPlayers[player.id!] == true) {
        selectedPlayersData.add({
          'teamIndex': teamIndex,
          'player': player,
        });
      }
    }
  }

  // Check if exactly two players are selected from different teams
  if (selectedPlayersData.length == 2 &&
      selectedPlayersData[0]['teamIndex'] != selectedPlayersData[1]['teamIndex']) {
    int team1Index = selectedPlayersData[0]['teamIndex'];
    int team2Index = selectedPlayersData[1]['teamIndex'];
    Player player1 = selectedPlayersData[0]['player'];
    Player player2 = selectedPlayersData[1]['player'];
    print('team1 indx ${team1Index} - team2 indx ${team2Index}');
    // Call the service to swap players
    _teamService.swapPlayers(teams[team1Index], teams[team2Index], player1, player2).then((_) {
      
      setState(() {
        // Update the teams after swapping
        teams = widget.game.teams!;
        
        // Reset the selection states after swapping
        selectedPlayers[player1.id!] = false;
        selectedPlayers[player2.id!] = false;
      });
    }).catchError((error) {
      // Handle errors if necessary
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error swapping players: $error')),
      );
    });
  } else {
    // Show a warning if the selection criteria are not met
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Select exactly two players from different teams to swap.')),
    );
  }
}*/

void _swapPlayers() {
  // Find selected players and their teams
  Map<int, List<Player>> selectedPlayersByTeam = {};

  for (int teamIndex = 0; teamIndex < teams.length; teamIndex++) {
    for (var player in teams[teamIndex].players) {
      if (selectedPlayers[player.id!] == true) {
        if (selectedPlayersByTeam.containsKey(teamIndex)) {
          selectedPlayersByTeam[teamIndex]!.add(player);
        } else {
          selectedPlayersByTeam[teamIndex] = [player];
        }
      }
    }
  }
  

  // Check if exactly two teams are involved and both have an equal number of selected players
  if (selectedPlayersByTeam.keys.length == 2) {
    List<int> teamIndices = selectedPlayersByTeam.keys.toList();
    int team1Index = teamIndices[0];
    int team2Index = teamIndices[1];
    List<Player> team1Players = selectedPlayersByTeam[team1Index]!;
    List<Player> team2Players = selectedPlayersByTeam[team2Index]!;

    if (team1Players.length == team2Players.length) {
      // Call the service to swap players
      _teamService.swapManyPlayers(teams[team1Index], teams[team2Index], team1Players, team2Players).then((_) {
        setState(() {
          // Update the teams after swapping
          teams = widget.game.teams!;

          // Reset the selection states after swapping
          for (var player in team1Players) {
            selectedPlayers[player.id!] = false;
          }
          for (var player in team2Players) {
            selectedPlayers[player.id!] = false;
          }
        });
      }
      ).catchError((error) {
        // Handle errors if necessary
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error swapping players: $error')),
        );
      });
    } else {
      // Show a warning if the number of selected players does not match
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('The number of selected players must be equal in both teams.')),
      );
    }
  } else {
    // Show a warning if the selection criteria are not met
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Select players from exactly two different teams to swap.')),
    );
  }
}


  void _regenerateTeams() {
    setState(() {
      teams = widget.game.generateTeams(); // Regenerate the teams within the game

      // Reset the selection state after regenerating
      selectedPlayers.clear();
      for (var team in teams) {
        for (var player in team.players) {
          selectedPlayers[player.id!] = false;
        }
      }
    });
  }

  void _saveGame() async{
    await _gameService.saveGame(widget.game);
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('The game saved succefully')),
      );
    Navigator.push(context, MaterialPageRoute(builder: (context){
      return GameView(game: widget.game,fromGenerated: true,);
    }));
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generated Teams'),
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
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
                    onTap: () =>  _showTeamPlayersDialog(team,colors[teamIndex%colors.length]),
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
                                  final isSelected = selectedPlayers[player.id] ?? false;
                                  return InkWell(
                                    onTap: () {
                                      setState(() {
                                        selectedPlayers[player.id!] = !isSelected; // Toggle selection state
                                          print(player.id!);
                                      });
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(vertical: 7),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: isSelected
                                            ? const Color.fromARGB(255, 54, 69, 95).withOpacity(0.3) // Highlight color
                                            : colors[teamIndex % colors.length],
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
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  player.fullName ?? 'Unnamed Player',
                                                  style: const TextStyle(fontSize: 14),
                                                ),
                                                Text(
                                                  'Overall: ${player.overall?.toStringAsFixed(2) ?? 'N/A'}',
                                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
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
            ),
            
            Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            //color: Colors.blue[50],
            child: Wrap(
              spacing: 10, // Horizontal space between buttons
              runSpacing: 10, // Vertical space between lines if they wrap
              alignment: WrapAlignment.center,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.save, color: Colors.white),
                  label: const Text("Save Game"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 16),
                        elevation: 9
                  ),
                  onPressed: _saveGame,
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.swap_horiz, color: Colors.white),
                  label: const Text("Swap players"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 16),
                        elevation: 9
                  ),
                  onPressed: _swapPlayers,
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.redo, color: Colors.white),
                  label: const Text("Regenerate Teams"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 235, 163, 122),
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 16),
                        elevation: 9
                  ),
                  onPressed: _regenerateTeams,
                ),
                
              ],
            ),
          ),
          ],
        ),
      ),
    );
  }
}

