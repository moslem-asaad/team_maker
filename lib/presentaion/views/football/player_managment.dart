import 'package:flutter/material.dart';
import 'package:team_maker/domain/controllers/playerController.dart';
import 'package:team_maker/domain/entities/player.dart';
import 'package:team_maker/presentaion/constFunctions/edit_player_data_dialog.dart';
import 'package:team_maker/presentaion/constFunctions/show_player_dialog.dart';
import 'package:team_maker/service/player_service.dart';

class PlayerManagementScreen extends StatefulWidget {
  const PlayerManagementScreen({super.key});

  @override
  State<PlayerManagementScreen> createState() => _PlayerManagementScreenState();
}

class _PlayerManagementScreenState extends State<PlayerManagementScreen> {
  late final PlayerService _playerService;
  List<Player> _players = [];

  @override
  void initState() {
    super.initState();
    _playerService = PlayerService();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _playerService.initialize();
    setState(() {
      _players = _playerService.getAllPlayers();
    });
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
      setState(() {
        _players = _playerService.getAllPlayers();
      });
    });
  }

  Future<void> _editPlayer(int index) async {
    final player = _players[index];
    showEditPlayerDataDialog(
      context,
      player.fullName ?? '',
      player.attackRate ?? 75,
      player.midRate ?? 75,
      player.defRate ?? 75,
      (String name, int attackRate, int midRate, int defRate) async {
        await _playerService.editPlayer(
          index: index,
          name: name,
          attackRate: attackRate,
          midRate: midRate,
          defRate: defRate,
          id: player.id!,
        );
        setState(() {
          _players = _playerService.getAllPlayers();
        });
      },
    );
  }

  Future<void> _deletePlayer(Player player) async {
    await _playerService.deletePlayer(player);
    setState(() {
      _players = _playerService.getAllPlayers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: GridView.count(
          crossAxisCount: 2, // 2 بطاقات في كل صف
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1.2, // اضبط حسب محتوى البطاقة
          children: List.generate(_players.length, (index) {
            final player = _players[index];
            return InkWell(
              onTap: () => _editPlayer(index),
              borderRadius: BorderRadius.circular(12),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                color: Colors.grey[100],
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        player.fullName ?? 'Unknown Player',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'Overall: ${player.overall?.toStringAsFixed(2) ?? 'N/A'}',
                        style: TextStyle(fontSize: 14),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deletePlayer(player),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addPlayer,
        child: const Icon(Icons.add),
      ),
    );
  }
}
