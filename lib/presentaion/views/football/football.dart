import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:team_maker/constants/colors.dart';
import 'package:team_maker/constants/routes.dart';
import 'package:team_maker/presentaion/constFunctions/my_text_field.dart';
import 'package:team_maker/presentaion/constFunctions/show_player_dialog.dart';
import 'package:team_maker/presentaion/views/football/create_game.dart';

import '../../../domain/controllers/playerController.dart';
import '../../../service/player_service.dart';

class Football extends StatefulWidget {
  const Football({super.key});

  @override
  State<Football> createState() => _FootballState();
}

class _FootballState extends State<Football> {
  int numOfGames = 5;
  late final TextEditingController playerName = TextEditingController();

  late final PlayerService _playerService;

  @override
  void initState() {
    super.initState();
    _playerService = PlayerService();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _playerService.initialize();
  }

  Future<void> _addPlayer() async {
    showPlayerDataDialog(context,
        (String name, int attackRate, int midRate, int defRate) async {
      await _playerService.addPlayer(
        name: name,
        attackRate: attackRate,
        midRate: midRate,
        defRate: defRate,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mainColor,
      appBar: AppBar(
        title: const Text('Football Management'),
      ),
      body: Column(
        children: [
          // Manage Games Section
          if (numOfGames > 0)
            Expanded(
              flex: 3,
              child: Container(
                color: Color.fromARGB(255, 230, 230, 230),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Manage Games',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: ListView.builder(
                        itemCount: numOfGames, // Example: 5 previous games
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5.0),
                            child: ElevatedButton(
                              onPressed: () {
                                // Action for tapping on the game item
                                print('Game ${index + 1} tapped');
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                padding: const EdgeInsets.all(
                                    0), // Remove default padding
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side: BorderSide(color: Colors.grey[300]!),
                                ),
                                elevation: 5,
                                shadowColor: Colors.grey.withOpacity(0.3),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 15, horizontal: 20),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Game ${index + 1}',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                        Text(
                                          'Opponent: Team ${index + 1}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Icon(
                                      Icons.arrow_forward_ios,
                                      size: 16,
                                      color: Colors.blue,
                                    ),
                                  ],
                                ),
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
          const Divider(height: 1),
          // Manage Players Section
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon:
                        const Icon(Icons.people, size: 40, color: Colors.blue),
                    onPressed: () {
                      // Navigate to player management screen
                      Navigator.pushNamed(context, playerManegmentRout);
                    },
                  ),
                  const Text(
                    'Manage Players',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ),
          // Quick Actions Section
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            color: Colors.blue[50],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text("Add New Game"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const CreateGameScreen()),
                    );
                  },
                ),
                ElevatedButton.icon(
                    icon: const Icon(Icons.person_add, color: Colors.white),
                    label: const Text("Add New Player"),
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    onPressed: _addPlayer),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper Widget for Stat Cards
  Widget _buildStatCard(String title, String value, IconData icon) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 30, color: Colors.blue),
        const SizedBox(height: 5),
        Text(title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        const SizedBox(height: 3),
        Text(value, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
