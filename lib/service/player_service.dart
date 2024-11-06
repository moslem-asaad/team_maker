import 'package:flutter/material.dart';
import '../domain/controllers/playerController.dart';
import '../domain/entities/player.dart';

class PlayerService {
  // Private constructor
  PlayerService._privateConstructor(this._playerController);

  // Static instance of PlayerService
  static final PlayerService _instance = PlayerService._privateConstructor(PlayerController());

  // Factory constructor to return the singleton instance
  factory PlayerService() {
    return _instance;
  }

  final PlayerController _playerController;

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
    await _playerController.addPlayer(name, attackRate, midRate, defRate);
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
    required String id,
  }) async {
    await _playerController.editPlayer(index, name, attackRate, midRate, defRate, id);
  }

  // Delete a player by index
  Future<void> deletePlayer(int index) async {
    await _playerController.deletePlayer(index);
  }
}
