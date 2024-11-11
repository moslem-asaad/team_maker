import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:team_maker/constants/colors.dart';
import 'package:team_maker/constants/routes.dart';
import 'package:team_maker/domain/entities/game.dart';
import 'package:team_maker/presentaion/constFunctions/show_player_dialog.dart';
import 'package:team_maker/presentaion/views/football/create_game.dart';
import 'package:team_maker/presentaion/views/football/game.dart';
import 'package:team_maker/service/game_service.dart';
import 'package:team_maker/service/score_service.dart';

import '../../../service/player_service.dart';
import '../../constFunctions/format-date.dart';

class Football extends StatefulWidget {
  const Football({super.key});

  @override
  State<Football> createState() => _FootballState();
}

class _FootballState extends State<Football> {
  int numOfGames = 5;
  late final GameService _gameService;
  late final PlayerService _playerService;
  //late final ScoreService _scoreService;
  List<Game> _games = [];

  @override
  void initState() {
    //_scoreService = ScoreService();
    //_scoreService.deleteAllScores();
    _gameService = GameService();
    //_gameService.deleteAllGames();
    super.initState();
    _playerService = PlayerService();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _playerService.initialize();
    await _gameService.initialize();
    setState(() {
      _games = _gameService.getAllGames();
      _games = _games.reversed.toList();
    });
  }

  void _navigateToAddGamePage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              CreateGameScreen()), // Replace with your actual page
    ).then((_) {
      // This will be called when returning to this page
      _refreshData();
    });
  }

  Future<void> _refreshData() async {
    // Refresh data after returning to the page
    await _initializeData();
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
        actions: [
          ButtonBar(
            children: [
              TextButton(
                  onPressed: () {
                    ScoreService().deleteAllScores();
                    _gameService.deleteAllGames();
                  },
                  child: Text('delete all data')),
            ],
          )
        ],
      ),
      body: Column(
        children: [
          // Manage Games Section
          if (_games.length > 0) _gamesSection(),
          const Divider(height: 1),
          // Manage Players Section
          _managePlayersSection(),
          // Quick Actions Section
          _quickActionsSection(),
        ],
      ),
    );
  }

  Widget _gamesSection() {
    return Expanded(
      flex: 3,
      child: Container(
        color: Color.fromARGB(255, 230, 230, 230),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Manage Games',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: _games.length, // Example: 5 previous games
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5.0),
                    child: ElevatedButton(
                      onPressed: () {
                        // Action for tapping on the game item
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GameView(
                              game: _games[index],
                              fromGenerated: false,
                            ), // Replace with your actual screen
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding:
                            const EdgeInsets.all(0), // Remove default padding
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
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
                                  'Date:  ${formatDate(_games[index].gameDate!)}',
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
    );
  }

  Widget _managePlayersSection() {
    return Expanded(
      flex: 1,
      child: Container(
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.people, size: 40, color: Colors.blue),
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
    );
  }

  Widget _quickActionsSection() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      color: Colors.blue[50],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton.icon(
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text("Create New Game"),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            onPressed: () {
              _navigateToAddGamePage(context);
            },
          ),
          ElevatedButton.icon(
              icon: const Icon(Icons.person_add, color: Colors.white),
              label: const Text("Create New Player"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: _addPlayer),
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
