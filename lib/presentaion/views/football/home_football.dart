import 'package:flutter/material.dart';
import 'package:team_maker/constants/colors.dart';
import 'package:team_maker/constants/icons.dart';
import 'package:team_maker/domain/entities/player.dart';
import 'package:team_maker/presentaion/views/football/create_game.dart';
import 'package:team_maker/presentaion/views/football/game.dart';
import 'package:team_maker/presentaion/views/football/player_managment.dart';
import 'package:team_maker/presentaion/views/football/widgets/game_card.dart';

import '../../../domain/entities/game.dart';
import '../../../service/game_service.dart';
import '../../../service/player_service.dart';
import '../../constFunctions/format-date.dart';
import '../../constFunctions/show_player_dialog.dart';

class HomeScreenFootball extends StatefulWidget {
  @override
  _HomeScreenFootballState createState() => _HomeScreenFootballState();
}

class _HomeScreenFootballState extends State<HomeScreenFootball>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late final GameService _gameService;
  late final PlayerService _playerService;
  List<Game> _games = [];
  late TabController _tabController;
  String _title = 'Games'; // Initial title

  @override
  void initState() {
    //_scoreService = ScoreService();
    //_scoreService.deleteAllScores();
    _gameService = GameService();
    //_gameService.deleteAllGames();
    super.initState();
    _playerService = PlayerService();
    _initializeData();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _title = _tabController.index == 0 ? 'Games' : 'Players';
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Number of tabs
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.grey[300],
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.menu, color: Colors.black),
            onPressed: () {
              // Add drawer functionality here
            },
          ),
          title: Text(
            _title,
            style: TextStyle(
              fontFamily: 'IrishGrover',
              fontSize: 32,
              color: Colors.black,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(Icons.person, color: Colors.black),
              onPressed: () {
                // Add profile functionality here
              },
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            labelColor: Colors.blue,
            unselectedLabelColor: Colors.black,
            indicatorColor: Colors.blue,
            tabs: [
              Tab(text: 'Games'),
              Tab(text: 'Players'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            gamesTap(context),
            //_gamesSection(),
            playersTap(context),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            if (_tabController.index == 0) {
              _navigateToAddGamePage(context);
            } else {
              _addPlayer();
            }
          },
          label: Text(
            _tabController.index == 0 ? 'Create New Game' : 'Create New Player',
            style: TextStyle(
              fontFamily: 'IrishGrover',
              fontSize: 16,
            ),
          ),
          backgroundColor: Colors.blue,
          icon: Icon(Icons.add),
        ),
      ),
    );
  }

  Widget gamesTap(BuildContext context) {
    return Stack(
      children: [
        // Centered background image
        Center(
          child: Opacity(
            opacity: 0.5,
            child: Image.asset(
              footballPath, // Replace with your image path
              width: 300,
              height: 300,
            ),
          ),
        ),
        // Foreground list and other widgets
        Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _games.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: gameCard(
                      imagePath: footballPath,
                      title: 'Game ${index + 1}',
                      date: formatDate(_games[index].gameDate!),
                      onDelete: () async {
                        await _gameService.deleteGameByInstance(_games[index]);
                        _refreshData();
                      },
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GameView(
                              game: _games[index],
                              fromGenerated: false,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget playersTap(BuildContext context) {
    return PlayerManagementScreen();
  }

  /*Widget playersTap(BuildContext context) {
  final players = _playerService.getAllPlayers();

  if (players.isEmpty) {
    return Center(child: Text('No players available'));
  }

  return Padding(
    padding: const EdgeInsets.all(12.0),
    child: GridView.count(
      crossAxisCount: 3,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 0.75, // لتقليل الارتفاع النسبي للبطاقة
      children: List.generate(players.length, (index) {
        final player = players[index];
        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          color: Colors.grey[100],
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Center(
                    child: Text(
                      player.fullName!,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    _showPlayerDetailsDialog(context, player);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    textStyle: TextStyle(fontSize: 12),
                  ),
                  child: Text('Details'),
                ),
                IconButton(
                  icon: Icon(Icons.delete, size: 20, color: Colors.red),
                  onPressed: () async {
                    await _playerService.deletePlayer(player);
                    setState(() {}); // تحديث بعد الحذف
                  },
                ),
              ],
            ),
          ),
        );
      }),
    ),
  );
}


  void _showPlayerDetailsDialog(BuildContext context, Player player) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(player.fullName!),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Attack: ${player.attackRate}'),
            Text('Midfield: ${player.midRate}'),
            Text('Defense: ${player.defRate}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }*/
}
