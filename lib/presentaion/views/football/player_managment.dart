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
    showPlayerDataDialog(context, (String name, int attackRate, int midRate, int defRate) async {
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

  Future<void> _deletePlayer(int index) async {
    await _playerService.deletePlayer(index);
    setState(() {
      _players = _playerService.getAllPlayers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Player Management')),
      body: ListView.builder(
        itemCount: _players.length,
        itemBuilder: (context, index) {
          final player = _players[index];
          return ListTile(
            title: Text(player.fullName ?? 'Unknown Player'),
            subtitle: Text('Overall: ${player.overall?.toStringAsFixed(2) ?? 'N/A'}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _editPlayer(index),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _deletePlayer(index),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addPlayer,
        child: const Icon(Icons.add),
      ),
    );
  }
}
