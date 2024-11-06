import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:team_maker/domain/entities/game.dart';

class Gamecontroller{
  static const String _gamessKey = 'games';
  List<Game> _games = [];

  // Load games from local storage
  Future<void> loadGames() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? gamesJson = prefs.getString(_gamessKey);
    if (gamesJson != null) {
      List<dynamic> gamesList = json.decode(gamesJson);
      _games = gamesList.map((json) => Game.fromJson(json)).toList();
    }
  }

  Future<void> _savegames() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String gamesJson = json.encode(_games.map((p) => p.toJson()).toList());
    await prefs.setString(_gamessKey, gamesJson);
  }

  Future<void> addGame(Game game) async {
    _games.add(game);
    await _savegames();
  }

  List<Game> getAllGames() {
    return _games;
  }

   // Delete a game by index
  Future<void> deleteGame(int index) async {
    if (index >= 0 && index < _games.length) {
      _games.removeAt(index);
      await _savegames();
    }
  }

  // Update an existing game by index
  Future<void> updateGame(int index, Game updatedGame) async {
    if (index >= 0 && index < _games.length) {
      _games[index] = updatedGame;
      await _savegames();
    }
  }
  
}