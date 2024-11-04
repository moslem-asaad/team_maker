// player_controller.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:team_maker/domain/entities/player.dart';

class PlayerController {
  static const String _playersKey = 'players';
  List<Player> _players = [];

  // Load players from local storage
  Future<void> loadPlayers() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? playersJson = prefs.getString(_playersKey);
    if (playersJson != null) {
      List<dynamic> playerList = json.decode(playersJson);
      _players = playerList.map((json) => Player.fromJson(json)).toList();
    }
  }

  // Save players to local storage
  Future<void> _savePlayers() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String playersJson = json.encode(_players.map((p) => p.toJson()).toList());
    await prefs.setString(_playersKey, playersJson);
  }

  // Add a player
  Future<void> addPlayer(Player player) async {
    _players.add(player);
    await _savePlayers();
  }

  // Get all players
  List<Player> getAllPlayers() {
    return _players;
  }

  // Edit a player
  Future<void> editPlayer(int index, Player updatedPlayer) async {
    if (index >= 0 && index < _players.length) {
      _players[index] = updatedPlayer;
      await _savePlayers();
    }
  }

  // Delete a player
  Future<void> deletePlayer(int index) async {
    if (index >= 0 && index < _players.length) {
      _players.removeAt(index);
      await _savePlayers();
    }
  }
}
