// player_service.dart
import 'package:flutter/material.dart';
import '../domain/controllers/playerController.dart';
import '../domain/entities/player.dart';

class PlayerService {
  final PlayerController _playerController;

  PlayerService(this._playerController);

  // Load players initially
  Future<void> initialize() async {
    await _playerController.loadPlayers();
  }

  // Add a new player
  Future<void> addPlayer({
    required String name,
    required int attackRate,
    required int midRate,
    required int defRate,
  }) async {
    Player newPlayer = Player(name, attackRate, midRate, defRate);
    await _playerController.addPlayer(newPlayer);
  }

  // Get all players
  List<Player> getAllPlayers() {
    return _playerController.getAllPlayers();
  }

  // Edit an existing player
  Future<void> editPlayer({
    required int index,
    required String name,
    required int attackRate,
    required int midRate,
    required int defRate,
  }) async {
    Player updatedPlayer = Player(name, attackRate, midRate, defRate);
    await _playerController.editPlayer(index, updatedPlayer);
  }

  // Delete a player by index
  Future<void> deletePlayer(int index) async {
    await _playerController.deletePlayer(index);
  }

  // Additional service logic (if needed) can go here
}
