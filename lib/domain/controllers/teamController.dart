// team_controller.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../entities/player.dart';
import '../entities/team.dart';

class TeamController {
  static const String _teamsKey = 'teams';
  List<Team> _teams = [];

  // Load teams from local storage
  Future<void> loadTeams() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? teamsJson = prefs.getString(_teamsKey);
    if (teamsJson != null) {
      List<dynamic> teamList = json.decode(teamsJson);
      _teams = teamList.map((json) => Team.fromJson(json)).toList();
    }
  }

  // Save teams to local storage
  Future<void> _saveTeams() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String teamsJson = json.encode(_teams.map((team) => team.toJson()).toList());
    await prefs.setString(_teamsKey, teamsJson);
  }

  // Get all teams
  List<Team> getAllTeams() {
    return _teams;
  }

  // Add a team with a unique default name and save it locally
  Future<void> addTeam(List<Player> players) async {
    String teamName = 'Team ${_teams.length + 1}';
    Team newTeam = Team(players, defaultName: teamName);
    _teams.add(newTeam);
    await _saveTeams();
  }

  // Edit a team's players and recalculate team rating
  Future<void> editTeam(int index, {List<Player>? playersToAdd, List<Player>? playersToRemove}) async {
    if (index >= 0 && index < _teams.length) {
      if (playersToAdd != null) {
        for (Player player in playersToAdd) {
          _teams[index].addPlayer(player);
        }
      }
      if (playersToRemove != null) {
        for (Player player in playersToRemove) {
          _teams[index].removePlayer(player);
        }
      }
      await _saveTeams();
    }
  }

  // Add a player to a specific team
  Future<void> addPlayerToTeam(int teamIndex, Player player) async {
    if (teamIndex >= 0 && teamIndex < _teams.length) {
      _teams[teamIndex].addPlayer(player);
      await _saveTeams();
    }
  }

  // Remove a player from a specific team
  Future<void> removePlayerFromTeam(int teamIndex, Player player) async {
    if (teamIndex >= 0 && teamIndex < _teams.length) {
      _teams[teamIndex].removePlayer(player);
      await _saveTeams();
    }
  }

  // Select a player from a specific team (optional method to return a player)
  Player? selectPlayerInTeam(int teamIndex, int playerIndex) {
    if (teamIndex >= 0 && teamIndex < _teams.length) {
      if (playerIndex >= 0 && playerIndex < _teams[teamIndex].players.length) {
        return _teams[teamIndex].players[playerIndex];
      }
    }
    return null;
  }

  Future<void> editTeamName(int teamIndex, String name)async {
    if (teamIndex >= 0 && teamIndex < _teams.length) {
      _teams[teamIndex].editTeamName(name);
      await _saveTeams();
    }
  }
}
