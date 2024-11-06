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

  Future<String> nextPlayerId ()async{
    return _players.length.toString();
  }

 // Add a player
  Future<void> addPlayer(String name,int attackRate,int midRate,int defRate) async {
    name = name == ''? 'player ${await nextPlayerId()}' : name;
    attackRate = attackRate == 0? 75:attackRate;
    midRate = midRate == 0? 75:midRate;
    defRate = defRate == 0? 75:defRate;
    Player newPlayer = Player(name, attackRate, midRate, defRate, await nextPlayerId());
    _players.add(newPlayer);
    await _savePlayers();
  }

  // Get all players
  List<Player> getAllPlayers() {
    return _players;
  }

  // Edit a player
  Future<void> editPlayer(int index, String name,int attackRate,int midRate,int defRate,String id) async {
    Player updatedPlayer = Player(name, attackRate, midRate, defRate,id);
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
